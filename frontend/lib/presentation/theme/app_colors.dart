import 'package:flutter/material.dart';

class AppColors {
  //primary color palette
  static const Color primary = Color(0xFF37B7C3);
  static const Color darkBlue = Color(0xFF0F172A);
  static const Color lightBlue = Color(0xFFC8F6F6);
  static const Color mint = Color(0xFFAFF2F2);
  static const Color white = Color(0xFFFFFFFF);
  // Medicine card colors (from your design)
  static const Color yellowCard = Color(0xFFFFF4D6);
  static const Color pinkCard = Color(0xFFFFE5E5);
  // legacy pink used by Home_page (kept for backwards compatibility)
  static const Color pink = Color(0xFFFFB6C1);
  // Home reminder box custom color requested: #DAA3B5
  static const Color reminderBox = Color(0xFFDAA3B5);
  static const Color blueCard = Color(0xFFD6F5F5);
  static const Color coralCard = Color(0xFFFFDDD6);
  static const Color lavenderCard = Color(0xFFE5E5FF);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFFF5252);
  static const Color inStock = Color(0xFF4CAF50);
  static const Color outOfStock = Color(0xFFFF5252);

  // Subscription badges
  static const Color premiumOrange = Color(0xFFFF9800);
  static const Color premiumGold = Color(0xFFFFD700);
}

/*
use it like this :
Container(color: AppColors.primary);
 */
