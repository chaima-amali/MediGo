import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../services/mock_database_service.dart';
import '../widgets/back_arrow.dart';
import 'reservation_details.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  String _selectedTab = 'Active';
  List<Map<String, dynamic>> _reservations = [];
  // Using modal bottom sheet now; no local bool required

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    final allReservations = MockDataService.getUserReservations();
    setState(() {
      if (_selectedTab == 'Active') {
        _reservations = allReservations
            .where((r) => r['status'] == 'pending')
            .toList();
      } else if (_selectedTab == 'Completed') {
        _reservations = allReservations
            .where((r) => r['status'] == 'completed')
            .toList();
      } else if (_selectedTab == 'Cancelled') {
        _reservations = allReservations
            .where((r) => r['status'] == 'cancelled')
            .toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFF4D6);
      case 'confirmed':
        return const Color(0xFFD6F5F5);
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

  @override
  Widget build(BuildContext context) {
    final totalReservations = MockDataService.getUserReservations().length;

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
                          'My Reservations',
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
                            Expanded(child: _buildTab('Active')),
                            Expanded(child: _buildTab('Completed')),
                            Expanded(child: _buildTab('Cancelled')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Reservations list
                    Expanded(
                      child: _reservations.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              itemCount: _reservations.length,
                              itemBuilder: (context, index) {
                                final res = _reservations[index];
                                return InkWell(
                                  onTap: () {
                                    // Navigate to details screen with reservation id
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ReservationDetailsScreen(
                                              reservationId:
                                                  res['reservation_id'],
                                            ),
                                      ),
                                    );
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
                              return SafeArea(child: _buildStatusGuideSheet());
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
                                'Status Guide',
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
  }

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
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
            label,
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

  Widget _buildReservationCard(Map<String, dynamic> reservation) {
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
                      reservation['medicine_name'],
                      style: AppText.bold.copyWith(
                        fontSize: 16,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${reservation['quantity']}',
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
                  color: _getStatusColor(reservation['status']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reservation['status'],
                  style: AppText.medium.copyWith(
                    fontSize: 12,
                    color: _getStatusTextColor(reservation['status']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.darkBlue.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                reservation['pharmacy_name'] ?? 'PharmSync',
                style: AppText.regular.copyWith(
                  fontSize: 12,
                  color: AppColors.darkBlue.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.darkBlue.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                'Pickup: ${reservation['pickup_date']} at ${reservation['pickup_time']}',
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
            'No ${_selectedTab.toLowerCase()} reservations',
            style: AppText.medium.copyWith(
              fontSize: 16,
              color: AppColors.darkBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your reservations will appear here',
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
                  'Status Guide',
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
            title: 'Pending',
            description:
                'Reservation request submitted and waiting for pharmacy confirmation. You\'ll be notified once confirmed.',
          ),
          _buildStatusGuideItem(
            color: AppColors.success,
            title: 'Confirmed',
            description:
                'Pharmacy has confirmed your reservation. Medicine is ready for pickup at the scheduled date and time.',
          ),
          _buildStatusGuideItem(
            color: Colors.blue,
            title: 'Completed',
            description:
                'You\'ve successfully picked up the medicine from the pharmacy. Reservation is now complete.',
          ),
          _buildStatusGuideItem(
            color: AppColors.error,
            title: 'Cancelled',
            description:
                'Reservation was cancelled either by you, the pharmacy, or due to expiration. Medicine is no longer reserved.',
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
