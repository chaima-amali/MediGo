import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubits/adherence_report_cubit.dart';
import '../../../data/repositories/adherence_report_repo.dart';
import 'reports_hub_page.dart';
import 'weekly_report_page.dart';
import 'monthly_report_page.dart';

/// Example: How to integrate reports into your app
///
/// Add these navigation methods to your existing screens

class ReportIntegrationExamples {
  /// Example 1: Navigate to Reports Hub
  /// Use this to show all report options
  static void navigateToReportsHub(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportsHubPage()),
    );
  }

  /// Example 2: Navigate directly to Weekly Report
  static void navigateToWeeklyReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) =>
              AdherenceReportCubit(AdherenceReportRepository()),
          child: const WeeklyReportPage(),
        ),
      ),
    );
  }

  /// Example 3: Navigate directly to Monthly Report
  static void navigateToMonthlyReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) =>
              AdherenceReportCubit(AdherenceReportRepository()),
          child: const MonthlyReportPage(),
        ),
      ),
    );
  }

  /// Example 4: Add a Reports button to your existing screen
  static Widget buildReportsButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => navigateToReportsHub(context),
      icon: const Icon(Icons.analytics, color: Colors.white),
      label: const Text('View Reports', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF37B7C3),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Example 5: Add Reports to AppBar actions
  static List<Widget> buildAppBarActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.analytics),
        onPressed: () => navigateToReportsHub(context),
        tooltip: 'View Reports',
      ),
    ];
  }

  /// Example 6: Add Reports card to dashboard
  static Widget buildReportsDashboardCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => navigateToReportsHub(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF37B7C3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFF37B7C3),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adherence Reports',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track your medication adherence',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// Integration Steps:
/// 
/// 1. Add to your home/dashboard screen:
///    ```dart
///    ReportIntegrationExamples.buildReportsDashboardCard(context)
///    ```
/// 
/// 2. Add to your settings or profile screen:
///    ```dart
///    ListTile(
///      leading: Icon(Icons.analytics),
///      title: Text('Adherence Reports'),
///      onTap: () => ReportIntegrationExamples.navigateToReportsHub(context),
///    )
///    ```
/// 
/// 3. Add to your reminders screen AppBar:
///    ```dart
///    AppBar(
///      title: Text('Reminders'),
///      actions: ReportIntegrationExamples.buildAppBarActions(context),
///    )
///    ```
