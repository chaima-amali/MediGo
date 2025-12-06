import 'package:sqflite/sqflite.dart';

import '../models/medicine_tracking.dart';
import '../models/medicine_plan.dart';
import '../models/occurrence_plan.dart';
import '../databases/db_helper.dart';
import 'database_change_notifier.dart';

class MedicineRepository {
  final Future<Database> dbFuture = DBHelper.getDatabase();

  // ------------------------------------------------------
  // SAVE NEW MEDICINE + PLAN + OCCURRENCES
  // ------------------------------------------------------
  Future<void> saveMedicine({
    required MedicineTracking tracking,
    required MedicinePlan plan,
    required List<String> times, // ["09:00", "18:00"]
  }) async {
    final db = await dbFuture;

    // Ensure medicine_plan has expected columns (helps after hot-reload
    // when DB was already opened without the new schema). This is a
    // defensive runtime guard so INSERT won't fail with 'no column named ...'.
    try {
      final planCols = await db.rawQuery('PRAGMA table_info(medicine_plan)');
      final planNames = planCols.map((r) => r['name'] as String).toSet();

      Future<void> addIfMissing(String name, String sql) async {
        if (!planNames.contains(name)) {
          try {
            await db.execute(sql);
          } catch (_) {}
        }
      }

      await addIfMissing(
        'interval_days',
        'ALTER TABLE medicine_plan ADD COLUMN interval_days INTEGER',
      );
      await addIfMissing(
        'weekdays',
        'ALTER TABLE medicine_plan ADD COLUMN weekdays TEXT',
      );
      await addIfMissing(
        'month_days',
        'ALTER TABLE medicine_plan ADD COLUMN month_days TEXT',
      );
      await addIfMissing(
        'custom_dates',
        'ALTER TABLE medicine_plan ADD COLUMN custom_dates TEXT',
      );
      await addIfMissing(
        'importance',
        'ALTER TABLE medicine_plan ADD COLUMN importance TEXT',
      );
    } catch (_) {}

    // 1️⃣ insert medicine_tracking
    // Ensure medicine_tracking has expected columns (defensive migration)
    try {
      final trackCols = await db.rawQuery(
        'PRAGMA table_info(medicine_tracking)',
      );
      final trackNames = trackCols.map((r) => r['name'] as String).toSet();

      Future<void> addIfMissing(String name, String sql) async {
        if (!trackNames.contains(name)) {
          try {
            await db.execute(sql);
          } catch (_) {}
        }
      }

      await addIfMissing(
        'unit',
        "ALTER TABLE medicine_tracking ADD COLUMN unit TEXT",
      );
      await addIfMissing(
        'dosage',
        "ALTER TABLE medicine_tracking ADD COLUMN dosage REAL",
      );
      await addIfMissing(
        'type',
        "ALTER TABLE medicine_tracking ADD COLUMN type TEXT",
      );
    } catch (_) {}

    final trackingId = await db.insert('medicine_tracking', tracking.toMap());

    // update plan with tracking id
    final updatedPlan = MedicinePlan(
      trackingId: trackingId,
      frequencyType: plan.frequencyType,
      startDate: plan.startDate,
      endDate: plan.endDate,
      importance: plan.importance,
      intervalDays: plan.intervalDays,
      weekdays: plan.weekdays,
      monthDays: plan.monthDays,
      customDates: plan.customDates,
    );

    // 2️⃣ insert medicine_plan
    final planId = await db.insert('medicine_plan', updatedPlan.toMap());

    // 3️⃣ generate all occurrences
    final occurrences = _generateOccurrences(
      planId: planId,
      start: plan.startDate,
      end: plan.endDate,
      frequencyType: plan.frequencyType,
      times: times,
      intervalDays: plan.intervalDays,
      weekdays: plan.weekdays,
      monthDays: plan.monthDays,
      customDates: plan.customDates,
    );

    // Ensure occurrence_plan has expected columns (defensive for hot-reload)
    try {
      final occCols = await db.rawQuery('PRAGMA table_info(occurrence_plan)');
      final occNames = occCols.map((r) => r['name'] as String).toSet();

      Future<void> addIfMissing(String name, String sql) async {
        if (!occNames.contains(name)) {
          try {
            await db.execute(sql);
          } catch (_) {}
        }
      }

      await addIfMissing(
        'date',
        'ALTER TABLE occurrence_plan ADD COLUMN date TEXT',
      );
      await addIfMissing(
        'is_taken',
        'ALTER TABLE occurrence_plan ADD COLUMN is_taken INTEGER DEFAULT 0',
      );
      await addIfMissing(
        'time',
        'ALTER TABLE occurrence_plan ADD COLUMN time TEXT',
      );
      await addIfMissing(
        'plan_id',
        'ALTER TABLE occurrence_plan ADD COLUMN plan_id INTEGER',
      );
    } catch (_) {}

    // 4️⃣ insert occurrences
    for (var occ in occurrences) {
      await db.insert("occurrence_plan", occ.toMap());
    }

    // notify listeners that DB changed (new medicine + occurrences)
    try {
      DatabaseChangeNotifier.instance.notify();
    } catch (_) {}
  }

