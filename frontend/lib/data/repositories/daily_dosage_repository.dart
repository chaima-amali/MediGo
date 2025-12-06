import 'package:sqflite/sqflite.dart';
import 'package:frontend/data/databases/db_helper.dart';
import 'package:frontend/data/models/daily_dosage_checking.dart';

class DailyDosageRepository {
  Future<Database> _db() => DBHelper.getDatabase();

  /// Insert a new daily check row or update an existing one matching
  /// plan + date + time. `planId` may be null in some schemas, so callers
  /// should be cautious; this method will still try to persist what it can.
  Future<void> insertOrUpdateCheck({
    required int? planId,
    required DateTime doseDate,
    required String doseTime,
    required String status,
    DateTime? takenAt,
  }) async {
    try {
      final db = await _db();
      final dateStr = doseDate.toIso8601String().split('T').first;

      // Defensive: ensure we have a time string
      final safeTime = doseTime.trim();

      final existing = await db.query(
        'daily_dosage_checking',
        where: 'plan_id = ? AND dose_date = ? AND dose_time = ?',
        whereArgs: [planId, dateStr, safeTime],
        limit: 1,
      );

      final map = <String, Object?>{
        'plan_id': planId,
        'dose_date': dateStr,
        'dose_time': safeTime,
        'status': status,
        'taken_at': takenAt?.toIso8601String(),
      };

      if (existing.isNotEmpty) {
        final id = existing.first['dc_id'];
        await db.update(
          'daily_dosage_checking',
          map,
          where: 'dc_id = ?',
          whereArgs: [id],
        );
      } else {
        await db.insert('daily_dosage_checking', map);
      }
    } catch (e) {
      // ignore: avoid_print
      print('DailyDosageRepository.insertOrUpdateCheck error: $e');
      rethrow;
    }
  }

  /// Delete daily check rows that correspond to an occurrence. Returns
  /// true if any rows were removed.
  Future<bool> deleteByOccurrence({
    required int? planId,
    required DateTime doseDate,
    required String doseTime,
  }) async {
    try {
      final db = await _db();
      final dateStr = doseDate.toIso8601String().split('T').first;
      final rows = await db.delete(
        'daily_dosage_checking',
        where: 'plan_id = ? AND dose_date = ? AND dose_time = ?',
        whereArgs: [planId, dateStr, doseTime],
      );
      return rows > 0;
    } catch (e) {
      // ignore: avoid_print
      print('DailyDosageRepository.deleteByOccurrence error: $e');
      return false;
    }
  }

  /// Return all daily checks for a given date.
  Future<List<DailyDosageChecking>> getChecksByDate(DateTime date) async {
    try {
      final db = await _db();
      final dateStr = date.toIso8601String().split('T').first;
      final rows = await db.query(
        'daily_dosage_checking',
        where: 'dose_date = ?',
        whereArgs: [dateStr],
      );
      return rows.map((r) => DailyDosageChecking.fromMap(r)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('DailyDosageRepository.getChecksByDate error: $e');
      return [];
    }
  }

  /// Count how many checks for the given date are marked 'taken'.
  Future<int> countTakenForDate(DateTime date) async {
    try {
      final db = await _db();
      final dateStr = date.toIso8601String().split('T').first;
      final rows = await db.rawQuery(
        'SELECT COUNT(1) as c FROM daily_dosage_checking WHERE dose_date = ? AND status = ?',
        [dateStr, 'taken'],
      );
      if (rows.isNotEmpty) return (rows.first['c'] as int?) ?? 0;
      return 0;
    } catch (e) {
      // ignore: avoid_print
      print('DailyDosageRepository.countTakenForDate error: $e');
      return 0;
    }
  }

  /// Count total checks recorded for the date.
  Future<int> countTotalForDate(DateTime date) async {
    try {
      final db = await _db();
      final dateStr = date.toIso8601String().split('T').first;
      final rows = await db.rawQuery(
        'SELECT COUNT(1) as c FROM daily_dosage_checking WHERE dose_date = ?',
        [dateStr],
      );
      if (rows.isNotEmpty) return (rows.first['c'] as int?) ?? 0;
      return 0;
    } catch (e) {
      // ignore: avoid_print
      print('DailyDosageRepository.countTotalForDate error: $e');
      return 0;
    }
  }
}
