import 'api_client.dart';

/// Pharmacy API Service
/// Handles pharmacy search and information
class PharmacyApiService {
  final ApiClient _client = ApiClient();

  /// Search for pharmacies near a location
  ///
  /// Optional parameters:
  /// - [latitude] - User's latitude
  /// - [longitude] - User's longitude
  /// - [radius] - Search radius in kilometers
  /// - [medicineName] - Filter by medicine availability
  Future<List<dynamic>> searchPharmacies({
    double? latitude,
    double? longitude,
    double? radius,
    String? medicineName,
  }) async {
    final response = await _client.get(
      '/pharmacies/search',
      queryParameters: {
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        if (radius != null) 'radius': radius,
        if (medicineName != null) 'medicine': medicineName,
      },
    );
    return response.data as List<dynamic>;
  }

  /// Get pharmacy details by ID
  Future<Map<String, dynamic>> getPharmacy(int pharmacyId) async {
    final response = await _client.get('/pharmacies/$pharmacyId');
    return response.data as Map<String, dynamic>;
  }
}
