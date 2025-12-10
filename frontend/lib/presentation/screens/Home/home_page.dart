import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/presentation/services/mock_database_service.dart';
import 'package:frontend/presentation/services/pharmacies.dart';
import 'package:frontend/presentation/services/navigation_helper.dart' as nav_helper;
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/widgets/Bottom_Navbar.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import '../Search/search_page.dart';
import '../notifications.dart' as notif_page;
import '../reminders/tracking_page.dart';
import '../Profile/profile_page.dart';
import '../Search/pharmacy_details_screen.dart';
import '../Reservations/reservations_form.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/models/pharmacy.dart';
import 'package:frontend/controllers/pharmacy_controller.dart';
import 'package:frontend/services/location_service.dart';

// Main Screen with Bottom Navigation
class MainScreen extends StatefulWidget {
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
    userName = MockDataServices.getUserFirstName();
    _screens = [
      HomeScreen(userName: userName),
      SearchPage(),
      TrackingPage(key: nav_helper.trackingPageKey),
      const ProfilePage(),
    ];
  }

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

// ADD THIS CLASS DEFINITION - PharmacyWithDistance
class PharmacyWithDistance {
  final Pharmacy pharmacy;
  final double distance; // in kilometers

  PharmacyWithDistance({
    required this.pharmacy,
    required this.distance,
  });

  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }
}

// Home Screen with Pharmacy Search in Search Bar
class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PharmacyController _pharmacyController = PharmacyController();
  final TextEditingController _homeSearchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<PharmacyWithDistance> _nearbyPharmacies = [];
  List<Pharmacy> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;


  @override
  void dispose() {
    _homeSearchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  

  void _performHomeSearch(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _searchResults = [];
        _isSearching = false;
      } else {
        _searchResults = _pharmacyController.searchPharmacies(query);
        _isSearching = true;
      }
    });
  }

  void _clearSearch() {
    _homeSearchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
    _searchFocusNode.unfocus();
  }

  // FIXED: Simple Image.asset for local images
  Widget _buildPharmacyImage(String? imageUrl) {
    // Default fallback image if no URL provided
    final assetPath = imageUrl ?? 'assets/images/ph1.jpg';
    
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Error loading image: $assetPath');
        return _buildFallbackIcon();
      },
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: AppColors.lightBlue.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.local_pharmacy,
          size: 50,
          color: AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
        },
        child: Column(
          children: [
            // Fixed Header and Search Bar
            Container(
              color: Colors.white,
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
                                builder: (_) =>
                                    const notif_page.NotificationsPage(),
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
                            text: widget.userName,
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

                    // Search Bar with Pharmacy Search
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.lightBlue),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _homeSearchController,
                              focusNode: _searchFocusNode,
                              onChanged: _performHomeSearch,
                              decoration: InputDecoration(
                                hintText: 'Search pharmacy...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_isSearching)
                            GestureDetector(
                              onTap: _clearSearch,
                              child: Icon(
                                Icons.close,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: _isSearching
                  ? _buildSearchResults()
                  : _buildHomeContent(loc),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      color: Colors.grey[50],
      child: _searchResults.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  'No pharmacies found',
                  style: TextStyle(
                    color: AppColors.darkBlue.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final pharmacy = _searchResults[index];
                return _buildSearchPharmacyCard(pharmacy);
              },
            ),
    );
  }

  Widget _buildSearchPharmacyCard(Pharmacy pharmacy) {
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
      child: InkWell(
        onTap: () {
          final pharmacyMap = pharmacy.toMap();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PharmacyDetailScreen(pharmacy: pharmacyMap),
            ),
          );
        },
        child: Row(
          children: [
            // Pharmacy Image in Search Results
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.lightBlue.withOpacity(0.3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildPharmacyImage(pharmacy.imageUrl),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pharmacy Name
                  Text(
                    pharmacy.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        pharmacy.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Phone
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        pharmacy.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(AppLocalizations loc) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Reminder Card
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
                          child: Text(
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
            _isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : _nearbyPharmacies.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            'No nearby pharmacies found',
                            style: TextStyle(
                              color: AppColors.darkBlue.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _nearbyPharmacies.length,
                        itemBuilder: (context, index) {
                          final pharmacyData = _nearbyPharmacies[index];
                          return _buildNearbyPharmacyCard(
                            context,
                            pharmacyData,
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyPharmacyCard(
    BuildContext context,
    PharmacyWithDistance pharmacyData,
  ) {
    final pharmacy = pharmacyData.pharmacy;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PharmacyDetailScreen(
              pharmacy: pharmacy.toMap(),
            ),
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
            // Pharmacy Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.3),
                ),
                child: _buildPharmacyImage(pharmacy.imageUrl),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    pharmacy.name,
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
                    pharmacyData.formattedDistance,
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
                  pharmacy.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              pharmacy.phone,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.darkBlue,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}