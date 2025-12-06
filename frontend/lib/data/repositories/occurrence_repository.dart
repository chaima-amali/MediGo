import 'package:sqflite/sqflite.dart';
import 'package:frontend/data/models/occurrence_plan.dart';
import 'package:frontend/data/repositories/database_change_notifier.dart';
import 'package:frontend/data/repositories/daily_dosage_repository.dart';
import 'package:frontend/data/databases/db_helper.dart';

class OccurrenceRepository {
  Future<List<Occurrence>> getOccurrencesByDate(DateTime date) async {
    try {
      final Database db = await DBHelper.getDatabase();

      // Normalize to YYYY-MM-DD to match stored ISO date strings
      final formatted = date.toIso8601String().split('T').first;

      final sql = '''
        SELECT o.*, mt.name AS medicine_name, mp.importance AS importance
        FROM occurrence_plan o
        LEFT JOIN medicine_plan mp ON o.plan_id = mp.plan_id
        LEFT JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
        WHERE o.date = ?
      ''';

      final result = await db.rawQuery(sql, [formatted]);

      // debug: print each returned row's id and plan_id to help diagnose
      try {
        for (final r in result) {
          // ignore: avoid_print
          print(
            'getOccurrencesByDate row -> id=${r['id'] ?? r['occurrence_id']}, plan_id=${r['plan_id']} medicine_name=${r['medicine_name'] ?? r['name']}',
          );
        }
      } catch (_) {}

      return result.map((e) => Occurrence.fromMap(e)).toList();
    } catch (e) {
      // If the DB schema doesn't match or another DB error occurs,
      // return an empty list to avoid leaving UI stuck in loading state.
      // The error can be investigated in logs during development.
      // ignore: avoid_print
      print('OccurrenceRepository.getOccurrencesByDate error: $e');
      return [];
    }
  }

  /// Mark an occurrence as taken (is_taken = 1) or not taken (0).
  Future<bool> updateOccurrenceTaken(int occurrenceId, int isTaken) async {
    try {
      final Database db = await DBHelper.getDatabase();

      // Inspect table schema to find an appropriate id column name.
      final cols = await db.rawQuery('PRAGMA table_info(occurrence_plan)');
      String? idCol;
      for (final c in cols) {
        final name = (c['name'] as String).toLowerCase();
        final pk = (c['pk'] as int?) ?? 0;
        if (name == 'id' || name == 'occurrence_id' || name == 'plan_id') {
          // prefer explicit id-like names (but not plan_id)
          if (name != 'plan_id') idCol = name;
        }
        if (idCol == null && pk == 1) {
          idCol = name;
        }
      }

      // If we couldn't find a clear id column, fallback to rowid
      if (idCol == null) idCol = 'rowid';

      // If the chosen column is 'rowid', use the special rowid reference.
      final whereClause = idCol == 'rowid' ? 'rowid = ?' : '$idCol = ?';

      // Before updating, fetch the occurrence row so we can enforce rules
      final occRows = await db.query(
        'occurrence_plan',
        where: whereClause,
        whereArgs: [occurrenceId],
        limit: 1,
      );
      if (occRows.isEmpty) return false;
      final occRow = occRows.first;
      DateTime occDate;
      try {
        occDate = DateTime.parse((occRow['date'] ?? '').toString());
      } catch (_) {
        occDate = DateTime.now();
      }

      // Do not allow marking future dates as taken
      final today = DateTime.now();
      final occYmd = DateTime(occDate.year, occDate.month, occDate.day);
      final todayYmd = DateTime(today.year, today.month, today.day);
      if (occYmd.isAfter(todayYmd) && isTaken == 1) {
        return false;
      }

      final rows = await db.update(
        'occurrence_plan',
        {'is_taken': isTaken},
        where: whereClause,
        whereArgs: [occurrenceId],
      );

      // notify listeners that DB changed
      if (rows > 0) {
        try {
          // Update daily_dosage_checking accordingly
          try {
            final int? planId = occRow['plan_id'] is int
                ? occRow['plan_id'] as int
                : int.tryParse('${occRow['plan_id'] ?? ''}');
            final time = (occRow['time'] ?? '').toString();
            final dateStr = (occRow['date'] ?? '').toString();
            DateTime parsedDate = DateTime.now();
            try {
              parsedDate = DateTime.parse(dateStr);
            } catch (_) {}
            final takenAt = isTaken == 1 ? DateTime.now() : null;
            // upsert via repository
            try {
              final dailyRepo = DailyDosageRepository();
              await dailyRepo.insertOrUpdateCheck(
                planId: planId,
                doseDate: parsedDate,
                doseTime: time,
                status: isTaken == 1 ? 'taken' : 'pending',
                takenAt: takenAt,
              );
            } catch (_) {}

            DatabaseChangeNotifier.instance.notify();
          } catch (_) {
            DatabaseChangeNotifier.instance.notify();
          }
        } catch (_) {}
      }

      // Debug: if no rows updated, print schema to help debugging.
      if (rows == 0) {
        // ignore: avoid_print
        print('updateOccurrenceTaken: 0 rows updated. Tried column: $idCol');
        // ignore: avoid_print
        print('PRAGMA table_info(occurrence_plan) => $cols');
      }

      return rows > 0;
    } catch (e) {
      // ignore: avoid_print
      print('OccurrenceRepository.updateOccurrenceTaken error: $e');
      return false;
    }
  }

