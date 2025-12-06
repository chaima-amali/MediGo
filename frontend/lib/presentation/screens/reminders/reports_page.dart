import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import 'package:frontend/presentation/theme/app_text.dart';
import 'package:frontend/presentation/theme/app_colors.dart';

import 'package:frontend/presentation/services/mock_database_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool isWeekly = false;
  late Map<String, dynamic> weeklyData;
  late Map<String, dynamic> monthlyData;

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  void _loadReportsData() {
    final weeklyReport = MockDataService.getWeeklyReport();
    final monthlyReport = MockDataService.getMonthlyReport();

    // Format weekly data
    weeklyData = {
      'period': 'Last 7 Days',
      'totalDoses': weeklyReport['total_doses'],
      'taken': weeklyReport['taken'],
      'delayed': weeklyReport['delayed'],
      'missed': weeklyReport['missed'],
      'medicines': (weeklyReport['by_medicine'] as List).map((med) => {
        'name': med['medicine_name'],
        'dosage': med['dosage'],
        'doses': med['total_doses'],
      }).toList(),
    };

    // Format monthly data
    monthlyData = {
      'period': 'Last 30 Days',
      'totalDoses': monthlyReport['total_doses'],
      'taken': monthlyReport['taken'],
      'delayed': monthlyReport['delayed'],
      'missed': monthlyReport['missed'],
      'medicines': (monthlyReport['by_medicine'] as List).map((med) => {
        'name': med['medicine_name'],
        'dosage': med['dosage'],
        'doses': med['total_doses'],
      }).toList(),
    };
  }

  Map<String, dynamic> get currentData => isWeekly ? weeklyData : monthlyData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: CustomBackArrow(),
        title: Text(
          'Reports',
          style: AppText.bold,
        ),
        centerTitle: false,
       actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.darkBlue, size: 18),
            onPressed: () {
              _showShareDialog();
            },
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.darkBlue, size: 18),
            onPressed: () {
              _showDownloadDialog();
            },
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    left: isWeekly ? 0 : MediaQuery.of(context).size.width / 2 - 40,
                    right: isWeekly ? MediaQuery.of(context).size.width / 2 - 40 : 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isWeekly 
                              ? [const Color(0xFF37B7C3), const Color(0xFF5DD4DE)]
                              : [const Color(0xFFEBABD3), const Color(0xFFF2C8E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (isWeekly ? const Color(0xFF37B7C3) : const Color(0xFFEBABD3)).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isWeekly = true);
                          },
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: AppText.medium.copyWith(
                                fontSize: 14,
                                color: isWeekly ? AppColors.white : Colors.grey[600],
                                fontWeight: isWeekly ? FontWeight.w600 : FontWeight.normal,
                              ),
                              child: Center(
                                child: Text('Weekly'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => isWeekly = false);
                          },
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: AppText.medium.copyWith(
                                fontSize: 14,
                                color: !isWeekly ? AppColors.white : Colors.grey[600],
                                fontWeight: !isWeekly ? FontWeight.w600 : FontWeight.normal,
                              ),
                              child: Center(
                                child: Text('Monthly'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Total Doses Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isWeekly
                      ? [const Color(0xFF37B7C3), const Color(0xFF5DD4DE)]
                      : [const Color(0xFFEBABD3), const Color(0xFFF2C8E0)],
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
                      const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        currentData['period'],
                        style: AppText.regular.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currentData['totalDoses']}',
                    style: AppText.bold.copyWith(
                      color: Colors.white,
                      fontSize: 48,
                    ),
                  ),
                  Text(
                    'Total doses',
                    style: AppText.regular.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Taken',
                    currentData['taken'],
                    const Color(0xFF4CAF50),
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Delayed',
                    currentData['delayed'],
                    const Color(0xFFFFA726),
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Missed Card
            _buildMissedCard(currentData['missed']),
            const SizedBox(height: 24),

            // By Medicine Section
            Text(
              'By Medicine',
              style: AppText.bold.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Medicine List
            ...List.generate(
              (currentData['medicines'] as List).length,
              (index) {
                final medicine = (currentData['medicines'] as List)[index];
                return _buildMedicineCard(
                  medicine['name'],
                  medicine['dosage'],
                  medicine['doses'],
                );
              },
            ),
            const SizedBox(height: 24),

            // Share Reports Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insert_drive_file, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Share Reports',
                        style: AppText.bold.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Export your reports to share with your doctor or family members',
                    style: AppText.regular.copyWith(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showDownloadDialog,
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.darkBlue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showShareDialog,
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.darkBlue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                style: AppText.regular.copyWith(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: AppText.bold.copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildMissedCard(int missed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Missed',
            style: AppText.regular.copyWith(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$missed',
            style: AppText.bold.copyWith(fontSize: 28, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(String name, String dosage, int doses) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppText.medium.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                dosage,
                style: AppText.regular.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$doses',
                style: AppText.bold.copyWith(
                  fontSize: 20,
                  color: isWeekly ? AppColors.primary : const Color(0xFFB76BA3),
                ),
              ),
              Text(
                'doses',
                style: AppText.regular.copyWith(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.share, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            const Text('Share Report'),
          ],
        ),
        content: Text(
          'Share your ${isWeekly ? "weekly" : "monthly"} report with your doctor or family members.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Report shared successfully!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.download, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            const Text('Download PDF'),
          ],
        ),
        content: Text(
          'Download your ${isWeekly ? "weekly" : "monthly"} report as a PDF file.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('PDF downloaded successfully!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}