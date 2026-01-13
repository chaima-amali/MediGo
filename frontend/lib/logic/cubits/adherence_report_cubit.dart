import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/adherence_report_repo.dart';
import '../../data/models/adherence_report.dart';

// States
abstract class AdherenceReportState {}

class AdherenceReportInitial extends AdherenceReportState {}

class AdherenceReportLoading extends AdherenceReportState {}

class AdherenceReportLoaded extends AdherenceReportState {
  final AdherenceReport report;

  AdherenceReportLoaded(this.report);
}

class AdherenceReportError extends AdherenceReportState {
  final String message;

  AdherenceReportError(this.message);
}

class AdherenceReportGenerating extends AdherenceReportState {
  final double progress;

  AdherenceReportGenerating(this.progress);
}

class AdherenceReportGenerated extends AdherenceReportState {
  final String filePath;

  AdherenceReportGenerated(this.filePath);
}

// Cubit
class AdherenceReportCubit extends Cubit<AdherenceReportState> {
  final AdherenceReportRepository repository;

  AdherenceReportCubit(this.repository) : super(AdherenceReportInitial());

  // Load report for a specific date range
  Future<void> loadReport(DateTime startDate, DateTime endDate) async {
    try {
      emit(AdherenceReportLoading());

      print(
        'Loading report from ${startDate.toString()} to ${endDate.toString()}',
      );

      // Sync occurrences to intake logs first
      await repository.syncOccurrencesToIntakeLogs();

      final report = await repository.getAdherenceReport(startDate, endDate);

      if (report == null) {
        emit(
          AdherenceReportError(
            'No user data found. Please add your profile information first.',
          ),
        );
      } else if (report.detailedIntakeLog.isEmpty) {
        emit(
          AdherenceReportError(
            'No medication data found for this period.\n\n'
            'Please add medicines and mark them as taken/missed to see reports.',
          ),
        );
      } else {
        print(
          'Report loaded successfully with ${report.detailedIntakeLog.length} entries',
        );
        emit(AdherenceReportLoaded(report));
      }
    } catch (e) {
      print('Error loading report: $e');
      emit(
        AdherenceReportError(
          'Failed to load report.\n\n'
          'Error: ${e.toString()}\n\n'
          'Please make sure you have added medicines and scheduled them.',
        ),
      );
    }
  }

  // Load weekly report (last 7 days from today)
  Future<void> loadWeeklyReport() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: 7));
    await loadReport(startDate, endDate);
  }

  // Load monthly report (last 30 days from today)
  Future<void> loadMonthlyReport() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: 30));
    await loadReport(startDate, endDate);
  }

  // Load report for custom date range
  Future<void> loadCustomReport(DateTime startDate, DateTime endDate) async {
    await loadReport(startDate, endDate);
  }

  // Reset to initial state
  void reset() {
    emit(AdherenceReportInitial());
  }
}
