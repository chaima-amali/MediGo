class MedicineProgress {
  final int? planId;
  final int? medicineId; // optional link to medicine_tracking id
  final String name;
  final String? color; // hex or named color string
  final DateTime? startDate;
  final DateTime? endDate;
  final double progress; // 0.0 - 1.0

  MedicineProgress({
    required this.planId,
    this.medicineId,
    required this.name,
    this.color,
    required this.startDate,
    required this.endDate,
    required this.progress,
  });
}
