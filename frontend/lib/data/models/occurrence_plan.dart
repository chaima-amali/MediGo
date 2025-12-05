class OccurrencePlan {
  final int? occurrenceId;
  final int planId;
  final String dayOfWeek;
  final String time;
  final int intervalValue;
  final String intervalUnit;

  OccurrencePlan({
    this.occurrenceId,
    required this.planId,
    required this.dayOfWeek,
    required this.time,
    required this.intervalValue,
    required this.intervalUnit,
  });

  OccurrencePlan copyWith({
    int? occurrenceId,
    int? planId,
    String? dayOfWeek,
    String? time,
    int? intervalValue,
    String? intervalUnit,
  }) {
    return OccurrencePlan(
      occurrenceId: occurrenceId ?? this.occurrenceId,
      planId: planId ?? this.planId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      time: time ?? this.time,
      intervalValue: intervalValue ?? this.intervalValue,
      intervalUnit: intervalUnit ?? this.intervalUnit,
    );
  }

  factory OccurrencePlan.fromMap(Map<String, dynamic> map) {
    return OccurrencePlan(
      occurrenceId: map['occurrence_id'] as int?,
      planId: map['plan_id'] as int,
      dayOfWeek: map['day_of_week'] as String,
      time: map['time'] as String,
      intervalValue: map['interval_value'] as int,
      intervalUnit: map['interval_unit'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'occurrence_id': occurrenceId,
      'plan_id': planId,
      'day_of_week': dayOfWeek,
      'time': time,
      'interval_value': intervalValue,
      'interval_unit': intervalUnit,
    };
  }
}
