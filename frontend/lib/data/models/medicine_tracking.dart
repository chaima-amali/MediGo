class MedicineTracking {
  final int? id;
  final String name;
  final String type;
  final double dosage;
  final String unit;

  MedicineTracking({
    this.id,
    required this.name,
    required this.type,
    required this.dosage,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicine_track_id': id,
      'name': name,
      'type': type,
      'dosage': dosage,
      'unit': unit,
    };
  }

  factory MedicineTracking.fromMap(Map<String, dynamic> map) {
    // dosage may be stored as text or number; normalize to double
    double parsedDosage = 0.0;
    try {
      final d = map['dosage'];
      if (d is num)
        parsedDosage = d.toDouble();
      else if (d is String)
        parsedDosage = double.tryParse(d) ?? 0.0;
    } catch (_) {}

    return MedicineTracking(
      id: map['medicine_track_id'] ?? map['id'],
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      dosage: parsedDosage,
      unit: map['unit'] ?? '',
    );
  }
}
