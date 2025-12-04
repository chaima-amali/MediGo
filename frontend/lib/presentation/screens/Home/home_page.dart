import 'package:flutter/material.dart';
import 'package:frontend/presentation/services/mock_database_service.dart';
import 'package:frontend/presentation/services/navigation_helper.dart' as nav_helper;
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/widgets/Bottom_Navbar.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import '../Search/Search_results_page.dart';
import '../notifications.dart' as notif_page;
import '../reminders/tracking_page.dart';
import '../Profile/profile_page.dart';
import '../Search/pharmacy_details_screen.dart';
import '../Reservations/reservations_form.dart';

void main() {
  runApp(const MediGoApp());
}

class MediGoApp extends StatelessWidget {
  const MediGoApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'MediGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MainScreen(),
    );
  }
}

// Main Screen with Bottom Navigation
class MainScreen extends StatefulWidget {
  // Attach the global key so other widgets can switch tabs or open tracking subviews
  MainScreen({Key? key}) : super(key: nav_helper.mainScreenKey);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late String userName;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Pull the name from the shared mock data service so Home uses centralized data
    userName = MockDataService.getUserFirstName();
    _screens = [
      HomeScreen(userName: userName),
      const SearchScreen(),
      // Provide the tracking page a global key so we can control its subview
      TrackingPage(key: nav_helper.trackingPageKey),
      const ProfilePage(),
    ];
  }

  // Called by navigation_helper to switch the main tab programmatically
  void setTab(int index) {
    if (index < 0 || index >= _screens.length) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Use the project's shared Bottom_Navbar widget from widgets/ to avoid duplicating nav logic.

// Search Screen
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
     
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void _performSearch(String query) {
    setState(() {
      final raw = MockDataService.searchMedicineInPharmacies(query);
      _searchResults = raw.map((r) {
        // Robust mapping with safe defaults (avoid passing null into Text widgets)
        return {
          'pharmacy_id': r['pharmacy_id'] ?? r['pharmacyId'] ?? '',
          'pharmacy_name': r['name'] ?? r['pharmacy_name'] ?? '',
          'address': r['full_address'] ?? r['address'] ?? '',
          'distance': r['distance_text'] ?? r['distance'] ?? '',
          // mock service uses 'phone_number' in pharmacies; fall back to other keys
          'phone': r['phone_number'] ?? r['phone'] ?? '',
          'in_stock': r['in_stock'] ?? false,
          'price': r['price'] ?? 0,
        };
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.lightBlue.withOpacity(0.3), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'MediGo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.local_hospital,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const notif_page.NotificationsPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Title
               Text(
                loc.findYourMedicine,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 20),
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.lightBlue, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _performSearch,
                        decoration: InputDecoration(
                          hintText: loc.searchYourMedicine,
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 161, 161, 161),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Search Results
              Expanded(
                child: _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? ''
                              : loc.noResultsFound,
                          style: TextStyle(
                            color: AppColors.darkBlue.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return _buildPharmacyCard(result);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPharmacyCard(Map<String, dynamic> data) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pharmacy Name and Stock Status (tappable header)
          GestureDetector(
            onTap: () {
              final pid = data['pharmacy_id'] ?? '';
              final pharmacyMap = {
                'pharmacy_id': pid,
                'name': data['pharmacy_name'],
                'address': data['address'],
                'distance_km': data['distance'],
                'phone_number': data['phone'],
              };
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PharmacyDetailScreen(pharmacy: pharmacyMap),
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    data['pharmacy_name'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: data['in_stock']
                        ? AppColors.inStock.withOpacity(0.3)
                        : AppColors.outOfStock.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['in_stock'] ? loc.inStock : loc.outOfStock,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: data['in_stock']
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Address
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.darkBlue.withOpacity(0.6),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "${data['distance']} ${data['address']}",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.darkBlue.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Phone
          Row(
            children: [
              Icon(Icons.phone_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                data['phone'],
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Pre Order Button (only if in stock)
          if (data['in_stock']) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final pid = data['pharmacy_id'] ?? '';
                  final pname = data['pharmacy_name'] ?? '';
                  if (pid.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(loc.pharmacyIdMissing)),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReservationFormScreen(
                        pharmacyId: pid,
                        pharmacyName: pname,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightBlue,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child:  Text(
                  loc.preOrder,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'MediGo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.local_hospital,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const notif_page.NotificationsPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Greeting
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.darkBlue,
                  ),
                  children: [
                     TextSpan(text: loc.hi),
                    TextSpan(
                      text: userName,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     TextSpan(text: loc.howAreYouFeeling),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.lightBlue),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SearchMedicineScreen(),
                          ),
                        );
                      },
                      child: Icon(Icons.search, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: loc.searchMedicinePrompt,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Medicine Reminder Card (uses requested color #DAA3B5)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.reminderBox,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            loc.medicineReminder,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                           Text(
                            loc.reminderDescription,
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                            ),
                            child:  Text(
                              loc.startNow,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nearby Pharmacy Section
               Text(
                loc.nearbyPharmacy,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 16),

              // Pharmacy Cards
              Row(
                children: [
                  Expanded(
                    child: _buildNearbyPharmacyCard(
                      context,
                      'PharmSync',
                      '0.8km',
                      '4.7',
                      '1222 reviews',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNearbyPharmacyCard(
                      context,
                      'PharmSync',
                      '0.8km',
                      '4.7',
                      '1222 reviews',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildNearbyPharmacyCard(
    BuildContext context,
    String name,
    String distance,
    String rating,
    String reviews,
  ) {
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      
      onTap: () {
        final pList = MockDataService.getNearbyPharmacies(limit: 1);
        final p = pList.isNotEmpty ? pList.first : <String, dynamic>{};
        Navigator.push(
          // use the nearest pharmacy details
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => PharmacyDetailScreen(pharmacy: p),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 100,
                width: double.infinity,
                color: AppColors.lightBlue.withOpacity(0.3),
                child: Center(
                  child: Icon(
                    Icons.local_pharmacy,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    distance,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  loc.rating,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
             SizedBox(height: 4),
            Text(
              loc.reviews,
              style: const TextStyle(fontSize: 10, color: AppColors.darkBlue),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder Screens
class CalendarScreen extends StatelessWidget {

  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return  Center(
      child: Text(
        loc.calendarScreen,
        style: TextStyle(fontSize: 24, color: AppColors.primary),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return  Center(
      child: Text(
        loc.profileScreen,
        style: TextStyle(fontSize: 24, color: AppColors.primary),
      ),
    );
  }
}