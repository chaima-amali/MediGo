import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/data/services/sync_service.dart';
import 'package:frontend/data/databases/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background tasks callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('🔄 Background task started: $task');

    try {
      switch (task) {
        case 'dataSync':
          await _performDataSync(inputData);
          break;
        case 'medicationReminder':
          await _checkMedicationReminders(inputData);
          break;
        case 'databaseBackup':
          await _performDatabaseBackup(inputData);
          break;
        case 'cleanupOldData':
          await _cleanupOldData(inputData);
          break;
        default:
          debugPrint('⚠️ Unknown task: $task');
      }

      debugPrint('✅ Background task completed: $task');
      return Future.value(true);
    } catch (e) {
      debugPrint('❌ Background task error: $e');
      return Future.value(false);
    }
  });
}

/// Perform data synchronization
Future<void> _performDataSync(Map<String, dynamic>? inputData) async {
  debugPrint('🔄 Performing background data sync');

  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId != null) {
      final syncService = SyncService();
      final result = await syncService.syncAll(userId);

      debugPrint('📊 Sync result: ${result.toString()}');

      // Save last sync time
      await prefs.setString('last_sync', DateTime.now().toIso8601String());
    } else {
      debugPrint('⚠️ No user ID found for sync');
    }
  } catch (e) {
    debugPrint('❌ Background sync error: $e');
  }
}

/// Check and trigger medication reminders
Future<void> _checkMedicationReminders(Map<String, dynamic>? inputData) async {
  debugPrint('💊 Checking medication reminders');

  try {
    // TODO: Implement medication reminder check logic
    // - Query upcoming medications
    // - Show local notifications
    // - Update reminder status
  } catch (e) {
    debugPrint('❌ Reminder check error: $e');
  }
}

/// Backup database to cloud storage
Future<void> _performDatabaseBackup(Map<String, dynamic>? inputData) async {
  debugPrint('💾 Performing database backup');

  try {
    // TODO: Implement database backup
    // - Export database to file
    // - Upload to Supabase storage or Firebase Storage
    // - Keep last 7 backups
  } catch (e) {
    debugPrint('❌ Backup error: $e');
  }
}

/// Cleanup old data
Future<void> _cleanupOldData(Map<String, dynamic>? inputData) async {
  debugPrint('🗑️ Cleaning up old data');

  try {
    final db = await DBHelper.getDatabase();

    // Delete old logs (older than 90 days)
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    await db.delete(
      'medicine_intake_log',
      where: 'taken_at < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );

    debugPrint('✅ Old data cleaned up');
  } catch (e) {
    debugPrint('❌ Cleanup error: $e');
  }
}

/// Background Jobs Service
class BackgroundJobsService {
  static final BackgroundJobsService _instance =
      BackgroundJobsService._internal();
  factory BackgroundJobsService() => _instance;
  BackgroundJobsService._internal();

  /// Initialize background jobs
  Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
      debugPrint('✅ Background jobs initialized');

      // Register periodic tasks
      await _registerPeriodicTasks();
    } catch (e) {
      debugPrint('❌ Background jobs initialization error: $e');
    }
  }

  /// Register all periodic tasks
  Future<void> _registerPeriodicTasks() async {
    // Data sync every 30 minutes
    await Workmanager().registerPeriodicTask(
      'dataSync',
      'dataSync',
      frequency: const Duration(minutes: 30),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    debugPrint('📅 Registered periodic data sync');

    // Medication reminders check every 15 minutes
    await Workmanager().registerPeriodicTask(
      'medicationReminder',
      'medicationReminder',
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    debugPrint('📅 Registered medication reminder check');

    // Daily database backup at midnight
    await Workmanager().registerPeriodicTask(
      'databaseBackup',
      'databaseBackup',
      frequency: const Duration(hours: 24),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    debugPrint('📅 Registered daily database backup');

    // Weekly cleanup
    await Workmanager().registerPeriodicTask(
      'cleanupOldData',
      'cleanupOldData',
      frequency: const Duration(days: 7),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    debugPrint('📅 Registered weekly data cleanup');
  }

  /// Trigger manual sync
  Future<void> triggerManualSync(int userId) async {
    try {
      await Workmanager().registerOneOffTask(
        'manualSync-${DateTime.now().millisecondsSinceEpoch}',
        'dataSync',
        inputData: {'user_id': userId, 'manual': true},
        constraints: Constraints(networkType: NetworkType.connected),
      );
      debugPrint('✅ Manual sync triggered');
    } catch (e) {
      debugPrint('❌ Manual sync trigger error: $e');
    }
  }

  /// Cancel all background tasks
  Future<void> cancelAll() async {
    try {
      await Workmanager().cancelAll();
      debugPrint('✅ All background tasks cancelled');
    } catch (e) {
      debugPrint('❌ Cancel tasks error: $e');
    }
  }

  /// Cancel specific task
  Future<void> cancelTask(String uniqueName) async {
    try {
      await Workmanager().cancelByUniqueName(uniqueName);
      debugPrint('✅ Task cancelled: $uniqueName');
    } catch (e) {
      debugPrint('❌ Cancel task error: $e');
    }
  }
}
