import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/services/api/medicine_search_api_service.dart';
import 'package:dio/dio.dart';

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
  final MedicineSearchApiService _apiService;

  MedicineSearchCubit({
    MedicineSearchApiService? apiService,
  })  : _apiService = apiService ?? MedicineSearchApiService(),
        super(MedicineSearchInitial());

  // Search medicines using remote API (Supabase data via Flask backend)
  Future<void> searchMedicine(String query) async {
    try {
      if (query.trim().isEmpty) {
        emit(MedicineSearchInitial());
        return;
      }

      emit(MedicineSearchLoading());
      print('🔍 [API] Searching for medicine: $query');

      // Call Flask backend API
      final response = await _apiService.searchMedicines(query);
      
      final results = (response['data'] as List<dynamic>?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [];

      print('✅ [API] Found ${results.length} results for: $query');

      if (results.isEmpty) {
        emit(
          MedicineSearchEmpty(
            'No pharmacies found with this medicine in stock',
            query,
          ),
        );
      } else {
        emit(MedicineSearchLoaded(results, query));
      }
    } on DioException catch (e) {
      print('❌ [API] Network error: ${e.message}');
      emit(MedicineSearchError('Connection failed. Check if backend is running.'));
    } catch (e) {
      print('❌ [API] Error searching medicine: $e');
      emit(MedicineSearchError('Failed to search medicine: $e'));
    }
  }

  // Request "Notify Me" when medicine not found
  Future<void> notifyMeWhenAvailable(int userId, String medicineName) async {
    try {
      print('🔔 [API] Recording notify-me request for: $medicineName');
      await _apiService.notifyMe(
        userId: userId,
        medicineName: medicineName,
      );
      print('✅ [API] Notify-me request recorded');
    } catch (e) {
      print('❌ [API] Failed to record notify-me: $e');
      rethrow;
    }
  }

  // Clear search
  void clearSearch() {
    emit(MedicineSearchInitial());
  }

  // Get medicine suggestions (for autocomplete) - using API
  Future<List<String>> getMedicineSuggestions(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      // Use the search API to get suggestions
      final response = await _apiService.searchMedicines(query);
      final results = (response['data'] as List<dynamic>?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [];
      
      // Extract unique medicine names
      final Set<String> uniqueNames = {};
      for (var result in results) {
        final name = result['medicine_name'] as String?;
        if (name != null) {
          uniqueNames.add(name);
        }
      }
      
      return uniqueNames.toList();
    } catch (e) {
      print('❌ [API] Error getting medicine suggestions: $e');
      return [];
    }
  }
}
