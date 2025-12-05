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
import 'db_medicine_find.dart';
import 'db_pharmacy.dart';
import 'db_pharmacy_medicine.dart';
import 'db_reservation.dart';

class DBHelper {
  static const _databaseName = "medic_app.db";
  static const _databaseVersion = 3;
  static Database? _database;

  // List all table create statements in order
  static final List<String> _tableSQL = [
    DBUserTable.sql_code,
    DBMedicineTrackingTable.sql_code,
    DBMedicinePlanTable.sql_code,
    DBOccurrencePlanTable.sql_code,
    DBDailyDosageCheckingTable.sql_code,
    DBNotificationTable.sql_code,
    DBMedicineFindTable.sql_code,
    DBPharmacyTable.sql_code,
    DBPharmacyMedicineTable.sql_code,
    DBReservationTable.sql_code,
  ];

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    // Desktop support: enable sqflite ffi
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      version: _databaseVersion,
      onCreate: (db, version) async {
        for (final sql in _tableSQL) {
          await db.execute(sql);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('🔄 Migrating database from version $oldVersion to $newVersion');
        
        // Upgrade from version 1 to 2 or higher
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE user ADD COLUMN latitude REAL');
            print('✅ Added latitude to user table');
          } catch (e) {
            print('⚠️ Column latitude may already exist: $e');
          }
          try {
            await db.execute('ALTER TABLE user ADD COLUMN longitude REAL');
            print('✅ Added longitude to user table');
          } catch (e) {
            print('⚠️ Column longitude may already exist: $e');
          }
          try {
            await db.execute('ALTER TABLE user ADD COLUMN location_name TEXT');
            print('✅ Added location_name to user table');
          } catch (e) {
            print('⚠️ Column location_name may already exist: $e');
          }
          try {
            await db.execute('ALTER TABLE pharmacy ADD COLUMN latitude REAL');
            await db.execute('ALTER TABLE pharmacy ADD COLUMN longitude REAL');
            print('✅ Added latitude and longitude to pharmacy table');
          } catch (e) {
            print('⚠️ Pharmacy table migration: $e');
          }
        }
        
        // Future upgrades can be added here
        if (oldVersion < 3) {
          print('✅ Database upgraded to version 3');
        }
      },
    );
    return _database!;
  }
}