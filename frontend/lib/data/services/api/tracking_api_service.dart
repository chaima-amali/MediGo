import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// API Service for Medicine Tracking operations
/// Provides methods to interact with medicine tracking, plans, occurrences, and intake logs
class TrackingApiService {
  final ApiClient _client = ApiClient();

  // ============ MEDICINE TRACKING ============

  /// Add a new medicine to tracking
  Future<Map<String, dynamic>> addMedicine({
    required int userId,
    required String name,
    String? type,
    String? dosage,
  }) async {
    try {
      debugPrint('📤 [Tracking] Adding medicine: $name for userId: $userId');
      debugPrint(
        '📤 [Tracking] Backend URL: ${_client.dio.options.baseUrl}/tracking/medicines',
      );
      debugPrint(
        '📤 [Tracking] Request data: {user_id: $userId, name: $name, type: $type, dosage: $dosage}',
      );

      final response = await _client.post(
        '/tracking/medicines',
        data: {'user_id': userId, 'name': name, 'type': type, 'dosage': dosage},
      );

      debugPrint('✅ [Tracking] Response status: ${response.statusCode}');
      debugPrint('✅ [Tracking] Response data: ${response.data}');

      final data = response.data as Map<String, dynamic>;

      // Verify response structure
      if (!data.containsKey('medicine')) {
        debugPrint('⚠️  [Tracking] Response missing "medicine" field!');
        debugPrint('⚠️  [Tracking] Response keys: ${data.keys.toList()}');
      }

      return data;
    } catch (e, stackTrace) {
      debugPrint('❌ [Tracking] addMedicine error: $e');
      debugPrint('❌ [Tracking] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all medicines for a user
  Future<List<dynamic>> getMedicines(int userId) async {
    try {
      final response = await _client.get('/tracking/medicines/$userId');
      final data = response.data as Map<String, dynamic>;
      return data['medicines'] as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get specific medicine details
  Future<Map<String, dynamic>> getMedicineDetail(int medicineTrackId) async {
    try {
      final response = await _client.get(
        '/tracking/medicines/detail/$medicineTrackId',
      );
      final data = response.data as Map<String, dynamic>;
      return data['medicine'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Update medicine tracking entry
  Future<Map<String, dynamic>> updateMedicine(
    int medicineTrackId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _client.put(
        '/tracking/medicines/$medicineTrackId',
        data: updateData,
      );
      final data = response.data as Map<String, dynamic>;
      return data['medicine'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete medicine and all associated data
  Future<void> deleteMedicine(int medicineTrackId) async {
    try {
      await _client.delete('/tracking/medicines/$medicineTrackId');
    } catch (e) {
      rethrow;
    }
  }

  // ============ MEDICINE PLANS ============

  /// Create a medicine plan (schedule)
  Future<Map<String, dynamic>> createMedicinePlan({
    required int medicineTrackId,
    required int userId,
    String? importance,
    required String startDate,
    String? endDate,
    required String frequencyType,
    int? intervalDays,
    String? weekdays,
    String? monthDays,
    String? customDates,
  }) async {
    try {
      final response = await _client.post(
        '/tracking/plans',
        data: {
          'medicine_track_id': medicineTrackId,
          'user_id': userId,
          'importance': importance,
          'start_date': startDate,
          'end_date': endDate,
          'frequency_type': frequencyType,
          'interval_days': intervalDays,
          'weekdays': weekdays,
          'month_days': monthDays,
          'custom_dates': customDates,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data['plan'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get specific medicine plan
  Future<Map<String, dynamic>> getMedicinePlan(int planId) async {
    try {
      final response = await _client.get('/tracking/plans/$planId');
      final data = response.data as Map<String, dynamic>;
      return data['plan'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all medicine plans for a user
  Future<List<dynamic>> getUserPlans(int userId) async {
    try {
      final response = await _client.get('/tracking/plans/user/$userId');
      final data = response.data as Map<String, dynamic>;
      return data['plans'] as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Update medicine plan
  Future<Map<String, dynamic>> updateMedicinePlan(
    int planId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _client.put(
        '/tracking/plans/$planId',
        data: updateData,
      );
      final data = response.data as Map<String, dynamic>;
      return data['plan'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete medicine plan
  Future<void> deleteMedicinePlan(int planId) async {
    try {
      await _client.delete('/tracking/plans/$planId');
    } catch (e) {
      rethrow;
    }
  }

  // ============ OCCURRENCES ============

  /// Create single occurrence
  Future<Map<String, dynamic>> createOccurrence({
    required int planId,
    required String date,
    required String time,
    String? dayOfWeek,
    int isTaken = 0,
  }) async {
    try {
      final response = await _client.post(
        '/tracking/occurrences',
        data: {
          'plan_id': planId,
          'date': date,
          'time': time,
          'day_of_week': dayOfWeek,
          'is_taken': isTaken,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data['occurrence'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Create multiple occurrences at once
  Future<List<dynamic>> createOccurrencesBatch(
    List<Map<String, dynamic>> occurrences,
  ) async {
    try {
      final response = await _client.post(
        '/tracking/occurrences/batch',
        data: {'occurrences': occurrences},
      );
      final data = response.data as Map<String, dynamic>;
      return data['occurrences'] as List<dynamic>? ?? [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get occurrences for a specific plan
  Future<List<dynamic>> getPlanOccurrences(int planId, {String? date}) async {
    try {
      final response = await _client.get(
        '/tracking/occurrences/plan/$planId',
        queryParameters: date != null ? {'date': date} : null,
      );
      final data = response.data as Map<String, dynamic>;
      return data['occurrences'] as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all occurrences for a specific date
  Future<List<dynamic>> getOccurrencesByDate(String date, int userId) async {
    try {
      final response = await _client.get(
        '/tracking/occurrences/date/$date',
        queryParameters: {'user_id': userId},
      );
      final data = response.data as Map<String, dynamic>;
      return data['occurrences'] as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Update occurrence (e.g., mark as taken)
  Future<Map<String, dynamic>> updateOccurrence(
    int occurrenceId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _client.put(
        '/tracking/occurrences/$occurrenceId',
        data: updateData,
      );
      final data = response.data as Map<String, dynamic>;
      return data['occurrence'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete occurrence
  Future<void> deleteOccurrence(int occurrenceId) async {
    try {
      await _client.delete('/tracking/occurrences/$occurrenceId');
    } catch (e) {
      rethrow;
    }
  }

  // ============ DOSAGE CHECKS ============

  /// Create dosage check
  Future<Map<String, dynamic>> createDosageCheck({
    required int planId,
    required String doseDate,
    required String doseTime,
    required String status,
    String? takenAt,
  }) async {
    try {
      final response = await _client.post(
        '/tracking/dosage-checks',
        data: {
          'plan_id': planId,
          'dose_date': doseDate,
          'dose_time': doseTime,
          'status': status,
          'taken_at': takenAt,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data['dosage_check'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get dosage checks for a specific date
  Future<List<dynamic>> getDosageChecksByDate(String date, int userId) async {
    try {
      final response = await _client.get(
        '/tracking/dosage-checks/date/$date',
        queryParameters: {'user_id': userId},
      );
      final data = response.data as Map<String, dynamic>;
      return data['dosage_checks'] as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Update dosage check
  Future<Map<String, dynamic>> updateDosageCheck(
    int dcId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _client.put(
        '/tracking/dosage-checks/$dcId',
        data: updateData,
      );
      final data = response.data as Map<String, dynamic>;
      return data['dosage_check'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ============ MEDICATION INTAKE LOGS ============

  /// Log medication intake
  Future<Map<String, dynamic>> logMedicationIntake({
    required int occurrenceId,
    required int medicineTrackId,
    required String scheduledDate,
    required String scheduledTime,
    String? actualTime,
    required String status,
    String? dosage,
    String? notes,
  }) async {
    try {
      final response = await _client.post(
        '/tracking/intake-logs',
        data: {
          'occurrence_id': occurrenceId,
          'medicine_track_id': medicineTrackId,
          'scheduled_date': scheduledDate,
          'scheduled_time': scheduledTime,
          'actual_time': actualTime,
          'status': status,
          'dosage': dosage,
          'notes': notes,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data['intake_log'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get intake logs for a specific medicine
  Future<List<dynamic>> getMedicineIntakeLogs(
    int medicineTrackId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _client.get(
        '/tracking/intake-logs/medicine/$medicineTrackId',
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data['intake_logs'] as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
