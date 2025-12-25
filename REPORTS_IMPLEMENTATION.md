# Medication Adherence Report Implementation

## Overview
This implementation provides a comprehensive medication adherence reporting system with local database integration, PDF generation, and sharing capabilities.

## Components Created

### 1. Database Layer

#### Tables
- **`medication_intake_log`** - Tracks all medication intake events
  - Fields: log_id, occurrence_id, medicine_track_id, scheduled_date, scheduled_time, actual_time, status, dosage, notes, created_at

#### Database Files
- `db_medication_intake_log.dart` - Table schema definition
- Updated `db_helper.dart` - Added new table to database creation

### 2. Models

#### `medication_intake_log.dart`
- Represents individual medication intake records
- Tracks scheduled vs actual intake times
- Status: taken, missed, skipped

#### `adherence_report.dart`
- **AdherenceReport** - Main report container
- **AdherenceSummary** - Summary statistics (not taken, average taken, fully adherent, medicine missed)
- **WeeklyAdherence** - Weekly breakdown with percentages
- **MedicationSummary** - Medicine-level summary (name, dosage, frequency, duration, status)
- **IntakeLogEntry** - Detailed intake log entries

### 3. Repository Layer

#### `adherence_report_repo.dart`
Provides data access methods:
- `logIntake()` - Log a medication intake
- `updateIntakeLog()` - Update existing log
- `getIntakeLogsByDateRange()` - Retrieve logs for date range
- `getDetailedIntakeLogs()` - Get logs with medicine details
- `getAdherenceSummary()` - Calculate summary statistics
- `getWeeklyAdherence()` - Get weekly breakdown
- `getMedicationSummary()` - Get medication-level summary
- `getAdherenceReport()` - Generate complete report
- `syncOccurrencesToIntakeLogs()` - Sync occurrence plan data

### 4. State Management

#### `adherence_report_cubit.dart`
States:
- `AdherenceReportInitial` - Initial state
- `AdherenceReportLoading` - Loading data
- `AdherenceReportLoaded` - Report successfully loaded
- `AdherenceReportError` - Error occurred
- `AdherenceReportGenerating` - PDF generation in progress
- `AdherenceReportGenerated` - PDF generated successfully

Methods:
- `loadWeeklyReport()` - Load last 7 days
- `loadMonthlyReport()` - Load last 30 days
- `loadCustomReport()` - Load custom date range

### 5. UI Screens

#### `weekly_report_page.dart`
- Displays 7-day adherence report
- Patient information section
- Adherence summary cards
- Weekly adherence chart with progress bars
- Medication summary table
- Detailed intake log (top 10 entries)
- Share/download functionality

#### `monthly_report_page.dart`
- Displays 30-day adherence report
- Same layout as weekly report
- Shows 20 intake log entries
- Multiple weeks in adherence chart

#### `reports_hub_page.dart`
- Main navigation hub for reports
- Three options: Weekly, Monthly, Custom
- Beautiful card-based UI
- Easy navigation to each report type

#### `date_range_selector_dialog.dart`
- Custom date range selection
- Start and end date pickers
- Quick select buttons (Last 7 Days, Last 30 Days, Last 3 Months, Last 6 Months)
- Generates PDF and shares

### 6. Services

#### `report_pdf_service.dart`
PDF generation and sharing service:
- `generatePdf()` - Create PDF from report
- `sharePdf()` - Share PDF via system share
- `savePdf()` - Save PDF to device

PDF includes:
- Header with MediGo branding
- Patient information
- Adherence summary with color-coded cards
- Weekly adherence chart with progress bars
- Medication summary table
- Detailed intake log table
- Footer with generation timestamp

### 7. Dependencies Added

```yaml
pdf: ^3.11.1              # PDF generation
printing: ^5.13.4         # PDF rendering and printing
path_provider: ^2.1.5     # File system access
share_plus: ^10.1.4       # System share functionality
```

## Usage

### Navigation to Reports

```dart
// From any screen, navigate to reports hub
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ReportsHubPage(),
  ),
);
```

### Direct Access to Specific Report

```dart
// Weekly Report
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => AdherenceReportCubit(AdherenceReportRepository()),
      child: WeeklyReportPage(),
    ),
  ),
);

// Monthly Report
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => AdherenceReportCubit(AdherenceReportRepository()),
      child: MonthlyReportPage(),
    ),
  ),
);
```

### Programmatic Report Generation

```dart
final cubit = AdherenceReportCubit(AdherenceReportRepository());

// Load weekly report
await cubit.loadWeeklyReport();

// Load custom date range
await cubit.loadCustomReport(
  DateTime.now().subtract(Duration(days: 90)),
  DateTime.now(),
);

// Listen to state
cubit.stream.listen((state) {
  if (state is AdherenceReportLoaded) {
    // Access report data
    final report = state.report;
    print('Adherence: ${report.adherenceSummary.averageTaken}%');
  }
});
```

### PDF Generation and Sharing

```dart
final pdfService = ReportPdfService();
final report = /* AdherenceReport instance */;

// Generate PDF
final pdfFile = await pdfService.generatePdf(report);

// Share PDF
await pdfService.sharePdf(pdfFile);

// Save PDF
final savedPath = await pdfService.savePdf(pdfFile, 'my_report.pdf');
```

## Data Flow

1. **Occurrence Tracking** → `occurrence_plan` table (existing)
2. **Sync to Intake Logs** → `medication_intake_log` table (automatic sync)
3. **Query Reports** → Repository aggregates data
4. **Display UI** → Cubit manages state, UI renders
5. **Generate PDF** → Service creates PDF document
6. **Share** → System share dialog

## Database Schema Integration

The medication intake log integrates with existing tables:
- References `occurrence_plan` for scheduled doses
- References `medicine_tracking` for medication details
- Automatic sync keeps intake logs up to date

## Color Coding

### Status Colors
- **Taken** - Green (#4CAF50)
- **Missed** - Red (#FF5252)
- **Skipped** - Orange (#FFA726)

### Adherence Thresholds
- **>=80%** - Green (Good adherence)
- **50-79%** - Orange (Moderate adherence)
- **<50%** - Red (Poor adherence)

## Installation

1. Install dependencies:
```bash
cd frontend
flutter pub get
```

2. Database will auto-migrate on next app launch (version 6)

3. Navigate to reports from your app:
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsHubPage()));
```

## Future Enhancements

1. **Email Reports** - Send PDF via email
2. **Charts** - Add visual charts (line/bar graphs)
3. **Export Formats** - CSV, Excel export options
4. **Scheduled Reports** - Auto-generate weekly/monthly
5. **Comparison** - Compare periods side-by-side
6. **Goals** - Set adherence targets and track progress
7. **Notifications** - Alert on low adherence

## Testing

Ensure you have some test data:
1. Add medicines in the app
2. Mark some as taken/missed
3. Wait or manually create intake logs
4. Navigate to reports to view

## Support

For issues or questions, check:
- Database logs for sync issues
- Cubit states for loading errors
- PDF generation errors in console
