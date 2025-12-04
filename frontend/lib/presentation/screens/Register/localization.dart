import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../../logic/cubits/user_cubit.dart';
import '../../../data/models/user.dart';
import '../Home/home_page.dart';
import 'Enter_location.dart';

class LocalizationPage extends StatelessWidget {
  final String email;
  final User? userData;

  const LocalizationPage({Key? key, required this.email, this.userData}) : super(key: key);

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
                            Icons.location_on,
                            color: AppColors.white,
                            size: 32,
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
                        onPressed: () async {
                          // Request location permission and get current location
                          try {
                            // Check if location services are enabled
                            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                            if (!serviceEnabled) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Location services are disabled. Please enable them in settings.'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                // Open location settings
                                await Geolocator.openLocationSettings();
                              }
                              return;
                            }

                            LocationPermission permission = await Geolocator.checkPermission();
                            if (permission == LocationPermission.denied) {
                              permission = await Geolocator.requestPermission();
                              if (permission == LocationPermission.denied) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Location permission denied')),
                                  );
                                }
                                return;
                              }
                            }

                            if (permission == LocationPermission.deniedForever) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Location permission permanently denied. Please enable it in app settings.'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                // Open app settings
                                await Geolocator.openAppSettings();
                              }
                              return;
                            }

                            // Get current position
                            Position position = await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );

                            print('🌍 GPS Location Retrieved: Latitude=${position.latitude}, Longitude=${position.longitude}');

                            final userCubit = BlocProvider.of<UserCubit>(context);
                            
                            if (userData != null) {
                              // New signup: Save user with location to database
                              final userWithLocation = userData!.copyWith(
                                latitude: position.latitude,
                                longitude: position.longitude,
                              );
                              print('💾 Saving new user to database with location');
                              await userCubit.registerUser(userWithLocation);
                              
                              if (context.mounted) {
                                final state = userCubit.state;
                                if (state is UserOperationSuccess) {
                                  print('✅ User registered successfully');
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => MainScreen()),
                                  );
                                } else if (state is UserError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.error)),
                                  );
                                }
                              }
                            } else {
                              // Existing user login: Update location
                              final user = await userCubit.userRepository.getUserByEmail(email);
                              print('👤 Updating location for user: ID=${user?.userId}');
                              if (user != null && context.mounted) {
                                await userCubit.updateUserLocation(
                                  user.userId!, 
                                  position.latitude, 
                                  position.longitude,
                                );
                                print('✅ Location updated for user ${user.userId}');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => MainScreen()),
                                );
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error getting location: $e')),
                            );
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
                          // Navigate to manual location entry page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EnterLocationPage(
                                email: email,
                                userData: userData,
                              ),
                            ),
                          );
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
