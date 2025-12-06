// lib/data/mock/pharmacy_mock_data.dart

import '../../data/models/pharmacy.dart';
import 'dart:math';

class MockDataServices {
  // Mock user data - update this with actual user location
  static double? userLatitude;
  static double? userLongitude;

  // Set user location (call this after user logs in or sets location)
  static void setUserLocation(double lat, double lng) {
    userLatitude = lat;
    userLongitude = lng;
    print('📍 User location set: $lat, $lng');
  }

  // Mock database of pharmacies in Algeria (Algiers region)
  // This matches your PharmacyMockData structure
  static final List<Map<String, dynamic>> _algerianPharmacies = [
    {
      'pharmacy_id': '1',
      'name': 'Pharmacie Centrale',
      'latitude': 36.7538,
      'longitude': 3.0588,
      'phone': '+213 21 63 45 67',
      'phone_number': '+213 21 63 45 67',
      'opening_hours': '8:00 AM - 8:00 PM',
      'rating': 4.5,
      'address': 'Rue Didouche Mourad, Alger Centre'
    },
    {
      'pharmacy_id': '2',
      'name': 'Pharmacie El Djazair',
      'latitude': 36.7372,
      'longitude': 3.0865,
      'phone': '+213 21 74 89 12',
      'phone_number': '+213 21 74 89 12',
      'opening_hours': '8:30 AM - 7:30 PM',
      'rating': 4.7,
      'address': 'Place des Martyrs, Alger'
    },
    {
      'pharmacy_id': '3',
      'name': 'Pharmacie Bab Ezzouar',
      'latitude': 36.7167,
      'longitude': 3.1833,
      'phone': '+213 21 24 56 78',
      'phone_number': '+213 21 24 56 78',
      'opening_hours': '9:00 AM - 9:00 PM',
      'rating': 4.3,
      'address': 'Bab Ezzouar, Alger'
    },
    {
      'pharmacy_id': '4',
      'name': 'Pharmacie Hydra',
      'latitude': 36.7628,
      'longitude': 3.0372,
      'phone': '+213 21 48 23 45',
      'phone_number': '+213 21 48 23 45',
      'opening_hours': '8:00 AM - 8:00 PM',
      'rating': 4.8,
      'address': 'Hydra, Alger'
    },
    {
      'pharmacy_id': '5',
      'name': 'Pharmacie Ben Aknoun',
      'latitude': 36.7689,
      'longitude': 3.0156,
      'phone': '+213 21 91 34 56',
      'phone_number': '+213 21 91 34 56',
      'opening_hours': '8:30 AM - 7:00 PM',
      'rating': 4.6,
      'address': 'Ben Aknoun, Alger'
    },
    {
      'pharmacy_id': '6',
      'name': 'Pharmacie Kouba',
      'latitude': 36.7289,
      'longitude': 3.0622,
      'phone': '+213 21 28 67 89',
      'phone_number': '+213 21 28 67 89',
      'opening_hours': '9:00 AM - 8:00 PM',
      'rating': 4.4,
      'address': 'Kouba, Alger'
    },
    {
      'pharmacy_id': '7',
      'name': 'Pharmacie Bir Mourad Rais',
      'latitude': 36.7456,
      'longitude': 3.0456,
      'phone': '+213 21 56 78 90',
      'phone_number': '+213 21 56 78 90',
      'opening_hours': '8:00 AM - 9:00 PM',
      'rating': 4.5,
      'address': 'Bir Mourad Rais, Alger'
    },
    {
      'pharmacy_id': '8',
      'name': 'Pharmacie Rouiba',
      'latitude': 36.7383,
      'longitude': 3.2833,
      'phone': '+213 21 85 12 34',
      'phone_number': '+213 21 85 12 34',
      'opening_hours': '8:30 AM - 7:30 PM',
      'rating': 4.2,
      'address': 'Rouiba, Alger'
    },
    {
      'pharmacy_id': '9',
      'name': 'Pharmacie Cheraga',
      'latitude': 36.7644,
      'longitude': 2.9506,
      'phone': '+213 21 36 45 67',
      'phone_number': '+213 21 36 45 67',
      'opening_hours': '9:00 AM - 8:30 PM',
      'rating': 4.6,
      'address': 'Cheraga, Alger'
    },
    {
      'pharmacy_id': '10',
      'name': 'Pharmacie Dely Ibrahim',
      'latitude': 36.7578,
      'longitude': 2.9892,
      'phone': '+213 21 91 23 45',
      'phone_number': '+213 21 91 23 45',
      'opening_hours': '8:00 AM - 8:00 PM',
      'rating': 4.7,
      'address': 'Dely Ibrahim, Alger'
    },
    {
      'pharmacy_id': '11',
      'name': 'Pharmacie Hussein Dey',
      'latitude': 36.7422,
      'longitude': 3.0956,
      'phone': '+213 21 77 89 01',
      'phone_number': '+213 21 77 89 01',
      'opening_hours': '8:30 AM - 7:30 PM',
      'rating': 4.3,
      'address': 'Hussein Dey, Alger'
    },
    {
      'pharmacy_id': '12',
      'name': 'Pharmacie El Harrach',
      'latitude': 36.7133,
      'longitude': 3.1378,
      'phone': '+213 21 52 34 56',
      'phone_number': '+213 21 52 34 56',
      'opening_hours': '9:00 AM - 9:00 PM',
      'rating': 4.5,
      'address': 'El Harrach, Alger'
    },
    {
      'pharmacy_id': '13',
      'name': 'Pharmacie Sidi M\'Hamed',
      'latitude': 36.7486,
      'longitude': 3.0566,
      'phone': '+213 21 63 78 90',
      'phone_number': '+213 21 63 78 90',
      'opening_hours': '24/7',
      'rating': 4.7,
      'address': 'Sidi M\'Hamed, Alger'
    },
    {
      'pharmacy_id': '14',
      'name': 'Pharmacie Bachdjerrah',
      'latitude': 36.7213,
      'longitude': 3.1158,
      'phone': '+213 21 45 23 67',
      'phone_number': '+213 21 45 23 67',
      'opening_hours': '8:00 AM - 8:00 PM',
      'rating': 4.5,
      'address': 'Bachdjerrah, Alger'
    },
    {
      'pharmacy_id': '15',
      'name': 'Pharmacie Bordj El Kiffan',
      'latitude': 36.7485,
      'longitude': 3.1943,
      'phone': '+213 21 87 65 43',
      'phone_number': '+213 21 87 65 43',
      'opening_hours': '8:00 AM - 9:00 PM',
      'rating': 4.4,
      'address': 'Bordj El Kiffan, Alger'
    },
  ];

