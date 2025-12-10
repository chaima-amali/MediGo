// search_page.dart - Unified search page with both landing and results
import 'package:flutter/material.dart';
import '../notifications.dart' as notif_page;
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/services/mock_database_service.dart';
import 'pharmacy_details_screen.dart';
import '../Reservations/reservations_form.dart';
import '../Reservations/reservation_details.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  
  const SearchPage({Key? key, this.initialQuery}) : super(key: key);
  
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';
  List<Map<String, dynamic>> results = [];
  FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      searchQuery = widget.initialQuery!;
      _searchMedicine(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _searchMedicine(String query) {
    if (query.isEmpty) {
      setState(() {
        results = [];
        searchQuery = query;
      });
      return;
    }

    setState(() {
      searchQuery = query;
      results = MockDataService.searchMedicineInPharmacies(query);
    });
  }

  void _clearSearch() {
    setState(() {
      searchQuery = '';
      results = [];
    });
    _searchFocusNode.unfocus();
  }

  Widget _buildSearchBar(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.lightBlue,
          width: 2,
        ),
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
          Icon(
            Icons.search,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: loc.searchHint,
                hintStyle: TextStyle(
                  color: const Color.fromARGB(255, 161, 161, 161),
                  fontSize: 13,
                ),
                border: InputBorder.none,
              ),
              onChanged: _searchMedicine,
              controller: TextEditingController(text: searchQuery),
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, size: 20),
              onPressed: _clearSearch,
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AppLocalizations loc) {
    if (searchQuery.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.grey[300],
              ),
              SizedBox(height: 16),
              Text(
                loc.searchPrompt,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[300],
              ),
              SizedBox(height: 16),
              Text(
                '${loc.noResults} "$searchQuery"',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final pharmacy = results[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16, left: 20, right: 20),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SearchResultCard(pharmacy: pharmacy),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.lightBlue.withOpacity(0.3), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
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
                    // Notifications button
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
              ),
              const SizedBox(height: 10),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  loc.searchMedicine,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchBar(loc),
              ),
              const SizedBox(height: 20),

              // Search Results
              _buildSearchResults(loc),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> pharmacy;

  SearchResultCard({required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final bool inStock = pharmacy['in_stock'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final pid = pharmacy['pharmacy_id'] ?? pharmacy['pharmacyId'] ?? '';

            // If the current user already has a reservation at this pharmacy,
            // open the reservation details. Otherwise show the pharmacy page.
            if (pid.isNotEmpty) {
              try {
                final userReservations = MockDataService.getUserReservations();
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
                builder: (context) => PharmacyDetailScreen(pharmacy: pharmacy),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacy['name'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${pharmacy['distance_text']}, ${pharmacy['full_address']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          pharmacy['phone_number'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: inStock ? Color(0xFFE8F5E9) : Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  inStock ? loc.inStock : loc.outOfStock,
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
        SizedBox(height: 12),
        // Pre Order button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final pid = pharmacy['pharmacy_id'] ?? pharmacy['pharmacyId'] ?? '';
              final pname = pharmacy['name'] ?? pharmacy['pharmacy_name'] ?? '';
              if (pid.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.pharmacyIdMissing)),
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
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              loc.preOrder,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}