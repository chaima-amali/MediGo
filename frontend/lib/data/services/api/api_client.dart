import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/config/environment.dart';
import 'package:frontend/data/services/crashlytics_service.dart';

/// Base API client for making HTTP requests
/// Provides generic HTTP methods (GET, POST, PUT, DELETE) and error handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  final CrashlyticsService _crashlytics = CrashlyticsService();

  /// Get Dio instance for advanced use
  Dio get dio => _dio;

  /// Initialize API client
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

    debugPrint('✅ API Client initialized: ${Environment.flaskBaseUrl}');
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
        errorMessage = 'Connection timeout - backend server may be unreachable';
        break;
      case DioExceptionType.badResponse:
        errorMessage = 'Server error: ${error.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection or backend server unreachable';
        break;
      default:
        errorMessage = 'Unknown error occurred';
    }

    debugPrint('❌ API Error: $errorMessage');
    debugPrint('❌ Request URL: ${error.requestOptions.uri}');
    debugPrint('❌ Method: ${error.requestOptions.method}');
    debugPrint('❌ Status Code: ${error.response?.statusCode}');
    debugPrint('❌ Response: ${error.response?.data}');
    debugPrint('❌ Details: ${error.message}');
  }
}
