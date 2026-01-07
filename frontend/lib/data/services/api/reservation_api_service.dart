import 'api_client.dart';

/// Reservation API Service
/// Handles medicine reservation operations
class ReservationApiService {
  final ApiClient _client = ApiClient();

  /// Create a new reservation
  Future<Map<String, dynamic>> createReservation(
    Map<String, dynamic> reservationData,
  ) async {
    final response = await _client.post('/reservations', data: reservationData);
    return response.data as Map<String, dynamic>;
  }

  /// Get all reservations for a user
  Future<List<dynamic>> getReservations(int userId) async {
    final response = await _client.get(
      '/reservations',
      queryParameters: {'user_id': userId},
    );
    return response.data as List<dynamic>;
  }

  /// Update reservation status
  Future<Map<String, dynamic>> updateReservationStatus(
    int reservationId,
    String status,
  ) async {
    final response = await _client.put(
      '/reservations/$reservationId/status',
      data: {'status': status},
    );
    return response.data as Map<String, dynamic>;
  }
}
