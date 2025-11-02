import 'package:flutter/material.dart';

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
    return Scaffold(
      body: Container(
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
                            hintText: 'Aspirin',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
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
                onPressed: () {
                  // Handle pre-order action
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