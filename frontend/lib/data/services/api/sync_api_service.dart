import 'api_client.dart';

/// Sync API Service
/// Handles data synchronization between local and remote databases
class SyncApiService {
  final ApiClient _client = ApiClient();

  /// Sync data with remote server
  Future<Map<String, dynamic>> syncData(Map<String, dynamic> syncData) async {
    final response = await _client.post('/sync', data: syncData);
    return response.data as Map<String, dynamic>;
  }
}
