import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import 'package:frontend/presentation/services/mock_database_service.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/data/models/user.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
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

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark
            ? Theme.of(context).appBarTheme.backgroundColor
            : const Color(0xFFB2EBF2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: CustomBackArrow(),
        title: Text(
          loc.subscription,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
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
              Text(
                loc.upgradeToPremium,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.premiumDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey,
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
                    icon: _getIconForFeature(feature['icon'] ?? '⚡'),
                    iconColor: _getColorForFeature(index),
                    title: feature['title'] ?? '',
                    description: feature['description'] ?? '',
                  ),
                );
              }).toList(),

              const SizedBox(height: 32),

              // Monthly Plan Card
              if (monthlyPlan != null) _buildMonthlyPlanCard(monthlyPlan),

              const SizedBox(height: 16),

              // Yearly Plan Card
              if (yearlyPlan != null) _buildYearlyPlanCard(yearlyPlan),

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
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedPlan == 'monthly'
              ? (isDark ? AppColors.premiumOrange : const Color(0xFF4DD0E1))
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black54, blurRadius: 8)]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan['name'] ?? loc.monthly,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.billedMonthly,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$price$currency',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  loc.perMonth,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features
              .map((feature) => _buildPlanFeature(feature.toString()))
              .toList(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle monthly subscription
                _upgradeUserToPremium(plan['name']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.premiumOrange
                    : const Color(0xFF4DD0E1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                loc.subscribeMonthly,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.black : Colors.white,
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
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [AppColors.premiumGold, AppColors.premiumOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDark ? AppColors.surfaceDark : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedPlan == 'yearly' ? Colors.white : Colors.transparent,
          width: 2,
        ),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black54, blurRadius: 8)]
            : [],
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
                    plan['name'] ?? loc.yearly,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.billedAnnually,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.white,
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
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  loc.perMonth,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  loc.perYear,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features
              .map(
                (feature) =>
                    _buildPlanFeature(feature.toString(), isWhite: true),
              )
              .toList(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle yearly subscription
                _upgradeUserToPremium(plan['name']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                loc.subscribeYearly,
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
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black54, blurRadius: 8)]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey,
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
                color: isWhite
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _upgradeUserToPremium(String planName) async {
    final userCubit = context.read<UserCubit>();
    final currentState = userCubit.state;

    // Get current user from state
    User? currentUser;
    if (currentState is UserAuthenticated) {
      currentUser = currentState.user;
    } else if (currentState is UserLoaded) {
      currentUser = currentState.user;
    }

    if (currentUser == null || currentUser.userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error: User not found')));
      return;
    }

    // Update premium status in database
    await userCubit.updateUserPremium(currentUser.userId!, true);

    // Show success dialog
    _showSubscriptionSuccess(planName);
  }

  void _showSubscriptionSuccess(String planName) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Text(loc.success),
          ],
        ),
        content: Text(
          loc.subscriptionSuccessMessage,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to profile page
            },
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }
}
