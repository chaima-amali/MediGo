import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/occurrence_repository.dart';
import '../../data/models/occurrence_plan.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../data/models/medicine_tracking.dart';
import '../../data/models/medicine_plan.dart';

class TrackingState {
  final bool loading;
  final List<Occurrence> occurrences;
  final DateTime selectedDate;

  TrackingState({
    required this.loading,
    required this.occurrences,
    required this.selectedDate,
  });

  TrackingState copyWith({
    bool? loading,
    List<Occurrence>? occurrences,
    DateTime? selectedDate,
  }) {
    return TrackingState(
      loading: loading ?? this.loading,
      occurrences: occurrences ?? this.occurrences,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class TrackingCubit extends Cubit<TrackingState> {
  final OccurrenceRepository repository;

  TrackingCubit(this.repository)
    : super(
        TrackingState(
          loading: false,
          occurrences: [],
          selectedDate: DateTime.now(),
        ),
      );

  /// Get current user ID from SharedPreferences
  Future<int?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('user_id');
    } catch (e) {
      // ignore: avoid_print
      print('TrackingCubit._getCurrentUserId error: $e');
      return null;
    }
  }

  Future<void> loadDay(DateTime date) async {
    print('🔄 TrackingCubit.loadDay: Starting load for date=$date');
    emit(state.copyWith(loading: true, selectedDate: date));

    final userId = await _getCurrentUserId();
    print('👤 TrackingCubit.loadDay: userId=$userId');

    final result = await repository.getOccurrencesByDate(date, userId: userId);
    print('📊 TrackingCubit.loadDay: Loaded ${result.length} occurrences');

    emit(state.copyWith(loading: false, occurrences: result));
    print(
      '✅ TrackingCubit.loadDay: State emitted with ${result.length} occurrences',
    );
  }

  /// Mark an occurrence as taken and refresh the day.
  Future<bool> markTaken(int occurrenceId, int isTaken) async {
    final ok = await repository.updateOccurrenceTaken(occurrenceId, isTaken);
    if (ok) await loadDay(state.selectedDate);
    return ok;
  }

  /// Delete an occurrence and refresh the day.
  Future<bool> deleteOccurrence(int occurrenceId) async {
    final ok = await repository.deleteOccurrence(occurrenceId);
    if (ok) await loadDay(state.selectedDate);
    return ok;
  }

  /// Delete all occurrences of a medicine at a specific time and refresh the day.
  Future<bool> deleteOccurrencesByTime(int planId, String time) async {
    final ok = await repository.deleteOccurrencesByPlanTime(planId, time);
    if (ok) await loadDay(state.selectedDate);
    return ok;
  }

  /// Save a new medicine (tracking + plan + occurrences) via MedicineRepository
  /// and refresh the currently selected day.
  Future<bool> addMedicine({
    required MedicineTracking tracking,
    required MedicinePlan plan,
    required List<String> times,
  }) async {
    try {
      print('🔄 TrackingCubit.addMedicine: Starting save...');
      final repo = MedicineRepository();
      await repo.saveMedicine(tracking: tracking, plan: plan, times: times);
      print('✅ TrackingCubit.addMedicine: Medicine saved successfully');

      // Reload the current day to show new medicine
      await loadDay(state.selectedDate);
      print('✅ TrackingCubit.addMedicine: Day reloaded with new data');

      return true;
    } catch (e) {
      print('❌ TrackingCubit.addMedicine error: $e');
      return false;
    }
  }
}
