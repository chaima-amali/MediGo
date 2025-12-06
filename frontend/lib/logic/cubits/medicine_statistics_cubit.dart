import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/medicine_progress.dart';
import 'package:frontend/data/repositories/medicine_statistics_repository.dart';

// States
abstract class MedicineStatisticsState {}

class MSLoading extends MedicineStatisticsState {}

class MSLoaded extends MedicineStatisticsState {
  final double todayProgress; // 0.0 - 1.0
  final List<MedicineProgress> items;

  MSLoaded({required this.todayProgress, required this.items});
}

class MSError extends MedicineStatisticsState {
  final String message;
  MSError(this.message);
}

class MedicineStatisticsCubit extends Cubit<MedicineStatisticsState> {
  final MedicineStatisticsRepository _repo;
  StreamSubscription<void>? _sub;
  DateTime _currentDate = DateTime.now();

  MedicineStatisticsCubit(this._repo) : super(MSLoading()) {
    // subscribe to DB changes and reload automatically for the current date
    _sub = _repo.watchChanges().listen((_) => load(_currentDate));
    // initial load
    load(_currentDate);
  }

  Future<void> load(DateTime date) async {
    _currentDate = DateTime(date.year, date.month, date.day);
    emit(MSLoading());
    try {
      final today = await _repo.computeTodayProgress(date);
      final items = await _repo.computeMedicineProgress(date);
      emit(MSLoaded(todayProgress: today, items: items));
    } catch (e) {
      emit(MSError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
