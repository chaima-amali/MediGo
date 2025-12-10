// lib/data/mock/pharmacy_mock_data.dart

import 'dart:math';
import 'package:frontend/data/models/pharmacy.dart';

class MockDataServices {
  // Mock user data
  static double? userLatitude;
  static double? userLongitude;

  static void setUserLocation(double lat, double lng) {
    userLatitude = lat;
    userLongitude = lng;
    print('📍 User location set: $lat, $lng');
  }

  // Mock database of 15 pharmacies in Algeria (Algiers region)
  static final List<Map<String, dynamic>> _algerianPharmacies = [
    {
      'pharmacy_id': '1',
      'name': 'Al-Mansour Pharmacy',
      'latitude': 36.7538,
      'longitude': 3.0588,
      'phone': '+213 21 63 45 67',
      'opening_hours': '8:00 AM - 8:00 PM',
      'rating': 4.5,
      'address': 'Rue Didouche Mourad, Alger Centre',
      'image_url': 'assets/images/ph1.jpg',
      'medicines': ['Panadol', 'Aspirin', 'Antibiotics', 'Vitamin C', 'Pain Relief'],
    },
    {
      'pharmacy_id': '2',
      'name': 'City Medical Center',
      'latitude': 36.7372,
      'longitude': 3.0865,
      'phone': '+213 21 74 89 12',
      'opening_hours': '8:30 AM - 7:30 PM',
      'rating': 4.7,
      'address': 'Place des Martyrs, Alger',
      'image_url': 'assets/images/ph2.jpg',
      'medicines': ['Ibuprofen', 'Vitamin C', 'Cough Syrup', 'Antibiotics', 'Cold Medicine'],
    },
    {
      'pharmacy_id': '3',
      'name': 'Green Pharmacy',
      'latitude': 36.7167,
      'longitude': 3.1833,
      'phone': '+213 21 24 56 78',
      'opening_hours': '9:00 AM - 9:00 PM',
      'rating': 4.3,
      'address': 'Bab Ezzouar, Alger',
      'image_url': 'assets/images/ph3.jpg',
      'medicines': ['Paracetamol', 'Allergy Meds', 'Pain Relief', 'Antiseptic', 'Bandages'],
    },
    {
      'pharmacy_id': '4',
      'name': 'Health Plus Pharmacy',
      'latitude': 36.7628,
      'longitude': 3.0372,
      'phone': '+213 21 48 23 45',
      'opening_hours': '8:00 AM - 8:00 PM',
      'rating': 4.8,
      'address': 'Hydra, Alger',
      'image_url': 'assets/images/ph4.jpg',
      'medicines': ['Cold Medicine', 'Antiseptic', 'Bandages', 'First Aid Kit', 'Thermometer'],
    },
    {
      'pharmacy_id': '5',
      'name': 'Royal Pharmacy',
      'latitude': 36.7689,
      'longitude': 3.0156,
      'phone': '+213 21 91 34 56',
      'opening_hours': '8:30 AM - 7:00 PM',
      'rating': 4.6,
      'address': 'Ben Aknoun, Alger',
      'image_url': 'assets/images/ph1.jpg',
      'medicines': ['Prescription Drugs', 'First Aid', 'Supplements', 'Diabetes Test Strips', 'Blood Pressure Monitor'],
    },
    {
      'pharmacy_id': '6',
      'name': 'Quick Care Pharmacy',
      'latitude': 36.7289,
      'longitude': 3.0622,
      'phone': '+213 21 28 67 89',
      'opening_hours': '9:00 AM - 8:00 PM',
      'rating': 4.4,
      'address': 'Kouba, Alger',
      'image_url': 'assets/images/ph2.jpg',
      'medicines': ['Emergency Meds', 'Baby Care', 'Skin Care', 'Eye Drops', 'Nasal Spray'],
    },
    {
      'pharmacy_id': '7',
      'name': 'Sunrise Pharmacy',
      'latitude': 36.7456,
      'longitude': 3.0456,
      'phone': '+213 21 56 78 90',
      'opening_hours': '8:00 AM - 9:00 PM',
      'rating': 4.5,
      'address': 'Bir Mourad Rais, Alger',
      'image_url': 'assets/images/ph3.jpg',
      'medicines': ['Antibiotics', 'Pain Killers', 'Vitamins', 'Creams', 'Ointments'],
    },
    {
      'pharmacy_id': '8',
      'name': 'Golden Pharmacy',
      'latitude': 36.7383,
      'longitude': 3.2833,
      'phone': '+213 21 85 12 34',
      'opening_hours': '8:30 AM - 7:30 PM',
      'rating': 4.2,
      'address': 'Rouiba, Alger',
      'image_url': 'assets/images/ph4.jpg',
      'medicines': ['Generic Medicines', 'First Aid', 'Baby Products', 'Elderly Care', 'Medical Devices'],
    },
    {
      'pharmacy_id': '9',
      'name': 'MediCare Pharmacy',
      'latitude': 36.7644,
      'longitude': 2.9506,
      'phone': '+213 21 36 45 67',
      'opening_hours': '9:00 AM - 8:30 PM',
      'rating': 4.6,
      'address': 'Cheraga, Alger',
      'image_url': 'assets/images/ph1.jpg',
      'medicines': ['Cardiac Drugs', 'Diabetes Meds', 'Asthma Inhalers', 'Antihistamines', 'Pain Relievers'],
    },
    {
      'pharmacy_id': '10',
      'name': 'PharmaPlus Algiers',
      'latitude': 36.7578,
      'longitude': 2.9892,
      'phone': '+213 21 91 23 45',
      'opening_hours': '8:00 AM - 8:00 PM',
      'rating': 4.7,
      'address': 'Dely Ibrahim, Alger',
      'image_url': 'assets/images/ph2.jpg',
      'medicines': ['Prescription Meds', 'Over-the-Counter', 'Supplements', 'Medical Equipment', 'First Aid'],
    },
    {
      'pharmacy_id': '11',
      'name': 'Wellness Pharmacy',
      'latitude': 36.7422,
      'longitude': 3.0956,
      'phone': '+213 21 77 89 01',
      'opening_hours': '8:30 AM - 7:30 PM',
      'rating': 4.3,
      'address': 'Hussein Dey, Alger',
      'image_url': 'assets/images/ph3.jpg',
      'medicines': ['Wellness Products', 'Vitamins', 'Herbal Remedies', 'Organic Meds', 'Homeopathy'],
    },
    {
      'pharmacy_id': '12',
      'name': '24/7 Emergency Pharmacy',
      'latitude': 36.7133,
      'longitude': 3.1378,
      'phone': '+213 21 52 34 56',
      'opening_hours': '24/7',
      'rating': 4.5,
      'address': 'El Harrach, Alger',
      'image_url': 'assets/images/ph4.jpg',
      'medicines': ['Emergency Drugs', 'First Aid Kits', 'Antidotes', 'IV Fluids', 'Critical Care Meds'],
    },
    {
      'pharmacy_id': '13',
      'name': 'Family Care Pharmacy',
      'latitude': 36.7486,
      'longitude': 3.0566,
      'phone': '+213 21 63 78 90',
      'opening_hours': '24/7',
      'rating': 4.7,
      'address': 'Sidi M\'Hamed, Alger',
      'image_url': 'assets/images/ph1.jpg',
      'medicines': ['Pediatric Meds', 'Baby Care', 'Maternity Products', 'Family Planning', 'Child Vaccines'],
    },
    {
      'pharmacy_id': '14',
      'name': 'Community Pharmacy',
      'latitude': 36.7213,
      'longitude': 3.1158,
      'phone': '+213 21 45 23 67',
      'opening_hours': '8:00 AM - 8:00 PM',
      'rating': 4.5,
      'address': 'Bachdjerrah, Alger',
      'image_url': 'assets/images/ph2.jpg',
      'medicines': ['Common Meds', 'OTC Drugs', 'Basic First Aid', 'Health Products', 'Sanitizers'],
    },
    {
      'pharmacy_id': '15',
      'name': 'Seaside Pharmacy',
      'latitude': 36.7485,
      'longitude': 3.1943,
      'phone': '+213 21 87 65 43',
      'opening_hours': '8:00 AM - 9:00 PM',
      'rating': 4.4,
      'address': 'Bordj El Kiffan, Alger',
      'image_url': 'assets/images/ph3.jpg',
      'medicines': ['Travel Meds', 'Sea-sickness Pills', 'Sunscreen', 'After-sun Care', 'Travel Vaccines'],
    },
  ];

