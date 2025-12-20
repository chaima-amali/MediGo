import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/theme/app_text.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import 'package:frontend/data/repositories/reservation_repo.dart';
import 'package:frontend/data/repositories/pharmacy_repo.dart';
import 'package:frontend/data/models/reservation.dart';
import 'package:frontend/data/models/pharmacy.dart';
import 'package:frontend/logic/cubits/reservation_cubit.dart';
import 'package:intl/intl.dart';
import 'reservation_confirm.dart' show ReservationDetailsPage;
import 'reservation_complete.dart' show ReservationCompletePage;
import 'reservation_pending.dart';
import 'reservation_cancelled.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final String reservationId;

  const ReservationDetailsScreen({Key? key, required this.reservationId})
    : super(key: key);

  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  Reservation? reservationData;
  Pharmacy? pharmacyData;
  final ReservationRepository _reservationRepo = ReservationRepository();
  final PharmacyRepository _pharmacyRepo = PharmacyRepository();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservationData();
  }

  Future<void> _loadReservationData() async {
    final reservationId = int.tryParse(widget.reservationId);

    if (reservationId == null) {
      debugPrint('❌ Invalid reservation ID: ${widget.reservationId}');
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Get reservation details from database
    final reservation = await _reservationRepo.getReservationById(
      reservationId,
    );

    debugPrint('📋 Reservation loaded: ${reservation?.toMap()}');
    debugPrint('🏥 Pharmacy ID from reservation: ${reservation?.pharmacyId}');

    // Get pharmacy details if pharmacy_id exists
    Pharmacy? pharmacy;
    if (reservation != null && reservation.pharmacyId != null) {
      debugPrint('🔍 Fetching pharmacy with ID: ${reservation.pharmacyId}');
      pharmacy = await _pharmacyRepo.getPharmacyById(reservation.pharmacyId!);
      debugPrint('🏥 Pharmacy loaded: ${pharmacy?.toMap()}');
    } else {
      debugPrint('⚠️ No pharmacy ID in reservation');
    }

    setState(() {
      reservationData = reservation;
      pharmacyData = pharmacy;
      isLoading = false;
    });

    // If the reservation is a confirmed/completed type, navigate to the
    // dedicated page so the correct UI is shown (avoid overlapping pending UI).
    if (reservationData != null) {
      final status = reservationData!.status;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (status == 'pending') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ReservationPendingPage(
                reservationId: reservationData!.reservationId!,
              ),
            ),
          );
        } else if (status == 'confirmed') {
          // Open the confirm-style page and replace this route.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ReservationDetailsPage(
                reservationId: reservationData!.reservationId!,
              ),
            ),
          );
        } else if (status == 'completed') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ReservationCompletePage(
                reservationId: reservationData!.reservationId!,
              ),
            ),
          );
        } else if (status == 'cancelled') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ReservationCancelledPage(
                reservationId: reservationData!.reservationId!,
              ),
            ),
          );
        }
      });
    }
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
                  AppLocalizations.of(context)!.cancelReservation,
                  style: AppText.bold.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.reserveCancelQuestion,
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
                    onPressed: () async {
                      // Close dialog
                      Navigator.pop(context);

                      // Update status in database
                      await _reservationRepo.updateReservationStatus(
                        reservationData!.reservationId!,
                        'cancelled',
                      );

                      setState(() {
                        reservationData = reservationData!.copyWith(
                          status: 'cancelled',
                        );
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.reservationCancelledSuccess,
                          ),
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
                      AppLocalizations.of(context)!.yesCancelReservation,
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
                      AppLocalizations.of(context)!.keepReservation,
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
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
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
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.darkBlue,
                size: 20,
              ),
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
                AppLocalizations.of(context)!.reservationNotFound,
                style: AppText.medium.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    final String status = reservationData!.status;
    final bool isPending = status == 'pending';
    final bool isCancelled = status == 'cancelled';
    final bool isCompleted = status == 'completed';
    final bool isConfirmed = status == 'confirmed';

    // Extract data from Reservation model
    final String medicineName =
        reservationData!.medicineName ??
        'Reservation #${reservationData!.reservationId}';
    final int quantity = reservationData!.quantity;
    final String pickupDate = reservationData!.day;
    final String pickupTime = reservationData!.time;

    // Format creation time
    String createdAtFormatted = 'N/A';
    if (reservationData!.createdAt != null) {
      try {
        final createdAt = DateTime.parse(reservationData!.createdAt!);
        createdAtFormatted = DateFormat(
          'dd/MM/yyyy\nHH:mm:ss',
        ).format(createdAt);
      } catch (e) {
        createdAtFormatted = reservationData!.createdAt!;
      }
    }

    // Pharmacy data from fetched pharmacy object
    final String pharmacyName = pharmacyData?.name ?? 'Pharmacy';
    final double distanceKm =
        0.0; // Can calculate from pharmacy lat/lng if needed
    final String pharmacyAddress = pharmacyData != null
        ? 'Lat: ${pharmacyData!.latitude}, Lng: ${pharmacyData!.longitude}'
        : 'Address not available';
    final String pharmacyPhone = pharmacyData?.phone ?? 'N/A';
    final String pharmacyHours = pharmacyData?.openingHours ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFFEBF8F9),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackArrow(),
                  // Delete icon for cancelled reservations
                  if (isCancelled)
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Delete Reservation',
                                style: AppText.bold.copyWith(fontSize: 18),
                              ),
                              content: Text(
                                'Are you sure you want to permanently delete this reservation?',
                                style: AppText.regular,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    await context
                                        .read<ReservationCubit>()
                                        .deleteReservation(
                                          reservationData!.reservationId!,
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Reservation deleted successfully',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.delete_outline, color: AppColors.error),
                    ),
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
                        // Use Flexible to avoid overflow on narrow screens
                        Flexible(
                          child: Text(
                            'Reservation Details',
                            style: AppText.bold.copyWith(fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isCancelled
                                ? const Color(0xFFFFE5E5)
                                : const Color(0xFFFFF4D6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Builder(
                            builder: (_) {
                              String label = 'pending';
                              Color textColor = const Color(0xFFFF9800);
                              Color bg = const Color(0xFFFFF4D6);
                              if (isCancelled) {
                                label = 'cancelled';
                                textColor = AppColors.error;
                                bg = const Color(0xFFFFE5E5);
                              } else if (isCompleted) {
                                label = 'completed';
                                textColor = Colors.blue;
                                bg = const Color(0xFFE3F2FD);
                              } else if (isConfirmed) {
                                label = 'confirmed';
                                textColor = AppColors.success;
                                bg = const Color(0xFFE8F5E9);
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  label,
                                  style: AppText.medium.copyWith(
                                    fontSize: 12,
                                    color: textColor,
                                  ),
                                ),
                              );
                            },
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
                                      medicineName,
                                      style: AppText.medium.copyWith(
                                        fontSize: 16,
                                      ),
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
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.pickupDate,
                                    style: AppText.regular.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pickupDate,
                                    style: AppText.medium.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Pickup Time
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.pickupTime,
                                    style: AppText.regular.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pickupTime,
                                    style: AppText.medium.copyWith(
                                      fontSize: 14,
                                    ),
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
                            AppLocalizations.of(context)!.pharmacyInformation,
                            style: AppText.bold.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Wrap the pharmacy name so long names don't overflow
                              Expanded(
                                child: Text(
                                  pharmacyName,
                                  style: AppText.medium.copyWith(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
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
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.grey[600],
                                size: 18,
                              ),
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
                              Icon(
                                Icons.phone_outlined,
                                color: Colors.grey[600],
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  pharmacyPhone,
                                  style: AppText.regular.copyWith(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                color: Colors.grey[600],
                                size: 18,
                              ),
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
                                    AppLocalizations.of(
                                      context,
                                    )!.awaitingConfirmation,
                                    style: AppText.medium.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.pharmacyWillConfirm,
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

                      // Confirm Button (manual confirmation)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await context
                                .read<ReservationCubit>()
                                .updateReservationStatus(
                                  reservationData!.reservationId!,
                                  'confirmed',
                                );
                            setState(() {
                              reservationData = reservationData!.copyWith(
                                status: 'confirmed',
                              );
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Reservation confirmed successfully',
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Confirm Reservation',
                            style: AppText.medium.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.openingDirections,
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.getDirections,
                          ),
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
                                content: Text(
                                  '${AppLocalizations.of(context)!.calling} $pharmacyPhone...',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone_outlined, size: 18),
                          label: Text(
                            AppLocalizations.of(context)!.contactPharmacy,
                          ),
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
                            AppLocalizations.of(context)!.cancelReservation,
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
                            AppLocalizations.of(context)!.reservationId,
                            style: AppText.regular.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'RES-${reservationData!.reservationId}',
                            style: AppText.medium.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.of(context)!.created}: $createdAtFormatted',
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
