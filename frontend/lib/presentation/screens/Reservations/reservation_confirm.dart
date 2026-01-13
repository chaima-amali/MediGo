import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/theme/app_text.dart';
import 'package:frontend/data/repositories/reservation_repo.dart';
import 'package:frontend/data/repositories/pharmacy_repo.dart';
import 'package:frontend/data/models/reservation.dart';
import 'package:frontend/data/models/pharmacy.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

// Custom Back Arrow Widget
class CustomBackArrow extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? imagePath;
  final double size;

  const CustomBackArrow({
    Key? key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.imagePath,
    this.size = 40,
  }) : super(key: key);

  factory CustomBackArrow.withImage({
    Key? key,
    VoidCallback? onPressed,
    String imagePath = 'images/back_arrow.png',
    Color backgroundColor = const Color(0xFF80DEEA),
    Color iconColor = const Color(0xFF4DD0E1),
    double size = 40,
  }) {
    return CustomBackArrow(
      key: key,
      onPressed: onPressed,
      imagePath: imagePath,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color.fromARGB(255, 160, 238, 248),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed ?? () => Navigator.pop(context),
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(8),
            child: imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: 24,
                    height: 24,
                    color: iconColor ?? const Color(0xFF4DD0E1),
                    fit: BoxFit.contain,
                  )
                : Icon(
                    Icons.arrow_back_ios_new,
                    color: iconColor ?? const Color(0xFF4DD0E1),
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}

// Reservation Details Page
class ReservationDetailsPage extends StatefulWidget {
  final int reservationId;

  const ReservationDetailsPage({Key? key, required this.reservationId})
    : super(key: key);

  @override
  State<ReservationDetailsPage> createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage> {
  final ReservationRepository _reservationRepo = ReservationRepository();
  final PharmacyRepository _pharmacyRepo = PharmacyRepository();
  Reservation? reservation;
  Pharmacy? pharmacy;
  String confirmationCode = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservationData();
  }

  Future<void> _loadReservationData() async {
    final res = await _reservationRepo.getReservationById(widget.reservationId);

    if (res != null && res.pharmacyId != null) {
      final pharm = await _pharmacyRepo.getPharmacyById(res.pharmacyId!);
      setState(() {
        reservation = res;
        pharmacy = pharm;
        confirmationCode = _generateConfirmationCode(widget.reservationId);
        isLoading = false;
      });
    } else {
      debugPrint('⚠️ Reservation is null or has no pharmacy_id');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _generateConfirmationCode(int reservationId) {
    // Generate a 6-digit code based on reservation ID + random component
    final random = Random(reservationId);
    final code = (100000 + random.nextInt(900000)).toString();
    return code;
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: confirmationCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.codeCopiedToClipboard),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.qrCode,
                style: AppText.bold.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightBlue),
                ),
                child: Column(
                  children: [
                    Icon(Icons.qr_code_2, size: 200, color: AppColors.darkBlue),
                    const SizedBox(height: 12),
                    Text(
                      confirmationCode,
                      style: AppText.bold.copyWith(
                        fontSize: 24,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Show this QR code at the pharmacy',
                textAlign: TextAlign.center,
                style: AppText.regular.copyWith(color: AppColors.darkBlue),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightBlue,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (reservation == null) {
      return Scaffold(
        backgroundColor: AppColors.lightBlue,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
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

    final medicineName = reservation!.medicineName ?? 'Medicine';
    final pharmacyName = pharmacy?.name ?? 'Pharmacy';
    final pickupDate = reservation!.day;
    final pickupTime = reservation!.time;
    final quantity = reservation!.quantity;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.lightBlue.withOpacity(0.3), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CustomBackArrow(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.reservationDetails,
                        style: AppText.bold.copyWith(
                          fontSize: 16,
                          color: AppColors.darkBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.confirmed,
                        style: AppText.bold.copyWith(
                          fontSize: 11,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verification Code Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.pickupCode,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              confirmationCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: _copyCode,
                              icon: const Icon(
                                Icons.copy,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.copyCode,
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _showQRCode,
                              icon: const Icon(
                                Icons.qr_code,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.showQrCode,
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.showCodeAtPickup,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Medicine Info Card
                      _buildInfoCard(
                        icon: Icons.medical_services,
                        title: medicineName,
                        subtitle: 'Quantity: $quantity',
                        color: AppColors.pink,
                      ),
                      const SizedBox(height: 16),

                      // Pickup Date Card
                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: AppLocalizations.of(context)!.pickupDate,
                        subtitle: pickupDate,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),

                      // Pickup Time Card
                      _buildInfoCard(
                        icon: Icons.access_time,
                        title: AppLocalizations.of(context)!.pickupTime,
                        subtitle: pickupTime,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 24),

                      // Pharmacy Information Section
                      Text(
                        AppLocalizations.of(context)!.pharmacyInformation,
                        style: AppText.bold.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.local_pharmacy,
                        title: pharmacyName,
                        subtitle: pharmacy?.phone ?? '',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.location_on,
                        title: pharmacyName,
                        subtitle: 'View on map for detailed directions',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.access_time,
                        title: pharmacy?.openingHours ?? 'Hours not available',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.watch_later,
                        title: AppLocalizations.of(context)!.readyForPickup,
                        subtitle: AppLocalizations.of(
                          context,
                        )!.readyForPickupMessage,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (pharmacy != null &&
                                pharmacy!.latitude != null &&
                                pharmacy!.longitude != null) {
                              final url = Uri.parse(
                                'https://www.google.com/maps/dir/?api=1&destination=${pharmacy!.latitude},${pharmacy!.longitude}',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.directions, size: 20),
                          label: Text(
                            AppLocalizations.of(context)!.getDirections,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            if (pharmacy != null) {
                              final url = Uri.parse('tel:${pharmacy!.phone}');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            }
                          },
                          icon: const Icon(Icons.phone, size: 20),
                          label: Text(
                            AppLocalizations.of(context)!.contactPharmacy,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Show confirmation dialog
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text(
                                    'Complete Reservation',
                                    style: AppText.bold.copyWith(fontSize: 18),
                                  ),
                                  content: Text(
                                    'Mark this reservation as completed? This means you have picked up your medicine.',
                                    style: AppText.regular,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: Text(
                                        AppLocalizations.of(context)!.cancel,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.markAsCompleted,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed == true) {
                              // Update reservation status to completed
                              final reservationRepo = ReservationRepository();
                              await reservationRepo.updateReservationStatus(
                                widget.reservationId,
                                'completed',
                              );

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Reservation marked as completed',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                // Navigate back to reservations list
                                Navigator.pop(context);
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 20,
                          ),
                          label: Text(
                            'Mark as Completed',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // Show cancel dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.cancelReservation,
                                    style: AppText.bold.copyWith(fontSize: 18),
                                  ),
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.reserveCancelQuestion,
                                    style: AppText.regular,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.keepReservation,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.yesCancelReservation,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
                      const SizedBox(height: 24),

                      // Secure Pickup Process Section
                      Text(
                        '🔒 ${AppLocalizations.of(context)!.securePickupProcess}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildPickupStep(
                        '1',
                        AppLocalizations.of(context)!.reservationInstructions1,
                      ),
                      _buildPickupStep(
                        '2',
                        AppLocalizations.of(context)!.reservationInstructions2,
                      ),
                      _buildPickupStep(
                        '3',
                        AppLocalizations.of(context)!.reservationInstructions3,
                      ),
                      _buildPickupStep(
                        '4',
                        AppLocalizations.of(context)!.reservationInstructions4,
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.verificationNote,
                              style: AppText.regular.copyWith(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${AppLocalizations.of(context)!.reservedOn}:\n${reservation!.createdAt != null ? DateFormat('MMM dd, yyyy\nHH:mm').format(DateTime.parse(reservation!.createdAt!)) : 'N/A'}',
                              style: AppText.regular.copyWith(
                                fontSize: 11,
                                color: AppColors.textLight,
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
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLight.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.bold.copyWith(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppText.regular.copyWith(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppText.bold.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppText.regular.copyWith(
                fontSize: 13,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
