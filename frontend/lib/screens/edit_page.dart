import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'statistics_page.dart';
import 'medicine_calendar.dart';
import 'tracking_page.dart';
import 'edit_medicine_page.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  int _selectedDateIndex = 16;

  final List<Map<String, dynamic>> medicines = [
    {
      'name': 'Telfast',
      'color': AppColors.yellowCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Aspirin',
      'color': AppColors.pinkCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Diclofenac',
      'color': AppColors.blueCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Naproxen',
      'color': AppColors.coralCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Vitamin C',
      'color': AppColors.lavenderCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: const EditContent(),
    );
  }
}

class EditContent extends StatefulWidget {
  const EditContent({super.key});

  @override
  State<EditContent> createState() => _EditContentState();
}

class _EditContentState extends State<EditContent> {
  int _selectedDateIndex = 16;

  final List<Map<String, dynamic>> medicines = [
    {
      'name': 'Telfast',
      'color': AppColors.yellowCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Aspirin',
      'color': AppColors.pinkCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Diclofenac',
      'color': AppColors.blueCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Naproxen',
      'color': AppColors.coralCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
    {
      'name': 'Vitamin C',
      'color': AppColors.lavenderCard,
      'details': '(100 mg, 1 Pill, Before eat)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightBlue, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 25),

                const Text(
                  "Have you taken your\nmedicine Today?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 10),

                // Month + Calendar
                Row(
                  children: [
                    const Text(
                      "September ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      "2025",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MedicineCalendarScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                _buildDateRow(),
                const SizedBox(height: 15),
                // 🔹 Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildButton(
                      "Tracking",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrackingPage(),
                          ),
                        );
                      },
                    ),
                    _buildButton(
                      "Statistics",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatisticsPage(),
                          ),
                        );
                      },
                    ),
                    _buildButton("Edit", isPrimary: true),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  "Your current medicines",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),

                const SizedBox(height: 15),

                // 💊 Medicine List
                Column(
                  children: medicines.map((medicine) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: medicine['color'],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medicine['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                medicine['details'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditMedicinePage(),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _showDeleteDialog(context),
                                child: const Icon(
                                  Icons.delete_outline,
                                  size: 22,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'MediGo',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Image.asset('assets/images/logo_medicine.png', height: 38),
          ],
        ),
        Stack(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.primary,
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    const int startDate = 12;
    const int count = 8;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(count, (index) {
        final int date = startDate + index;
        final bool isSelected = date == _selectedDateIndex;

        return GestureDetector(
          onTap: () => setState(() => _selectedDateIndex = date),
          child: Container(
            height: 38,
            width: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : AppColors.lightBlue,
            ),
            child: Text(
              '$date',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkBlue,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildButton(
    String text, {
    bool isPrimary = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : AppColors.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ❌ Delete confirmation dialog
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Delete Medicine",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this medicine?",
            style: TextStyle(color: Colors.black87),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.darkBlue,
                  ),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Implement deletion if needed
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
