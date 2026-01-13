import 'package:dio/dio.dart';
import '../../config/environment.dart';

class NotificationApiService {
  final Dio _dio;

  NotificationApiService()
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

  /// Get notifications for a user
  Future<List<Map<String, dynamic>>> getUserNotifications({
    required int userId,
    String? type,
    int? isRead,
    int limit = 50,
  }) async {
    try {
      print('📝 Fetching notifications for user $userId');

      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (isRead != null) queryParams['is_read'] = isRead;
      queryParams['limit'] = limit;

      final response = await _dio.get(
        '/notifications/$userId',
        queryParameters: queryParams,
      );

      print('✅ Notifications response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final notifications = response.data['notifications'] as List;
        return notifications.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch notifications: ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ Dio error fetching notifications: ${e.message}');
      if (e.response != null) {
        print('Response: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<void> markNotificationRead(int notificationId) async {
    try {
      print('📝 Marking notification $notificationId as read');

      final response = await _dio.put(
        '/notifications/$notificationId/mark-read',
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to mark notification as read');
      }

      print('✅ Notification marked as read');
    } on DioException catch (e) {
      print('❌ Dio error marking notification as read: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsRead(int userId) async {
    try {
      print('📝 Marking all notifications as read for user $userId');

      final response = await _dio.put('/notifications/mark-all-read/$userId');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to mark all notifications as read');
      }

      print('✅ All notifications marked as read');
    } on DioException catch (e) {
      print('❌ Dio error marking all notifications as read: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      rethrow;
    }
  }
}
