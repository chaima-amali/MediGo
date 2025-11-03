import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../services/mock_database_service.dart';
import 'pharmacy_details_screen.dart';
import '../widgets/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: _currentIndex == 0 ? _buildHomeContent() : _buildPlaceholder(),
      ),
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

  Widget _buildHomeContent() {
    // Fetch nearby pharmacies once so the list is stable and we don't
    // call the getter repeatedly from inside builders (helps debug).
    final nearbyPharmacies = MockDataService.getNearbyPharmacies(limit: 4);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${widget.userName}!',
                          style: AppText.bold.copyWith(
                            fontSize: 24,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How can we help you today?',
                          style: AppText.regular.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: AppText.bold.copyWith(
                    fontSize: 18,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.location_on,
                        title: 'Find\nPharmacy',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.search,
                        title: 'Search\nMedicine',
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.notifications,
                        title: 'Set\nReminder',
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.phone,
                        title: 'Contact\nPharmacy',
                        color: Color(0xFF00BFA5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Nearby Pharmacies
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Pharmacies',
                  style: AppText.bold.copyWith(
                    fontSize: 18,
                    color: AppColors.darkBlue,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: AppText.medium.copyWith(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: nearbyPharmacies.length,
              itemBuilder: (context, index) {
                final pharmacy = nearbyPharmacies[index];
                return _buildPharmacyCard(pharmacy);
              },
            ),
          ),
          const SizedBox(height: 30),
          // Popular Medicines
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Medicines',
                  style: AppText.bold.copyWith(
                    fontSize: 18,
                    color: AppColors.darkBlue,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: AppText.medium.copyWith(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5,
            itemBuilder: (context, index) {
              // Mock medicine data for display
              final medicines = [
                {
                  'id': 1,
                  'name': 'Aspirin',
                  'type': 'Tablet',
                  'price': 250.0,
                  'inStock': true,
                },
                {
                  'id': 2,
                  'name': 'Telfast',
                  'type': 'Tablet',
                  'price': 450.0,
                  'inStock': true,
                },
                {
                  'id': 3,
                  'name': 'Diclofenac',
                  'type': 'Tablet',
                  'price': 180.0,
                  'inStock': true,
                },
                {
                  'id': 4,
                  'name': 'Naproxen',
                  'type': 'Tablet',
                  'price': 320.0,
                  'inStock': false,
                },
                {
                  'id': 5,
                  'name': 'Vitamin C',
                  'type': 'Capsule',
                  'price': 150.0,
                  'inStock': true,
                },
              ];
              final medicine = medicines[index];
              return _buildMedicineCard(medicine);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppText.medium.copyWith(
              fontSize: 13,
              color: AppColors.darkBlue,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(Map<String, dynamic> pharmacy) {
    // Normalize potentially-null fields from the mock data to safe Dart types
    final bool isOpen = pharmacy['isOpen'] == true;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PharmacyDetailScreen(pharmacy: pharmacy),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBlue.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_pharmacy,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy['name'],
                        style: AppText.bold.copyWith(
                          fontSize: 16,
                          color: AppColors.darkBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isOpen ? Icons.circle : Icons.cancel_outlined,
                            size: 12,
                            color: isOpen ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOpen ? 'Open' : 'Closed',
                            style: AppText.regular.copyWith(
                              fontSize: 12,
                              color: isOpen
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    pharmacy['address'],
                    style: AppText.regular.copyWith(
                      fontSize: 12,
                      color: AppColors.darkBlue.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${pharmacy['distance_km']} km away',
                  style: AppText.regular.copyWith(
                    fontSize: 12,
                    color: AppColors.darkBlue.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.star, size: 16, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  pharmacy['rating'].toString(),
                  style: AppText.medium.copyWith(
                    fontSize: 12,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    final colors = [
      AppColors.yellowCard,
      AppColors.pinkCard,
      AppColors.blueCard,
      AppColors.coralCard,
      AppColors.lavenderCard,
    ];
    final color = colors[medicine['id'] % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medication,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['name'],
                  style: AppText.bold.copyWith(
                    fontSize: 16,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medicine['type'],
                  style: AppText.regular.copyWith(
                    fontSize: 12,
                    color: AppColors.darkBlue.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: medicine['inStock']
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        medicine['inStock'] ? 'In Stock' : 'Out of Stock',
                        style: AppText.medium.copyWith(
                          fontSize: 10,
                          color: medicine['inStock']
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "\$${medicine['price']}",
                      style: AppText.bold.copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: AppColors.darkBlue.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: AppText.bold.copyWith(
              fontSize: 20,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This feature is under development',
            style: AppText.regular.copyWith(
              fontSize: 14,
              color: AppColors.darkBlue.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
