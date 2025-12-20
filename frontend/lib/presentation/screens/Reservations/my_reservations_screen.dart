import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/theme/app_text.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/logic/cubits/reservation_cubit.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/data/models/reservation.dart';
import 'reservation_details.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  String _selectedTab = 'active'; // Use lowercase keys for consistency

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    final userState = context.read<UserCubit>().state;
    int userId = 0;

    if (userState is UserAuthenticated) {
      userId = userState.user.userId!;
    } else if (userState is UserLoaded) {
      userId = userState.user.userId!;
    }

    if (userId != 0) {
      context.read<ReservationCubit>().loadUserReservations(userId);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFF4D6);
      case 'confirmed':
        return const Color(0xFFE8F5E9); // Light green background
      case 'completed':
        return const Color(0xFFE3F2FD);
      case 'cancelled':
        return const Color(0xFFFFE5E5);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'confirmed':
        return AppColors.success;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getLocalizedStatus(String status, AppLocalizations loc) {
    switch (status) {
      case 'pending':
        return loc.pending;
      case 'confirmed':
        return loc.confirmed;
      case 'completed':
        return loc.completed;
      case 'cancelled':
        return loc.cancelled;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocBuilder<ReservationCubit, ReservationState>(
      builder: (context, state) {
        List<Reservation> allReservations = [];

        if (state is ReservationLoaded) {
          allReservations = state.reservations;
        }

        // Filter by selected tab
        List<Reservation> filteredReservations = [];
        if (_selectedTab == 'active') {
          // Active tab shows both pending and confirmed reservations
          filteredReservations = allReservations
              .where((r) => r.status == 'pending' || r.status == 'confirmed')
              .toList();
        } else if (_selectedTab == 'completed') {
          filteredReservations = allReservations
              .where((r) => r.status == 'completed')
              .toList();
        } else if (_selectedTab == 'cancelled') {
          filteredReservations = allReservations
              .where((r) => r.status == 'cancelled')
              .toList();
        }

        final totalReservations = allReservations.length;

        return Scaffold(
          // Full-bleed pale cyan header background to match design
          backgroundColor: AppColors.lightBlue,
          body: SafeArea(
            child: Column(
              children: [
                // Header (styled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      CustomBackArrow(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        // mint background for the rounded back bubble (matches design)
                        backgroundColor: AppColors.mint,
                        iconColor: AppColors.darkBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.myReservations,
                              style: AppText.bold.copyWith(
                                fontSize: 22,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalReservations total',
                              style: AppText.regular.copyWith(
                                fontSize: 13,
                                color: AppColors.darkBlue.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content (white rounded sheet overlapping header)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBlue.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Total reservations
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '$totalReservations total reservations',
                                  style: AppText.regular.copyWith(
                                    fontSize: 14,
                                    color: AppColors.darkBlue.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Tabs
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.darkBlue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildTab('active', loc.active),
                                ),
                                Expanded(
                                  child: _buildTab('completed', loc.completed),
                                ),
                                Expanded(
                                  child: _buildTab('cancelled', loc.cancelled),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Reservations list
                        Expanded(
                          child: state is ReservationLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                )
                              : filteredReservations.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  itemCount: filteredReservations.length,
                                  itemBuilder: (context, index) {
                                    final res = filteredReservations[index];
                                    return InkWell(
                                      onTap: () async {
                                        // Navigate to details screen with reservation id
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ReservationDetailsScreen(
                                                  reservationId: res
                                                      .reservationId!
                                                      .toString(),
                                                ),
                                          ),
                                        );
                                        // Reload reservations after returning from details
                                        _loadReservations();
                                      },
                                      child: _buildReservationCard(res),
                                    );
                                  },
                                ),
                        ),
                        // Status Guide Button
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: GestureDetector(
                            onTap: () {
                              // Open modal bottom sheet; it can be dismissed by tapping outside or swiping down
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (BuildContext ctx) {
                                  return SafeArea(
                                    child: _buildStatusGuideSheet(),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bar_chart,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.statusGuide,
                                    style: AppText.medium.copyWith(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String key, String displayText) {
    final isSelected = _selectedTab == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = key;
        });
        _loadReservations();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.darkBlue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            displayText,
            style: AppText.medium.copyWith(
              fontSize: 14,
              color: isSelected
                  ? AppColors.darkBlue
                  : AppColors.darkBlue.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.medicineName ??
                          'Reservation #${reservation.reservationId}',
                      style: AppText.bold.copyWith(
                        fontSize: 16,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${loc.quantity}: ${reservation.quantity}',
                      style: AppText.regular.copyWith(
                        fontSize: 12,
                        color: AppColors.darkBlue.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(reservation.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getLocalizedStatus(reservation.status, loc),
                  style: AppText.medium.copyWith(
                    fontSize: 12,
                    color: _getStatusTextColor(reservation.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.darkBlue.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${loc.pickup}: ${reservation.day} ${loc.at} ${reservation.time}',
                style: AppText.regular.copyWith(
                  fontSize: 12,
                  color: AppColors.darkBlue.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final loc = AppLocalizations.of(context)!;
    String emptyMessage;
    if (_selectedTab == 'active') {
      emptyMessage = loc.noActiveReservations;
    } else if (_selectedTab == 'completed') {
      emptyMessage = loc.noCompletedReservations;
    } else {
      emptyMessage = loc.noCancelledReservations;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.darkBlue.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: AppText.medium.copyWith(
              fontSize: 16,
              color: AppColors.darkBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.yourReservationsWillAppearHere,
            style: AppText.regular.copyWith(
              fontSize: 14,
              color: AppColors.darkBlue.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGuideSheet() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.bar_chart, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  loc.statusGuide,
                  style: AppText.bold.copyWith(
                    fontSize: 18,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Status items
          _buildStatusGuideItem(
            color: const Color(0xFFF59E0B),
            title: loc.pending,
            description: loc.pendingDescription,
          ),
          _buildStatusGuideItem(
            color: AppColors.success,
            title: loc.confirmed,
            description: loc.confirmedDescription,
          ),
          _buildStatusGuideItem(
            color: Colors.blue,
            title: loc.completed,
            description: loc.completedDescription,
          ),
          _buildStatusGuideItem(
            color: AppColors.error,
            title: loc.cancelled,
            description: loc.cancelledDescription,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusGuideItem({
    required Color color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.bold.copyWith(
                    fontSize: 14,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppText.regular.copyWith(
                    fontSize: 12,
                    color: AppColors.darkBlue.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
