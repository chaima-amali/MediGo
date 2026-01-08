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

  /// Update user premium status
  Future<Map<String, dynamic>> updateUserPremium(
    int userId,
    bool premium,
  ) async {
    final response = await _client.put(
      '/users/$userId/premium',
      data: {'premium': premium},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Update FCM token for push notifications
  Future<void> updateFCMToken(int userId, String token) async {
    await _client.post('/users/$userId/fcm-token', data: {'token': token});
  }
}
