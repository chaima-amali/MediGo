import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/presentation/services/mock_database_service.dart';
import 'package:frontend/presentation/services/pharmacies.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        // Get user name from the current state
        String userName = 'User';
        User? currentUser;
        
        if (state is UserAuthenticated) {
          userName = state.user.name.split(' ').first; // Get first name
          currentUser = state.user;
        } else if (state is UserLoaded) {
          userName = state.user.name.split(' ').first;
          currentUser = state.user;
        }

        final List<Widget> screens = [
          HomeScreen(key: ValueKey(userName), userName: userName, user: currentUser),
          const SearchScreen(),
          TrackingPage(key: nav_helper.trackingPageKey),
          const ProfilePage(),
        ];

        return Scaffold(
          body: screens[_currentIndex],
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}

// Search Screen with Pharmacy Search
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PharmacyController _pharmacyController = PharmacyController();
  List<Pharmacy> _searchResults = [];

  void _performSearch(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _pharmacyController.searchPharmacies(query);
      }
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
                'Search Pharmacy',
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
                          hintText: 'Search for pharmacy...',
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
                          final pharmacy = _searchResults[index];
                          return _buildPharmacyCard(pharmacy);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy) {
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
          // Pharmacy Name
          GestureDetector(
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
                Expanded(
                  child: Text(
                    pharmacy.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
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
          const SizedBox(height: 8),

          // Phone
          Row(
            children: [
              Icon(Icons.phone_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                pharmacy.phone,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Opening Hours
          Row(
            children: [
              Icon(Icons.access_time,
                  color: AppColors.darkBlue.withOpacity(0.6), size: 18),
              const SizedBox(width: 8),
              Text(
                pharmacy.openingHours,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.darkBlue.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Home Screen with Pharmacy Search in Search Bar
class HomeScreen extends StatefulWidget {
  final String userName;
  final User? user;

  const HomeScreen({super.key, required this.userName, this.user});

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
  void initState() {
    super.initState();
    _loadNearbyPharmacies();
    
    // Listen to search focus changes
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _homeSearchController.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _homeSearchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadNearbyPharmacies() {
    // Use actual user if available, otherwise use mock user
    final user = widget.user ?? User(
      userId: 1,
      name: widget.userName,
      email: 'user@example.com',
      phone: '+213555123456',
      password: '',
      gender: 'M',
      dob: '1990-01-01',
      latitude: 36.7538,
      longitude: 3.0588,
      premium: 'no',
    );

    final nearbyPharmacies = _pharmacyController.getNearestPharmacies(
      user: user,
      limit: 4,
    );

    setState(() {
      _nearbyPharmacies = nearbyPharmacies;
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          // Unfocus search when tapping outside
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

            // Main Content - Search Results or Normal Home Content
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

  // Search Results View
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
            const SizedBox(height: 12),

            // Rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
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
            const SizedBox(height: 8),

            // Phone
            Row(
              children: [
                Icon(Icons.phone_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  pharmacy.phone,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Opening Hours
            Row(
              children: [
                Icon(Icons.access_time,
                    color: AppColors.darkBlue.withOpacity(0.6), size: 18),
                const SizedBox(width: 8),
                Text(
                  pharmacy.openingHours,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkBlue.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Normal Home Content
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

// Placeholder Screens
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
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
    return Center(
      child: Text(
        loc.profileScreen,
        style: TextStyle(fontSize: 24, color: AppColors.primary),
      ),
    );
  }
}