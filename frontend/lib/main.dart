import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/presentation/screens/Home/splash_screen.dart';
import 'package:frontend/presentation/theme/app_theme.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/data/repositories/user_repo.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/data/databases/db_helper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  try {
    await DBHelper.getDatabase();
    debugPrint('✅ Database initialized successfully');
  } catch (e) {
    debugPrint('❌ Database initialization error: $e');
  }
  
  runApp(const MediGoApp());
}

class MediGoApp extends StatefulWidget {
  const MediGoApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MediGoAppState? state = context.findAncestorStateOfType<_MediGoAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MediGoApp> createState() => _MediGoAppState();
}

class _MediGoAppState extends State<MediGoApp> {
  Locale _locale = const Locale('en'); // Default to English

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(savedLanguage);
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(UserRepository()),
      child: MaterialApp(
      
      title: 'MediGo',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      locale: _locale,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],

      home: const SplashScreen(),


      //ReservationDetailsScreen(reservationId: 'res_002',),
      ),
    );
  }
}
