import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/repositories/notification_repository.dart';
import '../../data/models/notification_item.dart';

class NotificationsState {
  final List<GroupedNotifications> groupedNotifications;
  final bool isLoading;
  final String? error;

  NotificationsState({
    this.groupedNotifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<GroupedNotifications>? groupedNotifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      groupedNotifications: groupedNotifications ?? this.groupedNotifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _repository;
  final int userId;

  NotificationsCubit(this._repository, this.userId)
    : super(NotificationsState());

  Future<void> loadNotifications() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      print('🔍 Fetching notifications for user $userId...');
      
      // Fetch notifications from Supabase API
      final notificationsData = await _repository.getUserNotifications(
        userId: userId,
        limit: 100,
      );

      print('✅ Fetched ${notificationsData.length} notifications from API');

      // Convert to NotificationItem objects
      final List<NotificationItem> allNotifications = notificationsData
          .map((data) {
            final notif = NotificationItem.fromJson(data);
            print('   📬 Notification ${notif.notificationId}: ${notif.type} - ${notif.createdAt}');
            return notif;
          })
          .toList();

      // Sort by created_at descending (newest first)
      allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Group notifications by day
      final grouped = _groupNotificationsByDay(allNotifications);
      
      print('📊 Grouped into ${grouped.length} groups:');
      for (final group in grouped) {
        print('   - ${group.label}: ${group.notifications.length} notifications');
      }

      emit(state.copyWith(groupedNotifications: grouped, isLoading: false));
    } catch (e) {
      print('❌ Error loading notifications: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load notifications: $e',
        ),
      );
    }
  }

  Future<void> markNotificationRead(int notificationId) async {
    try {
      await _repository.markNotificationRead(notificationId);
      // Reload notifications to reflect the change
      await loadNotifications();
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _repository.markAllNotificationsRead(userId);
      // Reload notifications to reflect the change
      await loadNotifications();
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  List<GroupedNotifications> _groupNotificationsByDay(
    List<NotificationItem> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));

    final Map<String, List<NotificationItem>> groups = {
      'Today': [],
      'Yesterday': [],
      '2 days ago': [],
      'Earlier': [], // Add group for older notifications
    };

    for (final notification in notifications) {
      final notifDate = DateTime(
        notification.notificationDate.year,
        notification.notificationDate.month,
        notification.notificationDate.day,
      );

      if (notifDate == today) {
        groups['Today']!.add(notification);
      } else if (notifDate == yesterday) {
        groups['Yesterday']!.add(notification);
      } else if (notifDate == dayBeforeYesterday) {
        groups['2 days ago']!.add(notification);
      } else {
        // Add all older notifications to 'Earlier' group
        groups['Earlier']!.add(notification);
      }
    }

    // Sort notifications within each group by time (most recent first)
    for (final group in groups.values) {
      group.sort((a, b) {
        try {
          // Use datetime for sorting if available, otherwise fallback to time
          if (a.datetime != null && b.datetime != null) {
            return DateTime.parse(
              b.datetime!,
            ).compareTo(DateTime.parse(a.datetime!));
          }

          // Use time field if available
          if (a.time != null && b.time != null) {
            final aHour = int.parse(a.time!.split(':')[0]);
            final aMinute = int.parse(a.time!.split(':')[1]);
            final bHour = int.parse(b.time!.split(':')[0]);
            final bMinute = int.parse(b.time!.split(':')[1]);

            final aTotal = aHour * 60 + aMinute;
            final bTotal = bHour * 60 + bMinute;

            return bTotal.compareTo(aTotal); // Descending order
          }

          // Fallback to createdAt
          return b.createdAt.compareTo(a.createdAt);
        } catch (_) {
          return 0;
        }
      });
    }

    // Create grouped list (only include groups that have notifications)
    final result = <GroupedNotifications>[];
    for (final entry in groups.entries) {
      if (entry.value.isNotEmpty) {
        result.add(
          GroupedNotifications(label: entry.key, notifications: entry.value),
        );
      }
    }

    return result;
  }
}
