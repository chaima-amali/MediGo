import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'medicine_calendar.dart';
import 'add_medicine_page.dart';
import 'statistics_page.dart';
import 'edit_page.dart';
import 'notifications.dart'; 

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  static const String routeName = '/tracking';

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  int _selectedDateIndex = 16;
  String _activeSub = 'tracking'; // tracking | statistics | edit

  final List<Map<String, dynamic>> morningMeds = [
    {
      "name": "Telfast",
      "details": "(100 mg, 1 Pill, Before eat)",
      "done": true,
      "color": AppColors.yellowCard,
    },
    {
      "name": "Aspirin",
      "details": "(100 mg, 1 Pill, Before eat)",
      "done": true,
      "color": AppColors.pinkCard,
    },
    {
      "name": "Diclofenac",
      "details": "(100 mg, Before eat)",
      "done": true,
      "color": AppColors.blueCard,
    },
  ];

  final List<Map<String, dynamic>> eveningMeds = [
    {
      "name": "Aspirin",
      "details": "(100 mg, Before eat)",
      "done": false,
      "color": AppColors.pinkCard,
    },
    {
      "name": "Diclofenac",
      "details": "(100 mg, Before eat)",
      "done": true,
      "color": AppColors.blueCard,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      // ✅ Only show the + button in Tracking view
      floatingActionButton: _activeSub == 'tracking'
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMedicinePage()),
                );
              },
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            )
          : null,

      body: Container(
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

                  // Month + Calendar icon
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

                  // Tabs: Tracking | Statistics | Edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(
                        "Tracking",
                        isPrimary: _activeSub == 'tracking',
                        onTap: () => setState(() => _activeSub = 'tracking'),
                      ),
                      _buildButton(
                        "Statistics",
                        isPrimary: _activeSub == 'statistics',
                        onTap: () => setState(() => _activeSub = 'statistics'),
                      ),
                      _buildButton(
                        "Edit",
                        isPrimary: _activeSub == 'edit',
                        onTap: () => setState(() => _activeSub = 'edit'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ✅ Content switching
                  if (_activeSub == 'tracking') ...[
                    _buildMedicineSection("8:00 am Morning", morningMeds),
                    const SizedBox(height: 25),
                    _buildMedicineSection("2:00 pm Evening", eveningMeds),
                  ] else if (_activeSub == 'statistics') ...[
                    const StatisticsContent(),
                  ] else if (_activeSub == 'edit') ...[
                    const EditContent(),
                  ],

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI Helper Widgets ----------------

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
        // ✅ Notification icon now leads to notifications.dart
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
          child: Stack(
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
        ),
      ],
    );
  }

  Widget _buildMedicineSection(String title, List<Map<String, dynamic>> meds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: meds.asMap().entries.map((entry) {
            final Map<String, dynamic> med = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: med['color'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 5,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  med['details'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                med['done']
                                    ? "Marked as done"
                                    : "Not marked yet",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      med['done'] = !med['done'];
                                    });
                                  },
                                  child: Icon(
                                    med['done']
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: med['done']
                                        ? Colors.green
                                        : AppColors.darkBlue,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
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
}
