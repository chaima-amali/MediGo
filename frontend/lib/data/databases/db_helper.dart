import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Import all table schema files:
import 'db_user.dart';
import 'db_medicine_tracking.dart';
import 'db_medicine_plan.dart';
import 'db_occurrence_plan.dart';
import 'db_daily_dosage_checking.dart';
import 'db_notification.dart';
import 'db_medicine.dart';
import 'db_medicine_find.dart';
import 'db_pharmacy.dart';
import 'db_pharmacy_medicine.dart';
import 'db_reservation.dart';

class DBHelper {
  static const _databaseName = "medic_app.db";
  static const _databaseVersion = 2; // Incremented for schema change
  static Database? _database;

  // List all table create statements in order
  static final List<String> _tableSQL = [
    DBUserTable.sql_code,
    DBMedicineTrackingTable.sql_code,
    DBMedicinePlanTable.sql_code,
    DBOccurrencePlanTable.sql_code,
    DBDailyDosageCheckingTable.sql_code,
    DBNotificationTable.sql_code,
    DBMedicineTable.sql_code, // Medicine catalog first
    DBMedicineFindTable.sql_code, // Search history references medicine
    DBPharmacyTable.sql_code,
    DBPharmacyMedicineTable.sql_code, // Inventory references both
    DBReservationTable.sql_code,
  ];

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    // Desktop support: enable sqflite ffi
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = join(await getDatabasesPath(), _databaseName);
    _database = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        for (final sql in _tableSQL) {
          await db.execute(sql);
        }
        // Insert initial mock data
        await _insertMockData(db);
      },
      onOpen: (db) async {
        // Ensure any missing columns from older schemas are added so
        // the app can run without requiring a reinstall. Safe to run
        // on every open because ALTER TABLE ADD COLUMN is idempotent
        // when guarded by an existence check below.
        await _ensureSchema(db);
        // Ensure mock data exists
        await _ensureMockData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle schema migrations here if needed in future
      },
    );
    return _database!;
  }

  static Future<void> _ensureSchema(Database db) async {
    Future<List<Map<String, Object?>>> columns(String table) async {
      return await db.rawQuery('PRAGMA table_info($table)');
    }

    // occurrence_plan: ensure 'date' and 'is_taken' exist
    try {
      final occCols = await columns('occurrence_plan');
      final occNames = occCols.map((r) => r['name'] as String).toSet();
      if (!occNames.contains('date')) {
        await db.execute('ALTER TABLE occurrence_plan ADD COLUMN date TEXT');
      }
      if (!occNames.contains('is_taken')) {
        await db.execute(
          'ALTER TABLE occurrence_plan ADD COLUMN is_taken INTEGER DEFAULT 0',
        );
      }
    } catch (_) {}

    // medicine_plan: ensure 'medicine_track_id' exists
    try {
      final planCols = await columns('medicine_plan');
      final planNames = planCols.map((r) => r['name'] as String).toSet();
      if (!planNames.contains('medicine_track_id')) {
        await db.execute(
          'ALTER TABLE medicine_plan ADD COLUMN medicine_track_id INTEGER',
        );
      }
      // add other optional columns if missing
      if (!planNames.contains('interval_days')) {
        await db.execute(
          'ALTER TABLE medicine_plan ADD COLUMN interval_days INTEGER',
        );
      }
      if (!planNames.contains('weekdays')) {
        await db.execute('ALTER TABLE medicine_plan ADD COLUMN weekdays TEXT');
      }
      if (!planNames.contains('month_days')) {
        await db.execute(
          'ALTER TABLE medicine_plan ADD COLUMN month_days TEXT',
        );
      }
      if (!planNames.contains('custom_dates')) {
        await db.execute(
          'ALTER TABLE medicine_plan ADD COLUMN custom_dates TEXT',
        );
      }
      if (!planNames.contains('importance')) {
        await db.execute(
          'ALTER TABLE medicine_plan ADD COLUMN importance TEXT',
        );
      }
    } catch (_) {}

    // medicine_tracking: ensure 'medicine_track_id' exists
    try {
      final mtCols = await columns('medicine_tracking');
      final mtNames = mtCols.map((r) => r['name'] as String).toSet();
      if (!mtNames.contains('medicine_track_id')) {
        await db.execute(
          'ALTER TABLE medicine_tracking ADD COLUMN medicine_track_id INTEGER',
        );
      }
    } catch (_) {}
  }

  // Insert mock pharmacy data near Mahelma, Algiers
  static Future<void> _insertMockData(Database db) async {
    // Mahelma coordinates: approximately 36.7538° N, 3.0588° E
    final mockPharmacies = [
      {
        'name': 'Pharmacie Mahelma Centre',
        'latitude': 36.7538,
        'longitude': 3.0588,
        'phone': '+213 23 45 67 89',
        'opening_hours': 'Mon-Sat: 8:00 AM - 9:00 PM',
        'rating': 4.5,
        'image_url':
            'https://images.unsplash.com/photo-1576602976047-174e57a47881?w=400',
      },
      {
        'name': 'Pharmacie El Harrach',
        'latitude': 36.7450,
        'longitude': 3.0620,
        'phone': '+213 23 45 67 90',
        'opening_hours': 'Mon-Sun: 8:00 AM - 10:00 PM',
        'rating': 4.7,
        'image_url':
            'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=400',
      },
      {
        'name': 'Pharmacie Sidi Moussa',
        'latitude': 36.7600,
        'longitude': 3.0500,
        'phone': '+213 23 45 67 91',
        'opening_hours': 'Mon-Sat: 9:00 AM - 8:00 PM',
        'rating': 4.3,
        'image_url':
            'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400',
      },
      {
        'name': 'Pharmacie Bab Ezzouar',
        'latitude': 36.7480,
        'longitude': 3.0700,
        'phone': '+213 23 45 67 92',
        'opening_hours': 'Mon-Fri: 8:30 AM - 7:30 PM',
        'rating': 4.6,
        'image_url':
            'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=400',
      },
      {
        'name': 'Pharmacie Oued Smar',
        'latitude': 36.7350,
        'longitude': 3.0450,
        'phone': '+213 23 45 67 93',
        'opening_hours': 'Mon-Sat: 8:00 AM - 9:00 PM',
        'rating': 4.4,
        'image_url':
            'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=400',
      },
    ];

    for (final pharmacy in mockPharmacies) {
      await db.insert(
        DBPharmacyTable.table,
        pharmacy,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Insert mock medicines into the medicine catalog
    final mockMedicines = [
      {
        'name': 'Aspirin',
        'generic_name': 'Acetylsalicylic Acid',
        'dosage': '500mg',
        'form': 'Tablet',
        'manufacturer': 'Bayer',
        'description': 'Pain reliever and fever reducer',
        'requires_prescription': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Paracetamol',
        'generic_name': 'Acetaminophen',
        'dosage': '500mg',
        'form': 'Tablet',
        'manufacturer': 'Generic',
        'description': 'Pain and fever relief',
        'requires_prescription': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Ibuprofen',
        'generic_name': 'Ibuprofen',
        'dosage': '400mg',
        'form': 'Tablet',
        'manufacturer': 'Generic',
        'description': 'Anti-inflammatory pain reliever',
        'requires_prescription': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Amoxicillin',
        'generic_name': 'Amoxicillin',
        'dosage': '500mg',
        'form': 'Capsule',
        'manufacturer': 'Generic',
        'description': 'Antibiotic',
        'requires_prescription': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Doliprane',
        'generic_name': 'Paracetamol',
        'dosage': '1000mg',
        'form': 'Tablet',
        'manufacturer': 'Sanofi',
        'description': 'Pain and fever relief',
        'requires_prescription': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Efferalgan',
        'generic_name': 'Paracetamol',
        'dosage': '500mg',
        'form': 'Effervescent Tablet',
        'manufacturer': 'UPSA',
        'description': 'Fast pain and fever relief',
        'requires_prescription': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final medicine in mockMedicines) {
      await db.insert(
        DBMedicineTable.table,
        medicine,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Insert mock pharmacy-medicine inventory
    // Pharmacy IDs: 1-5, Medicine IDs: 1-6
    // Medicine IDs: 1=Aspirin, 2=Paracetamol, 3=Ibuprofen, 4=Amoxicillin, 5=Doliprane, 6=Efferalgan
    final mockInventory = [
      // Pharmacie Mahelma Centre (pharmacy_id: 1)
      {
        'pharmacy_id': 1,
        'medicine_id': 1,
        'price': 250.0,
        'stock': 150,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 1,
        'medicine_id': 2,
        'price': 180.0,
        'stock': 200,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 1,
        'medicine_id': 5,
        'price': 220.0,
        'stock': 100,
        'last_updated': DateTime.now().toIso8601String(),
      },

      // Pharmacie El Harrach (pharmacy_id: 2)
      {
        'pharmacy_id': 2,
        'medicine_id': 1,
        'price': 240.0,
        'stock': 80,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 2,
        'medicine_id': 3,
        'price': 320.0,
        'stock': 50,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 2,
        'medicine_id': 4,
        'price': 450.0,
        'stock': 30,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 2,
        'medicine_id': 6,
        'price': 210.0,
        'stock': 120,
        'last_updated': DateTime.now().toIso8601String(),
      },

      // Pharmacie Sidi Moussa (pharmacy_id: 3)
      {
        'pharmacy_id': 3,
        'medicine_id': 2,
        'price': 190.0,
        'stock': 150,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 3,
        'medicine_id': 3,
        'price': 310.0,
        'stock': 60,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 3,
        'medicine_id': 5,
        'price': 230.0,
        'stock': 90,
        'last_updated': DateTime.now().toIso8601String(),
      },

      // Pharmacie Bab Ezzouar (pharmacy_id: 4)
      {
        'pharmacy_id': 4,
        'medicine_id': 1,
        'price': 260.0,
        'stock': 100,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 4,
        'medicine_id': 2,
        'price': 185.0,
        'stock': 180,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 4,
        'medicine_id': 4,
        'price': 460.0,
        'stock': 40,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 4,
        'medicine_id': 6,
        'price': 200.0,
        'stock': 150,
        'last_updated': DateTime.now().toIso8601String(),
      },

      // Pharmacie Oued Smar (pharmacy_id: 5)
      {
        'pharmacy_id': 5,
        'medicine_id': 3,
        'price': 330.0,
        'stock': 70,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 5,
        'medicine_id': 4,
        'price': 440.0,
        'stock': 25,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 5,
        'medicine_id': 5,
        'price': 225.0,
        'stock': 110,
        'last_updated': DateTime.now().toIso8601String(),
      },
      {
        'pharmacy_id': 5,
        'medicine_id': 6,
        'price': 215.0,
        'stock': 130,
        'last_updated': DateTime.now().toIso8601String(),
      },
    ];

    for (final inventory in mockInventory) {
      await db.insert(
        DBPharmacyMedicineTable.table,
        inventory,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Ensure mock data exists (for existing databases)
  static Future<void> _ensureMockData(Database db) async {
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${DBPharmacyTable.table}'),
      );

      if (count == null || count == 0) {
        await _insertMockData(db);
      }
    } catch (_) {}
  }

  // Force reset mock data (for testing)
  static Future<void> resetMockData() async {
    final db = await getDatabase();

    // Delete existing data (in reverse order of foreign keys)
    await db.delete(DBPharmacyMedicineTable.table);
    await db.delete(DBMedicineFindTable.table); // Search history
    await db.delete(DBMedicineTable.table); // Medicine catalog
    await db.delete(DBPharmacyTable.table);

    // Reinsert mock data
    await _insertMockData(db);

    print('✅ Mock data reset successfully');
  }
}
