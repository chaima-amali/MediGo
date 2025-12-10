// lib/data/models/pharmacy_with_distance.dart
import 'package:frontend/data/models/pharmacy.dart';

class PharmacyWithDistance {
  final Pharmacy pharmacy;
  final double distanceInKm;

  PharmacyWithDistance({
    required this.pharmacy,
    required this.distanceInKm,
  });

  String get formattedDistance {
    if (distanceInKm < 1) {
      final distanceInMeters = (distanceInKm * 1000).round();
      return '${distanceInMeters}m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }
}