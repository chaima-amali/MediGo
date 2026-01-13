import 'package:sqflite/sqflite.dart';
import '../databases/db_helper.dart';
import '../databases/db_medicine_find.dart';
import '../services/medicine_search_history_api_service.dart';

class MedicineSearchHistoryRepository {
  final MedicineSearchHistoryApiService _apiService;

  MedicineSearchHistoryRepository({MedicineSearchHistoryApiService? apiService})
    : _apiService = apiService ?? MedicineSearchHistoryApiService();

  Future<Database> get _db async => await DBHelper.getDatabase();

  // Save search with restock notification request
  Future<int> saveSearchWithNotification({
    required int userId,
    required String medicineName,
    required bool notifyRestock,
  }) async {
    // Try to save to Supabase first (for premium users)
    try {
      print('🌐 Saving search history to Supabase...');
      await _apiService.saveSearchHistory(
        userId: userId,
        medicineName: medicineName,
        notifyRestock: notifyRestock,
      );
      print('✅ Search history saved to Supabase');
    } catch (e) {
      print('⚠️ Failed to save to Supabase: $e');
    }

    // Also save locally
    final db = await _db;

    // Check if already exists
    final existing = await db.query(
      DBMedicineFindTable.table,
      where: 'user_id = ? AND medicine_name = ?',
      whereArgs: [userId, medicineName],
    );

    if (existing.isNotEmpty) {
      // Update existing record
      return await db.update(
        DBMedicineFindTable.table,
        {
          'notify_restock': notifyRestock ? 1 : 0,
          'searched_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ? AND medicine_name = ?',
        whereArgs: [userId, medicineName],
      );
    } else {
      // Insert new record
      return await db.insert(DBMedicineFindTable.table, {
        'user_id': userId,
        'medicine_name': medicineName,
        'searched_at': DateTime.now().toIso8601String(),
        'notify_restock': notifyRestock ? 1 : 0,
      });
    }
  }

  // Get all medicines user wants restock notifications for
  Future<List<Map<String, dynamic>>> getRestockNotifications(int userId) async {
    final db = await _db;

    return await db.query(
      DBMedicineFindTable.table,
      where: 'user_id = ? AND notify_restock = 1',
      whereArgs: [userId],
      orderBy: 'searched_at DESC',
    );
  }

  // Disable restock notification for a medicine
  Future<int> disableRestockNotification(
    int userId,
    String medicineName,
  ) async {
    final db = await _db;
    return await db.update(
      DBMedicineFindTable.table,
      {'notify_restock': 0},
      where: 'user_id = ? AND medicine_name = ?',
      whereArgs: [userId, medicineName],
    );
  }
}
