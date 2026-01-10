import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import '../models/medicine_tracking.dart';
import '../models/medicine_plan.dart';
import '../models/occurrence_plan.dart';
import '../databases/db_helper.dart';
import '../services/api/tracking_api_service.dart';
import '../services/local_notification_service.dart';
import 'database_change_notifier.dart';
import 'occurrence_repository.dart';

class MedicineRepository {
  final Future<Database> dbFuture = DBHelper.getDatabase();
  final TrackingApiService _apiService = TrackingApiService();

  // Safely upsert a map into a table by filtering keys to existing columns
  Future<void> _safeUpsert(
    Database db,
    String table,
    Map<String, dynamic> values,
  ) async {
    try {
      print('🔍 _safeUpsert starting for table: $table');
      print('🔍 Values to insert: $values');

      final cols = await db.rawQuery('PRAGMA table_info($table)');
      final allowed = cols.map((c) => (c['name'] as String)).toSet();
      print('🔍 Allowed columns: $allowed');

      final filtered = <String, dynamic>{};
      for (final e in values.entries) {
        if (allowed.contains(e.key)) filtered[e.key] = e.value;
      }
      print('🔍 Filtered values: $filtered');

      if (filtered.isEmpty) {
        print('⚠️  No valid columns found, skipping insert');
        return;
      }

      await db.insert(
        table,
        filtered,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ _safeUpsert successful for table: $table');
    } catch (e, stack) {
      // ignore: avoid_print
      print('❌ _safeUpsert failed for table $table: $e');
      print('❌ Stack trace: $stack');
    }
  }

  Future<void> _scheduleLocalNotifications({
    required String medicineName,
    required String dosage,
    required List<Map<String, dynamic>> occurrences,
  }) async {
    final service = LocalNotificationService();
    for (final occ in occurrences) {
      try {
        final dateStr = occ['date'] as String;
        final timeStr = occ['time'] as String; // expected 'HH:mm' or 'HH:mm:ss'
        final parts = timeStr.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
        final scheduled = DateTime.parse(
          '${dateStr}T${parts[0].padLeft(2, '0')}:${parts.length > 1 ? parts[1].padLeft(2, '0') : '00'}:00',
        );
        final id = scheduled.millisecondsSinceEpoch % 2147483647;
        final title = 'Time to take $medicineName';
        final body = dosage.isNotEmpty
            ? 'Dose: $dosage'
            : 'It\'s time to take your medicine';
        await service.scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDateTime: scheduled,
        );
      } catch (e) {
        // ignore scheduling errors per-occurrence
        print('⚠️ _scheduleLocalNotifications error for occ $occ : $e');
      }
    }
  }

