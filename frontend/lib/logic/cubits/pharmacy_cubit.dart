// lib/cubits/pharmacy_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/pharmacy.dart';
import 'package:frontend/data/models/user.dart';
import 'dart:math';

// States
abstract class PharmacyState {}

class PharmacyInitial extends PharmacyState {}

class PharmacyLoading extends PharmacyState {}

class PharmacyLoaded extends PharmacyState {
  final List<PharmacyWithDistance> pharmacies;
  
  PharmacyLoaded(this.pharmacies);
}

class PharmacySearchResult extends PharmacyState {
  final List<Pharmacy> results;
  
  PharmacySearchResult(this.results);
}

class PharmacyError extends PharmacyState {
  final String message;
  
  PharmacyError(this.message);
}

// Helper class to hold pharmacy with distance
class PharmacyWithDistance {
  final Pharmacy pharmacy;
  final double distanceInKm;
  
  PharmacyWithDistance({
    required this.pharmacy,
    required this.distanceInKm,
  });
  
  String get formattedDistance {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)}m';
    }
    return '${distanceInKm.toStringAsFixed(1)}km';
  }
}

// Cubit
class PharmacyCubit extends Cubit<PharmacyState> {
  PharmacyCubit() : super(PharmacyInitial());
  
  // Dummy pharmacies list with Algiers coordinates
  final List<Pharmacy> _allPharmacies = [
    Pharmacy(
      pharmacyId: '1',
      name: 'Central Pharmacy',
      latitude: 36.7538,
      longitude: 3.0588,
      phone: '+213 21 123 456',
      openingHours: '08:00 - 20:00',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
    ),
    Pharmacy(
      pharmacyId: '2',
      name: 'City Care Pharmacy',
      latitude: 36.7628,
      longitude: 3.0508,
      phone: '+213 21 234 567',
      openingHours: '09:00 - 21:00',
      rating: 4.2,
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
    ),
    Pharmacy(
      pharmacyId: '3',
      name: 'Green Cross Pharmacy',
      latitude: 36.7438,
      longitude: 3.0688,
      phone: '+213 21 345 678',
      openingHours: '08:30 - 19:30',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
    ),
    Pharmacy(
      pharmacyId: '4',
      name: 'Health Plus Pharmacy',
      latitude: 36.7338,
      longitude: 3.0488,
      phone: '+213 21 456 789',
      openingHours: '07:00 - 22:00',
      rating: 4.3,
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
    ),
    Pharmacy(
      pharmacyId: '5',
      name: 'MediCare Pharmacy',
      latitude: 36.7638,
      longitude: 3.0788,
      phone: '+213 21 567 890',
      openingHours: '08:00 - 20:00',
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
    ),
    Pharmacy(
      pharmacyId: '6',
      name: 'Wellness Pharmacy',
      latitude: 36.7238,
      longitude: 3.0388,
      phone: '+213 21 678 901',
      openingHours: '09:00 - 19:00',
      rating: 4.4,
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
    ),
    Pharmacy(
      pharmacyId: '7',
      name: 'Quick Med Pharmacy',
      latitude: 36.7738,
      longitude: 3.0688,
      phone: '+213 21 789 012',
      openingHours: '24 Hours',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
    ),
    Pharmacy(
      pharmacyId: '8',
      name: 'Family Pharmacy',
      latitude: 36.7438,
      longitude: 3.0288,
      phone: '+213 21 890 123',
      openingHours: '08:00 - 20:00',
      rating: 4.1,
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
    ),
    Pharmacy(
      pharmacyId: '9',
      name: 'Care Plus Pharmacy',
      latitude: 36.7538,
      longitude: 3.0388,
      phone: '+213 21 901 234',
      openingHours: '08:00 - 21:00',
      rating: 4.4,
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
    ),
    Pharmacy(
      pharmacyId: '10',
      name: 'HealthFirst Pharmacy',
      latitude: 36.7338,
      longitude: 3.0688,
      phone: '+213 21 012 345',
      openingHours: '09:00 - 20:00',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&h=300&fit=crop',
    ),
  ];
  
  // Calculate distance using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // in kilometers
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    
    return distance;
  }
  
  double _toRadians(double degree) {
    return degree * pi / 180;
  }
  
  // Load and sort pharmacies by distance from user
  void loadNearestPharmacies(User user, {int? limit}) {
    emit(PharmacyLoading());
    
    try {
      // Check if user has location
      if (user.latitude == null || user.longitude == null) {
        // If no location, just show all pharmacies without distance calculation
        List<PharmacyWithDistance> pharmaciesWithDistance = _allPharmacies
            .map((pharmacy) => PharmacyWithDistance(
                  pharmacy: pharmacy,
                  distanceInKm: 0.0, // Default distance
                ))
            .toList();
        
        // Apply limit if specified
        if (limit != null && limit < pharmaciesWithDistance.length) {
          pharmaciesWithDistance = pharmaciesWithDistance.sublist(0, limit);
        }
        
        emit(PharmacyLoaded(pharmaciesWithDistance));
        return;
      }
      
      List<PharmacyWithDistance> pharmaciesWithDistance = [];
      
      for (var pharmacy in _allPharmacies) {
        if (pharmacy.latitude != null && pharmacy.longitude != null) {
          double distance = _calculateDistance(
            user.latitude!,
            user.longitude!,
            pharmacy.latitude!,
            pharmacy.longitude!,
          );
          
          pharmaciesWithDistance.add(
            PharmacyWithDistance(
              pharmacy: pharmacy,
              distanceInKm: distance,
            ),
          );
        }
      }
      
      // Sort by distance (nearest first)
      pharmaciesWithDistance.sort((a, b) => 
        a.distanceInKm.compareTo(b.distanceInKm)
      );
      
      // Apply limit if specified
      if (limit != null && limit < pharmaciesWithDistance.length) {
        pharmaciesWithDistance = pharmaciesWithDistance.sublist(0, limit);
      }
      
      emit(PharmacyLoaded(pharmaciesWithDistance));
    } catch (e) {
      emit(PharmacyError('Failed to load pharmacies: $e'));
    }
  }
  
  // Search pharmacies by name (case-insensitive)
  void searchPharmacies(String query) {
    if (query.trim().isEmpty) {
      emit(PharmacySearchResult([]));
      return;
    }
    
    try {
      String searchQuery = query.toLowerCase().trim();
      
      // Filter pharmacies that start with the search query OR match exactly
      List<Pharmacy> results = _allPharmacies.where((pharmacy) {
        String pharmacyName = pharmacy.name.toLowerCase();
        
        // Check if pharmacy name starts with query OR equals query
        return pharmacyName.startsWith(searchQuery) || 
               pharmacyName == searchQuery;
      }).toList();
      
      emit(PharmacySearchResult(results));
    } catch (e) {
      emit(PharmacyError('Search failed: $e'));
    }
  }
  
  // Get all pharmacies (for testing or display)
  List<Pharmacy> getAllPharmacies() {
    return List.from(_allPharmacies);
  }
  
  // Reset to initial state
  void reset() {
    emit(PharmacyInitial());
  }
}