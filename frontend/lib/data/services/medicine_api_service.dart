import 'package:dio/dio.dart';
import '../../config/environment.dart';

class MedicineApiService {
  final Dio _dio;

  MedicineApiService()
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

  /// Search medicines from remote API
  /// Returns list of medicines matching the query
  Future<List<Map<String, dynamic>>> searchMedicines(
    String query, {
    int limit = 20,
  }) async {
    try {
      print('🔍 Searching medicines remotely: $query');

      final response = await _dio.get(
        '/medicines/search',
        queryParameters: {'q': query, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final medicines = List<Map<String, dynamic>>.from(
            data['medicines'] ?? [],
          );
          print('✅ Found ${medicines.length} medicines from ${data['source']}');
          return medicines;
        }
      }

      print('⚠️ API returned unsuccessful response');
      return [];
    } on DioException catch (e) {
      print('❌ Medicine search API error: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ Unexpected error searching medicines: $e');
      rethrow;
    }
  }
}
