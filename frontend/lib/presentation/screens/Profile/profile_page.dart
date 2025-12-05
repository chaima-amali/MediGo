import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/theme/app_text.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'subscription_page.dart';
import 'edit_profile_page.dart';
import 'Language_page.dart';
import 'Edit_password.dart';
import '../Home/splash_screen.dart';
import '../Reservations/my_reservations_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = false;
  bool _darkModeEnabled = false;
  String _currentLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final locale = Localizations.localeOf(context).languageCode;
    setState(() {
      switch (locale) {
        case 'en':
          _currentLanguage = 'English';
          break;
        case 'fr':
          _currentLanguage = 'Français';
          break;
        case 'ar':
          _currentLanguage = 'العربية';
          break;
        default:
          _currentLanguage = 'English';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const CustomBackArrow(),
        title: Text(loc.profile, style: AppText.bold),
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          print('🔍 Profile page state: ${state.runtimeType}');
          
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (state is UserLoaded || state is UserAuthenticated) {
            final user = state is UserLoaded 
                ? state.user 
                : (state as UserAuthenticated).user;

            // Null-safety for latitude/longitude
            String address = 'Not specified';
            if (user.latitude != null && user.longitude != null) {
              address =
                  'Lat: ${user.latitude!.toStringAsFixed(4)}, Lng: ${user.longitude!.toStringAsFixed(4)}';
            } else if (user.locationName != null) {
              address = user.locationName!;
            }

            // Handle subscription type safely
            final isPremium = user.premium.toLowerCase() == 'premium';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Avatar and Name
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: const Color(0xFFB2EBF2),
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isPremium ? loc.premiumPlan : loc.freePlan,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isPremium
                                          ? AppColors.premiumOrange
                                          : Colors.grey,
                                      fontWeight:
                                          isPremium ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Contact Info
                          _buildInfoRow(Icons.email_outlined, user.email),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.phone_outlined, user.phone),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.location_on_outlined, address),
                          const SizedBox(height: 20),
                          // Edit Profile Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfileScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9999),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                loc.editProfile,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Premium Upgrade Card (only show if not premium)
                    if (!isPremium) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF9800),
                              Color(0xFFFF6D00),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.workspace_premium,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  loc.upgradeToPremium,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              loc.premiumDescription,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Premium Features List
                            _buildPremiumFeature(loc.adFreeExperience),
                            _buildPremiumFeature(loc.medicinePreOrderReservation),
                            _buildPremiumFeature(loc.instantRestockAlerts),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SubscriptionPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  loc.upgradeNowPrice,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFFF6D00),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Settings Title
                    Text(
                      loc.settings,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Settings Options
                    _buildSettingTile(
                      icon: Icons.calendar_today,
                      iconColor: const Color(0xFF4DD0E1),
                      backgroundColor: const Color(0xFFE0F7FA),
                      title: loc.myReservations,
                      subtitle: loc.activeReservations,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyReservationsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingTile(
                      icon: Icons.notifications_outlined,
                      iconColor: const Color(0xFF4DD0E1),
                      backgroundColor: const Color(0xFFE0F7FA),
                      title: loc.notifications,
                      subtitle: loc.receiveMedicineReminders,
                      showSwitch: true,
                      switchValue: _notificationsEnabled,
                      onSwitchChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _buildSettingTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: const Color(0xFFBA68C8),
                      backgroundColor: const Color(0xFFF3E5F5),
                      title: loc.darkMode,
                      subtitle: loc.darkModeDescription,
                      showSwitch: true,
                      switchValue: _darkModeEnabled,
                      onSwitchChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _buildSettingTile(
                      icon: Icons.language,
                      iconColor: const Color(0xFF64B5F6),
                      backgroundColor: const Color(0xFFE3F2FD),
                      title: loc.language,
                      subtitle: _currentLanguage,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguagePage(),
                          ),
                        );
                        // Reload current language when returning from language page
                        _loadCurrentLanguage();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingTile(
                      icon: Icons.security_outlined,
                      iconColor: const Color(0xFF81C784),
                      backgroundColor: const Color(0xFFE8F5E9),
                      title: loc.privacySecurity,
                      subtitle: loc.privacySecurityDescription,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditPasswordPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingTile(
                      icon: Icons.info_outline,
                      iconColor: const Color(0xFFE57373),
                      backgroundColor: const Color(0xFFFFEBEE),
                      title: loc.aboutMedigo,
                      subtitle: '',
                      onTap: () {
                        // Navigate to about page
                      },
                    ),
                    const SizedBox(height: 16),

                    // Log Out Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showLogoutConfirmation(context);
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: Text(
                          loc.logOut,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          } 
          
          // Handle error states
          if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          // Fallback for any other state (like UserOperationSuccess, UserInitial, etc.)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading profile...',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'State: ${state.runtimeType}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            loc.logOut,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            loc.logoutConfirmation,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(loc.cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (route) => false,
                );
              },
              child: Text(
                loc.logOut,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : null,
        trailing: showSwitch
            ? Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: iconColor,
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: showSwitch ? null : onTap,
      ),
    );
  }

  Widget _buildPremiumFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.circle,
            size: 6,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
