import 'api_client.dart';

/// Pharmacy API Service
/// Handles pharmacy search and information
class PharmacyApiService {
  final ApiClient _client = ApiClient();

  /// Get all pharmacies
  Future<Map<String, dynamic>> getAllPharmacies({
    double? userLat,
    double? userLon,
  }) async {
    final response = await _client.get(
      '/pharmacies/all',
      queryParameters: {
        if (userLat != null) 'user_lat': userLat,
        if (userLon != null) 'user_lon': userLon,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Search pharmacies by name
  Future<Map<String, dynamic>> searchPharmaciesByName(String query) async {
    final response = await _client.get(
      '/pharmacies/search',
      queryParameters: {'q': query},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get pharmacy details by ID
  Future<Map<String, dynamic>> getPharmacy(int pharmacyId) async {
    final response = await _client.get('/pharmacies/$pharmacyId');
    return response.data as Map<String, dynamic>;
  }

  /// Get nearby pharmacies
  Future<Map<String, dynamic>> getNearbyPharmacies({
    required double lat,
    required double lon,
    double radius = 10.0,
    int limit = 10,
  }) async {
    final response = await _client.get(
      '/pharmacies/nearby',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'radius': radius,
        'limit': limit,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
