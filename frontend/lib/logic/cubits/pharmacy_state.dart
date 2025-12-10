import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/pharmacy.dart';

abstract class PharmacyState extends Equatable {
  const PharmacyState();

  @override
  List<Object?> get props => [];
}

class PharmacyInitial extends PharmacyState {}

class PharmacyLoading extends PharmacyState {}

class PharmacyLoaded extends PharmacyState {
  final List<PharmacyWithDistance> nearbyPharmacies;
  final List<Pharmacy> allPharmacies;

  const PharmacyLoaded({
    required this.nearbyPharmacies,
    required this.allPharmacies,
  });

  @override
  List<Object?> get props => [nearbyPharmacies, allPharmacies];
}

class PharmacySearchResults extends PharmacyState {
  final List<Pharmacy> searchResults;

  const PharmacySearchResults({required this.searchResults});

  @override
  List<Object?> get props => [searchResults];
}

class PharmacyError extends PharmacyState {
  final String message;

  const PharmacyError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Helper class to hold pharmacy with calculated distance
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
    } else {
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }
}