  // Get ALL pharmacies
  static List<Map<String, dynamic>> getAllPharmacies() {
    return _algerianPharmacies.map((pharmacy) {
      return {
        'pharmacy_id': pharmacy['pharmacy_id'] ?? '',
        'name': pharmacy['name'] ?? '',
        'latitude': pharmacy['latitude'],
        'longitude': pharmacy['longitude'],
        'phone': pharmacy['phone_number'] ?? pharmacy['phone'] ?? '',
        'opening_hours': pharmacy['opening_hours'] ?? '08:00 - 20:00',
        'rating': pharmacy['rating']?.toDouble() ?? 4.5,
      };
    }).toList();
  }

  // Get ONE pharmacy by ID
  static Map<String, dynamic> getPharmacyById(String pharmacyId) {
    try {
      final pharmacy = _algerianPharmacies.firstWhere(
        (p) => p['pharmacy_id'] == pharmacyId,
        orElse: () => <String, dynamic>{},
      );
      
      if (pharmacy.isNotEmpty) {
        return {
          'pharmacy_id': pharmacy['pharmacy_id'] ?? '',
          'name': pharmacy['name'] ?? '',
          'latitude': pharmacy['latitude'],
          'longitude': pharmacy['longitude'],
          'phone': pharmacy['phone_number'] ?? pharmacy['phone'] ?? '',
          'opening_hours': pharmacy['opening_hours'] ?? '08:00 - 20:00',
          'rating': pharmacy['rating']?.toDouble() ?? 4.5,
        };
      }
    } catch (e) {
      print('Error finding pharmacy: $e');
    }
    return {};
  }
  // Calculate distance between two coordinates using Haversine formula
  static double calculateDistance(
    double lat1, 
    double lon1, 
    double lat2, 
    double lon2
  ) {
    const double earthRadius = 6371; // Radius in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // Get nearby pharmacies sorted by distance
  static List<Map<String, dynamic>> getNearbyPharmacies({int limit = 10}) {
    if (userLatitude == null || userLongitude == null) {
      print('⚠️ User location not set, returning pharmacies with default distances');
      // Return pharmacies with placeholder distances
      return _algerianPharmacies.take(limit).map((pharmacy) {
        return {
          ...pharmacy,
          'distance_km': 1.0 + Random().nextDouble() * 4, // 1-5 km random
          'distance_text': '${(1.0 + Random().nextDouble() * 4).toStringAsFixed(1)} km',
          'full_address': pharmacy['address'],
        };
      }).toList();
    }

    // Calculate distance for each pharmacy
    List<Map<String, dynamic>> pharmaciesWithDistance = _algerianPharmacies.map((pharmacy) {
      double distance = calculateDistance(
        userLatitude!,
        userLongitude!,
        pharmacy['latitude'],
        pharmacy['longitude'],
      );

      return {
        ...pharmacy,
        'distance_km': distance,
        'distance_text': '${distance.toStringAsFixed(1)} km',
        'full_address': pharmacy['address'],
      };
    }).toList();

    // Sort by distance
    pharmaciesWithDistance.sort((a, b) => 
      (a['distance_km'] as double).compareTo(b['distance_km'] as double)
    );

    print('📊 Found ${pharmaciesWithDistance.length} pharmacies');
    if (pharmaciesWithDistance.isNotEmpty) {
      print('🏥 Nearest pharmacy: ${pharmaciesWithDistance[0]['name']} at ${pharmaciesWithDistance[0]['distance_text']}');
    }

    return pharmaciesWithDistance.take(limit).toList();
  }

  // Search medicine in pharmacies - returns pharmacies that match search query
  static List<Map<String, dynamic>> searchMedicineInPharmacies(String query) {
    if (query.isEmpty) return [];

    print('🔍 Searching for medicine: "$query"');

    // Get all pharmacies with distances
    final allPharmacies = getNearbyPharmacies(limit: 15);
    
    // Filter pharmacies based on search query (search in pharmacy names or addresses)
    final filteredPharmacies = allPharmacies.where((pharmacy) {
      final name = (pharmacy['name'] ?? '').toLowerCase();
      final address = (pharmacy['address'] ?? '').toLowerCase();
      final searchQuery = query.toLowerCase();
      
      // Match if query is in name or address
      return name.contains(searchQuery) || address.contains(searchQuery);
    }).toList();

    // If no pharmacies match by name/address, return all with random stock status
    // This simulates "searching for a medicine" across pharmacies
    final pharmaciesToReturn = filteredPharmacies.isEmpty ? allPharmacies : filteredPharmacies;

    print('📦 Found ${pharmaciesToReturn.length} pharmacies for query "$query"');

    // Add stock information and price for the searched medicine
    return pharmaciesToReturn.map((pharmacy) {
      // Random stock availability (70% in stock, 30% out of stock)
      final inStock = Random().nextInt(100) < 70;
      
      return {
        ...pharmacy,
        'pharmacy_name': pharmacy['name'], // Add this for compatibility with search results
        'in_stock': inStock,
        'price': inStock ? (500 + Random().nextInt(1500)) : 0, // 500-2000 DZD
      };
    }).toList();
  }

  // Get user first name (existing method - keep for compatibility)
  static String getUserFirstName() {
    return 'Serine'; // Default user name - replace with actual user data
  }

  // Get pharmacy by ID
  
}