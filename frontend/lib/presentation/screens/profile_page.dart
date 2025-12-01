import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text.dart';
import '../../widgets/back_arrow.dart';
import '../../services/mock_database_service.dart';
import 'subscription_page.dart';
import 'edit_profile_page.dart';
import 'splash_screen.dart';
import 'my_reservations_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> userData;
  late Map<String, dynamic> userSettings;
  late List<Map<String, dynamic>> premiumFeatures;
  late int activeReservationsCount;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Log Out",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Perform logout action
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (route) => false, // Remove all previous routes
                );
              },
              child: const Text(
                "Log Out",
                style: TextStyle(
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

  void _loadUserData() {
    userData = MockDataService.getCurrentUser();
    userSettings = MockDataService.getUserSettings();
    premiumFeatures = MockDataService.getPremiumFeatures();

    // Get active reservations count
    final activeReservations = MockDataService.getUserReservations(
      status: 'pending',
    );
    activeReservationsCount = activeReservations.length;
  }

  @override
  Widget build(BuildContext context) {
    final bool isPremium = userData['subscription_type'] == 'premium';
    final String displayName = (userData['full_name'] ?? 'User').toString();
    final words = displayName
        .split(' ')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();
    final String initials = words.isEmpty
        ? 'U'
        : words.map((word) => word[0]).join().toUpperCase();
    final String email = userData['email'] ?? '';
    final String phone = userData['phone_number'] ?? '';
    final String address = userData['address'] ?? 'Not specified';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: CustomBackArrow(),
        title: const Text('Profile', style: AppText.bold),
      ),
      body: SingleChildScrollView(
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
                          backgroundImage: userData['profile_image_url'] != null
                              ? NetworkImage(userData['profile_image_url'])
                              : null,
                          child: userData['profile_image_url'] == null
                              ? Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isPremium ? 'Premium Plan' : 'Free Plan',
                              style: TextStyle(
                                fontSize: 14,
                                color: isPremium
                                    ? AppColors.premiumOrange
                                    : Colors.grey,
                                fontWeight: isPremium
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Contact Info
                    _buildInfoRow(Icons.email_outlined, email),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.phone_outlined, phone),
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
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9999),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Edit profile',
                          style: TextStyle(fontSize: 14, color: Colors.white),
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
                        AppColors.premiumOrange,
                        AppColors.premiumOrange,
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
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Upgrade to Premium',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Get add-free experience, priority\nreservations and instant restock alerts',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      // Display features from mock data
                      ...premiumFeatures.map(
                        (feature) => _buildFeature(feature['title']),
                      ),
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
                          child: const Text(
                            'Upgrade Now - 3000DA/year',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
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
              const Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Settings Options
              _buildSettingTile(
                icon: Icons.calendar_today,
                iconColor: const Color(0xFF4DD0E1),
                title: 'My Reservations',
                subtitle: '$activeReservationsCount active\nreservations',
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
              _buildSettingTileWithSwitch(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFF4DD0E1),
                title: 'Notifications',
                subtitle: 'Receive medicine reminders',
                value: userSettings['notifications_enabled'],
                onChanged: (val) {
                  setState(() {
                    userSettings['notifications_enabled'] = val;
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildSettingTileWithSwitch(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFFBA68C8),
                title: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: userSettings['dark_mode_enabled'],
                onChanged: (val) {
                  setState(() {
                    userSettings['dark_mode_enabled'] = val;
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildSettingTile(
                icon: Icons.language,
                iconColor: const Color(0xFF64B5F6),
                title: 'Language',
                subtitle: userSettings['language'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Language')),
                        body: const Center(
                          child: Text('Language Selection Page'),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildSettingTile(
                icon: Icons.security_outlined,
                iconColor: const Color(0xFF81C784),
                title: 'Privacy & Security',
                subtitle: 'Manage your data',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Privacy & Security')),
                        body: const Center(
                          child: Text('Privacy & Security Page'),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildSettingTile(
                icon: Icons.info_outline,
                iconColor: const Color(0xFFE57373),
                title: 'About MediGo',
                subtitle: '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('About MediGo')),
                        body: const Center(child: Text('About MediGo Page')),
                      ),
                    ),
                  );
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
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
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
      ),
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

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingTileWithSwitch({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }
}
