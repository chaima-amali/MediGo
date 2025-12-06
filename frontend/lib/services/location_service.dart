import 'dart:math';
import '../data/models/pharmacy.dart';

class LocationService {
  // Calculate distance between two coordinates using Haversine formula
  // Returns distance in kilometers
  static double calculateDistance(
    double userLat,
    double userLon,
    double pharmacyLat,
    double pharmacyLon,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final dLat = _toRadians(pharmacyLat - userLat);
    final dLon = _toRadians(pharmacyLon - userLon);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userLat)) *
            cos(_toRadians(pharmacyLat)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return distance;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Get pharmacies sorted by distance from user location
  static List<PharmacyWithDistance> getPharmaciesByDistance({
    required double userLat,
    required double userLon,
    required List<Pharmacy> pharmacies,
    int? limit,
  }) {
    final pharmaciesWithDistance = pharmacies
        .where((pharmacy) => 
            pharmacy.latitude != null && pharmacy.longitude != null)
        .map((pharmacy) {
      final distance = calculateDistance(
        userLat,
        userLon,
        pharmacy.latitude!,
        pharmacy.longitude!,
      );
      return PharmacyWithDistance(pharmacy: pharmacy, distance: distance);
    }).toList();

    // Sort by distance (nearest first)
    pharmaciesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    if (limit != null && limit > 0) {
      return pharmaciesWithDistance.take(limit).toList();
    }

    return pharmaciesWithDistance;
  }

  // Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }
}

// Helper class to store pharmacy with calculated distance
class PharmacyWithDistance {
  final Pharmacy pharmacy;
  final double distance;

  PharmacyWithDistance({
    required this.pharmacy,
    required this.distance,
  });

  String get formattedDistance => LocationService.formatDistance(distance);
}