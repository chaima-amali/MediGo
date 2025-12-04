import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class LocalizationPage extends StatelessWidget {
  const LocalizationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative circles top-right
            Positioned(
              right: -size.width * 0.25,
              top: -size.width * 0.18,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -size.width * 0.05,
              top: -size.width * 0.05,
              child: Container(
                width: size.width * 0.5,
                height: size.width * 0.5,
                decoration: BoxDecoration(
                  color: AppColors.mint.withOpacity(0.75),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Decorative circles bottom-left
            Positioned(
              left: -size.width * 0.3,
              bottom: -size.width * 0.2,
              child: Container(
                width: size.width * 0.65,
                height: size.width * 0.65,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon circle
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    Text(
                      'Your Location?',
                      style: AppText.bold.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'This app requires your location to function properly. Please allow location access.',
                      style: AppText.regular.copyWith(fontSize: 13, color: AppColors.darkBlue.withOpacity(0.7)),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // Allow Location button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: trigger permission flow
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Allow Location Access',
                          style: AppText.medium.copyWith(color: AppColors.white, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Enter Location Manually (outlined)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: navigate to manual entry
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          side: BorderSide(color: AppColors.lightBlue, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Enter Location Manually',
                          style: AppText.medium.copyWith(color: AppColors.darkBlue.withOpacity(0.7), fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
