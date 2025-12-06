import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> loadDay(DateTime date) async {
    emit(state.copyWith(loading: true, selectedDate: date));

    final result = await repository.getOccurrencesByDate(date);

    emit(state.copyWith(loading: false, occurrences: result));
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

  /// Save a new medicine (tracking + plan + occurrences) via MedicineRepository
  /// and refresh the currently selected day.
  Future<bool> addMedicine({
    required MedicineTracking tracking,
    required MedicinePlan plan,
    required List<String> times,
  }) async {
    try {
      final repo = MedicineRepository();
      await repo.saveMedicine(tracking: tracking, plan: plan, times: times);
      await loadDay(state.selectedDate);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('TrackingCubit.addMedicine error: $e');
      return false;
    }
  }
}
