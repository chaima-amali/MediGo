import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/medicine_find_repo.dart';
import '../../data/repositories/pharmacy_medicine_repo.dart';
import '../../data/services/medicine_api_service.dart';

// States
abstract class MedicineSearchState extends Equatable {
  const MedicineSearchState();

  @override
  List<Object?> get props => [];
}

class MedicineSearchInitial extends MedicineSearchState {}

class MedicineSearchLoading extends MedicineSearchState {}

class MedicineSearchLoaded extends MedicineSearchState {
  final List<Map<String, dynamic>> results;
  final String searchQuery;

  const MedicineSearchLoaded(this.results, this.searchQuery);

  @override
  List<Object?> get props => [results, searchQuery];
}

class MedicineSearchEmpty extends MedicineSearchState {
  final String message;
  final String searchQuery;

  const MedicineSearchEmpty(this.message, this.searchQuery);

  @override
  List<Object?> get props => [message, searchQuery];
}

class MedicineSearchError extends MedicineSearchState {
  final String error;

  const MedicineSearchError(this.error);

  @override
  List<Object?> get props => [error];
}

// Cubit
class MedicineSearchCubit extends Cubit<MedicineSearchState> {
  final PharmacyMedicineRepository pharmacyMedicineRepository;
  final MedicineFindRepository medicineFindRepository;
  final MedicineApiService medicineApiService;

  MedicineSearchCubit({
    required this.pharmacyMedicineRepository,
    required this.medicineFindRepository,
    MedicineApiService? medicineApiService,
  }) : medicineApiService = medicineApiService ?? MedicineApiService(),
       super(MedicineSearchInitial()) {
    _init();
  }

  Future<void> _init() async {
    // Debug: Check if data exists
    try {
      final allInventory = await pharmacyMedicineRepository
          .getAllPharmacyMedicines();
      print('📊 Total pharmacy medicines in database: ${allInventory.length}');
    } catch (e) {
      print('❌ Error checking inventory: $e');
    }
  }

  // Search medicines and get pharmacies that have them
  Future<void> searchMedicine(String query) async {
    try {
      if (query.trim().isEmpty) {
        emit(MedicineSearchInitial());
        return;
      }

      emit(MedicineSearchLoading());
      print('🔍 Searching for medicine: $query');

      // First, try to search from remote API
      try {
        final remoteMedicines = await medicineApiService.searchMedicines(
          query,
          limit: 50,
        );

        if (remoteMedicines.isNotEmpty) {
          print('✅ Found ${remoteMedicines.length} medicines from remote API');
          emit(MedicineSearchLoaded(remoteMedicines, query));
          return;
        }
      } catch (apiError) {
        print('⚠️ Remote search failed, falling back to local: $apiError');
      }

      // Fallback: Search pharmacies that have this medicine locally
      final results = await pharmacyMedicineRepository
          .searchPharmaciesByMedicineName(query);

      print('✅ Found ${results.length} pharmacies with medicine: $query');

      if (results.isEmpty) {
        emit(MedicineSearchEmpty('No medicines found', query));
      } else {
        emit(MedicineSearchLoaded(results, query));
      }
    } catch (e) {
      print('❌ Error searching medicine: $e');
      emit(MedicineSearchError('Failed to search medicine: $e'));
    }
  }

  // Clear search
  void clearSearch() {
    emit(MedicineSearchInitial());
  }

  // Get all medicines (for autocomplete suggestions)
  Future<List<String>> getMedicineSuggestions(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final medicines = await medicineFindRepository.searchMedicinesByName(
        query,
      );
      return medicines.map((m) => m.name).toList();
    } catch (e) {
      print('❌ Error getting medicine suggestions: $e');
      return [];
    }
  }
}
