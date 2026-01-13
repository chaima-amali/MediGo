import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/pharmacy.dart';
import '../../data/repositories/pharmacy_repo.dart';

// States
abstract class PharmacyState extends Equatable {
  const PharmacyState();

  @override
  List<Object?> get props => [];
}

class PharmacyInitial extends PharmacyState {}

class PharmacyLoading extends PharmacyState {}

class PharmacyLoaded extends PharmacyState {
  final Pharmacy pharmacy;

  const PharmacyLoaded(this.pharmacy);

  @override
  List<Object?> get props => [pharmacy];
}

class PharmacyListLoaded extends PharmacyState {
  final List<Pharmacy> pharmacies;

  const PharmacyListLoaded(this.pharmacies);

  @override
  List<Object?> get props => [pharmacies];
}

class PharmacyOperationSuccess extends PharmacyState {
  final String message;

  const PharmacyOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PharmacyError extends PharmacyState {
  final String error;

  const PharmacyError(this.error);

  @override
  List<Object?> get props => [error];
}

// Cubit
class PharmacyCubit extends Cubit<PharmacyState> {
  final PharmacyRepository pharmacyRepository;

  PharmacyCubit(this.pharmacyRepository) : super(PharmacyInitial());

  // Create new pharmacy
  Future<void> createPharmacy(Pharmacy pharmacy) async {
    try {
      emit(PharmacyLoading());
      print('💾 Creating pharmacy: ${pharmacy.name}');

      final pharmacyId = await pharmacyRepository.insertPharmacy(pharmacy);
      print('✅ Pharmacy created with ID: $pharmacyId');

      emit(const PharmacyOperationSuccess('Pharmacy created successfully'));

      // Reload all pharmacies
      await loadAllPharmacies();
    } catch (e) {
      print('❌ Error creating pharmacy: $e');
      emit(PharmacyError('Failed to create pharmacy: $e'));
    }
  }

  // Load pharmacy by ID
  Future<void> loadPharmacyById(int pharmacyId) async {
    try {
      emit(PharmacyLoading());
      print('🔍 Loading pharmacy with ID: $pharmacyId');

      final pharmacy = await pharmacyRepository.getPharmacyById(pharmacyId);
      if (pharmacy != null) {
        print('✅ Pharmacy loaded: ${pharmacy.name}');
        emit(PharmacyLoaded(pharmacy));
      } else {
        print('❌ Pharmacy not found');
        emit(const PharmacyError('Pharmacy not found'));
      }
    } catch (e) {
      print('❌ Error loading pharmacy: $e');
      emit(PharmacyError('Failed to load pharmacy: $e'));
    }
  }

  // Load all pharmacies
  Future<void> loadAllPharmacies() async {
    try {
      emit(PharmacyLoading());
      print('📋 Loading all pharmacies');

      final pharmacies = await pharmacyRepository.getAllPharmacies();
      print('✅ Loaded ${pharmacies.length} pharmacies');

      emit(PharmacyListLoaded(pharmacies));
    } catch (e) {
      print('❌ Error loading pharmacies: $e');
      emit(PharmacyError('Failed to load pharmacies: $e'));
    }
  }

  // Search pharmacies by name
  Future<void> searchPharmacies(String query) async {
    try {
      emit(PharmacyLoading());
      print('🔍 Searching pharmacies with query: $query');

      if (query.trim().isEmpty) {
        // If query is empty, load all pharmacies
        await loadAllPharmacies();
        return;
      }

      final pharmacies = await pharmacyRepository.searchPharmaciesByName(query);
      print('✅ Found ${pharmacies.length} pharmacies');

      emit(PharmacyListLoaded(pharmacies));
    } catch (e) {
      print('❌ Error searching pharmacies: $e');
      emit(PharmacyError('Failed to search pharmacies: $e'));
    }
  }

  // Get pharmacies near location
  Future<void> getPharmaciesNearLocation(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    try {
      emit(PharmacyLoading());
      print(
        '📍 Getting pharmacies near ($latitude, $longitude) within $radiusInKm km',
      );

      final pharmacies = await pharmacyRepository.getPharmaciesNearLocation(
        latitude,
        longitude,
        radiusInKm,
      );
      print('✅ Found ${pharmacies.length} pharmacies nearby');

      emit(PharmacyListLoaded(pharmacies));
    } catch (e) {
      print('❌ Error getting nearby pharmacies: $e');
      emit(PharmacyError('Failed to get nearby pharmacies: $e'));
    }
  }

  // Update pharmacy
  Future<void> updatePharmacy(Pharmacy pharmacy) async {
    try {
      emit(PharmacyLoading());
      print('🔄 Updating pharmacy: ${pharmacy.name}');

      final rowsAffected = await pharmacyRepository.updatePharmacy(pharmacy);
      if (rowsAffected > 0) {
        print('✅ Pharmacy updated successfully');
        emit(const PharmacyOperationSuccess('Pharmacy updated successfully'));

        // Reload the updated pharmacy
        await loadPharmacyById(pharmacy.pharmacyId!);
      } else {
        print('❌ Pharmacy not found');
        emit(const PharmacyError('Pharmacy not found'));
      }
    } catch (e) {
      print('❌ Error updating pharmacy: $e');
      emit(PharmacyError('Failed to update pharmacy: $e'));
    }
  }

  // Update pharmacy rating
  Future<void> updatePharmacyRating(int pharmacyId, double rating) async {
    try {
      emit(PharmacyLoading());
      print('⭐ Updating pharmacy rating to $rating');

      final rowsAffected = await pharmacyRepository.updatePharmacyRating(
        pharmacyId,
        rating,
      );
      if (rowsAffected > 0) {
        print('✅ Pharmacy rating updated successfully');
        emit(const PharmacyOperationSuccess('Rating updated successfully'));

        // Reload the updated pharmacy
        await loadPharmacyById(pharmacyId);
      } else {
        print('❌ Pharmacy not found');
        emit(const PharmacyError('Pharmacy not found'));
      }
    } catch (e) {
      print('❌ Error updating pharmacy rating: $e');
      emit(PharmacyError('Failed to update rating: $e'));
    }
  }

  // Delete pharmacy
  Future<void> deletePharmacy(int pharmacyId) async {
    try {
      emit(PharmacyLoading());
      print('🗑️ Deleting pharmacy with ID: $pharmacyId');

      final rowsAffected = await pharmacyRepository.deletePharmacy(pharmacyId);
      if (rowsAffected > 0) {
        print('✅ Pharmacy deleted successfully');
        emit(const PharmacyOperationSuccess('Pharmacy deleted successfully'));

        // Reload all pharmacies
        await loadAllPharmacies();
      } else {
        print('❌ Pharmacy not found');
        emit(const PharmacyError('Pharmacy not found'));
      }
    } catch (e) {
      print('❌ Error deleting pharmacy: $e');
      emit(PharmacyError('Failed to delete pharmacy: $e'));
    }
  }

  // Check if pharmacy exists
  Future<bool> checkPharmacyExists(int pharmacyId) async {
    try {
      print('🔍 Checking if pharmacy exists: $pharmacyId');
      final exists = await pharmacyRepository.pharmacyExists(pharmacyId);
      print('✅ Pharmacy exists: $exists');
      return exists;
    } catch (e) {
      print('❌ Error checking pharmacy existence: $e');
      return false;
    }
  }
}
