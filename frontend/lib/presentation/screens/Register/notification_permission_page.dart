import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../src/generated/l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../../logic/cubits/user_cubit.dart';
import '../../../data/models/user.dart';
import '../../../data/services/fcm_service.dart';
import '../../../data/services/fcm_token_manager.dart';
import '../../../firebase_options.dart';
import '../Home/home_page.dart';

class NotificationPermissionPage extends StatelessWidget {
  final User userData;

  const NotificationPermissionPage({Key? key, required this.userData})
    : super(key: key);

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
                          child: Icon(
                            Icons.notifications_active,
                            color: AppColors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    Text(
                      AppLocalizations.of(context)!.notifications,
                      style: AppText.bold.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      AppLocalizations.of(context)!.receiveMedicineReminders,
                      style: AppText.regular.copyWith(
                        fontSize: 13,
                        color: AppColors.darkBlue.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // Allow Notifications button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            // Initialize Firebase if not already initialized
                            try {
                              await Firebase.initializeApp(
                                options: DefaultFirebaseOptions.currentPlatform,
                              );
                              print('✅ Firebase initialized');
                            } catch (e) {
                              // Firebase already initialized, ignore
                              print('ℹ️ Firebase already initialized');
                            }

                            // Request notification permission
                            final fcmService = FCMService();
                            await fcmService.initialize();

                            // Get FCM token
                            final fcmToken = fcmService.fcmToken;
                            print('📱 FCM Token obtained: $fcmToken');

                            final userCubit = BlocProvider.of<UserCubit>(
                              context,
                            );

                            // Update user with notifications enabled and FCM token
                            final userWithNotifications = userData.copyWith(
                              notificationsEnabled: true,
                              fcmToken: fcmToken,
                            );

                            print(
                              '🔔 Updating user with notifications enabled and FCM token',
                            );
                            await userCubit.updateUser(userWithNotifications);

                            // Initialize FCM token manager to handle token refreshes
                            print('🔄 Setting up FCM token refresh handler');
                            await FCMTokenManager().initialize(userCubit);

                            if (context.mounted) {
                              print('✅ Notifications enabled successfully');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            print('❌ Error enabling notifications: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error enabling notifications: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Enable Notifications',
                          style: AppText.medium.copyWith(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Skip/Later button (outlined)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () async {
                          final userCubit = BlocProvider.of<UserCubit>(context);

                          // Update user with notifications disabled
                          final userWithoutNotifications = userData.copyWith(
                            notificationsEnabled: false,
                          );

                          print('🔕 User chose to skip notifications');
                          await userCubit.updateUser(userWithoutNotifications);

                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainScreen(),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          side: BorderSide(
                            color: AppColors.lightBlue,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Maybe Later',
                          style: AppText.medium.copyWith(
                            color: AppColors.darkBlue.withOpacity(0.7),
                            fontSize: 15,
                          ),
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
