class MedicineIntakeLog {
  final String logId;
  final String userMedicineId;
  final String medicineName;
  final String dosage;
  final String unit;
  final DateTime scheduledTime;
  final DateTime? actualTime;
  final String status; // taken, missed, skipped, pending
  final String notes;
  final String additionalNotes;

  MedicineIntakeLog({
    required this.logId,
    required this.userMedicineId,
    required this.medicineName,
    required this.dosage,
    required this.unit,
    required this.scheduledTime,
    this.actualTime,
    required this.status,
    required this.notes,
    required this.additionalNotes,
  });

  factory MedicineIntakeLog.fromJson(Map<String, dynamic> json) {
    return MedicineIntakeLog(
      logId: json['log_id'],
      userMedicineId: json['user_medicine_id'],
      medicineName: json['medicine_name'] ?? '',
      dosage: json['dosage']?.toString() ?? '',
      unit: json['unit'] ?? '',
      scheduledTime: DateTime.parse(json['scheduled_time']),
      actualTime: json['actual_time'] != null
          ? DateTime.parse(json['actual_time'])
          : null,
      status: json['status'],
      notes: json['notes'] ?? '',
      additionalNotes: json['additional_notes'] ?? '',
    );
  }

  String getTimeLabel() {
    final hour = scheduledTime.hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  bool isTaken() => status == 'taken';
  bool isMissed() => status == 'missed';
  bool isPending() => status == 'pending';
}