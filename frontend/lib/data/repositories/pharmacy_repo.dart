import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';
import '../databases/db_helper.dart';
import '../databases/db_pharmacy.dart';
import '../models/pharmacy.dart';
import '../services/api/pharmacy_api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PharmacyRepository {
  final PharmacyApiService _apiService = PharmacyApiService();

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

  // READ - Get pharmacy by ID (Remote-first)
  Future<Pharmacy?> getPharmacyById(int pharmacyId) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        print('☁️ Fetching pharmacy $pharmacyId from remote...');

        final response = await _apiService.getPharmacy(pharmacyId);

        if (response['success'] == true && response['pharmacy'] != null) {
          print('✅ Pharmacy fetched from remote');
          final pharmacy = Pharmacy.fromMap(response['pharmacy']);

          // Sync to local database
          await insertPharmacy(pharmacy);

          return pharmacy;
        }
      }
    } catch (e) {
      print('❌ Remote fetch failed: $e');
    }

    // Fallback to local database
    print('💾 Fetching pharmacy from local database...');
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyTable.table,
      where: 'pharmacy_id = ?',
      whereArgs: [pharmacyId],
    );

    if (maps.isEmpty) return null;
    return Pharmacy.fromMap(maps.first);
  }

  // READ - Get all pharmacies (Remote-first)
  Future<List<Pharmacy>> getAllPharmacies() async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        print('☁️ Fetching all pharmacies from remote...');

        final response = await _apiService.getAllPharmacies();

        if (response['success'] == true && response['pharmacies'] != null) {
          print('✅ Pharmacies fetched from remote');
          final pharmacies = (response['pharmacies'] as List)
              .map((p) => Pharmacy.fromMap(p))
              .toList();

          // Sync to local database
          for (var pharmacy in pharmacies) {
            await insertPharmacy(pharmacy);
          }

          return pharmacies;
        }
      }
    } catch (e) {
      print('❌ Remote fetch failed: $e');
    }

    // Fallback to local database
    print('💾 Fetching pharmacies from local database...');
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      DBPharmacyTable.table,
    );

    return List.generate(maps.length, (i) {
      return Pharmacy.fromMap(maps[i]);
    });
  }

  // READ - Search pharmacies by name (Remote-first)
  Future<List<Pharmacy>> searchPharmaciesByName(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        print('☁️ Searching pharmacies remotely for: $query');

        final response = await _apiService.searchPharmaciesByName(query);

        if (response['success'] == true && response['pharmacies'] != null) {
          print('✅ Pharmacies search results from remote');
          final pharmacies = (response['pharmacies'] as List)
              .map((p) => Pharmacy.fromMap(p))
              .toList();

          return pharmacies;
        }
      }
    } catch (e) {
      print('❌ Remote search failed: $e');
    }

    // Fallback to local search
    print('💾 Searching pharmacies locally for: $query');
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
