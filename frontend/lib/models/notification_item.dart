class NotificationItem {
  final int occurrenceId;
  final String medicineName;
  final String time;
  final DateTime date;
  final bool isTaken;
  final String? importance;

  NotificationItem({
    required this.occurrenceId,
    required this.medicineName,
    required this.time,
    required this.date,
    required this.isTaken,
    this.importance,
  });

  String get formattedTime {
    try {
      final parts = time.split(':');
      if (parts.length < 2) return time;

      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'pm' : 'am';

      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '$hour:$minute $period';
    } catch (_) {
      return time;
    }
  }

  // Get the message index (1-5) based on occurrence ID for localized message lookup
  int get messageIndex {
    return (occurrenceId % 5) + 1;
  }

  bool get isPast {
    final now = DateTime.now();
    final occDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(time.split(':')[0]),
      int.parse(time.split(':')[1]),
    );
    return occDateTime.isBefore(now);
  }
}

class GroupedNotifications {
  final String label;
  final List<NotificationItem> notifications;

  GroupedNotifications({required this.label, required this.notifications});
}
