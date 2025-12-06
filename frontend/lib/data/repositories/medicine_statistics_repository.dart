import 'package:frontend/data/models/medicine_progress.dart';
import 'package:frontend/data/repositories/occurrence_repository.dart';
import 'package:frontend/data/repositories/medicine_repository.dart';
import 'package:frontend/data/repositories/database_change_notifier.dart';
import 'package:frontend/data/repositories/daily_dosage_repository.dart';

class MedicineStatisticsRepository {
  final OccurrenceRepository _occRepo;
  final MedicineRepository _medRepo;

  MedicineStatisticsRepository({
    OccurrenceRepository? occRepo,
    MedicineRepository? medRepo,
  }) : _occRepo = occRepo ?? OccurrenceRepository(),
       _medRepo = medRepo ?? MedicineRepository();

  final DailyDosageRepository _dailyRepo = DailyDosageRepository();

  /// Stream that emits whenever the DB has been changed (insert/update/delete)
  Stream<void> watchChanges() => DatabaseChangeNotifier.instance.stream;

  /// Compute today's overall progress: fraction between 0.0 and 1.0
  Future<double> computeTodayProgress(DateTime date) async {
    // Prefer the daily_dosage_checking canonical table when available.
    try {
      final total = await _dailyRepo.countTotalForDate(date);
      if (total > 0) {
        final taken = await _dailyRepo.countTakenForDate(date);
        return total == 0 ? 0.0 : (taken / total);
      }
    } catch (_) {}

    // Fallback to occurrences if no daily records exist for the date.
    final occs = await _occRepo.getOccurrencesByDate(date);
    if (occs.isEmpty) return 0.0;
    final total = occs.length;
    final taken = occs.where((o) => o.isTaken == 1).length;
    return total == 0 ? 0.0 : (taken / total);
  }

  /// Compute per-medicine progress (treatment elapsed percent between start/end)
  Future<List<MedicineProgress>> computeMedicineProgress(DateTime date) async {
    final occs = await _occRepo.getOccurrencesByDate(date);

    // Collect distinct plan ids and last-seen medicine name
    final Map<int, String> planNames = {};
    final Set<int> planIds = {};
    for (final o in occs) {
      if (o.planId != null) {
        planIds.add(o.planId!);
        planNames[o.planId!] = o.medicineName ?? planNames[o.planId!] ?? '';
      }
    }

    final List<MedicineProgress> result = [];
    for (final pid in planIds) {
      final plan = await _medRepo.getPlanById(pid);
      DateTime? start;
      DateTime? end;
      int? medicineId;
      String? color;
      String name = planNames[pid] ?? '';
      if (plan != null) {
        start = plan.startDate;
        end = plan.endDate;
        medicineId = plan.trackingId;
        // try to get medicine tracking to extract name if available
        try {
          final tr = await _medRepo.getTrackingById(plan.trackingId);
          if (tr != null) {
            name = tr.name ?? name;
            // NOTE: medicine tracking model currently doesn't expose a color
            // property in the schema. Keep color null unless repository
            // or model is extended to include it.
          }
        } catch (_) {}
      }

      // Compute treatment elapsed percent between start and end dates.
      // This represents how far along the treatment is on the provided date
      // (e.g., start=1/12, end=12/12, date=6/12 => ~50%). This value is
      // independent from per-day taken/un-taken status.
      double prog = 0.0;
      try {
        if (start != null && end != null) {
          // normalize to date-only for inclusive day counting
          final s = DateTime(start.year, start.month, start.day);
          final e = DateTime(end.year, end.month, end.day);
          final d = DateTime(date.year, date.month, date.day);

          if (d.isBefore(s)) {
            prog = 0.0;
          } else if (d.isAfter(e) || d.isAtSameMomentAs(e)) {
            prog = 1.0;
          } else {
            final totalDays = e.difference(s).inDays;
            final elapsed = d.difference(s).inDays;
            if (totalDays <= 0) {
              prog = 1.0;
            } else {
              prog = elapsed / totalDays;
              if (prog < 0) prog = 0.0;
              if (prog > 1) prog = 1.0;
            }
          }
        } else {
          prog = 0.0;
        }
      } catch (_) {
        prog = 0.0;
      }

      result.add(
        MedicineProgress(
          planId: pid,
          medicineId: medicineId,
          name: name,
          color: color,
          startDate: start,
          endDate: end,
          progress: prog,
        ),
      );
    }

    return result;
  }
}