  /// Delete an occurrence row by id. Returns true if a row was deleted.
  Future<bool> deleteOccurrence(int occurrenceId) async {
    try {
      final Database db = await DBHelper.getDatabase();

      // Determine an appropriate id column (same logic as updateOccurrenceTaken)
      final cols = await db.rawQuery('PRAGMA table_info(occurrence_plan)');
      String? idCol;
      for (final c in cols) {
        final name = (c['name'] as String).toLowerCase();
        final pk = (c['pk'] as int?) ?? 0;
        if (name == 'id' || name == 'occurrence_id' || name == 'plan_id') {
          if (name != 'plan_id') idCol = name;
        }
        if (idCol == null && pk == 1) idCol = name;
      }
      if (idCol == null) idCol = 'rowid';
      final whereClause = idCol == 'rowid' ? 'rowid = ?' : '$idCol = ?';

      // Fetch occurrence row to allow cleaning up daily checks
      final occRows = await db.query(
        'occurrence_plan',
        where: whereClause,
        whereArgs: [occurrenceId],
        limit: 1,
      );
      Map<String, Object?>? occRow;
      if (occRows.isNotEmpty) occRow = occRows.first;

      final rows = await db.delete(
        'occurrence_plan',
        where: whereClause,
        whereArgs: [occurrenceId],
      );

      if (rows == 0) {
        // ignore: avoid_print
        print('deleteOccurrence: 0 rows deleted. Tried column: $idCol');
      }

      // Also remove any daily check row corresponding to this occurrence
      try {
        if (occRow != null) {
          final int? planId = occRow['plan_id'] is int
              ? occRow['plan_id'] as int
              : int.tryParse('${occRow['plan_id'] ?? ''}');
          final dateStr = (occRow['date'] ?? '').toString();
          DateTime parsedDate = DateTime.now();
          try {
            parsedDate = DateTime.parse(dateStr);
          } catch (_) {}
          final time = (occRow['time'] ?? '').toString();
          final dailyRepo = DailyDosageRepository();
          await dailyRepo.deleteByOccurrence(
            planId: planId,
            doseDate: parsedDate,
            doseTime: time,
          );
        }
      } catch (_) {}

      // notify listeners that DB changed
      try {
        DatabaseChangeNotifier.instance.notify();
      } catch (_) {}

      return rows > 0;
    } catch (e) {
      // ignore: avoid_print
      print('OccurrenceRepository.deleteOccurrence error: $e');
      return false;
    }
  }

  /// Attempts to find the plan_id for a given occurrence id. This helps
  /// when different schemas or id column names were used (e.g. 'id',
  /// 'occurrence_id' or 'rowid'). Returns null if not found.
  Future<int?> getPlanIdForOccurrence(int occurrenceId) async {
    try {
      final Database db = await DBHelper.getDatabase();

      // try common id column names
      final candidates = ['id', 'occurrence_id', 'rowid'];
      for (final col in candidates) {
        try {
          final rows = await db.query(
            'occurrence_plan',
            columns: ['plan_id'],
            where: '$col = ?',
            whereArgs: [occurrenceId],
            limit: 1,
          );
          if (rows.isNotEmpty) {
            final val = rows.first['plan_id'];
            if (val is int) return val;
            if (val is String) return int.tryParse(val);
          }
        } catch (_) {}
      }

      // last-resort: raw query for rowid
      try {
        final rows = await db.rawQuery(
          'SELECT plan_id FROM occurrence_plan WHERE rowid = ?',
          [occurrenceId],
        );
        if (rows.isNotEmpty) {
          final v = rows.first['plan_id'];
          if (v is int) return v;
          if (v is String) return int.tryParse(v);
        }
      } catch (_) {}

      return null;
    } catch (e) {
      // ignore: avoid_print
      print('getPlanIdForOccurrence error: $e');
      return null;
    }
  }

  /// Return distinct times for a given plan. Used to infer times-per-day
  /// when editing a plan (UI doesn't persist times-per-day separately).
  Future<List<String>> getDistinctTimesForPlan(int planId) async {
    try {
      final Database db = await DBHelper.getDatabase();
      final rows = await db.rawQuery(
        'SELECT DISTINCT time FROM occurrence_plan WHERE plan_id = ? ORDER BY time',
        [planId],
      );
      return rows
          .map((r) => (r['time'] ?? '') as String)
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('getDistinctTimesForPlan error: $e');
      return [];
    }
  }
}
