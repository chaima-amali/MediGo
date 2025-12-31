import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/config/environment.dart';
import 'package:frontend/data/services/crashlytics_service.dart';

/// API Service for Flask Backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final CrashlyticsService _crashlytics = CrashlyticsService();

  /// Initialize API service
  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Environment.flaskBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _crashlytics.logError(
            error,
            error.stackTrace,
            reason: 'API Error: ${error.requestOptions.path}',
          );
          return handler.next(error);
        },
      ),
    );

    debugPrint('✅ API Service initialized: ${Environment.flaskBaseUrl}');
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    debugPrint('🔐 Auth token set');
  }

  /// Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    debugPrint('🔐 Auth token cleared');
  }

  // ============ GENERIC HTTP METHODS ============

  /// Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ============ ERROR HANDLING ============

  void _handleError(DioException error) {
    String errorMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage = 'Server error: ${error.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection';
        break;
      default:
        errorMessage = 'Unknown error occurred';
    }

    debugPrint('❌ API Error: $errorMessage');
    debugPrint('❌ Details: ${error.message}');
  }

  // ============ SPECIFIC API ENDPOINTS ============

  // Users
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final response = await post('/users', data: userData);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUser(int userId) async {
    final response = await get('/users/$userId');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    final response = await put('/users/$userId', data: userData);
    return response.data as Map<String, dynamic>;
  }

  // Medicines
  Future<List<dynamic>> getMedicines(int userId) async {
    final response = await get(
      '/medicines',
      queryParameters: {'user_id': userId},
    );
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createMedicine(
    Map<String, dynamic> medicineData,
  ) async {
    final response = await post('/medicines', data: medicineData);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateMedicine(
    int medicineId,
    Map<String, dynamic> medicineData,
  ) async {
    final response = await put('/medicines/$medicineId', data: medicineData);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteMedicine(int medicineId) async {
    await delete('/medicines/$medicineId');
  }

  // Pharmacies
  Future<List<dynamic>> searchPharmacies({
    double? latitude,
    double? longitude,
    double? radius,
    String? medicineName,
  }) async {
    final response = await get(
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

  Future<Map<String, dynamic>> getPharmacy(int pharmacyId) async {
    final response = await get('/pharmacies/$pharmacyId');
    return response.data as Map<String, dynamic>;
  }

  // Reservations
  Future<Map<String, dynamic>> createReservation(
    Map<String, dynamic> reservationData,
  ) async {
    final response = await post('/reservations', data: reservationData);
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getReservations(int userId) async {
    final response = await get(
      '/reservations',
      queryParameters: {'user_id': userId},
    );
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateReservationStatus(
    int reservationId,
    String status,
  ) async {
    final response = await put(
      '/reservations/$reservationId/status',
      data: {'status': status},
    );
    return response.data as Map<String, dynamic>;
  }

  // Medication Logs
  Future<Map<String, dynamic>> logMedicationIntake(
    Map<String, dynamic> logData,
  ) async {
    final response = await post('/medication-logs', data: logData);
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMedicationLogs(
    int userId, {
    String? startDate,
    String? endDate,
  }) async {
    final response = await get(
      '/medication-logs',
      queryParameters: {
        'user_id': userId,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      },
    );
    return response.data as List<dynamic>;
  }

  // Statistics
  Future<Map<String, dynamic>> getAdherenceStats(
    int userId, {
    String? period,
  }) async {
    final response = await get(
      '/statistics/adherence',
      queryParameters: {
        'user_id': userId,
        if (period != null) 'period': period,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // FCM Token
  Future<void> updateFCMToken(int userId, String token) async {
    await post('/users/$userId/fcm-token', data: {'token': token});
  }

  // Sync
  Future<Map<String, dynamic>> syncData(Map<String, dynamic> syncData) async {
    final response = await post('/sync', data: syncData);
    return response.data as Map<String, dynamic>;
  }
}
