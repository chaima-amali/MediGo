/// Environment configuration for MediGo app
/// Contains API endpoints and service configuration
class Environment {
  // Flask Backend Configuration
  static const String flaskBaseUrl = String.fromEnvironment(
    'FLASK_BASE_URL',
    defaultValue:
       // 'http://localhost:5000/api', // Works with ADB reverse or emulator or desktop
    // 'http://10.0.2.2:5000/api', // For Android emulator (maps to localhost)
     'http://172.20.10.4:5000/api', // For physical device on same WiFi - CURRENT IP
    // 'http://10.66.113.125:5000/api', // Old IP
  );

  // App Configuration
  static const bool isProduction = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: false,
  );

  // Sync Configuration
  static const int syncIntervalMinutes = 30;
  static const int maxRetryAttempts = 3;
  static const Duration syncTimeout = Duration(seconds: 30);

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableAutoSync = true;
  static const bool enableCrashReporting = true;
}
