import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MedicineRing extends StatelessWidget {
  final double size;
  final double percent; // 0.0 - 1.0
  final String? colorHex;

  const MedicineRing({
    Key? key,
    required this.size,
    required this.percent,
    this.colorHex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _parseHexColor(colorHex) ?? AppColors.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(percent: percent.clamp(0.0, 1.0), color: color),
      ),
    );
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) cleaned = 'FF$cleaned';
    if (cleaned.length != 8) return null;
    try {
      return Color(int.parse(cleaned, radix: 16));
    } catch (_) {
      return null;
    }
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;

  _RingPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.12;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;

    final bgPaint = Paint()
      ..color = AppColors.lightBlue.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final start = -math.pi / 2;
    final sweep = 2 * math.pi * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.percent != percent || old.color != color;
}
