import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import '../widgets/back_arrow.dart';
import '../services/mock_database_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selectedPlan = 'yearly'; // 'monthly' or 'yearly'
  late List<Map<String, dynamic>> subscriptionPlans;
  late List<Map<String, dynamic>> premiumFeatures;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    subscriptionPlans = MockDataService.getSubscriptionPlans();
    premiumFeatures = MockDataService.getPremiumFeatures();
    
    // Set default selected plan to yearly if it exists
    if (subscriptionPlans.any((p) => p['billing_period'] == 'yearly')) {
      selectedPlan = 'yearly';
    } else if (subscriptionPlans.isNotEmpty) {
      selectedPlan = subscriptionPlans[0]['billing_period'];
    }
  }

  // Get plan data by billing period
  Map<String, dynamic>? getPlanByPeriod(String period) {
    try {
      return subscriptionPlans.firstWhere(
        (plan) => plan['billing_period'] == period,
      );
    } catch (e) {
      return null;
    }
  }

  // Get icon for feature emoji
  IconData _getIconForFeature(String emoji) {
    switch (emoji) {
      case '⚡':
        return Icons.flash_on;
      case '🔔':
        return Icons.notifications_active;
      case '✨':
        return Icons.shield_outlined;
      default:
        return Icons.star;
    }
  }

  // Get color for feature icon
  Color _getColorForFeature(int index) {
    final colors = [
      const Color(0xFFFF9800),
      const Color(0xFFFF6B6B),
      const Color(0xFF4DD0E1),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final monthlyPlan = getPlanByPeriod('monthly');
    final yearlyPlan = getPlanByPeriod('yearly');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFB2EBF2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: CustomBackArrow(),
        title: const Text(
          'Subscription',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Premium Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.premiumOrange, Color(0xFFFF9800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // Title and Subtitle
              const Text(
                'Upgrade to Premium',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unlock exclusive features and enhance\nyour medicine management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              
              // Features from mock data
              ...premiumFeatures.asMap().entries.map((entry) {
                final index = entry.key;
                final feature = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFeatureCard(
                    icon: _getIconForFeature(feature['icon']),
                    iconColor: _getColorForFeature(index),
                    title: feature['title'],
                    description: feature['description'],
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 32),
              // Choose Your Plan
              const Text(
                'Choose Your Plan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Monthly Plan (if exists)
              if (monthlyPlan != null) ...[
                GestureDetector(
                  onTap: () => setState(() => selectedPlan = 'monthly'),
                  child: _buildMonthlyPlanCard(monthlyPlan),
                ),
                const SizedBox(height: 16),
              ],
              
              // Yearly Plan (if exists)
              if (yearlyPlan != null) ...[
                GestureDetector(
                  onTap: () => setState(() => selectedPlan = 'yearly'),
                  child: _buildYearlyPlanCard(yearlyPlan),
                ),
              ],
              
              const SizedBox(height: 24),
              // Terms
              const Text(
                'By subscribing, you agree to our Terms of Service\nand Privacy Policy.\nSubscription auto-renews unless cancelled.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyPlanCard(Map<String, dynamic> plan) {
    final features = plan['features'] as List<dynamic>? ?? [];
    final price = plan['price'] ?? 0;
    final currency = plan['currency'] ?? 'DA';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedPlan == 'monthly'
              ? const Color(0xFF4DD0E1)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan['name'] ?? 'Monthly',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Billed monthly',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$price$currency',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '/month',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => _buildPlanFeature(feature.toString())).toList(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle monthly subscription
                _showSubscriptionSuccess(plan['name']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DD0E1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Subscribe Monthly',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyPlanCard(Map<String, dynamic> plan) {
    final features = plan['features'] as List<dynamic>? ?? [];
    final price = plan['price'] ?? 0;
    final currency = plan['currency'] ?? 'DA';
    final discountPercentage = plan['discount_percentage'] ?? 0;
    final badge = plan['badge'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.premiumGold, AppColors.premiumOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedPlan == 'yearly' ? Colors.white : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan['name'] ?? 'Yearly',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Billed annually',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.premiumOrange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$price$currency',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '/month',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${price * 12} $currency per year',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => _buildPlanFeature(feature.toString(), isWhite: true)).toList(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle yearly subscription
                _showSubscriptionSuccess(plan['name']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Subscribe Yearly (Best Value)',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.premiumOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanFeature(String text, {bool isWhite = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: isWhite ? Colors.white : const Color(0xFF4DD0E1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isWhite ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionSuccess(String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            const Text('Success!'),
          ],
        ),
        content: Text(
          'You\'ve successfully subscribed to the $planName plan!',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to profile page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}