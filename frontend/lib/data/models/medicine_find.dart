class MedicineFind {
  final int? medicineFindId;
  final int userId;
  final String name;
  final String timestamp;

  MedicineFind({
    this.medicineFindId,
    required this.userId,
    required this.name,
    required this.timestamp,
  });

  MedicineFind copyWith({
    int? medicineFindId,
    int? userId,
    String? name,
    String? timestamp,
  }) {
    return MedicineFind(
      medicineFindId: medicineFindId ?? this.medicineFindId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory MedicineFind.fromMap(Map<String, dynamic> map) {
    return MedicineFind(
      medicineFindId: map['medicine_find_id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      timestamp: map['timestamp'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicine_find_id': medicineFindId,
      'user_id': userId,
      'name': name,
      'timestamp': timestamp,
    };
  }
}