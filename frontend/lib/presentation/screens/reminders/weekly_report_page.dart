import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import '../../../logic/cubits/adherence_report_cubit.dart';
import '../../../data/models/adherence_report.dart';
import '../../../data/services/report_pdf_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/back_arrow.dart';

class WeeklyReportPage extends StatefulWidget {
  const WeeklyReportPage({Key? key}) : super(key: key);

  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdherenceReportCubit>().loadWeeklyReport();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: CustomBackArrow(),
        automaticallyImplyLeading: false,
        title: Text(
          l10n.weeklyReport,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<AdherenceReportCubit>().loadWeeklyReport();
            },
          ),
        ],
      ),
      body: BlocBuilder<AdherenceReportCubit, AdherenceReportState>(
        builder: (context, state) {
          if (state is AdherenceReportLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is AdherenceReportError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: AppColors.error),
                  SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: AppColors.textDark, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AdherenceReportCubit>().loadWeeklyReport(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(
                      l10n.retry,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is AdherenceReportLoaded) {
            return _buildReportContent(context, state.report);
          }
          return Center(child: Text(l10n.noMedicationDataFound));
        },
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, AdherenceReport report) {
    final l10n = AppLocalizations.of(context)!;

    // Calculate values from available data
    final totalScheduled = report.detailedIntakeLog.length;
    final taken = report.detailedIntakeLog
        .where((log) => log.status == 'taken')
        .length;
    final skipped = report.detailedIntakeLog
        .where((log) => log.status == 'skipped')
        .length;
    final missed = report.adherenceSummary.notTaken;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF37B7C3), Color(0xFF5DD4DE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      report.reportPeriod,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '$totalScheduled',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.totalScheduled,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.taken,
                  taken,
                  Color(0xFF4CAF50),
                  Icons.check_circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.skipped,
                  skipped,
                  Color(0xFFFFA726),
                  Icons.access_time,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Missed Card
          _buildMissedCard(l10n.missed, missed),
          SizedBox(height: 24),

          // By Medicine Section
          Text(
            l10n.medicationSummary,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          // Medicine List
          ...report.medicationSummary.map((medicine) {
            // Count occurrences for this medicine in the intake log
            final medicineCount = report.detailedIntakeLog
                .where((log) => log.medicineName == medicine.medicineName)
                .length;
            return _buildMedicineCard(
              medicine.medicineName,
              medicine.dosage,
              medicineCount,
            );
          }),
          SizedBox(height: 24),

          // Share Reports Card
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFE8F4FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      l10n.shareReports,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  l10n.shareReportDescription,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPdf(context, report),
                        icon: Icon(Icons.download, size: 18),
                        label: Text('PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sharePdf(context, report),
                        icon: Icon(Icons.share, size: 18),
                        label: Text(l10n.share),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissedCard(String label, int value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFEF5350).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cancel, color: Color(0xFFEF5350), size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(String name, String dosage, int doses) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication, color: AppColors.primary, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  dosage,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              doses.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(
    BuildContext context,
    AdherenceReport report,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.generatingPDF)));

      final pdfService = ReportPdfService();
      final pdfFile = await pdfService.generateAndSavePdf(report);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.pdfGeneratedSuccessfully}\nSaved to: Downloads/${pdfFile.path.split('/').last}',
          ),
          duration: Duration(seconds: 4),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToGeneratePDF}: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _sharePdf(BuildContext context, AdherenceReport report) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.generatingPDF)));

      final pdfService = ReportPdfService();
      final pdfFile = await pdfService.generatePdf(report);
      await pdfService.sharePdf(pdfFile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToGeneratePDF}: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
