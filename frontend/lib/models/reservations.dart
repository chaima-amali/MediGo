import 'package:flutter/material.dart';

class Reservation {
  final String reservationId;
  final String userId;
  final String pharmacyId;
  final String medicineId;
  final int quantity;
  final DateTime pickupDate;
  final TimeOfDay pickupTime;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime createdAt;

  Reservation({
    required this.reservationId,
    required this.userId,
    required this.pharmacyId,
    required this.medicineId,
    required this.quantity,
    required this.pickupDate,
    required this.pickupTime,
    required this.status,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final timeParts = json['pickup_time'].split(':');
    return Reservation(
      reservationId: json['reservation_id'],
      userId: json['user_id'],
      pharmacyId: json['pharmacy_id'],
      medicineId: json['medicine_id'],
      quantity: json['quantity'],
      pickupDate: DateTime.parse(json['pickup_date']),
      pickupTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

    String getPickupTimeFormatted() {
      final hour = pickupTime.hour > 12
          ? pickupTime.hour - 12
          : pickupTime.hour == 0
              ? 12
              : pickupTime.hour;
      final period = pickupTime.hour >= 12 ? 'PM' : 'AM';
      final minute = pickupTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    }
  }