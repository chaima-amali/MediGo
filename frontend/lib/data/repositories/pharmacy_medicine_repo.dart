import 'package:sqflite/sqflite.dart';
import '../databases/db_helper.dart';
import '../databases/db_pharmacy_medicine.dart';
import '../models/pharmacy_medicine.dart';

class PharmacyMedicineRepository {
  // Get database instance
  Future<Database> get _db async => await DBHelper.getDatabase();

  // CREATE - Insert pharmacy medicine inventory
  Future<int> insertPharmacyMedicine(PharmacyMedicine pharmacyMedicine) async {
    final db = await _db;
    return await db.insert(
      DBPharmacyMedicineTable.table,
      pharmacyMedicine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ - Get pharmacy medicine by ID
  Future<PharmacyMedicine?> getPharmacyMedicineById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyMedicineTable.table,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return PharmacyMedicine.fromMap(maps.first);
  }

  // READ - Get all pharmacy medicines
  Future<List<PharmacyMedicine>> getAllPharmacyMedicines() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyMedicineTable.table,
    );

    return List.generate(maps.length, (i) {
      return PharmacyMedicine.fromMap(maps[i]);
    });
  }

  // READ - Get medicines by pharmacy ID
  Future<List<PharmacyMedicine>> getMedicinesByPharmacyId(
    int pharmacyId,
  ) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyMedicineTable.table,
      where: 'pharmacy_id = ?',
      whereArgs: [pharmacyId],
    );

    return List.generate(maps.length, (i) {
      return PharmacyMedicine.fromMap(maps[i]);
    });
  }

  // READ - Get pharmacies that have a specific medicine (with stock > 0)
  Future<List<PharmacyMedicine>> getPharmaciesWithMedicine(
    int medicineFindId,
  ) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyMedicineTable.table,
      where: 'medicine_find_id = ? AND stock > 0',
      whereArgs: [medicineFindId],
    );

    return List.generate(maps.length, (i) {
      return PharmacyMedicine.fromMap(maps[i]);
    });
  }

  // READ - Search pharmacies by medicine name (joined query)
  Future<List<Map<String, dynamic>>> searchPharmaciesByMedicineName(
    String medicineName,
  ) async {
    final db = await _db;

    // Debug: Check if medicines exist in catalog
    final medicineCheck = await db.rawQuery('SELECT * FROM medicine');
    print('🔍 DEBUG: Total medicines in catalog: ${medicineCheck.length}');
    if (medicineCheck.isNotEmpty) {
      print(
        '   All medicine names: ${medicineCheck.map((m) => m['name']).join(', ')}',
      );
    }

    // Debug: Check pharmacy_medicine inventory
    final inventoryCheck = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DBPharmacyMedicineTable.table}',
    );
    print(
      '🔍 DEBUG: Total inventory records: ${inventoryCheck.first['count']}',
    );

    // Debug: Check pharmacies
    final pharmacyCheck = await db.rawQuery(
      'SELECT COUNT(*) as count FROM pharmacy',
    );
    print('🔍 DEBUG: Total pharmacies: ${pharmacyCheck.first['count']}');

    // Join pharmacy_medicine, medicine (catalog), and pharmacy tables
    final query =
        '''
      SELECT 
        pm.id,
        pm.pharmacy_id,
        pm.medicine_id,
        pm.price,
        pm.stock,
        m.name as medicine_name,
        m.generic_name,
        m.dosage,
        m.form,
        p.name as pharmacy_name,
        p.latitude,
        p.longitude,
        p.phone,
        p.opening_hours,
        p.rating
      FROM ${DBPharmacyMedicineTable.table} pm
      INNER JOIN medicine m ON pm.medicine_id = m.medicine_id
      INNER JOIN pharmacy p ON pm.pharmacy_id = p.pharmacy_id
      WHERE LOWER(m.name) LIKE LOWER(?) AND pm.stock > 0
      ORDER BY p.rating DESC
    ''';

    final results = await db.rawQuery(query, ['%$medicineName%']);
    print(
      '🔍 DEBUG: Query returned ${results.length} results for "$medicineName"',
    );
    return results;
  }

  // UPDATE - Update pharmacy medicine
  Future<int> updatePharmacyMedicine(PharmacyMedicine pharmacyMedicine) async {
    final db = await _db;
    return await db.update(
      DBPharmacyMedicineTable.table,
      pharmacyMedicine.toMap(),
      where: 'id = ?',
      whereArgs: [pharmacyMedicine.id],
    );
  }

  // UPDATE - Update stock
  Future<int> updateStock(int id, int newStock) async {
    final db = await _db;
    return await db.update(
      DBPharmacyMedicineTable.table,
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Delete pharmacy medicine
  Future<int> deletePharmacyMedicine(int id) async {
    final db = await _db;
    return await db.delete(
      DBPharmacyMedicineTable.table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
