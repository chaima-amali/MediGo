class MedicationIntakeLog {
  final int? id;
  final int? occurrenceId;
  final int medicineTrackId;
  final DateTime scheduledDate;
  final String scheduledTime;
  final DateTime? actualTime;
  final String status; // 'taken', 'missed', 'skipped'
  final String? dosage;
  final String? notes;
  final DateTime? createdAt;

  MedicationIntakeLog({
    this.id,
    this.occurrenceId,
    required this.medicineTrackId,
    required this.scheduledDate,
    required this.scheduledTime,
    this.actualTime,
    required this.status,
    this.dosage,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'log_id': id,
      'occurrence_id': occurrenceId,
      'medicine_track_id': medicineTrackId,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'scheduled_time': scheduledTime,
      'actual_time': actualTime?.toIso8601String(),
      'status': status,
      'dosage': dosage,
      'notes': notes,
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory MedicationIntakeLog.fromMap(Map<String, dynamic> map) {
    return MedicationIntakeLog(
      id: map['log_id'],
      occurrenceId: map['occurrence_id'],
      medicineTrackId: map['medicine_track_id'],
      scheduledDate: DateTime.parse(map['scheduled_date']),
      scheduledTime: map['scheduled_time'],
      actualTime: map['actual_time'] != null
          ? DateTime.parse(map['actual_time'])
          : null,
      status: map['status'],
      dosage: map['dosage'],
      notes: map['notes'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  MedicationIntakeLog copyWith({
    int? id,
    int? occurrenceId,
    int? medicineTrackId,
    DateTime? scheduledDate,
    String? scheduledTime,
    DateTime? actualTime,
    String? status,
    String? dosage,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicationIntakeLog(
      id: id ?? this.id,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      medicineTrackId: medicineTrackId ?? this.medicineTrackId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTime: actualTime ?? this.actualTime,
      status: status ?? this.status,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
