class Reservation {
  final int? reservationId;
  final int medicineFindId;
  final int userId;
  final int? pharmacyId;
  final String? medicineName;
  final String day;
  final String time;
  final int quantity;
  final String status;
  final String? createdAt;

  Reservation({
    this.reservationId,
    required this.medicineFindId,
    required this.userId,
    this.pharmacyId,
    this.medicineName,
    required this.day,
    required this.time,
    required this.quantity,
    required this.status,
    this.createdAt,
  });

  Reservation copyWith({
    int? reservationId,
    int? medicineFindId,
    int? userId,
    int? pharmacyId,
    String? medicineName,
    String? day,
    String? time,
    int? quantity,
    String? status,
    String? createdAt,
  }) {
    return Reservation(
      reservationId: reservationId ?? this.reservationId,
      medicineFindId: medicineFindId ?? this.medicineFindId,
      userId: userId ?? this.userId,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      medicineName: medicineName ?? this.medicineName,
      day: day ?? this.day,
      time: time ?? this.time,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      reservationId: map['reservation_id'] as int?,
      medicineFindId: map['medicine_find_id'] as int,
      userId: map['user_id'] as int,
      pharmacyId: map['pharmacy_id'] as int?,
      medicineName: map['medicine_name'] as String?,
      day: map['day'] as String,
      time: map['time'] as String,
      quantity: map['quantity'] as int,
      status: map['status'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reservation_id': reservationId,
      'medicine_find_id': medicineFindId,
      'user_id': userId,
      'pharmacy_id': pharmacyId,
      'medicine_name': medicineName,
      'day': day,
      'time': time,
      'quantity': quantity,
      'status': status,
      'created_at': createdAt,
    };
  }
}
