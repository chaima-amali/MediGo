import 'api_client.dart';

/// Statistics API Service
/// Handles statistics and analytics data for medicine tracking
class StatisticsApiService {
  final ApiClient _client = ApiClient();

  /// Get overall statistics overview for a user
  ///
  /// Optional parameters:
  /// - [period] - Time period for statistics ('week', 'month', 'year', 'all')
  Future<Map<String, dynamic>> getStatisticsOverview(
    int userId, {
    String? period,
  }) async {
    final response = await _client.get(
      '/statistics/overview/$userId',
      queryParameters: {
        if (period != null) 'period': period,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  /// Get statistics for a specific medicine
  ///
  /// Optional parameters:
  /// - [period] - Time period for statistics ('week', 'month', 'year', 'all')
  Future<Map<String, dynamic>> getMedicineStatistics(
    int medicineTrackId, {
    String? period,
  }) async {
    final response = await _client.get(
      '/statistics/medicine/$medicineTrackId',
      queryParameters: {
        if (period != null) 'period': period,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  /// Get daily statistics for a user
  ///
  /// Optional parameters:
  /// - [days] - Number of days to include (default: 30)
  Future<List<dynamic>> getDailyStatistics(
    int userId, {
    int? days,
  }) async {
    final response = await _client.get(
      '/statistics/daily/$userId',
      queryParameters: {
        if (days != null) 'days': days.toString(),
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as List<dynamic>;
  }

  /// Get weekly statistics for a user
  ///
  /// Optional parameters:
  /// - [weeks] - Number of weeks to include (default: 4)
  Future<List<dynamic>> getWeeklyStatistics(
    int userId, {
    int? weeks,
  }) async {
    final response = await _client.get(
      '/statistics/weekly/$userId',
      queryParameters: {
        if (weeks != null) 'weeks': weeks.toString(),
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as List<dynamic>;
  }

  /// Get monthly statistics for a user
  ///
  /// Optional parameters:
  /// - [months] - Number of months to include (default: 6)
  Future<List<dynamic>> getMonthlyStatistics(
    int userId, {
    int? months,
  }) async {
    final response = await _client.get(
      '/statistics/monthly/$userId',
      queryParameters: {
        if (months != null) 'months': months.toString(),
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as List<dynamic>;
  }

  /// Get adherence trend for the last 30 days
  Future<List<dynamic>> getAdherenceTrend(int userId) async {
    final response = await _client.get(
      '/statistics/adherence-trend/$userId',
    );
    final data = response.data as Map<String, dynamic>;
    return data['data'] as List<dynamic>;
  }

  /// Legacy method for backward compatibility
  /// Get medication adherence statistics
  ///
  /// Optional parameters:
  /// - [period] - Time period for statistics (e.g., 'week', 'month', 'year')
  Future<Map<String, dynamic>> getAdherenceStats(
    int userId, {
    String? period,
  }) async {
    // Use the new overview endpoint
    return getStatisticsOverview(userId, period: period);
  }
}
