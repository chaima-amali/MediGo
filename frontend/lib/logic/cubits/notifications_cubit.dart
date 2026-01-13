import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/repositories/occurrence_repository.dart';
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
  final OccurrenceRepository _repository;

  NotificationsCubit(this._repository) : super(NotificationsState());

  Future<void> loadNotifications() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get notifications for last 3 days
      final List<NotificationItem> allNotifications = [];

      for (int i = 0; i < 3; i++) {
        final date = today.subtract(Duration(days: i));
        final occurrences = await _repository.getOccurrencesByDate(date);

        for (final occurrence in occurrences) {
          // Create notification item
          final notification = NotificationItem(
            occurrenceId: occurrence.id ?? 0,
            medicineName: occurrence.medicineName ?? 'Medicine',
            time: occurrence.time,
            date: occurrence.date,
            isTaken: occurrence.isTaken == 1,
            importance: occurrence.importance,
          );

          // Only include past notifications (not future times)
          if (notification.isPast) {
            allNotifications.add(notification);
          }
        }
      }

      // Group notifications by day
      final grouped = _groupNotificationsByDay(allNotifications);

      emit(state.copyWith(groupedNotifications: grouped, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load notifications: $e',
        ),
      );
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
    };

    for (final notification in notifications) {
      final notifDate = DateTime(
        notification.date.year,
        notification.date.month,
        notification.date.day,
      );

      if (notifDate == today) {
        groups['Today']!.add(notification);
      } else if (notifDate == yesterday) {
        groups['Yesterday']!.add(notification);
      } else if (notifDate == dayBeforeYesterday) {
        groups['2 days ago']!.add(notification);
      }
    }

    // Sort notifications within each group by time (most recent first)
    for (final group in groups.values) {
      group.sort((a, b) {
        try {
          final aHour = int.parse(a.time.split(':')[0]);
          final aMinute = int.parse(a.time.split(':')[1]);
          final bHour = int.parse(b.time.split(':')[0]);
          final bMinute = int.parse(b.time.split(':')[1]);

          final aTotal = aHour * 60 + aMinute;
          final bTotal = bHour * 60 + bMinute;

          return bTotal.compareTo(aTotal); // Descending order
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
