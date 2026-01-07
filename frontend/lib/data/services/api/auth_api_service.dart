import 'api_client.dart';

/// Authentication API Service
/// Handles user registration, login, and verification
class AuthApiService {
  final ApiClient _client = ApiClient();

  /// Register a new user
  ///
  /// [userData] should contain:
  /// - name
  /// - email
  /// - phone
  /// - password
  /// - gender
  /// - dob
  /// - latitude
  /// - longitude
  /// - location_name
  /// - premium
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await _client.post('/auth/register', data: userData);
    return response.data as Map<String, dynamic>;
  }

  /// Login user with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Verify if user exists by email
  Future<Map<String, dynamic>> verifyUser(String email) async {
    final response = await _client.post('/auth/verify', data: {'email': email});
    return response.data as Map<String, dynamic>;
  }

  /// Set authentication token for subsequent requests
  void setAuthToken(String token) {
    _client.setAuthToken(token);
  }

  /// Clear authentication token
  void clearAuthToken() {
    _client.clearAuthToken();
  }
}
