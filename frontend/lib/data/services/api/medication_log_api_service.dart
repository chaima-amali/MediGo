import 'api_client.dart';

/// Medication Log API Service
/// Handles medication intake logging and history
class MedicationLogApiService {
  final ApiClient _client = ApiClient();

  /// Log medication intake
  Future<Map<String, dynamic>> logMedicationIntake(
    Map<String, dynamic> logData,
  ) async {
    final response = await _client.post('/medication-logs', data: logData);
    return response.data as Map<String, dynamic>;
  }

  /// Get medication logs for a user
  ///
  /// Optional parameters:
  /// - [startDate] - Filter logs from this date (YYYY-MM-DD)
  /// - [endDate] - Filter logs until this date (YYYY-MM-DD)
  Future<List<dynamic>> getMedicationLogs(
    int userId, {
    String? startDate,
    String? endDate,
  }) async {
    final response = await _client.get(
      '/medication-logs',
      queryParameters: {
        'user_id': userId,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      },
    );
    return response.data as List<dynamic>;
  }
}
