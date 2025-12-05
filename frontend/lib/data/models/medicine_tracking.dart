class MedicineTracking {
  final int? medicineTrackId;
  final int userId;
  final String name;
  final String type;
  final String dosage;

  MedicineTracking({
    this.medicineTrackId,
    required this.userId,
    required this.name,
    required this.type,
    required this.dosage,
  });

  MedicineTracking copyWith({
    int? medicineTrackId,
    int? userId,
    String? name,
    String? type,
    String? dosage,
  }) {
    return MedicineTracking(
      medicineTrackId: medicineTrackId ?? this.medicineTrackId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      dosage: dosage ?? this.dosage,
    );
  }

  factory MedicineTracking.fromMap(Map<String, dynamic> map) {
    return MedicineTracking(
      medicineTrackId: map['medicine_track_id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      dosage: map['dosage'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicine_track_id': medicineTrackId,
      'user_id': userId,
      'name': name,
      'type': type,
      'dosage': dosage,
    };
  }
}
