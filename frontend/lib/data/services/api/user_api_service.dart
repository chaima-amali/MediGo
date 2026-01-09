import 'api_client.dart';

/// User API Service
/// Handles user-related CRUD operations
class UserApiService {
  final ApiClient _client = ApiClient();

  /// Create a new user
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final response = await _client.post('/users', data: userData);
    return response.data as Map<String, dynamic>;
  }

  /// Get user by ID
  Future<Map<String, dynamic>> getUser(int userId) async {
    final response = await _client.get('/users/$userId');
    return response.data as Map<String, dynamic>;
  }

  /// Update user information
  Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    final response = await _client.put('/users/$userId', data: userData);
    return response.data as Map<String, dynamic>;
  }

  /// Update FCM token for push notifications
  Future<void> updateFCMToken(int userId, String token) async {
    await _client.put('/users/$userId/fcm-token', data: {'fcm_token': token});
  }

  /// Update notification preference
  Future<void> updateNotificationPreference(int userId, bool enabled) async {
    await _client.put(
      '/users/$userId/notification-preference',
      data: {'notifications_enabled': enabled},
    );
  }
}
