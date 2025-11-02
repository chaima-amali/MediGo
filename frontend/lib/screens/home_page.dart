import 'package:flutter/material.dart';

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
        fontFamily: 'Poppins',
      ),
      home: const MainScreen(),
    );
  }
}

// App Colors
class AppColors {
  static const Color primary = Color(0xFF4ECDC4);
  static const Color lightBlue = Color(0xFFB8F3F0);
  static const Color pink = Color(0xFFFFB6C1);
  static const Color background = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
  static const Color green = Color(0xFF90EE90);
  static const Color red = Color(0xFFFFB6C1);
}

// Mock Database
class MockDatabase {
  static List<Map<String, dynamic>> _getAllInventory() {
    return [
      {
        "inventory_id": "inv_001",
        "pharmacy_id": "pharm_002",
        "medicine_id": "med_001",
        "in_stock": true,
        "quantity": 150,
        "price": 250.00,
      },
      {
        "inventory_id": "inv_002",
        "pharmacy_id": "pharm_002",
        "medicine_id": "med_002",
        "in_stock": false,
        "quantity": 0,
        "price": 450.00,
      },
      {
        "inventory_id": "inv_003",
        "pharmacy_id": "pharm_001",
        "medicine_id": "med_001",
        "in_stock": true,
        "quantity": 80,
        "price": 240.00,
      },
    ];
  }

  static List<Map<String, dynamic>> _getAllMedicines() {
    return [
      {
        "medicine_id": "med_001",
        "name": "Aspirin",
        "description": "Pain reliever and fever reducer",
      },
      {
        "medicine_id": "med_002",
        "name": "Ibuprofen",
        "description": "Anti-inflammatory drug",
      },
    ];
  }

  static List<Map<String, dynamic>> _getAllPharmacies() {
    return [
      {
        "pharmacy_id": "pharm_001",
        "name": "HealthPlus Pharmacy",
        "address": "Rue de didouche",
        "distance": "0.5 km",
        "phone": "(+231)782758436",
      },
      {
        "pharmacy_id": "pharm_002",
        "name": "HealthPlus Pharmacy",
        "address": "Rue de didouche",
        "distance": "0.5 km",
        "phone": "(+231)782758436",
      },
    ];
  }

  static List<Map<String, dynamic>> searchMedicine(String query) {
    if (query.isEmpty) return [];

    final inventory = _getAllInventory();
    final medicines = _getAllMedicines();
    final pharmacies = _getAllPharmacies();

    List<Map<String, dynamic>> results = [];

    for (var med in medicines) {
      if (med['name'].toString().toLowerCase().contains(query.toLowerCase())) {
        for (var inv in inventory) {
          if (inv['medicine_id'] == med['medicine_id']) {
            var pharmacy = pharmacies.firstWhere(
              (p) => p['pharmacy_id'] == inv['pharmacy_id'],
            );

            results.add({
              'medicine_name': med['name'],
              'pharmacy_name': pharmacy['name'],
              'address': pharmacy['address'],
              'distance': pharmacy['distance'],
              'phone': pharmacy['phone'],
              'in_stock': inv['in_stock'],
              'price': inv['price'],
            });
          }
        }
      }
    }

    return results;
  }
}

// Main Screen with Bottom Navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final String userName = "Serine";

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userName: userName),
      const SearchScreen(),
      const CalendarScreen(),
      const ProfileScreen(),
    ];
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

// Custom Bottom Navigation Bar
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.search,
            activeIcon: Icons.search,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Icon(
          isActive ? activeIcon : icon,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }
}

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
      _searchResults = MockDatabase.searchMedicine(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lightBlue.withOpacity(0.3),
            Colors.white,
          ],
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
                  Container(
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
                ],
              ),
              const SizedBox(height: 30),

              // Title
              const Text(
                'Find your medicine',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
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
                          hintText: 'Search your medicine',
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
                              : 'No results found',
                          style: TextStyle(
                            color: AppColors.textLight,
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
          // Pharmacy Name and Stock Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['pharmacy_name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: data['in_stock'] 
                      ? AppColors.green.withOpacity(0.3)
                      : AppColors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data['in_stock'] ? 'In stock' : 'Out of stock',
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
          const SizedBox(height: 12),

          // Address
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.textLight,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '${data['distance']} ${data['address']}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Phone
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                color: AppColors.primary,
                size: 18,
              ),
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightBlue,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Pre Order',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
                  Container(
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
                ],
              ),
              const SizedBox(height: 24),

              // Greeting
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.textDark,
                  ),
                  children: [
                    const TextSpan(text: 'Hi '),
                    TextSpan(
                      text: userName,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ' ,How are you\nfeeling Today?'),
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
                    Icon(Icons.search, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for your medicine ...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Medicine Reminder Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.pink.withOpacity(0.6), AppColors.pink.withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medicine Remainder',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You want a Remainder to track\nyour treatment',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
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
                            child: const Text(
                              'Start Now',
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
              const Text(
                'Nearby Pharmacy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Pharmacy Cards
              Row(
                children: [
                  Expanded(
                    child: _buildPharmacyCard(
                      'PharmSync',
                      '0.8km',
                      '4.7',
                      '1222 reviews',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPharmacyCard(
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

  Widget _buildPharmacyCard(
    String name,
    String distance,
    String rating,
    String reviews,
  ) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                'Rating: $rating',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '($reviews)',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder Screens
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Calendar Screen',
        style: TextStyle(fontSize: 24, color: AppColors.primary),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Screen',
        style: TextStyle(fontSize: 24, color: AppColors.primary),
      ),
    );
  }
}