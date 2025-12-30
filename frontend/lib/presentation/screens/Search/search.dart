import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/pharmacy.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/logic/cubits/medicine_search_cubit.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/services/location_service.dart';
import 'package:frontend/data/repositories/medicine_search_history_repo.dart';
import 'package:frontend/data/repositories/medicine_find_repo.dart';
import '../notifications.dart' as notif_page;
import 'pharmacy_details_screen.dart';
import '../Reservations/reservations_form.dart';
import '../Profile/subscription_page.dart';

// Search Screen
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      context.read<MedicineSearchCubit>().clearSearch();
    } else {
      context.read<MedicineSearchCubit>().searchMedicine(query);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.darkBlue;
    final hintColor = isDark
        ? Colors.white70
        : const Color.fromARGB(255, 161, 161, 161);

    // Helper for tab button background
    Color getTabButtonColor(bool active) {
      if (active) return AppColors.lightBlue;
      return isDark ? Colors.black : Colors.white;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: isDark
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.lightBlue.withOpacity(0.3), Colors.white],
                ),
              ),
        color: isDark ? Colors.black : null,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                          Icon(
                            Icons.local_hospital,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const notif_page.NotificationsPage(),
                            ),
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
                                  width: 8,
                                  height: 8,
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
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    AppLocalizations.of(context)!.searchMedicines,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.lightBlue, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _performSearch,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              )!.searchMedicinePrompt,
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search Results
                  SizedBox(
                    height: 400,
                    child: BlocBuilder<MedicineSearchCubit, MedicineSearchState>(
                      builder: (context, state) {
                        if (state is MedicineSearchInitial) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medication_outlined,
                                  size: 80,
                                  color: AppColors.darkBlue.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.searchMedicinesDescription,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : AppColors.darkBlue.withOpacity(0.6),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is MedicineSearchLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        }

                        if (state is MedicineSearchEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 80,
                                    color: AppColors.darkBlue.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : AppColors.darkBlue.withOpacity(0.6),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Get notified when "${state.searchQuery}" is back in stock',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.darkBlue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _handleRestockNotification(
                                      context,
                                      state.searchQuery,
                                    ),
                                    icon: const Icon(
                                      Icons.notifications_active,
                                    ),
                                    label: const Text('Notify Me'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.premiumOrange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (state is MedicineSearchError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 80,
                                  color: Colors.red.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is MedicineSearchLoaded) {
                          return _buildSearchResults(context, state.results);
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<Map<String, dynamic>> results,
  ) {
    // Get user location for distance calculation
    User? currentUser;
    final userState = context.watch<UserCubit>().state;
    if (userState is UserAuthenticated) {
      currentUser = userState.user;
    } else if (userState is UserLoaded) {
      currentUser = userState.user;
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];

        // Calculate distance if user has location
        double? distance;
        if (currentUser != null &&
            currentUser.latitude != null &&
            currentUser.longitude != null &&
            result['latitude'] != null &&
            result['longitude'] != null) {
          distance = LocationService.calculateDistance(
            currentUser.latitude!,
            currentUser.longitude!,
            result['latitude'],
            result['longitude'],
          );
        }

        return _buildPharmacyCard(context, result, distance);
      },
    );
  }

  Widget _buildPharmacyCard(
    BuildContext context,
    Map<String, dynamic> result,
    double? distance,
  ) {
    final inStock = (result['stock'] as int) > 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Name
          Text(
            result['medicine_name'] ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),

          // Pharmacy Name
          GestureDetector(
            onTap: () {
              final pharmacyMap = {
                'pharmacy_id': result['pharmacy_id'],
                'name': result['pharmacy_name'],
                'latitude': result['latitude'],
                'longitude': result['longitude'],
                'phone': result['phone'],
                'opening_hours': result['opening_hours'],
                'rating': result['rating'],
                if (distance != null) 'distance_km': distance,
              };
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PharmacyDetailScreen(pharmacy: pharmacyMap),
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    result['pharmacy_name'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkBlue,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Distance
          if (distance != null)
            Row(
              children: [
                Icon(Icons.navigation, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  LocationService.formatDistance(distance),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white70
                        : AppColors.darkBlue.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          if (distance != null) const SizedBox(height: 8),

          // Stock Status and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: inStock
                          ? AppColors.inStock.withOpacity(0.1)
                          : AppColors.outOfStock.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      inStock
                          ? AppLocalizations.of(context)!.inStock
                          : AppLocalizations.of(context)!.outOfStock,
                      style: TextStyle(
                        fontSize: 12,
                        color: inStock
                            ? AppColors.inStock
                            : AppColors.outOfStock,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (inStock) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${result['stock']} ${AppLocalizations.of(context)!.inStock.toLowerCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white70
                            : AppColors.darkBlue.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '${result['price']} DZD',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pre-Order Button
          if (inStock)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePreOrder(context, result),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.preOrder,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handlePreOrder(BuildContext context, Map<String, dynamic> result) {
    // Check if user is premium
    final userState = context.read<UserCubit>().state;
    User? currentUser;

    if (userState is UserAuthenticated) {
      currentUser = userState.user;
    } else if (userState is UserLoaded) {
      currentUser = userState.user;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.logIn),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check premium status
    if (currentUser.premium.toLowerCase() != 'premium') {
      _showPremiumRequiredDialog(context);
      return;
    }

    // Navigate to reservation form
    // Create pharmacy object with safe defaults
    final pharmacy = Pharmacy(
      pharmacyId: result['pharmacy_id'] as int?,
      name: result['pharmacy_name'] as String? ?? 'Unknown Pharmacy',
      latitude: (result['latitude'] as num?)?.toDouble(),
      longitude: (result['longitude'] as num?)?.toDouble(),
      phone:
          result['phone_number'] as String? ?? result['phone'] as String? ?? '',
      openingHours: result['opening_hours'] as String? ?? '8:00 AM - 9:00 PM',
      rating: (result['rating'] as num?)?.toDouble() ?? 0.0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReservationFormScreen(
          pharmacy: pharmacy,
          medicineName: result['medicine_name'] ?? '',
        ),
      ),
    );
  }

  void _showPremiumRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: AppColors.premiumOrange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.premiumFeature,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.premiumFeatureMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.darkBlue),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.premiumOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.upgradeToPremium,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Handle restock notification request
  void _handleRestockNotification(
    BuildContext context,
    String medicineName,
  ) async {
    // Check if user is logged in
    final userState = context.read<UserCubit>().state;
    User? currentUser;

    if (userState is UserAuthenticated) {
      currentUser = userState.user;
    } else if (userState is UserLoaded) {
      currentUser = userState.user;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.logIn),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check premium status
    if (currentUser.premium.toLowerCase() != 'premium') {
      _showPremiumRequiredForNotification(context);
      return;
    }

    // User is premium - save restock notification
    try {
      // Save restock notification request with medicine name
      // We use medicine name as the identifier since medicine_id references
      // the catalog which may not have this out-of-stock medicine
      final historyRepo = MedicineSearchHistoryRepository();
      await historyRepo.saveSearchWithNotification(
        userId: currentUser.userId!,
        medicineName: medicineName,
        notifyRestock: true,
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'ll be notified when "$medicineName" is back in stock',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.inStock,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving restock notification: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPremiumRequiredForNotification(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: AppColors.premiumOrange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.premiumFeature,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_active,
                size: 60,
                color: AppColors.premiumOrange,
              ),
              const SizedBox(height: 16),
              Text(
                'Restock notifications are a premium feature. Upgrade to get instant alerts when out-of-stock medicines become available!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.darkBlue),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.premiumOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.upgradeToPremium,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
