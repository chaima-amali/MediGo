import 'api_client.dart';

/// Statistics API Service
/// Handles statistics and analytics data
class StatisticsApiService {
  final ApiClient _client = ApiClient();

  /// Get medication adherence statistics
  ///
  /// Optional parameters:
  /// - [period] - Time period for statistics (e.g., 'week', 'month', 'year')
  Future<Map<String, dynamic>> getAdherenceStats(
    int userId, {
    String? period,
  }) async {
    final response = await _client.get(
      '/statistics/adherence',
      queryParameters: {
        'user_id': userId,
        if (period != null) 'period': period,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
