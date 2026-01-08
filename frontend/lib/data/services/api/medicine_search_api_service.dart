import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// API Service for medicine search and reservation features
/// Connects to the Flask backend's medicine search endpoints
class MedicineSearchApiService {
  final ApiClient _apiClient;

  MedicineSearchApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Search medicines by name with pharmacy availability
  /// Returns list of pharmacies that have the medicine in stock
  Future<Map<String, dynamic>> searchMedicines(String query) async {
    try {
      debugPrint('🔍 API: Searching medicines for: $query');
      
      final response = await _apiClient.post(
        '/search/medicines',
        data: {'search_term': query},
      );

      debugPrint('✅ API: Search returned ${response.data['data']?.length ?? 0} results');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ API: Search failed: ${e.message}');
      rethrow;
    }
  }

  /// Record "Notify Me" request when medicine is not found
  /// Backend will track this for future stock notifications
  Future<Map<String, dynamic>> notifyMe({
    required int userId,
    required String medicineName,
  }) async {
    try {
      debugPrint('🔔 API: Requesting notify-me for: $medicineName');
      
      final response = await _apiClient.post(
        '/search/notify-me',
        data: {
          'user_id': userId,
          'medicine_name': medicineName,
        },
      );

      debugPrint('✅ API: Notify-me request recorded');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ API: Notify-me failed: ${e.message}');
      rethrow;
    }
  }

  /// Create medicine reservation (premium users only)
  /// Validates premium status and stock availability
  Future<Map<String, dynamic>> createReservation({
    required int userId,
    required int medicineId,
    required int pharmacyId,
    required int quantity,
  }) async {
    try {
      debugPrint('📦 API: Creating reservation for medicine $medicineId');
      
      final response = await _apiClient.post(
        '/reservations',
        data: {
          'user_id': userId,
          'medicine_id': medicineId,
          'pharmacy_id': pharmacyId,
          'quantity': quantity,
        },
      );

      debugPrint('✅ API: Reservation created successfully');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ API: Reservation failed: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  /// Get user's reservations
  /// Returns list of all reservations for the user
  Future<Map<String, dynamic>> getUserReservations(int userId) async {
    try {
      debugPrint('📋 API: Fetching reservations for user $userId');
      
      final response = await _apiClient.get(
        '/reservations/user/$userId',
      );

      debugPrint('✅ API: Retrieved ${response.data['data']?.length ?? 0} reservations');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ API: Failed to fetch reservations: ${e.message}');
      rethrow;
    }
  }

  /// Get user's search history
  /// Returns list of past searches including notify-me requests
  Future<Map<String, dynamic>> getSearchHistory(int userId) async {
    try {
      debugPrint('📜 API: Fetching search history for user $userId');
      
      final response = await _apiClient.get(
        '/search/history/$userId',
      );

      debugPrint('✅ API: Retrieved search history');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ API: Failed to fetch search history: ${e.message}');
      rethrow;
    }
  }

  /// Check if user has premium status
  /// Used for reservation validation
  Future<Map<String, dynamic>> checkPremiumStatus(int userId) async {
    try {
      debugPrint('👑 API: Checking premium status for user $userId');
      
      final response = await _apiClient.get(
        '/user/$userId/premium-status',
      );

      debugPrint('✅ API: Premium status: ${response.data['data']['premium']}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('❌ API: Failed to check premium status: ${e.message}');
      rethrow;
    }
  }
}
