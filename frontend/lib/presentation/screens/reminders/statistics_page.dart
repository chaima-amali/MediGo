import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../theme/app_colors.dart';



class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: StatisticsContent(),
        ),
      ),
    );
  }
}

/// Embeddable statistics content (no Scaffold or AppBar)
class StatisticsContent extends StatelessWidget {
  const StatisticsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: CircularPercentIndicator(
              radius: 110,
              lineWidth: 14,
              percent: 0.92,
              progressColor: AppColors.primary,
              backgroundColor: AppColors.lightBlue.withOpacity(0.4),
              circularStrokeCap: CircularStrokeCap.round,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "92%",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Completed",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "DON'T STOP, you're so close to finish your treatment",
              style: TextStyle(fontSize: 13, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Med progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              Text(
                "3 months",
                style: TextStyle(fontSize: 14, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const MultiRingProgressChart(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppColors.pinkCard, "Aspirin"),
              SizedBox(width: 12),
              _buildLegend(AppColors.yellowCard, "Telfast"),
              SizedBox(width: 12),
              _buildLegend(AppColors.coralCard, "Naproxen"),
              SizedBox(width: 12),
              _buildLegend(AppColors.blueCard, "Diclofenac"),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.darkBlue),
        ),
      ],
    );
  }
}

class MultiRingProgressChart extends StatelessWidget {
  const MultiRingProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 340,
        width: 340,
        child: CustomPaint(painter: _MultiRingPainter()),
      ),
    );
  }
}

class _MultiRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const double startAngle = 3.14;
    const double sweepBase = 3.14;

    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16;

    for (int i = 0; i < 4; i++) {
      final double radius = 140 - (i * 25);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepBase,
        false,
        bgPaint,
      );
    }

    final List<Color> colors = [
      const Color(0xFFFFC107),
      const Color(0xFFFFA5D0),
      const Color(0xFF00C853),
      const Color(0xFF00B0FF),
    ];

    final List<double> progresses = [0.9, 0.8, 0.7, 0.6];

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 16;

      final double radius = 140 - (i * 25);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepBase * progresses[i],
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
