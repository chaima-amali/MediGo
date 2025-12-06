import 'package:flutter/material.dart';
import 'package:frontend/presentation/screens/reminders/edit_page.dart';
import 'package:frontend/presentation/screens/reminders/tracking_page.dart';
import '../screens/notifications.dart';
import '../theme/app_colors.dart';
import '../screens/reminders/statistics_page.dart';

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
                Text(
                  'MediGo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.local_hospital, color: AppColors.primary, size: 24),
              ],
            ),

            // Notification Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Navigation buttons
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
                    MaterialPageRoute(builder: (_) => TrackingPage()),
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
                    MaterialPageRoute(builder: (_) => const EditPage()),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  static Widget _navButton(
    BuildContext context, {
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
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
