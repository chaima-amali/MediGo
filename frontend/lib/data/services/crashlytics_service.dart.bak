import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Crashlytics Service for error reporting
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initialize Crashlytics
  Future<void> initialize() async {
    try {
      // Enable crash collection in release mode only
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      debugPrint('✅ Crashlytics initialized (enabled: ${!kDebugMode})');

      // Set custom keys
      await _crashlytics.setCustomKey('app_version', '1.0.0');
      await _crashlytics.setCustomKey(
        'build_mode',
        kDebugMode ? 'debug' : 'release',
      );
    } catch (e) {
      debugPrint('❌ Crashlytics initialization error: $e');
    }
  }

  /// Set user identifier
  Future<void> setUserIdentifier(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      debugPrint('👤 Crashlytics user ID set: $userId');
    } catch (e) {
      debugPrint('❌ Error setting Crashlytics user ID: $e');
    }
  }

  /// Log custom error
  Future<void> logError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      debugPrint('📝 Error logged to Crashlytics: $exception');
    } catch (e) {
      debugPrint('❌ Error logging to Crashlytics: $e');
    }
  }

  /// Log custom message/event
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
      debugPrint('📝 Logged to Crashlytics: $message');
    } catch (e) {
      debugPrint('❌ Error logging message: $e');
    }
  }

  /// Set custom key-value pair
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      debugPrint('❌ Error setting custom key: $e');
    }
  }

  /// Force a crash (for testing only)
  void forceCrash() {
    if (kDebugMode) {
      debugPrint('⚠️ Force crash is only for testing!');
      _crashlytics.crash();
    }
  }
}
