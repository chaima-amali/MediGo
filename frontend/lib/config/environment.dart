/// Environment configuration for MediGo app
/// Contains API endpoints and service configuration
class Environment {
  // Flask Backend Configuration
  static const String flaskBaseUrl = String.fromEnvironment(
    'FLASK_BASE_URL',
    defaultValue:
        'http://10.66.113.125:5000/api', // Change to your PC IP when testing on device or use localhost for the emulator
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
