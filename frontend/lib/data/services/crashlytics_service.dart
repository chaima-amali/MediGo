import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Service for Firebase Crashlytics integration
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  /// Initialize Crashlytics
  Future<void> initialize() async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
      
      FlutterError.onError = _crashlytics.recordFlutterFatalError;
      
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
      
      debugPrint('✅ Crashlytics initialized successfully');
    } catch (e) {
      debugPrint('❌ Crashlytics initialization error: $e');
    }
  }

  /// Log an error to Crashlytics
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      debugPrint('📊 Error logged to Crashlytics: $error');
    } catch (e) {
      debugPrint('❌ Failed to log error to Crashlytics: $e');
    }
  }

  /// Log a message to Crashlytics
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      debugPrint('❌ Failed to log message to Crashlytics: $e');
    }
  }

  /// Set user identifier
  Future<void> setUserIdentifier(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      debugPrint('👤 User identifier set: $userId');
    } catch (e) {
      debugPrint('❌ Failed to set user identifier: $e');
    }
  }

  /// Set custom key-value pair
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      debugPrint('❌ Failed to set custom key: $e');
    }
  }

  /// Check if Crashlytics is enabled
  bool get isCrashlyticsEnabled => !kDebugMode;
}
