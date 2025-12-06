import 'package:frontend/presentation/services/pharmacies.dart';
import '../models/pharmacy.dart';

class PharmacyRepository {
  // Get all pharmacies from mock database
  List<Pharmacy> getAllPharmacies() {
    final pharmaciesData = MockDataServices.getAllPharmacies();
    return pharmaciesData.map((data) => Pharmacy.fromMap(data)).toList();
  }

  // Get pharmacy by ID
  Pharmacy? getPharmacyById(String pharmacyId) {
    try {
      final pharmacyData = MockDataServices.getPharmacyById(pharmacyId);
      if (pharmacyData.isNotEmpty) {
        return Pharmacy.fromMap(pharmacyData);
      }
    } catch (e) {
      print('Error getting pharmacy by ID: $e');
    }
    return null;
  }

  // Search pharmacies by name
  List<Pharmacy> searchPharmaciesByName(String query) {
    if (query.trim().isEmpty) return [];
    
    final allPharmacies = getAllPharmacies();
    final lowerQuery = query.toLowerCase();
    
    return allPharmacies.where((pharmacy) {
      return pharmacy.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}