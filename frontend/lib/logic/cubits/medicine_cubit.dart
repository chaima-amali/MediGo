import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/repositories/medicine_repository.dart';
import 'package:frontend/data/models/medicine_plan.dart';
import 'package:frontend/data/models/medicine_tracking.dart';

class MedicineState {
  final bool loading;
  final String? error;

  MedicineState({this.loading = false, this.error});

  MedicineState copyWith({bool? loading, String? error}) {
    return MedicineState(loading: loading ?? this.loading, error: error);
  }
}

class MedicineCubit extends Cubit<MedicineState> {
  final MedicineRepository repository;

  MedicineCubit(this.repository) : super(MedicineState());

  Future<void> saveMedicine({
    required MedicineTracking tracking,
    required MedicinePlan plan,
    required List<String> times,
  }) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      await repository.saveMedicine(
        tracking: tracking,
        plan: plan,
        times: times,
      );
      emit(state.copyWith(loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
