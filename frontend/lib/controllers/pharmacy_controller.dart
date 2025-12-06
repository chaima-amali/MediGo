import '../data/models/pharmacy.dart';
import '../data/models/user.dart';
import '../data/repositories/pharmacy_repo.dart';
import '../services/location_service.dart';

class PharmacyController {
  final PharmacyRepository _repository = PharmacyRepository();

  // Get nearest pharmacies based on user location
  List<PharmacyWithDistance> getNearestPharmacies({
    required User user,
    int limit = 10,
  }) {
    // Check if user has location data
    if (user.latitude == null || user.longitude == null) {
      print('User location not available');
      return [];
    }

    // Get all pharmacies
    final allPharmacies = _repository.getAllPharmacies();

    // Calculate distances and sort
    final nearestPharmacies = LocationService.getPharmaciesByDistance(
      userLat: user.latitude!,
      userLon: user.longitude!,
      pharmacies: allPharmacies,
      limit: limit,
    );

    return nearestPharmacies;
  }

  // Search pharmacies by name
  List<Pharmacy> searchPharmacies(String query) {
    return _repository.searchPharmaciesByName(query);
  }

  // Get pharmacy by ID
  Pharmacy? getPharmacyById(String pharmacyId) {
    return _repository.getPharmacyById(pharmacyId);
  }

  // Get all pharmacies
  List<Pharmacy> getAllPharmacies() {
    return _repository.getAllPharmacies();
  }
}