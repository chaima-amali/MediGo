import 'package:sqflite/sqflite.dart';
import 'package:frontend/data/models/occurrence_plan.dart';
import 'package:frontend/data/repositories/database_change_notifier.dart';
import 'package:frontend/data/repositories/daily_dosage_repository.dart';
import 'package:frontend/data/databases/db_helper.dart';
import 'package:frontend/data/services/api/tracking_api_service.dart';

class OccurrenceRepository {
  final TrackingApiService _apiService = TrackingApiService();

  Future<List<Occurrence>> getOccurrencesByDate(
    DateTime date, {
    int? userId,
  }) async {
    // Try remote API first
    if (userId != null) {
      try {
        final formatted = date.toIso8601String().split('T').first;
        print(
          '🌐 Fetching occurrences from remote: date=$formatted, userId=$userId',
        );

        final remoteData = await _apiService.getOccurrencesByDate(
          formatted,
          userId,
        );

        if (remoteData.isNotEmpty) {
          print('✅ Remote: Found ${remoteData.length} occurrences');

          final List<Occurrence> occurrences = [];
          final Database db = await DBHelper.getDatabase();

          for (final raw in remoteData) {
            final occMap = raw as Map<String, dynamic>;

            // Try multiple nested locations for medicine name
            String? medicineName;
            try {
              medicineName =
                  occMap['medicine_plan']?['medicine_tracking']?['name']
                      as String?;
            } catch (_) {}
            medicineName ??= occMap['medicine_tracking']?['name'] as String?;
            medicineName ??= occMap['name'] as String?;
            medicineName ??= occMap['medicine_name'] as String?;
            medicineName ??= occMap['medicine_plan']?['name'] as String?;

            String? importance;
            try {
              importance = occMap['medicine_plan']?['importance'] as String?;
            } catch (_) {}
            importance ??=
                occMap['medicine_plan']?['plan_importance'] as String?;
            importance ??= occMap['importance'] as String?;

            // If backend provided nested medicine_plan and medicine_tracking, upsert them locally
            try {
              final mp = occMap['medicine_plan'] as Map<String, dynamic>?;
              if (mp != null) {
                // upsert medicine_tracking if present
                final mt = mp['medicine_tracking'] as Map<String, dynamic>?;
                if (mt != null) {
                  try {
                    await db.insert(
                      'medicine_tracking',
                      {
                        'medicine_track_id':
                            mt['medicine_track_id'] ?? mt['id'],
                        'user_id': mt['user_id'],
                        'name': mt['name'],
                        'type': mt['type'],
                        'dosage': mt['dosage'],
                        'unit': mt['unit'] ?? '',
                      },
                      conflictAlgorithm: ConflictAlgorithm.replace,
                    );
                  } catch (e) {
                    print('⚠️  Failed to upsert medicine_tracking locally: $e');
                    // fallback: filtered insert based on PRAGMA
                    try {
                      final cols = await db.rawQuery(
                        'PRAGMA table_info(medicine_tracking)',
                      );
                      final allowed = cols
                          .map((c) => (c['name'] as String))
                          .toSet();
                      final cand = {
                        'medicine_track_id':
                            mt['medicine_track_id'] ?? mt['id'],
                        'user_id': mt['user_id'],
                        'name': mt['name'],
                        'type': mt['type'],
                        'dosage': mt['dosage'],
                        'unit': mt['unit'] ?? '',
                      };
                      final filtered = <String, dynamic>{};
                      for (final ent in cand.entries) {
                        if (allowed.contains(ent.key))
                          filtered[ent.key] = ent.value;
                      }
                      if (filtered.isNotEmpty) {
                        try {
                          await db.insert(
                            'medicine_tracking',
                            filtered,
                            conflictAlgorithm: ConflictAlgorithm.replace,
                          );
                        } catch (e2) {
                          print(
                            '⚠️  Failed to insert medicine_tracking filtered row: $e2',
                          );
                        }
                      }
                    } catch (e2) {
                      print(
                        '⚠️  Failed to upsert medicine_tracking locally: $e2',
                      );
                    }
                  }
                }

                // upsert medicine_plan (filter to existing columns)
                try {
                  final cols = await db.rawQuery(
                    'PRAGMA table_info(medicine_plan)',
                  );
                  final allowed = cols
                      .map((c) => (c['name'] as String))
                      .toSet();
                  final cand = {
                    'plan_id': mp['plan_id'] ?? mp['id'],
                    'medicine_track_id': mp['medicine_track_id'],
                    'user_id': mp['user_id'],
                    'importance': mp['importance'],
                    'start_date': mp['start_date'],
                    'end_date': mp['end_date'],
                    'frequency_type': mp['frequency_type'],
                    'interval_days': mp['interval_days'],
                    'weekdays': mp['weekdays'],
                    'month_days': mp['month_days'],
                    'custom_dates': mp['custom_dates'],
                  };
                  final filtered = <String, dynamic>{};
                  for (final ent in cand.entries) {
                    if (allowed.contains(ent.key))
                      filtered[ent.key] = ent.value;
                  }
                  if (filtered.isNotEmpty) {
                    try {
                      await db.insert(
                        'medicine_plan',
                        filtered,
                        conflictAlgorithm: ConflictAlgorithm.replace,
                      );
                    } catch (e2) {
                      print(
                        '⚠️  Failed to insert medicine_plan filtered row: $e2',
                      );
                    }
                  }
                } catch (e) {
                  print('⚠️  Failed to upsert medicine_plan locally: $e');
                }
              }

              // Build occurrence object from remote map and add to list
              try {
                final occ = Occurrence.fromMap({
                  'id': occMap['id'],
                  'plan_id': occMap['plan_id'] ?? occMap['planId'],
                  'date': occMap['date'],
                  'time': occMap['time'],
                  'is_taken': occMap['is_taken'] ?? 0,
                  'medicine_name':
                      medicineName ?? occMap['medicine_name'] ?? occMap['name'],
                  'importance': importance,
                });
                occurrences.add(occ);
              } catch (e) {
                print('⚠️ Failed to parse remote occurrence: $e');
              }
            } catch (e) {
              print(
                '⚠️  Error processing nested medicine_plan/medicine_tracking: $e',
              );
            }
          }

          // After processing all remote occurrences, sync them locally and return
          try {
            await _syncOccurrencesToLocal(occurrences);
          } catch (e) {
            print('⚠️  Failed to sync occurrences to local: $e');
          }

          return occurrences;
        }
      } catch (e) {
        print('⚠️  Remote API failed: $e, falling back to local');
      }
    }

    // Fallback to local database
    try {
      final Database db = await DBHelper.getDatabase();

      // Normalize to YYYY-MM-DD to match stored ISO date strings
      final formatted = date.toIso8601String().split('T').first;

      print(
        '🔍 OccurrenceRepository.getOccurrencesByDate: date=$formatted, userId=$userId',
      );

      final sql = userId != null
          ? '''
        SELECT o.*, mt.name AS medicine_name, mp.importance AS importance
        FROM occurrence_plan o
        LEFT JOIN medicine_plan mp ON o.plan_id = mp.plan_id
        LEFT JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
        WHERE o.date = ? AND mt.user_id = ?
      '''
          : '''
        SELECT o.*, mt.name AS medicine_name, mp.importance AS importance
        FROM occurrence_plan o
        LEFT JOIN medicine_plan mp ON o.plan_id = mp.plan_id
        LEFT JOIN medicine_tracking mt ON mp.medicine_track_id = mt.medicine_track_id
        WHERE o.date = ?
      ''';

      final result = userId != null
          ? await db.rawQuery(sql, [formatted, userId])
          : await db.rawQuery(sql, [formatted]);

      print(
        '📊 OccurrenceRepository.getOccurrencesByDate: Found ${result.length} occurrences',
      );

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

  /// Sync remote occurrences to local database for offline access
  Future<void> _syncOccurrencesToLocal(List<Occurrence> occurrences) async {
    final Database db = await DBHelper.getDatabase();
    for (final occ in occurrences) {
      try {
        // Check if occurrence already exists
        final existing = await db.query(
          'occurrence_plan',
          where: 'id = ?',
          whereArgs: [occ.id],
          limit: 1,
        );

        if (existing.isEmpty) {
          // Insert new occurrence
          await db.insert('occurrence_plan', occ.toMap());
        } else {
          // Update existing
          await db.update(
            'occurrence_plan',
            occ.toMap(),
            where: 'id = ?',
            whereArgs: [occ.id],
          );
        }
      } catch (e) {
        print('⚠️  Failed to sync occurrence ${occ.id}: $e');
      }
    }
  }

  /// Mark an occurrence as taken and refresh the day.
  Future<bool> updateOccurrenceTaken(int occurrenceId, int isTaken) async {
    // Try remote API first
    try {
      print(
        '🌐 Updating occurrence remotely: ID=$occurrenceId, isTaken=$isTaken',
      );
      await _apiService.updateOccurrence(occurrenceId, {'is_taken': isTaken});
      print('✅ Remote: Occurrence updated successfully');

      // Also update local
      try {
        final Database db = await DBHelper.getDatabase();
        final cols = await db.rawQuery('PRAGMA table_info(occurrence_plan)');
        String? idCol;
        for (final c in cols) {
          final name = (c['name'] as String).toLowerCase();
          if (name == 'id' || name == 'occurrence_id') {
            idCol = name;
            break;
          }
        }
        if (idCol == null) idCol = 'id';

        await db.update(
          'occurrence_plan',
          {'is_taken': isTaken},
          where: '$idCol = ?',
          whereArgs: [occurrenceId],
        );

        try {
          DatabaseChangeNotifier.instance.notify();
        } catch (_) {}
      } catch (e) {
        print('⚠️  Failed to update local occurrence: $e');
      }

      return true;
    } catch (e) {
      print('⚠️  Remote update failed: $e, using local only');
    }

    // Fallback to local only
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

  /// Delete all occurrences of a specific medicine at a specific time.
  /// This deletes all occurrences with the same medicine and time across all dates.
  Future<bool> deleteOccurrencesByPlanTime(int planId, String time) async {
    try {
      // Try remote API first
      try {
        print(
          '🌐 Deleting occurrences by plan and time remotely: planId=$planId, time=$time',
        );
        // Get all occurrences for this plan and time to delete them from remote
        final Database db = await DBHelper.getDatabase();
        final occRows = await db.rawQuery(
          '''
          SELECT o.id FROM occurrence_plan o
          WHERE o.plan_id = ? AND o.time = ?
          ''',
          [planId, time],
        );

        // Delete each occurrence from remote
        for (final row in occRows) {
          final occId = row['id'];
          if (occId != null) {
            try {
              await _apiService.deleteOccurrence(occId as int);
            } catch (e) {
              print('⚠️  Failed to delete occurrence $occId from remote: $e');
            }
          }
        }
        print('✅ Remote: Deleted ${occRows.length} occurrences');
      } catch (e) {
        print('⚠️  Remote API delete failed: $e, continuing with local delete');
      }

      // Delete from local database
      final Database db = await DBHelper.getDatabase();

      // First, get the medicine_track_id for this plan
      final planRows = await db.query(
        'medicine_plan',
        columns: ['medicine_track_id'],
        where: 'plan_id = ?',
        whereArgs: [planId],
        limit: 1,
      );

      if (planRows.isEmpty) {
        print(
          '⚠️ deleteOccurrencesByPlanTime: No plan found with plan_id=$planId',
        );
        return false;
      }

      final medicineTrackId = planRows.first['medicine_track_id'] as int;

      // Delete all occurrences with this medicine_track_id and time
      // We need to join with medicine_plan to filter by medicine_track_id
      final rows = await db.rawDelete(
        '''
        DELETE FROM occurrence_plan 
        WHERE plan_id IN (
          SELECT plan_id FROM medicine_plan WHERE medicine_track_id = ?
        ) AND time = ?
      ''',
        [medicineTrackId, time],
      );

      print(
        '🗑️ deleteOccurrencesByPlanTime: Deleted $rows occurrences for medicineTrackId=$medicineTrackId, time=$time',
      );

      // notify listeners that DB changed
      try {
        DatabaseChangeNotifier.instance.notify();
      } catch (_) {}

      return rows > 0;
    } catch (e) {
      print('OccurrenceRepository.deleteOccurrencesByPlanTime error: $e');
      return false;
    }
  }

  /// Delete an occurrence row by id. Returns true if a row was deleted.
  Future<bool> deleteOccurrence(int occurrenceId) async {
    try {
      // Try remote API first
      try {
        print('🌐 Deleting occurrence remotely: ID=$occurrenceId');
        await _apiService.deleteOccurrence(occurrenceId);
        print('✅ Remote: Occurrence deleted successfully');
      } catch (e) {
        print('⚠️  Remote API delete failed: $e, continuing with local delete');
      }

      // Delete from local database
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
      // Try remote API first
      try {
        final remote = await _apiService.getPlanOccurrences(planId);
        if (remote.isNotEmpty) {
          final List<Occurrence> occurrences = [];
          for (final raw in remote) {
            final occMap = raw as Map<String, dynamic>;
            final occ = Occurrence.fromMap({
              'id': occMap['id'],
              'plan_id': occMap['plan_id'] ?? occMap['planId'],
              'date': occMap['date'],
              'time': occMap['time'],
              'is_taken': occMap['is_taken'] ?? 0,
              'medicine_name': occMap['medicine_name'] ?? occMap['name'],
            });
            occurrences.add(occ);
          }

          // Sync remote occurrences to local
          try {
            await _syncOccurrencesToLocal(occurrences);
          } catch (e) {
            print('⚠️  Failed to sync remote plan occurrences to local: $e');
          }

          final times =
              occurrences
                  .map((o) => o.time)
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();
          return times;
        }
      } catch (_) {}

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