  // ------------------------------------------------------
  // GENERATE ALL OCCURRENCES (Full logic)
  // ------------------------------------------------------
  List<Occurrence> _generateOccurrences({
    required int planId,
    required DateTime start,
    required DateTime end,
    required String frequencyType,
    required List<String> times,
    int? intervalDays,
    List<String>? weekdays,
    List<int>? monthDays,
    List<String>? customDates,
  }) {
    final List<Occurrence> result = [];
    DateTime current = start;

    // map weekdays
    const daysMap = {
      "Mon": 1,
      "Tue": 2,
      "Wed": 3,
      "Thu": 4,
      "Fri": 5,
      "Sat": 6,
      "Sun": 7,
    };

    // DAILY
    if (frequencyType == "daily") {
      while (current.isBefore(end.add(const Duration(days: 1)))) {
        for (var t in times) {
          result.add(Occurrence(planId: planId, date: current, time: t));
        }
        current = current.add(const Duration(days: 1));
      }
    }
    // EVERY X DAYS
    else if (frequencyType == "interval") {
      while (current.isBefore(end.add(const Duration(days: 1)))) {
        for (var t in times) {
          result.add(Occurrence(planId: planId, date: current, time: t));
        }
        current = current.add(Duration(days: intervalDays!));
      }
    }
    // WEEKLY
    else if (frequencyType == "weekly") {
      final wantedDays = weekdays!.map((d) => daysMap[d]!).toList();

      while (current.isBefore(end.add(const Duration(days: 1)))) {
        if (wantedDays.contains(current.weekday)) {
          for (var t in times) {
            result.add(Occurrence(planId: planId, date: current, time: t));
          }
        }
        current = current.add(const Duration(days: 1));
      }
    }
    // MONTHLY
    else if (frequencyType == "monthly") {
      while (current.isBefore(end.add(const Duration(days: 1)))) {
        if (monthDays!.contains(current.day)) {
          for (var t in times) {
            result.add(Occurrence(planId: planId, date: current, time: t));
          }
        }
        current = current.add(const Duration(days: 1));
      }
    }
    // CUSTOM DATES
    else if (frequencyType == "custom") {
      for (var dateStr in customDates!) {
        final d = DateTime.parse(dateStr);
        if (d.isAfter(start.subtract(const Duration(days: 1))) &&
            d.isBefore(end.add(const Duration(days: 1)))) {
          for (var t in times) {
            result.add(Occurrence(planId: planId, date: d, time: t));
          }
        }
      }
    }

    return result;
  }

  // ------------------------------------------------------
  // READ / UPDATE helpers for Edit flow
  // ------------------------------------------------------
  Future<MedicinePlan?> getPlanById(int planId) async {
    final db = await dbFuture;
    try {
      final rows = await db.query(
        'medicine_plan',
        where: 'plan_id = ?',
        whereArgs: [planId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      // ignore: avoid_print
      print('getPlanById: plan row => ${rows.first}');
      return MedicinePlan.fromMap(rows.first);
    } catch (_) {
      return null;
    }
  }

  Future<MedicineTracking?> getTrackingById(int trackingId) async {
    final db = await dbFuture;
    try {
      final rows = await db.query(
        'medicine_tracking',
        where: 'medicine_track_id = ?',
        whereArgs: [trackingId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      // ignore: avoid_print
      print('getTrackingById: tracking row => ${rows.first}');
      return MedicineTracking.fromMap(rows.first);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateMedicineTracking(MedicineTracking tracking) async {
    final db = await dbFuture;
    try {
      final id = tracking.id;
      if (id == null) return false;
      final rows = await db.update(
        'medicine_tracking',
        tracking.toMap(),
        where: 'medicine_track_id = ?',
        whereArgs: [id],
      );
      if (rows > 0) {
        try {
          DatabaseChangeNotifier.instance.notify();
        } catch (_) {}
      }
      return rows > 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateMedicinePlan(MedicinePlan plan) async {
    final db = await dbFuture;
    try {
      final id = plan.id;
      if (id == null) return false;
      final rows = await db.update(
        'medicine_plan',
        plan.toMap(),
        where: 'plan_id = ?',
        whereArgs: [id],
      );
      if (rows > 0) {
        try {
          DatabaseChangeNotifier.instance.notify();
        } catch (_) {}
      }
      return rows > 0;
    } catch (_) {
      return false;
    }
  }
}
