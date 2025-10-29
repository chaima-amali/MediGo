import 'package:flutter/material.dart';
import 'screens/Home_page.dart';
import 'screens/Search_results_page.dart';
import 'screens/reminders.dart';
import 'screens/reservations.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MediGoApp());
}

class MediGoApp extends StatelessWidget {
  const MediGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      // Set the initial route to home page
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/home': (context) => HomeScreen(),
        '/search': (context) => SearchMedicineScreen(),
        '/reminders': (context) => RemindersScreen(),
        '/reservations': (context) =>
            ReservationFormScreen(pharmacyId: '', pharmacyName: ''),
      },
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Page not found: ${settings.name}')),
          ),
        );
      },
    );
  }
}
