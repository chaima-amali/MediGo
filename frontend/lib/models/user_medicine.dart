class UserMedicine {
  final String userMedicineId;
  final String userId;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final String unit;
  final String frequency;
  final int timesPerDay;
  final String importance;
  final DateTime startDate;
  final DateTime? endDate;
  final String additionalNotes;
  final bool isActive;

  UserMedicine({
    required this.userMedicineId,
    required this.userId,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.unit,
    required this.frequency,
    required this.timesPerDay,
    required this.importance,
    required this.startDate,
    this.endDate,
    required this.additionalNotes,
    required this.isActive,
  });

  factory UserMedicine.fromJson(Map<String, dynamic> json) {
    return UserMedicine(
      userMedicineId: json['user_medicine_id'],
      userId: json['user_id'],
      medicineId: json['medicine_id'],
      medicineName: json['medicine_name'] ?? '',
      dosage: json['dosage'],
      unit: json['unit'],
      frequency: json['frequency'],
      timesPerDay: json['times_per_day'],
      importance: json['importance'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      additionalNotes: json['additional_notes'] ?? '',
      isActive: json['is_active'],
    );
  }
}
