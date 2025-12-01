import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

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
      home: const SplashScreen(),

      //ReservationDetailsScreen(reservationId: 'res_002',),
    );
  }
}
