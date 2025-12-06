import 'package:flutter/material.dart';
import 'package:frontend/presentation/screens/reminders/tracking_page.dart';
import '../theme/app_colors.dart';

import '../screens/reminders/edit_page.dart';
import '../screens/reminders/statistics_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // determine if we're inside the tracking-related pages (so calendar icon stays active)
    bool _isCalendarActive(BuildContext ctx) {
      return ctx.findAncestorWidgetOfExactType<TrackingPage>() != null ||
          ctx.findAncestorWidgetOfExactType<EditPage>() != null ||
          ctx.findAncestorWidgetOfExactType<StatisticsPage>() != null;
    }

    final bool isCalendarActive = _isCalendarActive(context);

    return Container(
      height: 70,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          _buildNavItem(
            context,
            index: 1,
            icon: Icons.search,
            activeIcon: Icons.search,
          ),
          // ✅ Calendar icon: navigates to TrackingPage and stays colored there / in related pages
          _buildNavItem(
            context,
            index: 2,
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            isCalendar: true,
            isCalendarActive: isCalendarActive,
          ),
          _buildNavItem(
            context,
            index: 3,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    bool isCalendar = false,
    bool isCalendarActive = false,
  }) {
    // Calendar should be active when either the tracking-related pages are
    // active (isCalendarActive) OR when the main currentIndex matches.
    final isActive = isCalendar
        ? (currentIndex == index || isCalendarActive)
        : (currentIndex == index);

    // matches the other icons when selected.
    final Color activeColor = AppColors.primary;

    return GestureDetector(
      onTap: () {
        // Use the provided callback to switch tabs in the MainScreen.
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? activeColor : Colors.black54,
          size: 28,
        ),
      ),
    );
  }
}
