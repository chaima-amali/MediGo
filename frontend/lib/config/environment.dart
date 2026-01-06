/// Environment configuration for MediGo app
/// Contains API endpoints and service configuration
class Environment {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://oubdfkmmmjrvyfroqcoy.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91YmRma21tbWpydnlmcm9xY295Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcyOTQ0NjMsImV4cCI6MjA4Mjg3MDQ2M30.G7Gva5X0_ZiKajvJAEjzl_72zebeb1zernJfZrblfgo',
  );

  // Flask Backend Configuration
  static const String flaskBaseUrl = String.fromEnvironment(
    'FLASK_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
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
