import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../theme/app_colors.dart';
import 'medicine_calendar.dart';
import 'tracking_page.dart';
import 'edit_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedDateIndex = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: const StatisticsContent(),
    );
  }
}

/// Embeddable statistics content without a Scaffold so it can be reused
/// inside other screens (e.g., `TrackingPage`) without causing nested
/// scaffold/scroll layout issues.
class StatisticsContent extends StatelessWidget {
  const StatisticsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightBlue, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderStatic(context),
                const SizedBox(height: 25),
                const Text(
                  "Have you taken your\nmedicine Today?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 10),
                // Month + Calendar
                Row(
                  children: [
                    const Text(
                      "September ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      "2025",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MedicineCalendarScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // reuse the date row builder from the original page
                _buildDateRowStatic(),
                const SizedBox(height: 15),
                const SizedBox(height: 30),
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
                    const SizedBox(width: 12),
                    _buildLegend(AppColors.yellowCard, "Telfast"),
                    const SizedBox(width: 12),
                    _buildLegend(AppColors.coralCard, "Naproxen"),
                    const SizedBox(width: 12),
                    _buildLegend(AppColors.blueCard, "Diclofenac"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
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

  Widget _buildHeaderStatic(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'MediGo',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Image.asset('assets/images/logo_medicine.png', height: 38),
          ],
        ),
        Stack(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.primary,
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRowStatic() {
    const int startDate = 12;
    const int count = 8;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(count, (index) {
        final int date = startDate + index;
        final bool isSelected = date == 16;

        return Container(
          height: 38,
          width: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.primary : AppColors.lightBlue,
          ),
          child: Text(
            '$date',
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.darkBlue,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            ),
          ),
        );
      }),
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
