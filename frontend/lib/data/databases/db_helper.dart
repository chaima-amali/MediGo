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
  static const _databaseVersion = 1;
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
      onOpen: (db) async {
        // Ensure any missing columns from older schemas are added so
        // the app can run without requiring a reinstall. Safe to run
        // on every open because ALTER TABLE ADD COLUMN is idempotent
        // when guarded by an existence check below.
        await _ensureSchema(db);
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
}
