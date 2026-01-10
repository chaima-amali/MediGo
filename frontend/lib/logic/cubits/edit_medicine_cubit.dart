import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/medicine_plan.dart';
import 'package:frontend/data/models/medicine_tracking.dart';
import 'package:frontend/data/repositories/medicine_repository.dart';
import 'package:frontend/data/repositories/database_change_notifier.dart';
import 'package:frontend/logic/cubits/tracking_cubit.dart';

// sentinel used so callers can explicitly clear nullable fields (like `error`)
const _noValue = Object();

class EditMedicineState {
  final bool loading;
  final bool saving;
  final MedicinePlan? plan;
  final MedicineTracking? tracking;
  final String? error;
  final bool success;

  EditMedicineState({
    this.loading = false,
    this.saving = false,
    this.plan,
    this.tracking,
    this.error,
    this.success = false,
  });

  EditMedicineState copyWith({
    bool? loading,
    bool? saving,
    Object? plan = _noValue,
    Object? tracking = _noValue,
    Object? error = _noValue,
    bool? success,
  }) {
    return EditMedicineState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      plan: plan == _noValue ? this.plan : plan as MedicinePlan?,
      tracking: tracking == _noValue
          ? this.tracking
          : tracking as MedicineTracking?,
      error: error == _noValue ? this.error : error as String?,
      success: success ?? this.success,
    );
  }
}

class EditMedicineCubit extends Cubit<EditMedicineState> {
  final MedicineRepository _repo;
  final TrackingCubit? _trackingCubit;

  EditMedicineCubit(this._repo, [this._trackingCubit])
    : super(EditMedicineState());

  Future<void> load(int planId) async {
    emit(state.copyWith(loading: true, error: null, success: false));
    try {
      final plan = await _repo.getPlanById(planId);
      if (plan == null) {
        emit(state.copyWith(loading: false, error: 'Plan not found'));
        return;
      }
      // debug
      // ignore: avoid_print
      print(
        'EditMedicineCubit.load planId=$planId -> plan.trackingId=${plan.trackingId}',
      );
      final tracking = await _repo.getTrackingById(plan.trackingId);
      emit(state.copyWith(loading: false, plan: plan, tracking: tracking));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> save({
    required MedicineTracking updatedTracking,
    required MedicinePlan updatedPlan,
  }) async {
    emit(state.copyWith(saving: true, error: null, success: false));
    try {
      // Debug: log payloads being saved
      try {
        // ignore: avoid_print
        print(
          'EditMedicineCubit.save: updating tracking -> ${updatedTracking.toMap()}',
        );
        // ignore: avoid_print
        print(
          'EditMedicineCubit.save: updating plan -> ${updatedPlan.toMap()}',
        );
      } catch (_) {}

      final ok1 = await _repo.updateMedicineTracking(updatedTracking);
      // ignore: avoid_print
      print('EditMedicineCubit.save: updateMedicineTracking returned: $ok1');

      final ok2 = await _repo.updateMedicinePlan(updatedPlan);
      // ignore: avoid_print
      print('EditMedicineCubit.save: updateMedicinePlan returned: $ok2');

      if (ok1 && ok2) {
        // ignore: avoid_print
        print('EditMedicineCubit.save: both updates succeeded');
        // notify tracking cubit to reload today's occurrences if available
        try {
          // reload the currently selected date in the tracking cubit
          final sel = _trackingCubit?.state.selectedDate;
          if (sel != null) {
            _trackingCubit?.loadDay(sel);
          } else {
            _trackingCubit?.loadDay(DateTime.now());
          }
        } catch (_) {}
        // ensure listeners (statistics cubit etc.) are notified in case
        // repositories missed notifying for some edge case
        try {
          DatabaseChangeNotifier.instance.notify();
        } catch (_) {}
        // Final success emit
        emit(state.copyWith(saving: false, success: true));
      } else {
        // ignore: avoid_print
        print('EditMedicineCubit.save: failed to save (ok1=$ok1, ok2=$ok2)');
        emit(state.copyWith(saving: false, error: 'Failed to save'));
      }
    } catch (e) {
      // ignore: avoid_print
      print('EditMedicineCubit.save: exception -> $e');
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  Future<void> deletePlan(int planId) async {
    emit(state.copyWith(saving: true, error: null, success: false));
    try {
      final ok = await _repo.deleteMedicinePlan(planId);
      if (ok) {
        // notify tracking cubit to reload
        try {
          _trackingCubit?.loadDay(DateTime.now());
        } catch (_) {}
        try {
          DatabaseChangeNotifier.instance.notify();
        } catch (_) {}
        emit(state.copyWith(saving: false, success: true));
      } else {
        emit(state.copyWith(saving: false, error: 'Failed to delete'));
      }
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  Future<void> regenerateOccurrences({
    required int planId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> times,
  }) async {
    emit(state.copyWith(saving: true, error: null, success: false));
    try {
      final ok = await _repo.regenerateOccurrences(
        planId: planId,
        startDate: startDate,
        endDate: endDate,
        times: times,
      );
      if (ok) {
        try {
          _trackingCubit?.loadDay(DateTime.now());
        } catch (_) {}
        try {
          DatabaseChangeNotifier.instance.notify();
        } catch (_) {}
        emit(state.copyWith(saving: false, success: true));
      } else {
        emit(state.copyWith(saving: false, error: 'Failed to regenerate'));
      }
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }
}
