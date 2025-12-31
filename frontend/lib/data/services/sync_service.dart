import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/data/services/supabase_service.dart';
import 'package:frontend/data/databases/db_helper.dart';
import 'package:sqflite/sqflite.dart';

/// Data synchronization service between local and remote databases
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ApiService _apiService = ApiService();
  final SupabaseService _supabaseService = SupabaseService();
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Check internet connectivity
  Future<bool> hasConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Sync all data (medicines, reservations, logs, etc.)
  Future<SyncResult> syncAll(int userId) async {
    if (_isSyncing) {
      debugPrint('⚠️ Sync already in progress');
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    if (!await hasConnection()) {
      debugPrint('❌ No internet connection');
      return SyncResult(success: false, message: 'No internet connection');
    }

    _isSyncing = true;
    debugPrint('🔄 Starting full sync for user $userId');

    try {
      final results = await Future.wait([
        _syncMedicines(userId),
        _syncReservations(userId),
        _syncMedicationLogs(userId),
        _syncUserProfile(userId),
      ]);

      final allSuccess = results.every((r) => r.success);
      _lastSyncTime = DateTime.now();

      debugPrint(
        allSuccess
            ? '✅ Full sync completed successfully'
            : '⚠️ Sync completed with some errors',
      );

      return SyncResult(
        success: allSuccess,
        message: allSuccess
            ? 'All data synced successfully'
            : 'Some items failed to sync',
        syncedItems: results.fold(0, (sum, r) => sum + r.syncedItems),
        failedItems: results.fold(0, (sum, r) => sum + r.failedItems),
      );
    } catch (e) {
      debugPrint('❌ Sync error: $e');
      return SyncResult(success: false, message: 'Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync medicines
  Future<SyncResult> _syncMedicines(int userId) async {
    debugPrint('🔄 Syncing medicines...');
    int synced = 0;
    int failed = 0;

    try {
      final db = await DBHelper.getDatabase();

      // Get local medicines that need syncing (not synced or modified)
      final localMedicines = await db.query(
        'user_medicines',
        where: 'user_id = ? AND (synced = 0 OR synced IS NULL)',
        whereArgs: [userId],
      );

      // Upload to backend
      for (var medicine in localMedicines) {
        try {
          if (medicine['remote_id'] == null) {
            // Create new medicine on server
            final result = await _apiService.createMedicine(medicine);

            // Update local record with remote ID
            await db.update(
              'user_medicines',
              {
                'remote_id': result['id'],
                'synced': 1,
                'last_synced': DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [medicine['id']],
            );
          } else {
            // Update existing medicine on server
            await _apiService.updateMedicine(
              medicine['remote_id'] as int,
              medicine,
            );

            await db.update(
              'user_medicines',
              {'synced': 1, 'last_synced': DateTime.now().toIso8601String()},
              where: 'id = ?',
              whereArgs: [medicine['id']],
            );
          }
          synced++;
        } catch (e) {
          debugPrint('❌ Failed to sync medicine ${medicine['id']}: $e');
          failed++;
        }
      }

      // Download remote medicines
      final remoteMedicines = await _apiService.getMedicines(userId);
      for (var remoteMedicine in remoteMedicines) {
        try {
          // Check if exists locally
          final existing = await db.query(
            'user_medicines',
            where: 'remote_id = ?',
            whereArgs: [remoteMedicine['id']],
          );

          if (existing.isEmpty) {
            // Insert new local record
            await db.insert('user_medicines', {
              ...remoteMedicine,
              'remote_id': remoteMedicine['id'],
              'synced': 1,
              'last_synced': DateTime.now().toIso8601String(),
            }, conflictAlgorithm: ConflictAlgorithm.replace);
            synced++;
          }
        } catch (e) {
          debugPrint('❌ Failed to download medicine: $e');
          failed++;
        }
      }

      debugPrint('✅ Medicines sync: $synced synced, $failed failed');
      return SyncResult(
        success: failed == 0,
        syncedItems: synced,
        failedItems: failed,
      );
    } catch (e) {
      debugPrint('❌ Medicines sync error: $e');
      return SyncResult(success: false, message: e.toString());
    }
  }

  /// Sync reservations
  Future<SyncResult> _syncReservations(int userId) async {
    debugPrint('🔄 Syncing reservations...');
    int synced = 0;
    int failed = 0;

    try {
      final db = await DBHelper.getDatabase();

      // Get local reservations that need syncing
      final localReservations = await db.query(
        'reservations',
        where: 'user_id = ? AND (synced = 0 OR synced IS NULL)',
        whereArgs: [userId],
      );

      // Upload to backend
      for (var reservation in localReservations) {
        try {
          if (reservation['remote_id'] == null) {
            final result = await _apiService.createReservation(reservation);

            await db.update(
              'reservations',
              {
                'remote_id': result['id'],
                'synced': 1,
                'last_synced': DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [reservation['id']],
            );
          }
          synced++;
        } catch (e) {
          debugPrint('❌ Failed to sync reservation: $e');
          failed++;
        }
      }

      // Download remote reservations
      final remoteReservations = await _apiService.getReservations(userId);
      for (var remote in remoteReservations) {
        try {
          final existing = await db.query(
            'reservations',
            where: 'remote_id = ?',
            whereArgs: [remote['id']],
          );

          if (existing.isEmpty) {
            await db.insert('reservations', {
              ...remote,
              'remote_id': remote['id'],
              'synced': 1,
              'last_synced': DateTime.now().toIso8601String(),
            }, conflictAlgorithm: ConflictAlgorithm.replace);
            synced++;
          }
        } catch (e) {
          debugPrint('❌ Failed to download reservation: $e');
          failed++;
        }
      }

      debugPrint('✅ Reservations sync: $synced synced, $failed failed');
      return SyncResult(
        success: failed == 0,
        syncedItems: synced,
        failedItems: failed,
      );
    } catch (e) {
      debugPrint('❌ Reservations sync error: $e');
      return SyncResult(success: false, message: e.toString());
    }
  }

  /// Sync medication logs
  Future<SyncResult> _syncMedicationLogs(int userId) async {
    debugPrint('🔄 Syncing medication logs...');
    int synced = 0;
    int failed = 0;

    try {
      final db = await DBHelper.getDatabase();

      // Get local logs that need syncing
      final localLogs = await db.query(
        'medicine_intake_log',
        where: 'user_id = ? AND (synced = 0 OR synced IS NULL)',
        whereArgs: [userId],
      );

      // Upload to backend
      for (var log in localLogs) {
        try {
          await _apiService.logMedicationIntake(log);

          await db.update(
            'medicine_intake_log',
            {'synced': 1, 'last_synced': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [log['id']],
          );
          synced++;
        } catch (e) {
          debugPrint('❌ Failed to sync log: $e');
          failed++;
        }
      }

      debugPrint('✅ Logs sync: $synced synced, $failed failed');
      return SyncResult(
        success: failed == 0,
        syncedItems: synced,
        failedItems: failed,
      );
    } catch (e) {
      debugPrint('❌ Logs sync error: $e');
      return SyncResult(success: false, message: e.toString());
    }
  }

  /// Sync user profile
  Future<SyncResult> _syncUserProfile(int userId) async {
    debugPrint('🔄 Syncing user profile...');

    try {
      final db = await DBHelper.getDatabase();
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isNotEmpty) {
        final user = users.first;

        // Upload to backend
        await _apiService.updateUser(userId, user);

        await db.update(
          'users',
          {'synced': 1, 'last_synced': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [userId],
        );

        debugPrint('✅ User profile synced');
        return SyncResult(success: true, syncedItems: 1);
      }

      return SyncResult(success: false, message: 'User not found');
    } catch (e) {
      debugPrint('❌ User profile sync error: $e');
      return SyncResult(success: false, message: e.toString());
    }
  }

  /// Push specific item to remote
  Future<bool> pushItem(String table, Map<String, dynamic> data) async {
    if (!await hasConnection()) return false;

    try {
      // Determine endpoint based on table
      switch (table) {
        case 'user_medicines':
          await _apiService.createMedicine(data);
          break;
        case 'reservations':
          await _apiService.createReservation(data);
          break;
        case 'medicine_intake_log':
          await _apiService.logMedicationIntake(data);
          break;
        default:
          debugPrint('⚠️ Unknown table for push: $table');
          return false;
      }

      debugPrint('✅ Pushed item to $table');
      return true;
    } catch (e) {
      debugPrint('❌ Push error: $e');
      return false;
    }
  }
}

/// Sync result model
class SyncResult {
  final bool success;
  final String? message;
  final int syncedItems;
  final int failedItems;

  SyncResult({
    required this.success,
    this.message,
    this.syncedItems = 0,
    this.failedItems = 0,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, synced: $syncedItems, failed: $failedItems, message: $message)';
  }
}
