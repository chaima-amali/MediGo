class MedicinePlan {
  final int? id;
  final int trackingId;
  final int? userId;

  final String importance;
  final DateTime startDate;
  final DateTime endDate;

  final String frequencyType;
  final int? intervalDays;
  final List<String>? weekdays;
  final List<int>? monthDays;
  final List<String>? customDates;

  MedicinePlan({
    this.id,
    required this.trackingId,
    this.userId,
    required this.importance,
    required this.startDate,
    required this.endDate,
    required this.frequencyType,
    this.intervalDays,
    this.weekdays,
    this.monthDays,
    this.customDates,
  });
  
  MedicinePlan copyWith({
  int? id,
  int? trackingId,
  int? userId,
  String? importance,
  DateTime? startDate,
  DateTime? endDate,
  String? frequencyType,
  int? intervalDays,
  List<String>? weekdays,
  List<int>? monthDays,
  List<String>? customDates,
}) {
  return MedicinePlan(
    id: id ?? this.id,
    trackingId: trackingId ?? this.trackingId,
    userId: userId ?? this.userId,
    importance: importance ?? this.importance,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    frequencyType: frequencyType ?? this.frequencyType,
    intervalDays: intervalDays ?? this.intervalDays,
    weekdays: weekdays ?? this.weekdays,
    monthDays: monthDays ?? this.monthDays,
    customDates: customDates ?? this.customDates,
  );
}


  factory MedicinePlan.fromMap(Map<String, dynamic> map) {
    return MedicinePlan(
      id: map['plan_id'],
      trackingId: map['medicine_track_id'],   // ✅ FIXED
      userId: map['user_id'],

      importance: map['importance'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),

      frequencyType: map['frequency_type'],
      intervalDays: map['interval_days'],

      weekdays: map['weekdays'] != null
          ? (map['weekdays'] as String).split(',')
          : null,

      monthDays: map['month_days'] != null
          ? (map['month_days'] as String)
              .split(',')
              .map((e) => int.parse(e))
              .toList()
          : null,

      customDates: map['custom_dates'] != null
          ? (map['custom_dates'] as String).split(',')
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan_id': id,
      'medicine_track_id': trackingId,   // ✅ FIXED
      'user_id': userId,
      'importance': importance,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'frequency_type': frequencyType,
      'interval_days': intervalDays,
      'weekdays': weekdays?.join(','),
      'month_days': monthDays?.join(','),
      'custom_dates': customDates?.join(','),
    };
  }
}
