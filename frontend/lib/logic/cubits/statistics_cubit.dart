import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/repositories/occurrence_repository.dart';
import 'package:frontend/data/repositories/medicine_repository.dart';
import 'package:frontend/data/models/medicine_progress.dart';

class StatisticsState {
  final bool loading;
  final double percent; // 0.0 - 1.0 for today's taken ratio
  final List<MedicineProgress> items;
  final DateTime date;

  StatisticsState({
    required this.loading,
    required this.percent,
    required this.items,
    required this.date,
  });

  factory StatisticsState.initial() => StatisticsState(
    loading: true,
    percent: 0.0,
    items: [],
    date: DateTime.now(),
  );

  StatisticsState copyWith({
    bool? loading,
    double? percent,
    List<MedicineProgress>? items,
    DateTime? date,
  }) {
    return StatisticsState(
      loading: loading ?? this.loading,
      percent: percent ?? this.percent,
      items: items ?? this.items,
      date: date ?? this.date,
    );
  }
}

class StatisticsCubit extends Cubit<StatisticsState> {
  final OccurrenceRepository occRepo;
  final MedicineRepository medRepo;

  StatisticsCubit(this.occRepo, this.medRepo)
    : super(StatisticsState.initial());

  Future<void> load(DateTime date) async {
    emit(state.copyWith(loading: true, date: date));

    final occs = await occRepo.getOccurrencesByDate(date);

    final total = occs.length;
    final taken = occs.where((o) => o.isTaken == 1).length;
    final percent = total == 0 ? 0.0 : (taken / total);

    // group by plan id to compute per-plan day progress
    final Map<int?, String> planName = {};
    final Set<int?> planIds = {};
    for (final o in occs) {
      planIds.add(o.planId);
      if (o.planId != null &&
          (planName[o.planId] == null || planName[o.planId]!.isEmpty)) {
        planName[o.planId] = o.medicineName ?? '';
      }
    }

    final List<MedicineProgress> items = [];
    for (final pid in planIds) {
      if (pid == null) continue;
      final plan = await medRepo.getPlanById(pid);
      DateTime? start;
      DateTime? end;
      if (plan != null) {
        start = plan.startDate;
        end = plan.endDate;
      }

      double prog = 0.0;
      try {
        if (start != null && end != null && !end.isAtSameMomentAs(start)) {
          final totalDays = end.difference(start).inDays;
          final elapsed = date.difference(start).inDays;
          prog = totalDays <= 0 ? 1.0 : (elapsed / totalDays);
          if (prog < 0) prog = 0.0;
          if (prog > 1) prog = 1.0;
        } else if (start != null &&
            end != null &&
            end.isAtSameMomentAs(start)) {
          prog = 1.0;
        }
      } catch (_) {
        prog = 0.0;
      }

      final name = planName[pid] ?? '';
      items.add(
        MedicineProgress(
          planId: pid,
          name: name,
          startDate: start,
          endDate: end,
          progress: prog,
        ),
      );
    }

    emit(state.copyWith(loading: false, percent: percent, items: items));
  }
}
