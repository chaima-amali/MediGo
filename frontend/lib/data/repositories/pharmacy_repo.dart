import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';
import '../databases/db_helper.dart';
import '../databases/db_pharmacy.dart';
import '../models/pharmacy.dart';

class PharmacyRepository {
  // Get database instance
  Future<Database> get _db async => await DBHelper.getDatabase();

  // CREATE - Insert a new pharmacy
  Future<int> insertPharmacy(Pharmacy pharmacy) async {
    final db = await _db;
    final pharmacyData = pharmacy.toMap();
    print('💾 Inserting pharmacy data: $pharmacyData');

    final pharmacyId = await db.insert(
      DBPharmacyTable.table,
      pharmacyData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Pharmacy inserted with ID: $pharmacyId');
    return pharmacyId;
  }

  // READ - Get pharmacy by ID
  Future<Pharmacy?> getPharmacyById(int pharmacyId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyTable.table,
      where: 'pharmacy_id = ?',
      whereArgs: [pharmacyId],
    );

    if (maps.isEmpty) return null;
    return Pharmacy.fromMap(maps.first);
  }

  // READ - Get all pharmacies
  Future<List<Pharmacy>> getAllPharmacies() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyTable.table,
    );

    return List.generate(maps.length, (i) {
      return Pharmacy.fromMap(maps[i]);
    });
  }

  // READ - Search pharmacies by name
  Future<List<Pharmacy>> searchPharmaciesByName(String query) async {
    if (query.trim().isEmpty) return [];

    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyTable.table,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Pharmacy.fromMap(maps[i]);
    });
  }

  // READ - Get pharmacies by location (within radius)
  Future<List<Pharmacy>> getPharmaciesNearLocation(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyTable.table,
      where: 'latitude IS NOT NULL AND longitude IS NOT NULL',
    );

    // Filter by distance (simple calculation)
    final pharmacies = List.generate(maps.length, (i) {
      return Pharmacy.fromMap(maps[i]);
    });

    return pharmacies.where((pharmacy) {
      if (pharmacy.latitude == null || pharmacy.longitude == null) return false;

      final distance = _calculateDistance(
        latitude,
        longitude,
        pharmacy.latitude!,
        pharmacy.longitude!,
      );

      return distance <= radiusInKm;
    }).toList();
  }

  // UPDATE - Update pharmacy information
  Future<int> updatePharmacy(Pharmacy pharmacy) async {
    final db = await _db;
    final pharmacyData = pharmacy.toMap();

    return await db.update(
      DBPharmacyTable.table,
      pharmacyData,
      where: 'pharmacy_id = ?',
      whereArgs: [pharmacy.pharmacyId],
    );
  }

  // UPDATE - Update pharmacy rating
  Future<int> updatePharmacyRating(int pharmacyId, double rating) async {
    final db = await _db;
    return await db.update(
      DBPharmacyTable.table,
      {'rating': rating},
      where: 'pharmacy_id = ?',
      whereArgs: [pharmacyId],
    );
  }

  // DELETE - Delete pharmacy by ID
  Future<int> deletePharmacy(int pharmacyId) async {
    final db = await _db;
    return await db.delete(
      DBPharmacyTable.table,
      where: 'pharmacy_id = ?',
      whereArgs: [pharmacyId],
    );
  }

  // CHECK - Check if pharmacy exists
  Future<bool> pharmacyExists(int pharmacyId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyTable.table,
      where: 'pharmacy_id = ?',
      whereArgs: [pharmacyId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  // UTILITY - Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }
}
