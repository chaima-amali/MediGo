class Reservation {
  final int? reservationId;
  final int medicineFindId;
  final int userId;
  final String day;
  final String time;
  final int quantity;
  final String status;

  Reservation({
    this.reservationId,
    required this.medicineFindId,
    required this.userId,
    required this.day,
    required this.time,
    required this.quantity,
    required this.status,
  });

  Reservation copyWith({
    int? reservationId,
    int? medicineFindId,
    int? userId,
    String? day,
    String? time,
    int? quantity,
    String? status,
  }) {
    return Reservation(
      reservationId: reservationId ?? this.reservationId,
      medicineFindId: medicineFindId ?? this.medicineFindId,
      userId: userId ?? this.userId,
      day: day ?? this.day,
      time: time ?? this.time,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
    );
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      reservationId: map['reservation_id'] as int?,
      medicineFindId: map['medicine_find_id'] as int,
      userId: map['user_id'] as int,
      day: map['day'] as String,
      time: map['time'] as String,
      quantity: map['quantity'] as int,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reservation_id': reservationId,
      'medicine_find_id': medicineFindId,
      'user_id': userId,
      'day': day,
      'time': time,
      'quantity': quantity,
      'status': status,
    };
  }
}