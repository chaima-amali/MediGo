class MedicinePlan {
  final int? planId;
  final int medicineTrackId;
  final int userId;
  final String importance;
  final String startDate;
  final String endDate;
  final String frequencyType;

  MedicinePlan({
    this.planId,
    required this.medicineTrackId,
    required this.userId,
    required this.importance,
    required this.startDate,
    required this.endDate,
    required this.frequencyType,
  });

  MedicinePlan copyWith({
    int? planId,
    int? medicineTrackId,
    int? userId,
    String? importance,
    String? startDate,
    String? endDate,
    String? frequencyType,
  }) {
    return MedicinePlan(
      planId: planId ?? this.planId,
      medicineTrackId: medicineTrackId ?? this.medicineTrackId,
      userId: userId ?? this.userId,
      importance: importance ?? this.importance,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      frequencyType: frequencyType ?? this.frequencyType,
    );
  }

  factory MedicinePlan.fromMap(Map<String, dynamic> map) {
    return MedicinePlan(
      planId: map['plan_id'] as int?,
      medicineTrackId: map['medicine_track_id'] as int,
      userId: map['user_id'] as int,
      importance: map['importance'] as String,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      frequencyType: map['frequency_type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan_id': planId,
      'medicine_track_id': medicineTrackId,
      'user_id': userId,
      'importance': importance,
      'start_date': startDate,
      'end_date': endDate,
      'frequency_type': frequencyType,
    };
  }
}