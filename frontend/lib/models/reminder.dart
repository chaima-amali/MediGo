import 'package:flutter/material.dart';

class Reminder {
  final String reminderId;
  final String userMedicineId;
  final TimeOfDay reminderTime;
  final bool isEnabled;

  Reminder({
    required this.reminderId,
    required this.userMedicineId,
    required this.reminderTime,
    required this.isEnabled,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final timeParts = json['reminder_time'].split(':');
    return Reminder(
      reminderId: json['reminder_id'],
      userMedicineId: json['user_medicine_id'],
      reminderTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      isEnabled: json['is_enabled'],
    );
  }

  String getFormattedTime() {
    final hour = reminderTime.hour.toString().padLeft(2, '0');
    final minute = reminderTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
