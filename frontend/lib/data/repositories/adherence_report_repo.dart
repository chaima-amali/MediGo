import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../databases/db_helper.dart';
import '../databases/db_medication_intake_log.dart';
import '../models/medication_intake_log.dart';
import '../models/adherence_report.dart';
import '../services/api/statistics_api_service.dart';

class AdherenceReportRepository {
  final StatisticsApiService _apiService = StatisticsApiService();
  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  Future<bool> _hasConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      print('⚠️  Failed to check connectivity: $e');
      return false;
    }
  }

  // Log a medication intake
  Future<int> logIntake(MedicationIntakeLog log) async {
    final db = await DBHelper.getDatabase();
    return await db.insert(
      DBMedicationIntakeLogTable.table,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an existing intake log
  Future<int> updateIntakeLog(MedicationIntakeLog log) async {
    final db = await DBHelper.getDatabase();
    return await db.update(
      DBMedicationIntakeLogTable.table,
      log.toMap(),
      where: 'log_id = ?',
      whereArgs: [log.id],
    );
  }

  // Get all intake logs for a specific date range
  Future<List<MedicationIntakeLog>> getIntakeLogsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DBHelper.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      DBMedicationIntakeLogTable.table,
      where: 'scheduled_date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'scheduled_date DESC, scheduled_time DESC',
    );
    return List.generate(
      maps.length,
      (i) => MedicationIntakeLog.fromMap(maps[i]),
    );
  }

  // Get intake logs with medicine details
  Future<List<Map<String, dynamic>>> getDetailedIntakeLogs(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DBHelper.getDatabase();

    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];

    print('Querying detailed logs between $startDateStr and $endDateStr');

    // First check what dates exist in the table
    final allDates = await db.rawQuery(
      'SELECT DISTINCT scheduled_date FROM medication_intake_log ORDER BY scheduled_date',
    );
    print(
      'Available dates in medication_intake_log: ${allDates.map((d) => d['scheduled_date']).toList()}',
    );

    // Check a sample row to see the full data
    final sampleRows = await db.rawQuery(
      'SELECT * FROM medication_intake_log LIMIT 3',
    );
    print('Sample rows from medication_intake_log: $sampleRows');

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        l.log_id,
        l.scheduled_date,
        l.scheduled_time,
        l.actual_time,
        l.status,
        l.dosage,
        l.notes,
        m.name as medicine_name,
        m.type as medicine_type
      FROM medication_intake_log l
      INNER JOIN medicine_tracking m ON l.medicine_track_id = m.medicine_track_id
      WHERE l.scheduled_date BETWEEN ? AND ?
      ORDER BY l.scheduled_date DESC, l.scheduled_time DESC
    ''',
      [startDateStr, endDateStr],
    );

    print('Query returned ${maps.length} detailed logs');

    // If no results, try without the JOIN to see if that's the issue
    if (maps.isEmpty) {
      final noJoinTest = await db.rawQuery(
        'SELECT COUNT(*) as count FROM medication_intake_log WHERE scheduled_date BETWEEN ? AND ?',
        [startDateStr, endDateStr],
      );
      print('Without JOIN, count = ${noJoinTest.first['count']}');

      // Check if medicine_tracking has data
      final medCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM medicine_tracking',
      );
      print('Total medicine_tracking records: ${medCount.first['count']}');
    }

    return maps;
  }

  // Get adherence summary statistics
  Future<AdherenceSummary> getAdherenceSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DBHelper.getDatabase();

    // Get total scheduled and status counts
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN status = 'taken' THEN 1 ELSE 0 END) as taken,
        SUM(CASE WHEN status = 'missed' THEN 1 ELSE 0 END) as missed,
        SUM(CASE WHEN status = 'skipped' THEN 1 ELSE 0 END) as skipped
      FROM medication_intake_log
      WHERE scheduled_date BETWEEN ? AND ?
    ''',
      [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
    );

    final total = result[0]['total'] as int;
    final taken = result[0]['taken'] as int? ?? 0;
    final missed = result[0]['missed'] as int? ?? 0;
    final skipped = result[0]['skipped'] as int? ?? 0;

    final notTaken = missed + skipped;
    final averageTaken = total > 0 ? (taken / total) * 100 : 0.0;

    // Get fully adherent percentage (days with 100% adherence)
    final List<Map<String, dynamic>> dailyAdherence = await db.rawQuery(
      '''
      SELECT 
        scheduled_date,
        COUNT(*) as total,
        SUM(CASE WHEN status = 'taken' THEN 1 ELSE 0 END) as taken
      FROM medication_intake_log
      WHERE scheduled_date BETWEEN ? AND ?
      GROUP BY scheduled_date
    ''',
      [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
    );

    int fullyAdherentDays = 0;
    for (var day in dailyAdherence) {
      if (day['total'] == day['taken']) {
        fullyAdherentDays++;
      }
    }
    final fullyAdherent = dailyAdherence.isNotEmpty
        ? (fullyAdherentDays / dailyAdherence.length) * 100
        : 0.0;

    return AdherenceSummary(
      notTaken: notTaken,
      averageTaken: averageTaken,
      fullyAdherent: fullyAdherent,
      medicineMissed: missed,
    );
  }

  // Get weekly adherence breakdown
  Future<List<WeeklyAdherence>> getWeeklyAdherence(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DBHelper.getDatabase();
    final List<WeeklyAdherence> weeklyData = [];

    DateTime currentWeekStart = startDate;
    int weekNumber = 1;

    while (currentWeekStart.isBefore(endDate)) {
      final weekEnd = currentWeekStart.add(Duration(days: 6));
      final actualWeekEnd = weekEnd.isAfter(endDate) ? endDate : weekEnd;

      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN status = 'taken' THEN 1 ELSE 0 END) as taken
        FROM medication_intake_log
        WHERE scheduled_date BETWEEN ? AND ?
      ''',
        [
          currentWeekStart.toIso8601String().split('T')[0],
          actualWeekEnd.toIso8601String().split('T')[0],
        ],
      );

      final total = result[0]['total'] as int;
      final taken = result[0]['taken'] as int? ?? 0;
      final percentage = total > 0 ? (taken / total) * 100 : 0.0;

      final weekLabel =
          'Week $weekNumber (${currentWeekStart.day}~${actualWeekEnd.day} ${_getMonthName(currentWeekStart.month)})';

      weeklyData.add(
        WeeklyAdherence(weekLabel: weekLabel, percentage: percentage),
      );

      currentWeekStart = weekEnd.add(Duration(days: 1));
      weekNumber++;
    }

    return weeklyData;
  }

  // Get medication summary for the report
  Future<List<MedicationSummary>> getMedicationSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DBHelper.getDatabase();

    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];

    print('Querying medication summary between $startDateStr and $endDateStr');

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT DISTINCT
        m.name as medicine_name,
        m.dosage,
        m.type,
        p.frequency_type,
        p.start_date,
        p.end_date
      FROM medication_intake_log l
      INNER JOIN medicine_tracking m ON l.medicine_track_id = m.medicine_track_id
      LEFT JOIN medicine_plan p ON m.medicine_track_id = p.medicine_track_id
      WHERE l.scheduled_date BETWEEN ? AND ?
      GROUP BY m.medicine_track_id
    ''',
      [startDateStr, endDateStr],
    );

    print('Query returned ${maps.length} medication summaries');

    return maps.map((map) {
      final dosage = '${map['dosage'] ?? '0'} mg';
      final frequency = _formatFrequency(map['frequency_type'] ?? 'daily');
      final duration = _calculateDuration(
        map['start_date'] != null
            ? DateTime.parse(map['start_date'])
            : startDate,
        map['end_date'] != null ? DateTime.parse(map['end_date']) : endDate,
      );

      // Determine status
      String status;
      if (map['end_date'] != null) {
        final endDate = DateTime.parse(map['end_date']);
        if (endDate.isBefore(DateTime.now())) {
          status = 'completed';
        } else {
          status = 'ongoing';
        }
      } else {
        status = 'ongoing';
      }

      return MedicationSummary(
        medicineName: map['medicine_name'] ?? 'Unknown',
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        status: status,
      );
    }).toList();
  }

  // Get full adherence report with remote-first approach
  Future<AdherenceReport?> getAdherenceReport(
    DateTime startDate,
    DateTime endDate, {
    int? userId,
  }) async {
    try {
      // Try to fetch from remote API first if connected
      if (await _hasConnection()) {
        try {
          print('🌐 Fetching adherence report from remote...');

          // Calculate period parameter
          final duration = endDate.difference(startDate).inDays;
          String period;
          if (duration <= 7) {
            period = 'week';
          } else if (duration <= 30) {
            period = 'month';
          } else if (duration <= 365) {
            period = 'year';
          } else {
            period = 'all';
          }

          // Get user ID from database if not provided
          int effectiveUserId = userId ?? 0;
          if (effectiveUserId == 0) {
            final db = await DBHelper.getDatabase();
            final userMaps = await db.query('user', limit: 1);
            if (userMaps.isNotEmpty) {
              effectiveUserId = userMaps.first['user_id'] as int? ?? 0;
            }
          }

          if (effectiveUserId > 0) {
            final remoteReport = await _apiService.getAdherenceStats(
              effectiveUserId,
              period: period,
            );

            print('✅ Remote report fetched successfully');

            // Parse remote response to AdherenceReport model
            // You may need to adjust this based on the actual API response structure
            return _parseRemoteReport(remoteReport, startDate, endDate);
          }
        } catch (e) {
          print('⚠️  Remote fetch failed, falling back to local: $e');
        }
      }

      // Fallback to local database
      print('📦 Fetching adherence report from local database...');
      return await _getLocalAdherenceReport(startDate, endDate);
    } catch (e) {
      print('❌ Error generating adherence report: $e');
      return null;
    }
  }

  // Parse remote API response to AdherenceReport model
  AdherenceReport? _parseRemoteReport(
    Map<String, dynamic> remoteData,
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      // Parse based on actual API response structure
      // This is a placeholder - adjust based on your actual API response
      final userData = remoteData['user'] as Map<String, dynamic>? ?? {};
      final stats = remoteData['statistics'] as Map<String, dynamic>? ?? {};

      final missed = stats['missed'] ?? 0;
      final notTaken = missed + (stats['skipped'] ?? 0);
      final adherenceRate = (stats['adherence_rate'] ?? 0.0).toDouble();

      return AdherenceReport(
        fullName: userData['name'] ?? 'Unknown',
        age: userData['age'] ?? 0,
        phone: userData['phone'] ?? '',
        reportGeneratedDate: DateTime.now(),
        reportPeriod: remoteData['period'] ?? '',
        adherenceSummary: AdherenceSummary(
          notTaken: notTaken,
          averageTaken: adherenceRate,
          fullyAdherent: (stats['fully_adherent'] ?? 0.0).toDouble(),
          medicineMissed: missed,
        ),
        weeklyAdherence: [], // Parse weekly data if available
        medicationSummary: [], // Parse medication summary if available
        detailedIntakeLog: [], // Parse detailed logs if available
      );
    } catch (e) {
      print('Error parsing remote report: $e');
      return null;
    }
  }

  // Get adherence report from local database
  Future<AdherenceReport?> _getLocalAdherenceReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get user info (assuming user_id = 1 for now)
      final db = await DBHelper.getDatabase();
      final userMaps = await db.query('user', limit: 1);

      if (userMaps.isEmpty) {
        print('No user found in database');
        return null;
      }

      final userData = userMaps.first;
      final fullName = userData['name']?.toString() ?? 'Unknown';

      // Calculate age from date of birth
      int age = 0;
      if (userData['dob'] != null) {
        try {
          final dob = DateTime.parse(userData['dob'].toString());
          age = DateTime.now().year - dob.year;
          if (DateTime.now().month < dob.month ||
              (DateTime.now().month == dob.month &&
                  DateTime.now().day < dob.day)) {
            age--;
          }
        } catch (e) {
          print('Error parsing date of birth: $e');
        }
      }

      final phone = userData['phone']?.toString() ?? '';

      print('User found: $fullName, Age: $age');

      // Get all report components
      final adherenceSummary = await getAdherenceSummary(startDate, endDate);
      print(
        'Adherence summary - Total: ${adherenceSummary.notTaken}, Avg: ${adherenceSummary.averageTaken}%',
      );

      final weeklyAdherence = await getWeeklyAdherence(startDate, endDate);
      print('Weekly adherence data points: ${weeklyAdherence.length}');

      final medicationSummary = await getMedicationSummary(startDate, endDate);
      print('Medication summary entries: ${medicationSummary.length}');

      final detailedLogs = await getDetailedIntakeLogs(startDate, endDate);
      print('Detailed intake logs retrieved: ${detailedLogs.length}');

      final intakeLogEntries = detailedLogs.map((log) {
        return IntakeLogEntry(
          date: DateTime.parse(log['scheduled_date']),
          medicineName: log['medicine_name'] ?? 'Unknown',
          time: log['scheduled_time'] ?? '',
          status: log['status'] ?? 'unknown',
          dosage: log['dosage'] ?? '0 mg',
          notes: log['notes'],
        );
      }).toList();

      final duration = endDate.difference(startDate).inDays;
      final reportPeriod = duration >= 30
          ? '${(duration / 30).ceil()} month${duration >= 60 ? 's' : ''}'
          : '$duration days';

      return AdherenceReport(
        fullName: fullName,
        age: age,
        phone: phone,
        reportGeneratedDate: DateTime.now(),
        reportPeriod: reportPeriod,
        adherenceSummary: adherenceSummary,
        weeklyAdherence: weeklyAdherence,
        medicationSummary: medicationSummary,
        detailedIntakeLog: intakeLogEntries,
      );
    } catch (e) {
      print('Error generating adherence report: $e');
      return null;
    }
  }

  // Helper method to sync occurrences to intake logs
  Future<void> syncOccurrencesToIntakeLogs() async {
    final db = await DBHelper.getDatabase();

    // First, fix any existing records with medicine_track_id = 0
    await _fixInvalidMedicineTrackIds();

    // First, check total occurrences
    final totalOccurrences = await db.rawQuery(
      'SELECT COUNT(*) as count FROM occurrence_plan WHERE date IS NOT NULL',
    );
    print('Total occurrences in database: ${totalOccurrences.first['count']}');

    // Step 1: Update existing intake logs with latest status from occurrence_plan
    final existingLogs = await db.rawQuery('''
      SELECT l.log_id, o.is_taken
      FROM medication_intake_log l
      INNER JOIN occurrence_plan o ON l.occurrence_id = o.id
      WHERE o.is_taken != CASE 
        WHEN l.status = 'taken' THEN 1
        WHEN l.status = 'missed' THEN 0
        WHEN l.status = 'scheduled' THEN 0
        ELSE 0
      END
    ''');

    print('Updating ${existingLogs.length} intake logs with new status');
    for (var log in existingLogs) {
      final newStatus = log['is_taken'] == 1 ? 'taken' : 'missed';
      await db.update(
        'medication_intake_log',
        {
          'status': newStatus,
          'actual_time': log['is_taken'] == 1
              ? DateTime.now().toIso8601String()
              : null,
        },
        where: 'log_id = ?',
        whereArgs: [log['log_id']],
      );
    }

    // Step 2: Get all occurrences that don't have a corresponding intake log
    final List<Map<String, dynamic>> occurrences = await db.rawQuery('''
      SELECT o.id, o.plan_id, o.date, o.time, o.is_taken,
             p.medicine_track_id, m.dosage, m.name
      FROM occurrence_plan o
      INNER JOIN medicine_plan p ON o.plan_id = p.plan_id
      INNER JOIN medicine_tracking m ON p.medicine_track_id = m.medicine_track_id
      LEFT JOIN medication_intake_log l ON o.id = l.occurrence_id
      WHERE l.log_id IS NULL AND o.date IS NOT NULL
    ''');

    print('Syncing ${occurrences.length} new occurrences to intake logs');

    if (occurrences.isEmpty) {
      print('No occurrences to sync. Checking if data already exists...');
      final existingLogs = await db.rawQuery(
        'SELECT COUNT(*) as count FROM medication_intake_log',
      );
      print('Existing intake logs: ${existingLogs.first['count']}');
    }

    int successCount = 0;
    for (var occ in occurrences) {
      try {
        print(
          'Syncing occurrence ${occ['id']}: ${occ['name']}, date: ${occ['date']}, is_taken: ${occ['is_taken']}',
        );

        // Determine status based on is_taken flag
        String status;
        if (occ['is_taken'] == null || occ['is_taken'] == 0) {
          // Check if this is a past occurrence (missed) or future (scheduled)
          final occDate = DateTime.parse(occ['date']);
          final now = DateTime.now();
          if (occDate.isBefore(DateTime(now.year, now.month, now.day))) {
            status = 'missed';
          } else {
            status = 'scheduled';
          }
        } else {
          status = 'taken';
        }

        final log = MedicationIntakeLog(
          occurrenceId: occ['id'],
          medicineTrackId: occ['medicine_track_id'],
          scheduledDate: DateTime.parse(occ['date']),
          scheduledTime: occ['time'],
          status: status,
          dosage: occ['dosage']?.toString(),
        );
        await logIntake(log);
        successCount++;
      } catch (e) {
        print('Error syncing occurrence ${occ['id']}: $e');
      }
    }

    print(
      'Sync completed: $successCount/${occurrences.length} occurrences synced successfully',
    );
  }

  // Fix existing intake logs with invalid medicine_track_id (0 or null)
  Future<void> _fixInvalidMedicineTrackIds() async {
    final db = await DBHelper.getDatabase();

    // Find logs with invalid medicine_track_id
    final invalidLogs = await db.rawQuery('''
      SELECT l.log_id, l.occurrence_id, o.plan_id, p.medicine_track_id
      FROM medication_intake_log l
      INNER JOIN occurrence_plan o ON l.occurrence_id = o.id
      INNER JOIN medicine_plan p ON o.plan_id = p.plan_id
      WHERE l.medicine_track_id IS NULL OR l.medicine_track_id = 0
    ''');

    if (invalidLogs.isNotEmpty) {
      print(
        'Fixing ${invalidLogs.length} intake logs with invalid medicine_track_id',
      );

      for (var log in invalidLogs) {
        final correctTrackId = log['medicine_track_id'];
        if (correctTrackId != null && correctTrackId != 0) {
          await db.update(
            'medication_intake_log',
            {'medicine_track_id': correctTrackId},
            where: 'log_id = ?',
            whereArgs: [log['log_id']],
          );
        }
      }

      print('Fixed ${invalidLogs.length} intake logs');
    }
  }

  String _formatFrequency(String frequencyType) {
    switch (frequencyType.toLowerCase()) {
      case 'daily':
        return 'Once daily';
      case 'twice_daily':
        return '2x weekly';
      case 'weekly':
        return 'Once weekly';
      case 'monthly':
        return 'Once monthly';
      default:
        return frequencyType;
    }
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    if (days < 7) {
      return '$days days';
    } else if (days < 30) {
      return '${(days / 7).ceil()} weeks';
    } else {
      return '${(days / 30).ceil()} months';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
