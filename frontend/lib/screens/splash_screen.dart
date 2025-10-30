import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Try to load the asset early and precache it so we can detect
    // asset packaging issues. This will print a debug line on success
    // or failure to the platform logs.
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
          // Background circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MediGo',
                      style: AppText.bold.copyWith(
                        fontSize: 48,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Medicine logo image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Transform.rotate(
                        angle: -0.3,
                        child: Image.asset(
                          'assets/images/logo_medicine.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.medication,
                            size: 40,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 200),
                SizedBox(
                  width: 200,
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
                      backgroundColor: AppColors.lightBlue,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: AppText.medium.copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
