import 'package:flutter/material.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/presentation/theme/app_text.dart';
import 'package:frontend/data/repositories/reservation_repo.dart';
import 'package:frontend/data/repositories/pharmacy_repo.dart';
import 'package:frontend/data/models/reservation.dart';
import 'package:frontend/data/models/pharmacy.dart';

class ReservationCompletePage extends StatefulWidget {
  final int reservationId;

  const ReservationCompletePage({Key? key, required this.reservationId})
    : super(key: key);

  @override
  State<ReservationCompletePage> createState() =>
      _ReservationCompletePageState();
}

class _ReservationCompletePageState extends State<ReservationCompletePage> {
  final ReservationRepository _reservationRepo = ReservationRepository();
  final PharmacyRepository _pharmacyRepo = PharmacyRepository();
  Reservation? reservationData;
  Pharmacy? pharmacyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservationData();
  }

  Future<void> _loadReservationData() async {
    final reservation = await _reservationRepo.getReservationById(
      widget.reservationId,
    );

    Pharmacy? pharmacy;
    if (reservation != null && reservation.pharmacyId != null) {
      pharmacy = await _pharmacyRepo.getPharmacyById(reservation.pharmacyId!);
    }

    setState(() {
      reservationData = reservation;
      pharmacyData = pharmacy;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F9FA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (reservationData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CustomBackArrow(),
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

    final String medicineName = reservationData!.medicineName ?? 'Medicine';
    final int quantity = reservationData!.quantity;
    final String pickupDate = reservationData!.day;
    final String pickupTime = reservationData!.time;
    final String pharmacyName = pharmacyData?.name ?? 'Pharmacy';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CustomBackArrow(
                    backgroundColor: Color(0xFF80DEEA),
                    iconColor: Color(0xFF4DD0E1),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.reservationDetails,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.completed,
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Medicine Card
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFFE1BEE7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.medication,
                              color: Color(0xFF9C27B0),
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicineName,
                                  style: AppText.bold.copyWith(fontSize: 16),
                                ),
                                SizedBox(height: 4),
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
                    ),

                    SizedBox(height: 20),

                    // Pickup Information Card
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.pickupDate,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      pickupDate,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.pickupTime,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      pickupTime,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Pharmacy Information
                    Text(
                      AppLocalizations.of(context)!.pharmacyInformation,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 12),

                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  pharmacyName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (pharmacyData != null) ...[
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pharmacyData!.name,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pharmacyData!.phone,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF00BCD4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pharmacyData!.openingHours,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Completed Status Card
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF1976D2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.completed,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.pickedUpSuccessfully,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Reservation Created Date
                    if (reservationData!.createdAt != null)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.created,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              reservationData!.createdAt!,
                              style: TextStyle(fontSize: 13),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Color(0xFF80DEEA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
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
            padding: EdgeInsets.all(8),
            child: imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: 24,
                    height: 24,
                    color: iconColor ?? Color(0xFF4DD0E1),
                    fit: BoxFit.contain,
                  )
                : Icon(
                    Icons.arrow_back_ios_new,
                    color: iconColor ?? Color(0xFF4DD0E1),
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
