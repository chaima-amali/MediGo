import 'package:dio/dio.dart';
import '../../config/environment.dart';

class MedicineSearchHistoryApiService {
  final Dio _dio;

  MedicineSearchHistoryApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: Environment.flaskBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  /// Save medicine search history with notification preference
  Future<Map<String, dynamic>> saveSearchHistory({
    required int userId,
    required String medicineName,
    required bool notifyRestock,
  }) async {
    try {
      print(
        '📝 Saving search history remotely for user $userId: $medicineName (notify: $notifyRestock)',
      );

      final response = await _dio.post(
        '/medicine-search-history',
        data: {
          'user_id': userId,
          'medicine_name': medicineName,
          'notify_restock': notifyRestock,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          print('✅ Search history saved remotely');
          return data['history'];
        }
      }

      throw Exception('Failed to save search history');
    } on DioException catch (e) {
      print('❌ Search history API error: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ Unexpected error saving search history: $e');
      rethrow;
    }
  }

  /// Get user's search history with restock notifications
  Future<List<Map<String, dynamic>>> getUserSearchHistory(int userId) async {
    try {
      final response = await _dio.get('/medicine-search-history/$userId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['history']);
        }
      }

      return [];
    } catch (e) {
      print('❌ Error getting search history: $e');
      return [];
    }
  }
}
