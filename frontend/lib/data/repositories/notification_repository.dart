import '../services/notification_api_service.dart';

class NotificationRepository {
  final NotificationApiService _apiService;

  NotificationRepository({NotificationApiService? apiService})
    : _apiService = apiService ?? NotificationApiService();

  /// Get all notifications for a user
  Future<List<Map<String, dynamic>>> getUserNotifications({
    required int userId,
    String? type,
    bool? isRead,
    int limit = 50,
  }) async {
    try {
      return await _apiService.getUserNotifications(
        userId: userId,
        type: type,
        isRead: isRead == null ? null : (isRead ? 1 : 0),
        limit: limit,
      );
    } catch (e) {
      print('❌ Error in NotificationRepository.getUserNotifications: $e');
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<void> markNotificationRead(int notificationId) async {
    try {
      await _apiService.markNotificationRead(notificationId);
    } catch (e) {
      print('❌ Error in NotificationRepository.markNotificationRead: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsRead(int userId) async {
    try {
      await _apiService.markAllNotificationsRead(userId);
    } catch (e) {
      print('❌ Error in NotificationRepository.markAllNotificationsRead: $e');
      rethrow;
    }
  }
}
