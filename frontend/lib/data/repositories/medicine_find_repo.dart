import 'package:sqflite/sqflite.dart';
import '../databases/db_helper.dart';
import '../databases/db_medicine_find.dart';
import '../models/medicine_find.dart';

class MedicineFindRepository {
  // Get database instance
  Future<Database> get _db async => await DBHelper.getDatabase();

  // CREATE - Insert a new medicine
  Future<int> insertMedicine(MedicineFind medicine) async {
    final db = await _db;
    return await db.insert(
      DBMedicineFindTable.table,
      medicine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ - Get medicine by ID
  Future<MedicineFind?> getMedicineById(int medicineId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBMedicineFindTable.table,
      where: 'medicine_find_id = ?',
      whereArgs: [medicineId],
    );

    if (maps.isEmpty) return null;
    return MedicineFind.fromMap(maps.first);
  }

  // READ - Get all medicines
  Future<List<MedicineFind>> getAllMedicines() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBMedicineFindTable.table,
    );

    return List.generate(maps.length, (i) {
      return MedicineFind.fromMap(maps[i]);
    });
  }

  // READ - Search medicines by name
  Future<List<MedicineFind>> searchMedicinesByName(String query) async {
    if (query.trim().isEmpty) return [];

    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBMedicineFindTable.table,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return MedicineFind.fromMap(maps[i]);
    });
  }

  // READ - Get medicines by user ID
  Future<List<MedicineFind>> getMedicinesByUserId(int userId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBMedicineFindTable.table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return MedicineFind.fromMap(maps[i]);
    });
  }

  // UPDATE - Update medicine
  Future<int> updateMedicine(MedicineFind medicine) async {
    final db = await _db;
    return await db.update(
      DBMedicineFindTable.table,
      medicine.toMap(),
      where: 'medicine_find_id = ?',
      whereArgs: [medicine.medicineFindId],
    );
  }

  // DELETE - Delete medicine
  Future<int> deleteMedicine(int medicineId) async {
    final db = await _db;
    return await db.delete(
      DBMedicineFindTable.table,
      where: 'medicine_find_id = ?',
      whereArgs: [medicineId],
    );
  }
}