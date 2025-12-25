import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme States
abstract class ThemeState {
  final ThemeMode themeMode;
  final bool isDark;

  const ThemeState({required this.themeMode, required this.isDark});
}

class ThemeLight extends ThemeState {
  const ThemeLight() : super(themeMode: ThemeMode.light, isDark: false);
}

class ThemeDark extends ThemeState {
  const ThemeDark() : super(themeMode: ThemeMode.dark, isDark: true);
}

// Theme Cubit
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeLight()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('darkMode') ?? false;
    emit(isDark ? const ThemeDark() : const ThemeLight());
  }

  Future<void> toggleTheme() async {
    final isDark = !state.isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    emit(isDark ? const ThemeDark() : const ThemeLight());
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    emit(isDark ? const ThemeDark() : const ThemeLight());
  }
}
