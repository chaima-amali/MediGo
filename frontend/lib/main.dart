import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/screens/Home/splash_screen.dart';
import 'package:frontend/presentation/theme/app_theme.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/data/repositories/user_repo.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';


void main() {
  runApp(const MediGoApp());
}

class MediGoApp extends StatelessWidget {
  const MediGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(UserRepository()),
      child: MaterialApp(
      
      title: 'MediGo',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      locale: Locale('ar'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en'), Locale('fr'), Locale('ar')],

      home: const SplashScreen(),


      //ReservationDetailsScreen(reservationId: 'res_002',),
      ),
    );
  }
}