  // Get ALL pharmacies with complete data
  static List<Map<String, dynamic>> getAllPharmacies() {
    return _algerianPharmacies.map((pharmacy) {
      return {
        'pharmacy_id': pharmacy['pharmacy_id'] ?? '',
        'name': pharmacy['name'] ?? '',
        'latitude': pharmacy['latitude'],
        'longitude': pharmacy['longitude'],
        'phone': pharmacy['phone'] ?? '',
        'opening_hours': pharmacy['opening_hours'] ?? '08:00 - 20:00',
        'rating': pharmacy['rating']?.toDouble() ?? 4.5,
        'address': pharmacy['address'] ?? '',
        'image_url': pharmacy['image_url'] ?? 'assets/images/ph1.jpg',
        'medicines': pharmacy['medicines'] ?? [],
      };
    }).toList();
  }

  // Get ONE pharmacy by ID with complete data
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
          'phone': pharmacy['phone'] ?? '',
          'opening_hours': pharmacy['opening_hours'] ?? '08:00 - 20:00',
          'rating': pharmacy['rating']?.toDouble() ?? 4.5,
          'address': pharmacy['address'] ?? '',
          'image_url': pharmacy['image_url'] ?? 'assets/images/ph1.jpg',
          'medicines': pharmacy['medicines'] ?? [],
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

