import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Preload the splash asset so it's ready when the widget builds.
    rootBundle
        .load('assets/images/logo_medicine.png')
        .then((bd) {
          debugPrint('logo_medicine.png loaded (${bd.lengthInBytes} bytes)');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            precacheImage(
              const AssetImage('assets/images/logo_medicine.png'),
              context,
            );
          });
        })
        .catchError((e) {
          debugPrint(
            'Failed to load asset assets/images/logo_medicine.png: $e',
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Top right background circle
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom left background circle
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MediGo',
                      style: AppText.bold.copyWith(
                        fontSize: 48,
                        color: AppColors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Medicine logo image
                    Transform.rotate(
                      angle: -0.4,
                      child: Image.asset(
                        'assets/images/logo_medicine.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                // Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue.withOpacity(0.95),
                        foregroundColor: AppColors.darkBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 6,
                        shadowColor: AppColors.darkBlue.withOpacity(0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: AppText.medium.copyWith(
                          fontSize: 16,
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                // No on-screen fallback — we always render the raw asset.
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
