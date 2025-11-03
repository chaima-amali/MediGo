import 'package:flutter/material.dart';
import 'package:frontend/screens/edit_profile_page.dart';
import 'package:frontend/screens/profile_page.dart';
import 'package:frontend/screens/reports_page.dart';
import 'package:frontend/screens/reservation_details.dart';
import 'package:frontend/screens/subscription_page.dart';
import '../theme/app_theme.dart';
import './screens/splash_screen.dart';
import './screens/medicine_calendar.dart';
import '../screens/my_reservations_screen.dart';
import '../screens/edit_page.dart';
<<<<<<< HEAD
import '../screens/home_page.dart';
=======
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/reminders.dart';
import 'package:frontend/screens/search.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:frontend/screens/reservation.dart';
import 'package:frontend/screens/reservation_confirm.dart';
import 'package:frontend/screens/reservation_complete.dart';
import 'package:frontend/screens/notifications.dart';



>>>>>>> 354fa15 (Save my current work before rebase)

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
<<<<<<< HEAD
      home: const SplashScreen(),
=======


      home: const MainScreen(),
>>>>>>> 354fa15 (Save my current work before rebase)

      //ReservationDetailsScreen(reservationId: 'res_002',),
    );
  }
}
