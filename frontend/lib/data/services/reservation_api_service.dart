import 'package:dio/dio.dart';
import '../../config/environment.dart';

class ReservationApiService {
  final Dio _dio;

  ReservationApiService()
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

  /// Create a reservation remotely
  Future<Map<String, dynamic>> createReservation({
    required int userId,
    required int pharmacyId,
    required String medicineName,
    required String day,
    required String time,
    required int quantity,
    required bool isPremium,
    int? medicineFindId,
  }) async {
    try {
      print(
        '📝 Creating reservation remotely for user $userId (premium: $isPremium)',
      );
      print('🌐 API URL: ${_dio.options.baseUrl}/reservations');

      final requestData = {
        'user_id': userId,
        'pharmacy_id': pharmacyId,
        'medicine_name': medicineName,
        'day': day,
        'time': time,
        'quantity': quantity,
        'is_premium': isPremium,
        if (medicineFindId != null) 'medicine_find_id': medicineFindId,
      };

      print('📤 Request data: $requestData');

      final response = await _dio.post('/reservations', data: requestData);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          print('✅ Reservation created: ${data['source']}');
          return data['reservation'];
        }
      }

      throw Exception('Failed to create reservation');
    } on DioException catch (e) {
      print('❌ Reservation API DioException: ${e.type}');
      print('❌ Error message: ${e.message}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      if (e.error != null) {
        print('❌ Error object: ${e.error}');
      }
      rethrow;
    } catch (e) {
      print('❌ Unexpected error creating reservation: $e');
      rethrow;
    }
  }

  /// Get user reservations
  Future<List<Map<String, dynamic>>> getUserReservations(int userId) async {
    try {
      print('📋 Fetching reservations for user $userId');

      final response = await _dio.get('/reservations/$userId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final reservations = List<Map<String, dynamic>>.from(
            data['reservations'] ?? [],
          );
          print(
            '✅ Found ${reservations.length} reservations from ${data['source']}',
          );
          return reservations;
        }
      }

      return [];
    } on DioException catch (e) {
      print('❌ Fetch reservations API error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error fetching reservations: $e');
      rethrow;
    }
  }

  /// Update reservation status
  Future<Map<String, dynamic>> updateReservationStatus({
    required int reservationId,
    required String status,
    required int userId,
  }) async {
    try {
      print('🔄 Updating reservation $reservationId status to: $status');

      final response = await _dio.patch(
        '/reservations/$reservationId',
        data: {'status': status, 'user_id': userId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          print('✅ Reservation status updated remotely');
          return data['reservation'];
        }
      }

      throw Exception('Failed to update reservation status');
    } on DioException catch (e) {
      print('❌ Update status API error: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ Unexpected error updating status: $e');
      rethrow;
    }
  }
}
