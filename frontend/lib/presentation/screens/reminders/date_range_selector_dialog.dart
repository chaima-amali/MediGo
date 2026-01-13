import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../../logic/cubits/adherence_report_cubit.dart';
import '../../../data/services/report_pdf_service.dart';
import '../../../data/models/adherence_report.dart';
import 'package:intl/intl.dart';

class DateRangeSelectorDialog extends StatefulWidget {
  const DateRangeSelectorDialog({Key? key}) : super(key: key);

  @override
  State<DateRangeSelectorDialog> createState() =>
      _DateRangeSelectorDialogState();
}

class _DateRangeSelectorDialogState extends State<DateRangeSelectorDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customReport,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 20),
            _buildDateSelector(l10n.startDate, _startDate, () async {
              final date = await _selectDate(
                context,
                _startDate ?? DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _startDate = date;
                });
              }
            }),
            SizedBox(height: 16),
            _buildDateSelector(l10n.endDate, _endDate, () async {
              final date = await _selectDate(
                context,
                _endDate ?? DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _endDate = date;
                });
              }
            }),
            if (_startDate != null &&
                _endDate != null &&
                _startDate!.isAfter(_endDate!))
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Start date must be before end date',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            SizedBox(height: 24),
            _buildQuickSelections(),
            SizedBox(height: 24),
            if (_isGenerating)
              Center(child: CircularProgressIndicator(color: AppColors.primary))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _canGenerate()
                          ? _generateAndShareReport
                          : null,
                      icon: Icon(
                        Icons.picture_as_pdf,
                        size: 18,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      label: Text(
                        l10n.generateReport,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(
                          0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? DateFormat('dd MMM yyyy').format(date)
                      : l10n.selectDateRange,
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null
                        ? AppColors.textDark
                        : AppColors.textLight,
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSelections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Select',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickButton('Last 7 Days', () {
              setState(() {
                _endDate = DateTime.now();
                _startDate = _endDate!.subtract(Duration(days: 7));
              });
            }),
            _buildQuickButton('Last 30 Days', () {
              setState(() {
                _endDate = DateTime.now();
                _startDate = _endDate!.subtract(Duration(days: 30));
              });
            }),
            _buildQuickButton('Last 3 Months', () {
              setState(() {
                _endDate = DateTime.now();
                _startDate = DateTime(
                  _endDate!.year,
                  _endDate!.month - 3,
                  _endDate!.day,
                );
              });
            }),
            _buildQuickButton('Last 6 Months', () {
              setState(() {
                _endDate = DateTime.now();
                _startDate = DateTime(
                  _endDate!.year,
                  _endDate!.month - 6,
                  _endDate!.day,
                );
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(
    BuildContext context,
    DateTime initialDate,
  ) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  bool _canGenerate() {
    return _startDate != null &&
        _endDate != null &&
        _startDate!.isBefore(_endDate!) &&
        !_isGenerating;
  }

  Future<void> _generateAndShareReport() async {
    if (!_canGenerate()) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Load report data
      final cubit = context.read<AdherenceReportCubit>();
      await cubit.loadCustomReport(_startDate!, _endDate!);

      final state = cubit.state;
      if (state is AdherenceReportLoaded) {
        // Generate PDF and save to Downloads
        final pdfService = ReportPdfService();
        final pdfFile = await pdfService.generateAndSavePdf(state.report);

        // Close dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PDF saved to Downloads/${pdfFile.path.split('/').last}',
            ),
            duration: Duration(seconds: 4),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Share',
              textColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () async {
                await pdfService.sharePdf(pdfFile);
              },
            ),
          ),
        );
      } else if (state is AdherenceReportError) {
        _showError(context, state.message);
      }
    } catch (e) {
      _showError(context, 'Failed to generate report: ${e.toString()}');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _showShareOptions(
    BuildContext context,
    dynamic pdfFile,
    ReportPdfService pdfService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Generated'),
        content: Text('Your PDF report has been generated successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await pdfService.sharePdf(pdfFile);
            },
            icon: Icon(Icons.share, size: 18, color: Theme.of(context).colorScheme.onSurface),
            label: Text('Share', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
