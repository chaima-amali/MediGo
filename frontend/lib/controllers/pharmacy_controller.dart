import '../data/models/pharmacy.dart';
import '../data/models/user.dart';
import '../data/repositories/pharmacy_repo.dart';
import '../presentation/services/location_service.dart';

class PharmacyController {
  final PharmacyRepository _repository = PharmacyRepository();

  // Get nearest pharmacies based on user location
  Future<List<PharmacyWithDistance>> getNearestPharmacies({
    required User user,
    int limit = 10,
  }) async {
    // Check if user has location data
    if (user.latitude == null || user.longitude == null) {
      print('User location not available');
      return [];
    }

    // Get all pharmacies
    final allPharmacies = await _repository.getAllPharmacies();

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
  Future<List<Pharmacy>> searchPharmacies(String query) async {
    return await _repository.searchPharmaciesByName(query);
  }

  // Get pharmacy by ID
  Future<Pharmacy?> getPharmacyById(int pharmacyId) async {
    return await _repository.getPharmacyById(pharmacyId);
  }

  // Get all pharmacies
  Future<List<Pharmacy>> getAllPharmacies() async {
    return await _repository.getAllPharmacies();
  }
}
