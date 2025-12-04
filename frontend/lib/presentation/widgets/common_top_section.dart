import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/tracking_page.dart';
import '../screens/reminders/statistics_page.dart';
import '../screens/edit_medicine_page.dart';

class CommonTopSection extends StatelessWidget {
  final String activeTab;
  const CommonTopSection({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/images/logo_medicine.png', height: 32),
                const SizedBox(width: 6),
                const Text(
                  'MediGo',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
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
                  child: const Icon(Icons.notifications_none,
                      color: AppColors.primary),
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
            )
          ],
        ),

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

        Row(
          children: const [
            Text(
              "September 2025",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.primary),
          ],
        ),

        const SizedBox(height: 20),

        // Buttons Row (Navigation)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navButton(
              context,
              label: "Tracking",
              isActive: activeTab == "Tracking",
              onTap: () {
                if (activeTab != "Tracking") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TrackingPage()),
                  );
                }
              },
            ),
            _navButton(
              context,
              label: "Statistics",
              isActive: activeTab == "Statistics",
              onTap: () {
                if (activeTab != "Statistics") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const StatisticsPage()),
                  );
                }
              },
            ),
            _navButton(
              context,
              label: "Edit",
              isActive: activeTab == "Edit",
              onTap: () {
                if (activeTab != "Edit") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const EditMedicinePage()),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  static Widget _navButton(BuildContext context,
      {required String label,
      required bool isActive,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
