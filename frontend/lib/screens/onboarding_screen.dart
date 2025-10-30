import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.location_on,
      iconColor: AppColors.primary,
      title: 'Find Nearby Pharmacies',
      description:
          'Discover pharmacies near you with real-time distance tracking and easy navigation.',
    ),
    OnboardingData(
      icon: Icons.search,
      iconColor: Color(0xFF9C27B0),
      title: 'Search for Medicines',
      description:
          'Quickly find the medicines you need with our smart search feature.',
    ),
    OnboardingData(
      icon: Icons.notifications,
      iconColor: Color(0xFFE91E63),
      title: 'Medicine Reminders',
      description:
          'Never miss your medication with personalized reminders and treatment tracking.',
    ),
    OnboardingData(
      icon: Icons.phone,
      iconColor: Color(0xFF00BFA5),
      title: 'Contact & Directions',
      description:
          'Get detailed pharmacy information, directions, and contact them directly from the app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _goToLogin(),
                child: Text(
                  'Skip',
                  style: AppText.medium.copyWith(
                    fontSize: 16,
                    color: AppColors.darkBlue.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _goToLogin();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                    style: AppText.medium.copyWith(
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  OnboardingData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  String _getImageUrl(String title) {
    // Placeholder images based on the feature
    switch (title) {
      case 'Find Nearby Pharmacies':
        return 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&q=80'; // Pharmacy storefront
      case 'Search for Medicines':
        return 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=800&q=80'; // Medicine pills
      case 'Medicine Reminders':
        return 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&q=80'; // Medical workspace
      case 'Contact & Directions':
        return 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80'; // Map/directions
      default:
        return 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&q=80';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: data.iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 52, color: AppColors.white),
          ),
          const SizedBox(height: 16),
          // Image / illustration (flexible to avoid overflow)
          Flexible(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBlue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  _getImageUrl(data.title),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.darkBlue.withOpacity(0.05),
                    alignment: Alignment.center,
                    child: Icon(
                      data.icon,
                      size: 80,
                      color: AppColors.darkBlue.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            data.title,
            style: AppText.bold.copyWith(
              fontSize: 24,
              color: AppColors.darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            data.description,
            style: AppText.regular.copyWith(
              fontSize: 14,
              color: AppColors.darkBlue.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
