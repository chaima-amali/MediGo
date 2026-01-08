import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../data/models/adherence_report.dart';

class ReportPdfService {
  // Generate PDF from AdherenceReport and save to Downloads
  Future<File> generateAndSavePdf(AdherenceReport report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(report),
          pw.SizedBox(height: 20),
          _buildPatientInfo(report),
          pw.SizedBox(height: 20),
          _buildAdherenceSummary(report.adherenceSummary),
          pw.SizedBox(height: 20),
          _buildWeeklyAdherence(report.weeklyAdherence),
          pw.SizedBox(height: 20),
          _buildMedicationSummary(report.medicationSummary),
          pw.SizedBox(height: 20),
          _buildDetailedIntakeLog(report.detailedIntakeLog),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    // Save to Downloads folder
    Directory? directory;

    if (!kIsWeb && Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      // Fallback to external storage if Download doesn't exist
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final fileName =
        'MediGo_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final file = File('${directory!.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Generate PDF from AdherenceReport (for sharing - uses temp directory)
  Future<File> generatePdf(AdherenceReport report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(report),
          pw.SizedBox(height: 20),
          _buildPatientInfo(report),
          pw.SizedBox(height: 20),
          _buildAdherenceSummary(report.adherenceSummary),
          pw.SizedBox(height: 20),
          _buildWeeklyAdherence(report.weeklyAdherence),
          pw.SizedBox(height: 20),
          _buildMedicationSummary(report.medicationSummary),
          pw.SizedBox(height: 20),
          _buildDetailedIntakeLog(report.detailedIntakeLog),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/adherence_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Share the generated PDF
  Future<void> sharePdf(File pdfFile) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      subject: 'Medication Adherence Report',
      text: 'Here is my medication adherence report',
    );
  }

  // Save PDF to device
  Future<String> savePdf(File pdfFile, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/$fileName';
    await pdfFile.copy(savePath);
    return savePath;
  }

  // Build header
  pw.Widget _buildHeader(AdherenceReport report) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#37B7C3').flatten(),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MediGo - Medicine Adherence Report',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Comprehensive Health Tracking & Analysis',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  // Build patient information section
  pw.Widget _buildPatientInfo(AdherenceReport report) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patient Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#37B7C3'),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Full Name', report.fullName),
              _buildInfoItem('Age', report.age.toString()),
              _buildInfoItem('Phone', report.phone),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                'Report Generated',
                DateFormat('dd MMM yyyy').format(report.reportGeneratedDate),
              ),
              _buildInfoItem('Report Period', report.reportPeriod),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  // Build adherence summary
  pw.Widget _buildAdherenceSummary(AdherenceSummary summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Adherence Summary',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildSummaryCard(
                'Not Taken',
                summary.notTaken.toString(),
                PdfColors.red,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: _buildSummaryCard(
                'Average Taken',
                '${summary.averageTaken.toStringAsFixed(0)}%',
                PdfColors.orange,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: _buildSummaryCard(
                'Fully Adherent',
                '${summary.fullyAdherent.toStringAsFixed(0)}%',
                PdfColors.green,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: _buildSummaryCard(
                'Medicine Missed',
                summary.medicineMissed.toString(),
                PdfColors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSummaryCard(String label, String value, PdfColor color) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Build weekly adherence chart
  pw.Widget _buildWeeklyAdherence(List<WeeklyAdherence> weeklyData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Weekly Adherence Chart',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        ...weeklyData.map((week) => _buildWeekBar(week)).toList(),
      ],
    );
  }

  pw.Widget _buildWeekBar(WeeklyAdherence week) {
    final barColor = week.percentage >= 80
        ? PdfColors.green
        : week.percentage >= 50
        ? PdfColors.orange
        : PdfColors.red;

    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(week.weekLabel, style: pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Stack(
                  children: [
                    pw.Container(
                      height: 20,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey300,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                    ),
                    pw.Container(
                      width: (week.percentage / 100) * 450, // Approximate width
                      height: 20,
                      decoration: pw.BoxDecoration(
                        color: barColor,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Container(
                width: 45,
                child: pw.Text(
                  '${week.percentage.toStringAsFixed(0)}%',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build medication summary table
  pw.Widget _buildMedicationSummary(List<MedicationSummary> medications) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Medication Summary',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E0F7FA')),
              children: [
                _buildTableCell('Medicine', isHeader: true),
                _buildTableCell('Dosage', isHeader: true),
                _buildTableCell('Frequency', isHeader: true),
                _buildTableCell('Duration', isHeader: true),
                _buildTableCell('Status', isHeader: true),
              ],
            ),
            // Data rows
            ...medications.map(
              (med) => pw.TableRow(
                children: [
                  _buildTableCell(med.medicineName),
                  _buildTableCell(med.dosage),
                  _buildTableCell(med.frequency),
                  _buildTableCell(med.duration),
                  _buildTableCell(med.status),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build detailed intake log table
  pw.Widget _buildDetailedIntakeLog(List<IntakeLogEntry> logs) {
    final displayLogs = logs.take(20).toList(); // Limit to 20 entries

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detailed Intake Log',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        if (logs.length > 20)
          pw.Text(
            'Showing 20 of ${logs.length} entries',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: pw.FlexColumnWidth(1.5),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1),
            4: pw.FlexColumnWidth(1),
            5: pw.FlexColumnWidth(2),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E0F7FA')),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Medicine', isHeader: true),
                _buildTableCell('Time', isHeader: true),
                _buildTableCell('Status', isHeader: true),
                _buildTableCell('Dosage', isHeader: true),
                _buildTableCell('Notes', isHeader: true),
              ],
            ),
            // Data rows
            ...displayLogs.map(
              (log) => pw.TableRow(
                children: [
                  _buildTableCell(DateFormat('dd/MM/yyyy').format(log.date)),
                  _buildTableCell(log.medicineName),
                  _buildTableCell(log.time),
                  _buildTableCell(log.status),
                  _buildTableCell(log.dosage),
                  _buildTableCell(log.notes ?? '-'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColor.fromHex('#37B7C3') : PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 2),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'This report was generated automatically by MediGo',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'For questions or concerns, please consult your healthcare provider',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated on ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
}
