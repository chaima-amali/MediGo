import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../services/mock_database_service.dart';
import '../widgets/back_arrow.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final String reservationId;

  const ReservationDetailsScreen({
    Key? key,
    required this.reservationId,
  }) : super(key: key);

  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  late Map<String, dynamic>? reservationData;
  late Map<String, dynamic>? pharmacyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservationData();
  }

  void _loadReservationData() {
    // Get reservation details
    reservationData = MockDataService.getReservationDetails(widget.reservationId);
    
    if (reservationData != null) {
      // Get pharmacy details
      pharmacyData = MockDataService.getPharmacyDetails(reservationData!['pharmacy_id']);
    }
    
    setState(() {
      isLoading = false;
    });
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cancel Reservation?',
                  style: AppText.bold.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to cancel this reservation? This action cannot be undone.',
                  style: AppText.regular.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Close dialog and update status
                      Navigator.pop(context);
                      
                      setState(() {
                        reservationData!['status'] = 'cancelled';
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Reservation cancelled successfully'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Yes, Cancel',
                      style: AppText.medium.copyWith(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Keep Reservation',
                      style: AppText.medium.copyWith(fontSize: 15),
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFEBF8F9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (reservationData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEBF8F9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.darkBlue, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Reservation not found',
                style: AppText.medium.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    final String status = reservationData!['status'];
    final bool isPending = status == 'pending';
    final bool isCancelled = status == 'cancelled';

    // Extract data
    final String medicineName = reservationData!['medicine_name'] ?? 'Unknown';
    final String dosage = reservationData!['dosage'] ?? '';
    final int quantity = reservationData!['quantity'] ?? 1;
    final String pickupDate = reservationData!['pickup_date'] ?? '';
    final String pickupTime = reservationData!['pickup_time'] ?? '';
    final String reservationCode = reservationData!['reservation_code'] ?? '';
    
    // Pharmacy data
    final String pharmacyName = pharmacyData?['name'] ?? 'Unknown Pharmacy';
    final double distanceKm = pharmacyData?['distance_km'] ?? 0.0;
    final String pharmacyAddress = pharmacyData?['address'] ?? '';
    final String pharmacyPhone = pharmacyData?['phone_number'] ?? '';
    final String pharmacyHours = pharmacyData?['opening_hours'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFEBF8F9),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                 CustomBackArrow(),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservation Details',
                          style: AppText.bold.copyWith(fontSize: 22),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCancelled 
                                ? const Color(0xFFFFE5E5) 
                                : const Color(0xFFFFF4D6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isCancelled ? 'cancelled' : 'pending',
                            style: AppText.medium.copyWith(
                              fontSize: 12,
                              color: isCancelled 
                                  ? AppColors.error 
                                  : const Color(0xFFFF9800),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Medicine Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8D4FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.medication,
                                  color: Color(0xFF9C27B0),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$medicineName${dosage.isNotEmpty ? " $dosage" : ""}',
                                      style: AppText.medium.copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Quantity: $quantity',
                                      style: AppText.regular.copyWith(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Pickup Date
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, 
                                  color: Colors.grey[600], size: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup Date',
                                    style: AppText.regular.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pickupDate,
                                    style: AppText.medium.copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Pickup Time
                          Row(
                            children: [
                              Icon(Icons.access_time, 
                                  color: Colors.grey[600], size: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup Time',
                                    style: AppText.regular.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pickupTime,
                                    style: AppText.medium.copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pharmacy Information Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pharmacy Information',
                            style: AppText.bold.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pharmacyName,
                                style: AppText.medium.copyWith(fontSize: 15),
                              ),
                              Text(
                                '${distanceKm}km away',
                                style: AppText.regular.copyWith(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, 
                                  color: Colors.grey[600], size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  pharmacyAddress,
                                  style: AppText.regular.copyWith(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, 
                                  color: Colors.grey[600], size: 18),
                              const SizedBox(width: 12),
                              Text(
                                pharmacyPhone,
                                style: AppText.regular.copyWith(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.access_time_outlined, 
                                  color: Colors.grey[600], size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  pharmacyHours,
                                  style: AppText.regular.copyWith(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Only show for pending status
                    if (isPending) ...[
                      const SizedBox(height: 16),
                      // Awaiting Confirmation Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4D6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFFFF9800),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Awaiting Confirmation',
                                    style: AppText.medium.copyWith(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'The pharmacy will confirm your reservation shortly. You will be notified once it\'s ready.',
                                    style: AppText.regular.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening directions...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.location_on_outlined, size: 18),
                          label: const Text('Get Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling $pharmacyPhone...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone_outlined, size: 18),
                          label: const Text('Contact Pharmacy'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _showCancelDialog,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel Reservation',
                            style: AppText.medium.copyWith(
                              fontSize: 15,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Reservation ID and Created Date
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Reservation ID:',
                            style: AppText.regular.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            reservationCode,
                            style: AppText.medium.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Created: 28/10/2025\n16:24:06',
                            textAlign: TextAlign.center,
                            style: AppText.regular.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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
}
