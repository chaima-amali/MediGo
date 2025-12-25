import 'package:flutter/material.dart';
import 'app_colors.dart';

final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.light,
);

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.dark,
);

ThemeData appTheme = ThemeData.from(colorScheme: lightColorScheme).copyWith(
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: lightColorScheme.onBackground,
    displayColor: lightColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightColorScheme.primary,
      foregroundColor: lightColorScheme.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: lightColorScheme.primary,
    foregroundColor: lightColorScheme.onPrimary,
    elevation: 0,
  ),
  scaffoldBackgroundColor: lightColorScheme.background,
  cardColor: lightColorScheme.surface,
);

ThemeData darkTheme = ThemeData.from(colorScheme: darkColorScheme).copyWith(
  useMaterial3: false,
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: darkColorScheme.onBackground,
    displayColor: darkColorScheme.onBackground,
    fontFamily: 'Poppins',
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: darkColorScheme.surface,
    foregroundColor: darkColorScheme.onSurface,
    elevation: 0,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  cardColor: AppColors.surfaceDark,
);
/*use it like this :
MaterialApp(
  theme: appTheme,
  home: MyHomePage(),
);
*/