  /// Save medicine (tracking + plan + occurrences). Tries remote-first,
  /// falls back to local-only on error.
  Future<void> saveMedicine({
    required MedicineTracking tracking,
    required MedicinePlan plan,
    required List<String> times,
  }) async {
    try {
      // 1. Create medicine tracking remotely
      final medicineResponse = await _apiService.addMedicine(
        userId: tracking.userId ?? 0,
        name: tracking.name ?? '',
        type: tracking.type,
        dosage: tracking.dosage?.toString(),
      );

      // remote medicine id can be under 'medicine' or directly provided
      final remoteMedicineId =
          (medicineResponse['medicine'] != null
                  ? medicineResponse['medicine']['medicine_track_id'] ??
                        medicineResponse['medicine']['id']
                  : medicineResponse['medicine_track_id'] ??
                        medicineResponse['id'])
              as int;

      // Immediately upsert remote medicine into local DB so subsequent
      // operations that rely on local rows (backend helpers) can map IDs.
      try {
        final db = await dbFuture;
        await _safeUpsert(db, 'medicine_tracking', {
          'medicine_track_id': remoteMedicineId,
          'user_id': tracking.userId,
          'name': tracking.name,
          'type': tracking.type,
          'dosage': tracking.dosage,
          'unit': tracking.unit ?? '',
        });
      } catch (e) {
        print('⚠️  Failed to upsert remote tracking early: $e');
      }

      // 2. Create medicine plan remotely
      final planResponse = await _apiService.createMedicinePlan(
        medicineTrackId: remoteMedicineId,
        userId: tracking.userId ?? 0,
        importance: plan.importance,
        startDate: plan.startDate.toIso8601String().split('T')[0],
        endDate: plan.endDate?.toIso8601String().split('T')[0],
        frequencyType: plan.frequencyType,
        intervalDays: plan.intervalDays,
        weekdays: plan.weekdays != null ? jsonEncode(plan.weekdays) : null,
        monthDays: plan.monthDays != null ? jsonEncode(plan.monthDays) : null,
        customDates: plan.customDates != null
            ? jsonEncode(plan.customDates)
            : null,
      );

      final remotePlanId = planResponse['plan_id'] ?? planResponse['id'];
      final int planIdInt = remotePlanId is int
          ? remotePlanId
          : int.parse('$remotePlanId');

      // 3. Upsert remote plan into local DB (keep local copy in sync)
      print(
        '📝 Step 3: Upserting medicine_plan locally (planIdInt=$planIdInt, remoteMedicineId=$remoteMedicineId)',
      );
      try {
        final db = await dbFuture;
        await _safeUpsert(db, 'medicine_plan', {
          'plan_id': planIdInt,
          'medicine_track_id': remoteMedicineId,
          'user_id': tracking.userId,
          'importance': plan.importance,
          'start_date': plan.startDate.toIso8601String().split('T')[0],
          'end_date': plan.endDate?.toIso8601String().split('T')[0],
          'frequency_type': plan.frequencyType,
          'interval_days': plan.intervalDays,
          'weekdays': plan.weekdays != null ? jsonEncode(plan.weekdays) : null,
          'month_days': plan.monthDays != null
              ? jsonEncode(plan.monthDays)
              : null,
          'custom_dates': plan.customDates != null
              ? jsonEncode(plan.customDates)
              : null,
        });
        print('✅ Step 3 complete: medicine_plan upserted locally');
      } catch (e, stack) {
        print('❌ Step 3 FAILED: Failed to upsert remote plan locally: $e');
        print('❌ Stack: $stack');
      }

      // 4. Generate occurrences and create batch remotely
      final occurrencesData =
          _generateOccurrences(
                planId: planIdInt,
                start: plan.startDate,
                end:
                    plan.endDate ??
                    plan.startDate.add(const Duration(days: 30)),
                frequencyType: plan.frequencyType,
                times: times,
                intervalDays: plan.intervalDays,
                weekdays: plan.weekdays,
                monthDays: plan.monthDays,
                customDates: plan.customDates,
              )
              .map(
                (occ) => {
                  'plan_id': planIdInt,
                  'date': occ.date.toIso8601String().split('T')[0],
                  'time': occ.time,
                  'day_of_week': null,
                  'is_taken': 0,
                },
              )
              .toList();

      if (occurrencesData.isNotEmpty) {
        final occResp = await _apiService.createOccurrencesBatch(
          occurrencesData,
        );
        // ignore: avoid_print
        print('✅ Remote occurrences response: $occResp');
        // Schedule local notifications for the created remote occurrences
        try {
          await _scheduleLocalNotifications(
            medicineName: tracking.name ?? 'Medicine',
            dosage: tracking.dosage?.toString() ?? '',
            occurrences: occurrencesData,
          );
        } catch (e) {
          print('⚠️ Failed to schedule local notifications: $e');
        }
        // Also persist the created occurrences locally so UI can show them.
        // If the server returned occurrence_ids, map them to local rows so
        // local `id` matches remote id.
        try {
          final db = await dbFuture;
          final List<dynamic>? returnedIds =
              (occResp['occurrence_ids'] as List<dynamic>?)?.toList();

          for (var i = 0; i < occurrencesData.length; i++) {
            final occ = occurrencesData[i] as Map<String, dynamic>;
            try {
              if (returnedIds != null &&
                  returnedIds.length == occurrencesData.length) {
                occ['id'] = returnedIds[i];
              }

              // Filter to allowed columns in occurrence_plan
              final cols = await db.rawQuery(
                'PRAGMA table_info(occurrence_plan)',
              );
              final allowed = cols.map((c) => (c['name'] as String)).toSet();
              final filtered = <String, dynamic>{};
              for (final ent in occ.entries) {
                if (allowed.contains(ent.key)) filtered[ent.key] = ent.value;
              }
              if (filtered.isNotEmpty) {
                await db.insert(
                  'occurrence_plan',
                  filtered,
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
              }
            } catch (e) {
              print('⚠️ Failed to insert remote occurrence locally: $e');
            }
          }
        } catch (e) {
          print('⚠️ Failed to persist occurrences locally: $e');
        }
      }

      // No extra local insert after successful remote sync. We already
      // upserted the remote tracking and plan to keep IDs consistent.

      // Notify listeners
      try {
        DatabaseChangeNotifier.instance.notify();
      } catch (_) {}

      // ignore: avoid_print
      print('✅ Medicine saved successfully to both remote and local!');
      return;
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('❌ Remote API failed: $e');
      // ignore: avoid_print
      print('❌ Stack trace: $stackTrace');
      // Fallback to local only
      // ignore: avoid_print
      print('📱 Falling back to local database...');
      await _saveMedicineLocal(tracking, plan, times);
      // ignore: avoid_print
      print('✅ Medicine saved locally (not synced to Supabase)');
      return;
    }
  }

  /// Save medicine to local database (used as fallback)
  Future<void> _saveMedicineLocal(
    MedicineTracking tracking,
    MedicinePlan plan,
    List<String> times,
  ) async {
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
    print('📝 MedicineRepository: Inserting medicine tracking...');
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
    print('✅ MedicineRepository: Tracking inserted with ID: $trackingId');

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
    print('✅ MedicineRepository: Plan inserted with ID: $planId');

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
    print(
      '📝 MedicineRepository: Inserting ${occurrences.length} occurrences...',
    );
    for (var occ in occurrences) {
      await db.insert("occurrence_plan", occ.toMap());
    }
    print('✅ MedicineRepository: All occurrences inserted successfully');

    // Schedule local notifications for local-only occurrences
    try {
      final occMaps = occurrences
          .map(
            (o) => {
              'plan_id': o.planId,
              'date': o.date.toIso8601String().split('T')[0],
              'time': o.time,
              'day_of_week': null,
              'is_taken': 0,
            },
          )
          .toList();
      await _scheduleLocalNotifications(
        medicineName: tracking.name ?? 'Medicine',
        dosage: tracking.dosage?.toString() ?? '',
        occurrences: occMaps,
      );
    } catch (e) {
      print('⚠️ Failed to schedule local notifications (local fallback): $e');
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
      // Try remote API first
      try {
        final remote = await _apiService.getMedicinePlan(planId);
        if (remote.isNotEmpty) {
          // Upsert into local DB
          try {
            await _safeUpsert(db, 'medicine_plan', {
              'plan_id': remote['plan_id'] ?? remote['id'],
              'medicine_track_id': remote['medicine_track_id'],
              'user_id': remote['user_id'],
              'importance': remote['importance'],
              'start_date': remote['start_date'],
              'end_date': remote['end_date'],
              'frequency_type': remote['frequency_type'],
              'interval_days': remote['interval_days'],
              'weekdays': remote['weekdays'],
              'month_days': remote['month_days'],
              'custom_dates': remote['custom_dates'],
            });
          } catch (e) {
            print('⚠️  Failed to upsert remote plan locally: $e');
          }
          return MedicinePlan.fromMap(remote);
        }
      } catch (_) {}

      // Fallback to local database
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
      // Try remote API first
      try {
        final remote = await _apiService.getMedicineDetail(trackingId);
        if (remote.isNotEmpty) {
          try {
            await _safeUpsert(db, 'medicine_tracking', {
              'medicine_track_id': remote['medicine_track_id'] ?? remote['id'],
              'user_id': remote['user_id'],
              'name': remote['name'],
              'type': remote['type'],
              'dosage': remote['dosage'],
              'unit': remote['unit'] ?? '',
            });
          } catch (e) {
            print('⚠️  Failed to upsert remote tracking locally: $e');
          }
          return MedicineTracking.fromMap(remote);
        }
      } catch (_) {}

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
    // Try remote API first
    try {
      final id = tracking.id;
      if (id != null) {
        // Debug: show payload
        // ignore: avoid_print
        print(
          '🌐 Updating medicine tracking remotely: ID=$id payload=${tracking.toMap()}',
        );
        await _apiService.updateMedicine(id, {
          'name': tracking.name,
          'type': tracking.type,
          'dosage': tracking.dosage?.toString(),
          if (tracking.userId != null) 'user_id': tracking.userId,
        });
        // ignore: avoid_print
        print('✅ Remote: Medicine tracking updated successfully');

        // Also update local
        final db = await dbFuture;
        final rows = await db.update(
          'medicine_tracking',
          tracking.toMap(),
          where: 'medicine_track_id = ?',
          whereArgs: [id],
        );
        // ignore: avoid_print
        print('💾 Local: medicine_tracking rows updated: $rows');

        try {
          DatabaseChangeNotifier.instance.notify();
        } catch (_) {}
        return true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('⚠️  Remote update failed: $e, using local only');
    }

    // Fallback to local only
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
      // ignore: avoid_print
      print('💾 Fallback local: medicine_tracking rows updated: $rows');
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
    // Try remote API first
    try {
      final id = plan.id;
      if (id != null) {
        // Debug: show payload
        // ignore: avoid_print
        print(
          '🌐 Updating medicine plan remotely: ID=$id payload=${plan.toMap()}',
        );
        await _apiService.updateMedicinePlan(id, {
          'importance': plan.importance,
          'start_date': plan.startDate.toIso8601String().split('T')[0],
          if (plan.endDate != null)
            'end_date': plan.endDate!.toIso8601String().split('T')[0],
          'frequency_type': plan.frequencyType,
          if (plan.intervalDays != null) 'interval_days': plan.intervalDays,
          if (plan.weekdays != null) 'weekdays': jsonEncode(plan.weekdays),
          if (plan.monthDays != null) 'month_days': jsonEncode(plan.monthDays),
          if (plan.customDates != null)
            'custom_dates': jsonEncode(plan.customDates),
        });
        // ignore: avoid_print
        print('✅ Remote: Medicine plan updated successfully');

        // Also update local
        final db = await dbFuture;
        final rows = await db.update(
          'medicine_plan',
          plan.toMap(),
          where: 'plan_id = ?',
          whereArgs: [id],
        );
        // ignore: avoid_print
        print('💾 Local: medicine_plan rows updated: $rows');

        try {
          DatabaseChangeNotifier.instance.notify();
        } catch (_) {}
        return true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('⚠️  Remote update failed: $e, using local only');
    }

    // Fallback to local only
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
      // ignore: avoid_print
      print('💾 Fallback local: medicine_plan rows updated: $rows');
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

  /// Delete a medicine plan and all its occurrences
  Future<bool> deleteMedicinePlan(int planId) async {
    final db = await dbFuture;
    try {
      // First, delete all occurrences for this plan
      final occRepo = OccurrenceRepository();
      final occurrences = await db.query(
        'occurrence_plan',
        where: 'plan_id = ?',
        whereArgs: [planId],
      );

      for (final occ in occurrences) {
        final occIdRaw = occ['id'] ?? occ['occurrence_id'] ?? occ['rowid'];
        int? occId;
        if (occIdRaw is int)
          occId = occIdRaw;
        else if (occIdRaw is String)
          occId = int.tryParse(occIdRaw);
        if (occId != null) {
          await occRepo.deleteOccurrence(occId);
        }
      }

      // Then delete the plan itself
      final rows = await db.delete(
        'medicine_plan',
        where: 'plan_id = ?',
        whereArgs: [planId],
      );

      if (rows > 0) {
        try {
          DatabaseChangeNotifier.instance.notify();
        } catch (_) {}
      }
      return rows > 0;
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting medicine plan: $e');
      return false;
    }
  }

  /// Regenerate occurrences for a plan when dates or times change
  Future<bool> regenerateOccurrences({
    required int planId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> times,
  }) async {
    final db = await dbFuture;
    try {
      // Debug info
      // ignore: avoid_print
      print(
        'MedicineRepository.regenerateOccurrences: planId=$planId start=$startDate end=$endDate times=${times.length}',
      );

      final occRepo = OccurrenceRepository();

      // Delete all existing occurrences for this plan
      final occurrences = await db.query(
        'occurrence_plan',
        where: 'plan_id = ?',
        whereArgs: [planId],
      );
      // ignore: avoid_print
      print(
        'MedicineRepository.regenerateOccurrences: existing occurrences=${occurrences.length}',
      );

      for (final occ in occurrences) {
        final occIdRaw = occ['id'] ?? occ['occurrence_id'] ?? occ['rowid'];
        int? occId;
        if (occIdRaw is int)
          occId = occIdRaw;
        else if (occIdRaw is String)
          occId = int.tryParse(occIdRaw);
        if (occId != null) {
          await occRepo.deleteOccurrence(occId);
        }
      }

      // Generate new occurrences
      DateTime current = startDate;
      var inserted = 0;
      while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
        for (final time in times) {
          await db.insert('occurrence_plan', {
            'plan_id': planId,
            'date': current.toIso8601String().split('T')[0],
            'time': time,
            'is_taken': 0,
          });
          inserted++;
        }
        current = current.add(const Duration(days: 1));
      }

      // ignore: avoid_print
      print(
        'MedicineRepository.regenerateOccurrences: inserted=$inserted new occurrences',
      );

      try {
        DatabaseChangeNotifier.instance.notify();
      } catch (_) {}
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error regenerating occurrences: $e');
      return false;
    }
  }
}
