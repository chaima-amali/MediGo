import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/theme/app_text.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';

class PharmacyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pharmacy;

  const PharmacyDetailScreen({
    super.key,
    required this.pharmacy,
  });

  @override
  State<PharmacyDetailScreen> createState() => _PharmacyDetailScreenState();
}

class _PharmacyDetailScreenState extends State<PharmacyDetailScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Center map on pharmacy location after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(
        LatLng(
          widget.pharmacy['latitude'] ?? 36.753769,
          widget.pharmacy['longitude'] ?? 3.058756,
        ),
        15.0,
      );
    });
  }

  Future<void> _openDirections() async {
    final lat = widget.pharmacy['latitude'] ?? 36.753769;
    final lng = widget.pharmacy['longitude'] ?? 3.058756;
    
    // Try to open Google Maps
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to Apple Maps on iOS or generic maps
      final fallbackUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps application'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _makePhoneCall() async {
    final phoneNumber = widget.pharmacy['phone_number'] ?? '';
    if (phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number not available'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final telUrl = Uri.parse('tel:${phoneNumber.replaceAll(' ', '')}');
    
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not make phone call'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pharmacy = widget.pharmacy;
    final lat = pharmacy['latitude'] ?? 36.753769;
    final lng = pharmacy['longitude'] ?? 3.058756;
    final distance = pharmacy['distance_km'] ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Map section
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.medigo.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_pharmacy,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Back button overlay
                Positioned(
                  top: 16,
                  left: 16,
                  child: CustomBackArrow(
                    backgroundColor: AppColors.white,
                    iconColor: AppColors.darkBlue,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Coordinates display (like in your design)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBlue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${lat.toStringAsFixed(4)}°N ${lng.toStringAsFixed(4)}°E',
                      style: AppText.regular.copyWith(
                        fontSize: 10,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                ),
                // Distance and Get Directions overlay
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkBlue.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.navigation,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${distance.toStringAsFixed(1)}km away',
                              style: AppText.medium.copyWith(
                                fontSize: 12,
                                color: AppColors.darkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _openDirections,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Get directions',
                            style: AppText.medium.copyWith(
                              fontSize: 14,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Pharmacy details section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pharmacy name
                    Text(
                      pharmacy['name'] ?? 'Pharmacy',
                      style: AppText.bold.copyWith(
                        fontSize: 24,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Address
                    _buildDetailItem(
                      icon: Icons.location_on_outlined,
                      title: 'Address',
                      content: pharmacy['address'] ?? 'N/A',
                    ),
                    const SizedBox(height: 20),
                    // Contact
                    _buildDetailItem(
                      icon: Icons.phone_outlined,
                      title: 'Contact',
                      content: pharmacy['phone_number'] ?? 'N/A',
                    ),
                    const SizedBox(height: 20),
                    // Opening Hours
                    _buildDetailItem(
                      icon: Icons.access_time_outlined,
                      title: 'Opening Hours',
                      content: pharmacy['opening_hours'] ??
                          'Mon-Sat: 8:00 AM - 9:00 PM',
                    ),
                    const SizedBox(height: 20),
                    // Rating
                    _buildDetailItem(
                      icon: Icons.star_outline,
                      title: 'Rating',
                      content:
                          '${pharmacy['rating'] ?? 4.7} (${pharmacy['total_reviews'] ?? 0} reviews)',
                    ),
                    const SizedBox(height: 32),
                    // Call Now button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _makePhoneCall,
                        icon: const Icon(Icons.phone),
                        label: Text(
                          'Call Now',
                          style: AppText.medium.copyWith(
                            fontSize: 16,
                            color: AppColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppText.medium.copyWith(
                  fontSize: 14,
                  color: AppColors.darkBlue.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: AppText.regular.copyWith(
                  fontSize: 14,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