  // Get nearby pharmacies sorted by distance with complete data
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
        'distance_text': distance < 1 
            ? '${(distance * 1000).round()} m'
            : '${distance.toStringAsFixed(1)} km',
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

  // Search pharmacies by name, address, or medicines
  static List<Map<String, dynamic>> searchPharmacies(String query) {
    if (query.isEmpty) return [];

    print('🔍 Searching pharmacies for: "$query"');
    
    final searchQuery = query.toLowerCase();
    
    return _algerianPharmacies.where((pharmacy) {
      final name = (pharmacy['name'] ?? '').toLowerCase();
      final address = (pharmacy['address'] ?? '').toLowerCase();
      final medicines = List<String>.from(pharmacy['medicines'] ?? []);
      
      // Search in name, address, or medicines
      return name.contains(searchQuery) || 
             address.contains(searchQuery) ||
             medicines.any((medicine) => medicine.toLowerCase().contains(searchQuery));
    }).toList();
  }

  // Search medicines across all pharmacies
  static List<String> searchMedicines(String query) {
    if (query.isEmpty) return [];
    
    final searchQuery = query.toLowerCase();
    final allMedicines = <String>{};
    
    for (var pharmacy in _algerianPharmacies) {
      final medicines = List<String>.from(pharmacy['medicines'] ?? []);
      for (var medicine in medicines) {
        if (medicine.toLowerCase().contains(searchQuery)) {
          allMedicines.add(medicine);
        }
      }
    }
    
    return allMedicines.toList()..sort();
  }

  // Get user first name
  static String getUserFirstName() {
    return ''; // Default user name - replace with actual user data
  }

  // Get all medicines available across all pharmacies
  static List<String> getAllMedicines() {
    final allMedicines = <String>{};
    for (var pharmacy in _algerianPharmacies) {
      final medicines = List<String>.from(pharmacy['medicines'] ?? []);
      allMedicines.addAll(medicines);
    }
    return allMedicines.toList()..sort();
  }

  // Get pharmacies that have a specific medicine
  static List<Map<String, dynamic>> getPharmaciesByMedicine(String medicineName) {
    final searchQuery = medicineName.toLowerCase();
    
    return _algerianPharmacies.where((pharmacy) {
      final medicines = List<String>.from(pharmacy['medicines'] ?? []);
      return medicines.any((medicine) => 
          medicine.toLowerCase().contains(searchQuery));
    }).toList();
  }
}