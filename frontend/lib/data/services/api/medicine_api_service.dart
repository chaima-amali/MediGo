import 'api_client.dart';

/// Medicine API Service
/// Handles medicine-related operations
class MedicineApiService {
  final ApiClient _client = ApiClient();

  /// Get all medicines for a user
  Future<List<dynamic>> getMedicines(int userId) async {
    final response = await _client.get(
      '/medicines',
      queryParameters: {'user_id': userId},
    );
    return response.data as List<dynamic>;
  }

  /// Create a new medicine entry
  Future<Map<String, dynamic>> createMedicine(
    Map<String, dynamic> medicineData,
  ) async {
    final response = await _client.post('/medicines', data: medicineData);
    return response.data as Map<String, dynamic>;
  }

  /// Update medicine information
  Future<Map<String, dynamic>> updateMedicine(
    int medicineId,
    Map<String, dynamic> medicineData,
  ) async {
    final response = await _client.put(
      '/medicines/$medicineId',
      data: medicineData,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Delete a medicine
  Future<void> deleteMedicine(int medicineId) async {
    await _client.delete('/medicines/$medicineId');
  }
}
