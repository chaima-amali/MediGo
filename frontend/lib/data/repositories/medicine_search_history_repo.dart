import 'package:sqflite/sqflite.dart';
import '../databases/db_helper.dart';
import '../databases/db_medicine_find.dart';

class MedicineSearchHistoryRepository {
  Future<Database> get _db async => await DBHelper.getDatabase();

  // Save search with restock notification request
  Future<int> saveSearchWithNotification({
    required int userId,
    required int medicineId,
    required bool notifyRestock,
  }) async {
    final db = await _db;
    
    // Check if already exists
    final existing = await db.query(
      DBMedicineFindTable.table,
      where: 'user_id = ? AND medicine_id = ?',
      whereArgs: [userId, medicineId],
    );

    if (existing.isNotEmpty) {
      // Update existing record
      return await db.update(
        DBMedicineFindTable.table,
        {
          'notify_restock': notifyRestock ? 1 : 0,
          'searched_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ? AND medicine_id = ?',
        whereArgs: [userId, medicineId],
      );
    } else {
      // Insert new record
      return await db.insert(
        DBMedicineFindTable.table,
        {
          'user_id': userId,
          'medicine_id': medicineId,
          'searched_at': DateTime.now().toIso8601String(),
          'notify_restock': notifyRestock ? 1 : 0,
        },
      );
    }
  }

  // Get all medicines user wants restock notifications for
  Future<List<Map<String, dynamic>>> getRestockNotifications(int userId) async {
    final db = await _db;
    
    final query = '''
      SELECT 
        msh.id,
        msh.user_id,
        msh.medicine_id,
        msh.searched_at,
        m.name as medicine_name,
        m.generic_name,
        m.dosage,
        m.form
      FROM ${DBMedicineFindTable.table} msh
      INNER JOIN medicine m ON msh.medicine_id = m.medicine_id
      WHERE msh.user_id = ? AND msh.notify_restock = 1
      ORDER BY msh.searched_at DESC
    ''';

    return await db.rawQuery(query, [userId]);
  }

  // Disable restock notification for a medicine
  Future<int> disableRestockNotification(int userId, int medicineId) async {
    final db = await _db;
    return await db.update(
      DBMedicineFindTable.table,
      {'notify_restock': 0},
      where: 'user_id = ? AND medicine_id = ?',
      whereArgs: [userId, medicineId],
    );
  }
}