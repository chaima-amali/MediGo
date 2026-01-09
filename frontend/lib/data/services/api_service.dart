import 'api/api_client.dart';
import 'api/auth_api_service.dart';
import 'api/user_api_service.dart';
import 'api/medicine_api_service.dart';
import 'api/pharmacy_api_service.dart';
import 'api/reservation_api_service.dart';
import 'api/medication_log_api_service.dart';
import 'api/statistics_api_service.dart';
import 'api/sync_api_service.dart';
import 'api/tracking_api_service.dart';

/// Main API Service - Unified access to all API endpoints
///
/// This service combines all feature-specific API services for easy access.
/// Each feature has its own service file for better organization and maintainability.
///
/// Example usage:
/// ```dart
/// final api = ApiService();
/// api.initialize();
///
/// // Authentication
/// await api.auth.login(email, password);
///
/// // Medicines
/// final medicines = await api.medicines.getMedicines(userId);
///
/// // Medicine Tracking
/// await api.tracking.addMedicine(userId: 1, name: 'Aspirin', type: 'Tablet');
///
/// // Pharmacies
/// final pharmacies = await api.pharmacies.searchPharmacies(lat: 40.7, lng: -74.0);
/// ```
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Core API client
  final ApiClient _client = ApiClient();

  // Feature-specific services
  late final AuthApiService auth = AuthApiService();
  late final UserApiService users = UserApiService();
  late final MedicineApiService medicines = MedicineApiService();
  late final PharmacyApiService pharmacies = PharmacyApiService();
  late final ReservationApiService reservations = ReservationApiService();
  late final MedicationLogApiService medicationLogs = MedicationLogApiService();
  late final StatisticsApiService statistics = StatisticsApiService();
  late final SyncApiService sync = SyncApiService();
  late final TrackingApiService tracking = TrackingApiService();

  /// Initialize API service and all sub-services
  void initialize() {
    _client.initialize();
  }

  /// Set authentication token for all requests
  void setAuthToken(String token) {
    _client.setAuthToken(token);
  }

  /// Clear authentication token
  void clearAuthToken() {
    _client.clearAuthToken();
  }

  // ============ BACKWARD COMPATIBILITY METHODS ============
  // These methods maintain backward compatibility with existing code
  // New code should use the feature-specific services instead

  // Authentication (use api.auth instead)
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return auth.register(userData);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return auth.login(email, password);
  }

  Future<Map<String, dynamic>> verifyUser(String email) async {
    return auth.verifyUser(email);
  }

  // Users (use api.users instead)
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    return users.createUser(userData);
  }

  Future<Map<String, dynamic>> getUser(int userId) async {
    return users.getUser(userId);
  }

  Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    return users.updateUser(userId, userData);
  }

  Future<void> updateFCMToken(int userId, String token) async {
    return users.updateFCMToken(userId, token);
  }

  Future<void> updateNotificationPreference(int userId, bool enabled) async {
    return users.updateNotificationPreference(userId, enabled);
  }

  // Medicines (use api.medicines instead)
  Future<List<dynamic>> getMedicines(int userId) async {
    return medicines.getMedicines(userId);
  }

  Future<Map<String, dynamic>> createMedicine(
    Map<String, dynamic> medicineData,
  ) async {
    return medicines.createMedicine(medicineData);
  }

  Future<Map<String, dynamic>> updateMedicine(
    int medicineId,
    Map<String, dynamic> medicineData,
  ) async {
    return medicines.updateMedicine(medicineId, medicineData);
  }

  Future<void> deleteMedicine(int medicineId) async {
    return medicines.deleteMedicine(medicineId);
  }

  // Pharmacies (use api.pharmacies instead)
  Future<List<dynamic>> searchPharmacies({
    double? latitude,
    double? longitude,
    double? radius,
    String? medicineName,
  }) async {
    return pharmacies.searchPharmacies(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      medicineName: medicineName,
    );
  }

  Future<Map<String, dynamic>> getPharmacy(int pharmacyId) async {
    return pharmacies.getPharmacy(pharmacyId);
  }

  // Reservations (use api.reservations instead)
  Future<Map<String, dynamic>> createReservation(
    Map<String, dynamic> reservationData,
  ) async {
    return reservations.createReservation(reservationData);
  }

  Future<List<dynamic>> getReservations(int userId) async {
    return reservations.getReservations(userId);
  }

  Future<Map<String, dynamic>> updateReservationStatus(
    int reservationId,
    String status,
  ) async {
    return reservations.updateReservationStatus(reservationId, status);
  }

  // Medication Logs (use api.medicationLogs instead)
  Future<Map<String, dynamic>> logMedicationIntake(
    Map<String, dynamic> logData,
  ) async {
    return medicationLogs.logMedicationIntake(logData);
  }

  Future<List<dynamic>> getMedicationLogs(
    int userId, {
    String? startDate,
    String? endDate,
  }) async {
    return medicationLogs.getMedicationLogs(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Statistics (use api.statistics instead)
  Future<Map<String, dynamic>> getAdherenceStats(
    int userId, {
    String? period,
  }) async {
    return statistics.getAdherenceStats(userId, period: period);
  }

  // Sync (use api.sync instead)
  Future<Map<String, dynamic>> syncData(Map<String, dynamic> syncData) async {
    return sync.syncData(syncData);
  }
}
