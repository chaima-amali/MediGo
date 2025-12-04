import 'package:flutter/material.dart';
import '../notifications.dart' as notif_page;
import 'package:frontend/presentation/theme/app_colors.dart';

import 'package:frontend/presentation/services/mock_database_service.dart';

import 'pharmacy_details_screen.dart';
import '../Reservations/reservations_form.dart';
import '../Reservations/reservation_details.dart';

class SearchMedicineScreen extends StatefulWidget {
  @override
  _SearchMedicineScreenState createState() => _SearchMedicineScreenState();
}

class _SearchMedicineScreenState extends State<SearchMedicineScreen> {
  String searchQuery = '';
  List<Map<String, dynamic>> results = [];

  void _searchMedicine(String query) {
    if (query.isEmpty) {
      setState(() => results = []);
      return;
    }

    setState(() {
      searchQuery = query;
      results = MockDataService.searchMedicineInPharmacies(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: Text(
          'Find your medicine',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const notif_page.NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search for your medicine...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchMedicine,
            ),
          ),

          Expanded(
            child: results.isEmpty
                ? Center(child: Text('Search for a medicine to see results'))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final pharmacy = results[index];
                      return SearchResultCard(pharmacy: pharmacy);
                    },
                  ),
          ),
        ],
      ),
      // TODO: Add CustomBottomNavBar widget when created
      // bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}

class SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> pharmacy;

  SearchResultCard({required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    final bool inStock = pharmacy['in_stock'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              final pid =
                  pharmacy['pharmacy_id'] ?? pharmacy['pharmacyId'] ?? '';

              // If the current user already has a reservation at this pharmacy,
              // open the reservation details. Otherwise show the pharmacy page.
              if (pid.isNotEmpty) {
                try {
                  final userReservations =
                      MockDataService.getUserReservations();
                  final match = userReservations.firstWhere(
                    (r) => (r['pharmacy_id'] ?? '') == pid,
                    orElse: () => {},
                  );
                  if (match.isNotEmpty) {
                    // Open reservation details for the found reservation
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationDetailsScreen(
                          reservationId: match['reservation_id'],
                        ),
                      ),
                    );
                    return;
                  }
                } catch (_) {
                  // fall through to show pharmacy details
                }

                final details = MockDataService.getPharmacyDetails(pid);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PharmacyDetailScreen(pharmacy: details ?? pharmacy),
                  ),
                );
                return;
              }

              // No pharmacy id available — fallback to details with the raw map
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PharmacyDetailScreen(pharmacy: pharmacy),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pharmacy['name'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: inStock ? Color(0xFFE8F5E9) : Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    inStock ? 'In stock' : 'Out of stock',
                    style: TextStyle(
                      color: inStock ? AppColors.inStock : AppColors.outOfStock,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                '${pharmacy['distance_text']}, ${pharmacy['full_address']}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                pharmacy['phone_number'],
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Always offer the Pre Order button (so users can open the reservation
          // form even when an item is temporarily out of stock). The form will
          // handle validation/availability as needed.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final pid =
                    pharmacy['pharmacy_id'] ?? pharmacy['pharmacyId'] ?? '';
                final pname =
                    pharmacy['name'] ?? pharmacy['pharmacy_name'] ?? '';
                if (pid.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pharmacy identifier missing')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationFormScreen(
                      pharmacyId: pid,
                      pharmacyName: pname,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Pre Order'),
            ),
          ),
        ],
      ),
    );
  }
}
