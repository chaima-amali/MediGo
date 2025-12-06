import 'package:flutter/material.dart';
import 'package:frontend/presentation/theme/app_colors.dart';

class Occurrence {
  final int? id;
  final int planId;
  final DateTime date;
  final String time;
  final int isTaken;

  Occurrence({
    this.id,
    required this.planId,
    required this.date,
    required this.time,
    this.isTaken = 0,
  });

  // Derived formatted date string for UI (e.g. 12/3/2025)
  String get dateString => '${date.day}/${date.month}/${date.year}';

  // Optional placeholder for medicine name (can be populated later)
  String? medicineName;
  // optional importance string (hex without 0x) provided by medicine_plan
  String? importance;

  // Parse importance string into a Color. Returns null if parsing fails.
  Color? get importanceColor {
    if (importance == null) return null;
    final key = importance!.toLowerCase();
    // Map some known named values to AppColors
    switch (key) {
      case 'primary':
        return AppColors.primary;
      case 'pinkcard':
      case 'pink_card':
      case 'pink':
        return AppColors.pinkCard;
      case 'yellowcard':
      case 'yellow_card':
        return AppColors.yellowCard;
      case 'bluecard':
      case 'blue_card':
        return AppColors.blueCard;
      case 'coralcard':
      case 'coral_card':
        return AppColors.coralCard;
      case 'lavendercard':
      case 'lavender_card':
        return AppColors.lavenderCard;
      case 'mint':
        return AppColors.mint;
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      default:
        break;
    }

    // Attempt to parse common hex formats: '#RRGGBB', '#AARRGGBB', '0xAARRGGBB', 'AARRGGBB', 'RRGGBB'
    try {
      String s = importance!.trim();
      // remove 'Color(' or other wrapper text
      s = s.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
      if (s.isEmpty) return null;
      // if length == 6 (RRGGBB) -> add full opacity
      if (s.length == 6) s = 'FF' + s;
      // if length == 8 (AARRGGBB) ok
      if (s.length == 8) {
        final int v = int.parse(s, radix: 16);
        return Color(v);
      }
    } catch (_) {}
    return null;
  }

  factory Occurrence.fromMap(Map<String, dynamic> map) {
    // Normalize id and planId to int when possible
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    final id = parseInt(map["id"] ?? map["occurrence_id"]);
    final planId = parseInt(map["plan_id"]) ?? 0;

    // Prefer explicit date column; fall back to today if missing/invalid
    DateTime parsedDate = DateTime.now();
    try {
      final ds = map["date"] ?? map["day_of_week"] ?? map["day"] ?? '';
      if (ds != null && ds.toString().isNotEmpty) {
        parsedDate = DateTime.parse(ds.toString());
      }
    } catch (_) {}

    final isTakenVal = map["is_taken"] ?? map["isTaken"] ?? 0;
    final isTaken =
        parseInt(isTakenVal) ?? (isTakenVal is bool ? (isTakenVal ? 1 : 0) : 0);

    final occ = Occurrence(
      id: id,
      planId: planId,
      date: parsedDate,
      time: map["time"] ?? '',
      isTaken: isTaken,
    );

    // if joined query provided medicine name
    occ.medicineName = map['medicine_name'] ?? map['name'] ?? null;
    // if joined query provided importance (from medicine_plan)
    occ.importance = map['importance'] ?? map['plan_importance'] ?? null;
    return occ;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      "plan_id": planId,
      "date": date.toIso8601String().split("T")[0],
      "time": time,
      "is_taken": isTaken,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
