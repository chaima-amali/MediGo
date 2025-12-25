import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import '../../../logic/cubits/adherence_report_cubit.dart';
import '../../../data/repositories/adherence_report_repo.dart';
import '../../theme/app_colors.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import 'weekly_report_page.dart';
import 'monthly_report_page.dart';
import 'date_range_selector_dialog.dart';

class ReportsHubPage extends StatelessWidget {
  const ReportsHubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: CustomBackArrow(onPressed: () => Navigator.pop(context)),
        title: Text(
          l10n.medicationReports,
          style: TextStyle(
            color:
                Theme.of(context).appBarTheme.foregroundColor ??
                Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adherenceReports,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 8),
            Text(
              l10n.trackMedicationAdherence,
              style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).textTheme.bodySmall?.color ??
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 32),
            _buildReportCard(
              context,
              title: l10n.weeklyReport,
              description: l10n.viewAdherenceLast7Days,
              icon: Icons.calendar_view_week,
              color: AppColors.primary,
              onTap: () => _navigateToWeeklyReport(context),
            ),
            SizedBox(height: 16),
            _buildReportCard(
              context,
              title: l10n.monthlyReport,
              description: l10n.viewAdherenceLast30Days,
              icon: Icons.calendar_month,
              color: AppColors.success,
              onTap: () => _navigateToMonthlyReport(context),
            ),
            SizedBox(height: 16),
            _buildReportCard(
              context,
              title: l10n.customReport,
              description: l10n.generateCustomDateRange,
              icon: Icons.date_range,
              color: AppColors.warning,
              onTap: () => _showCustomReportDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToWeeklyReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) =>
              AdherenceReportCubit(AdherenceReportRepository()),
          child: WeeklyReportPage(),
        ),
      ),
    );
  }

  void _navigateToMonthlyReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) =>
              AdherenceReportCubit(AdherenceReportRepository()),
          child: MonthlyReportPage(),
        ),
      ),
    );
  }

  void _showCustomReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (context) => AdherenceReportCubit(AdherenceReportRepository()),
        child: DateRangeSelectorDialog(),
      ),
    );
  }
}
