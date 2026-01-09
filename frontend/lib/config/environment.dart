/// Environment configuration for MediGo app
/// Contains API endpoints and service configuration
class Environment {
  // Flask Backend Configuration
  // IMPORTANT: Update this IP to match your backend server's IP address
  // - For emulator/web: use 'http://localhost:5000/api' or '10.0.2.2:5000/api' (emulator default gateway)
  // - For physical device: use your PC's local IP (e.g., 192.168.x.x or 10.x.x.x)
  // - Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find your PC's IP
  
  // UPDATE THIS IP ADDRESS TO YOUR BACKEND SERVER'S IP
  static const String flaskBaseUrl = String.fromEnvironment(
    'FLASK_BASE_URL',
    defaultValue: 'http://192.168.1.3:5000/api', // CHANGE THIS TO YOUR PC'S IP
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
