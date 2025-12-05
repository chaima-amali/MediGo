class DailyDosageChecking {
  final int? dcId;
  final int planId;
  final String doseDate;
  final String doseTime;
  final String status;
  final String takenAt;

  DailyDosageChecking({
    this.dcId,
    required this.planId,
    required this.doseDate,
    required this.doseTime,
    required this.status,
    required this.takenAt,
  });

  DailyDosageChecking copyWith({
    int? dcId,
    int? planId,
    String? doseDate,
    String? doseTime,
    String? status,
    String? takenAt,
  }) {
    return DailyDosageChecking(
      dcId: dcId ?? this.dcId,
      planId: planId ?? this.planId,
      doseDate: doseDate ?? this.doseDate,
      doseTime: doseTime ?? this.doseTime,
      status: status ?? this.status,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  factory DailyDosageChecking.fromMap(Map<String, dynamic> map) {
    return DailyDosageChecking(
      dcId: map['dc_id'] as int?,
      planId: map['plan_id'] as int,
      doseDate: map['dose_date'] as String,
      doseTime: map['dose_time'] as String,
      status: map['status'] as String,
      takenAt: map['taken_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dc_id': dcId,
      'plan_id': planId,
      'dose_date': doseDate,
      'dose_time': doseTime,
      'status': status,
      'taken_at': takenAt,
    };
  }
}
