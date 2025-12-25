import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/presentation/screens/Home/splash_screen.dart';
import 'package:frontend/presentation/theme/app_theme.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/data/repositories/user_repo.dart';
import 'package:frontend/data/repositories/medicine_find_repo.dart';
import 'package:frontend/data/repositories/pharmacy_medicine_repo.dart';
import 'package:frontend/data/repositories/reservation_repo.dart';
import 'package:frontend/data/databases/db_helper.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/logic/cubits/medicine_search_cubit.dart';
import 'package:frontend/logic/cubits/reservation_cubit.dart';
import 'package:frontend/logic/cubits/theme_cubit.dart';

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
    MediGoAppState? state = context.findAncestorStateOfType<MediGoAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MediGoApp> createState() => MediGoAppState();
}

class MediGoAppState extends State<MediGoApp> {
  Locale _locale = const Locale('ar'); // Default to Arabic

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

  static MediGoAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<MediGoAppState>();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 Building MediGoApp widget...');
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            debugPrint('👤 Creating UserCubit...');
            return UserCubit(UserRepository());
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('💊 Creating MedicineSearchCubit...');
            return MedicineSearchCubit(
              pharmacyMedicineRepository: PharmacyMedicineRepository(),
              medicineFindRepository: MedicineFindRepository(),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('📋 Creating ReservationCubit...');
            return ReservationCubit(ReservationRepository());
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🎨 Creating ThemeCubit...');
            return ThemeCubit();
          },
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'MediGo',
            theme: appTheme,
            darkTheme: darkTheme,
            themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
            locale: _locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],

            home: SplashScreen(),

            //ReservationDetailsScreen(reservationId: 'res_002',),
          );
        },
      ),
    );
  }
}
