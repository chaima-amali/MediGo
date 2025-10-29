import 'package:flutter/material.dart';
import '../services/mock_database_service.dart';
import '../theme/app_colors.dart';

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
            onPressed: () {},
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pharmacy['name'],
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
          if (inStock)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to ReservationFormScreen when created
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reservation feature coming soon!')),
                  );
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ReservationFormScreen(
                  //       pharmacyId: pharmacy['pharmacy_id'],
                  //       pharmacyName: pharmacy['name'],
                  //     ),
                  //   ),
                  // );
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
