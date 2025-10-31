import 'package:flutter/material.dart';
import 'package:frontend/screens/edit_profile_page.dart';
import 'package:frontend/screens/profile_page.dart';
import 'package:frontend/screens/reports_page.dart';
import 'package:frontend/screens/reservation_details.dart';
import 'package:frontend/screens/subscription_page.dart';
import '../theme/app_theme.dart';
import './screens/splash_screen.dart';
import './screens/medicine_calendar.dart';


void main() {
  runApp(const MediGoApp());
}

class MediGoApp extends StatelessWidget {
  const MediGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediGo',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home:  const MedicineCalendarScreen() //ReservationDetailsScreen(reservationId: 'res_002',),

    );
  }
}
