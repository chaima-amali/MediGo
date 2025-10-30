import 'package:flutter/material.dart';
import 'app_colors.dart';

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
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.search,
            activeIcon: Icons.search,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Icon(
          isActive ? activeIcon : icon,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }
}

// Example usage in your screen:
/*
class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const Center(child: Text('Home'));
      case 1:
        return const Center(child: Text('Search'));
      case 2:
        return const Center(child: Text('Calendar'));
      case 3:
        return const Center(child: Text('Profile'));
      default:
        return const Center(child: Text('Home'));
    }
  }
}
*/