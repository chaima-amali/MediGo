class NotificationItem {
  final int notificationId;
  final int userId;
  final int? planId;
  final int? reservationId;
  final int? medicineFindId;
  final int? dcId;
  final String? datetime;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  // Legacy fields for backward compatibility
  final int? occurrenceId;
  final String? medicineName;
  final String? time;
  final DateTime? date;
  final bool? isTaken;
  final String? importance;

  NotificationItem({
    required this.notificationId,
    required this.userId,
    this.planId,
    this.reservationId,
    this.medicineFindId,
    this.dcId,
    this.datetime,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.occurrenceId,
    this.medicineName,
    this.time,
    this.date,
    this.isTaken,
    this.importance,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      notificationId: json['notification_id'] as int,
      userId: json['user_id'] as int,
      planId: json['plan_id'] as int?,
      reservationId: json['reservation_id'] as int?,
      medicineFindId: json['medicine_find_id'] as int?,
      dcId: json['dc_id'] as int?,
      datetime: json['datetime'] as String?,
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      isRead: (json['is_read'] as int?) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  String get formattedTime {
    try {
      if (datetime != null && datetime!.isNotEmpty) {
        final dt = DateTime.parse(datetime!);
        int hour = dt.hour;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'pm' : 'am';

        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;

        return '$hour:$minute $period';
      } else if (time != null) {
        final parts = time!.split(':');
        if (parts.length < 2) return time!;

        int hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'pm' : 'am';

        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;

        return '$hour:$minute $period';
      }
      return createdAt.toString().split(' ')[1].substring(0, 5);
    } catch (_) {
      return time ?? '';
    }
  }

  // Get the message index (1-5) based on notification ID for localized message lookup
  int get messageIndex {
    return (notificationId % 5) + 1;
  }

  bool get isPast {
    final now = DateTime.now();
    if (datetime != null && datetime!.isNotEmpty) {
      try {
        final dt = DateTime.parse(datetime!);
        return dt.isBefore(now);
      } catch (_) {}
    }
    if (date != null && time != null) {
      try {
        final occDateTime = DateTime(
          date!.year,
          date!.month,
          date!.day,
          int.parse(time!.split(':')[0]),
          int.parse(time!.split(':')[1]),
        );
        return occDateTime.isBefore(now);
      } catch (_) {}
    }
    return createdAt.isBefore(now);
  }

  DateTime get notificationDate {
    if (datetime != null && datetime!.isNotEmpty) {
      try {
        return DateTime.parse(datetime!);
      } catch (_) {}
    }
    if (date != null) {
      return date!;
    }
    return createdAt;
  }
}

class GroupedNotifications {
  final String label;
  final List<NotificationItem> notifications;

  GroupedNotifications({required this.label, required this.notifications});
}
