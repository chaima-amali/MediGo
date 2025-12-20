import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import 'package:frontend/data/models/pharmacy.dart';
import 'package:frontend/logic/cubits/reservation_cubit.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:intl/intl.dart';

class ReservationFormScreen extends StatefulWidget {
  final Pharmacy pharmacy;
  final String medicineName;

  ReservationFormScreen({required this.pharmacy, required this.medicineName});

  @override
  _ReservationFormScreenState createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int quantity = 1;
  DateTime? pickupDate;
  TimeOfDay? pickupTime;
  int? openHour;
  int? closeHour;
  @override
  void initState() {
    super.initState();
    // Parse openingHours string, e.g. "Mon-Fri: 8:30 AM - 7:30 PM"
    print('DEBUG: Original hours string: ${widget.pharmacy.openingHours}');

    final hoursStr = widget.pharmacy.openingHours;

    // Remove day information (everything before and including the colon)
    String timeOnly = hoursStr;
    if (hoursStr.contains(':')) {
      final parts = hoursStr.split(':');
      if (parts.length >= 2) {
        // Rejoin everything after the first colon
        timeOnly = parts.sublist(1).join(':').trim();
      }
    }

    print('DEBUG: Time only string: "$timeOnly"');

    // Now split by '-' to get opening and closing times
    final times = timeOnly.split('-').map((s) => s.trim()).toList();

    if (times.length >= 2) {
      openHour = _parseHour(times[0]);
      closeHour = _parseHour(times[1]);
      print('DEBUG: Parsed hours - Open: $openHour, Close: $closeHour');
    } else {
      print('DEBUG: Failed to split time string, parts: $times');
    }
  }

  int? _parseHour(String timeStr) {
    final time = timeStr.trim();
    print('DEBUG: Parsing time string: "$time"');

    // Try AM/PM format first: "8:00 AM" or "9:00 PM"
    final ampmMatch = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)',
      caseSensitive: false,
    ).firstMatch(time);
    if (ampmMatch != null) {
      int hour = int.parse(ampmMatch.group(1)!);
      final ampm = ampmMatch.group(3)!.toUpperCase();
      if (ampm == 'PM' && hour != 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;
      print('DEBUG: Parsed AM/PM format - result: $hour');
      return hour;
    }

    // Try 24-hour format: "08:00" or "21:00"
    final twentyFourMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(time);
    if (twentyFourMatch != null) {
      int hour = int.parse(twentyFourMatch.group(1)!);
      print('DEBUG: Parsed 24-hour format - result: $hour');
      return hour;
    }

    // Try just hour number: "8" or "21"
    final hourOnly = int.tryParse(time);
    if (hourOnly != null) {
      print('DEBUG: Parsed hour only - result: $hourOnly');
      return hourOnly;
    }

    print('DEBUG: Failed to parse time string: "$time"');
    return null;
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReservationCubit, ReservationState>(
      listener: (context, state) {
        if (state is ReservationCreated) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.reservationConfirmed),
              content: Text(
                AppLocalizations.of(context)!.readyForPickupMessage,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
          );
        } else if (state is ReservationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: CustomBackArrow(onPressed: () => Navigator.pop(context)),
          title: Text(
            AppLocalizations.of(context)!.reserveMedicine,
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.completeForm,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),

                // Pharmacy info card
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.local_pharmacy,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pharmacy.name,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              AppLocalizations.of(context)!.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Medicine Name
                Text(
                  AppLocalizations.of(context)!.medicineName,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                TextFormField(
                  initialValue: widget.medicineName,
                  enabled: false,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Quantity
                Text(
                  AppLocalizations.of(context)!.quantity,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                TextFormField(
                  initialValue: '1',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.enterQuantity;
                    }
                    final qty = int.tryParse(value);
                    if (qty == null || qty < 1) {
                      return AppLocalizations.of(context)!.invalidQuantity;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    quantity = int.tryParse(value) ?? 1;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Pickup Date & Time (side by side)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.pickupDate,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  Duration(days: 30),
                                ),
                              );
                              setState(() => pickupDate = date);
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      pickupDate != null
                                          ? '${pickupDate!.day}/${pickupDate!.month}/${pickupDate!.year}'
                                          : 'Select date',
                                      style: TextStyle(
                                        color: pickupDate != null
                                            ? Colors.black
                                            : Colors.grey,
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
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.pickupTime,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              setState(() => pickupTime = time);
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      pickupTime != null
                                          ? pickupTime!.format(context)
                                          : 'Select time',
                                      style: TextStyle(
                                        color: pickupTime != null
                                            ? Colors.black
                                            : Colors.grey,
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
                  ],
                ),

                SizedBox(height: 16),

                // Pharmacy Hours info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.openHours,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.pharmacy.openingHours,
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        AppLocalizations.of(context)!.pickupTimeDuringHours,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      if (pickupDate == null || pickupTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.selectDateAndTime,
                            ),
                          ),
                        );
                        return;
                      }
                      // Validate pickup time within working hours
                      final hour = pickupTime!.hour;
                      print(
                        'DEBUG: Selected hour: $hour, openHour: $openHour, closeHour: $closeHour',
                      );

                      if (openHour == null || closeHour == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.unableToValidatePharmacyHours,
                            ),
                          ),
                        );
                        return;
                      }

                      // Check if the selected hour is outside working hours
                      if (hour < openHour! || hour >= closeHour!) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pickup time must be between ${_formatHour(openHour!)} and ${_formatHour(closeHour!)}',
                            ),
                          ),
                        );
                        return;
                      }

                      // Validate pickup date and time is not in the past
                      final pickupDateTime = DateTime(
                        pickupDate!.year,
                        pickupDate!.month,
                        pickupDate!.day,
                        pickupTime!.hour,
                        pickupTime!.minute,
                      );

                      if (pickupDateTime.isBefore(DateTime.now())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.pickupTimeCannotBeInPast,
                            ),
                          ),
                        );
                        return;
                      }

                      // Get current user ID
                      final userState = context.read<UserCubit>().state;
                      int userId = 0;
                      if (userState is UserAuthenticated) {
                        userId = userState.user.userId!;
                      } else if (userState is UserLoaded) {
                        userId = userState.user.userId!;
                      }

                      if (userId == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.userNotAuthenticated,
                            ),
                          ),
                        );
                        return;
                      }

                      // Create reservation
                      final formattedDate = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickupDate!);
                      final formattedTime = pickupTime!.format(context);

                      context.read<ReservationCubit>().createReservation(
                        medicineFindId:
                            0, // TODO: Link to medicine search if needed
                        userId: userId,
                        pharmacyId: widget.pharmacy.pharmacyId ?? 0,
                        medicineName: widget.medicineName,
                        day: formattedDate,
                        time: formattedTime,
                        quantity: quantity,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.confirmReservation,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
