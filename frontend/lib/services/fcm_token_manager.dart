import 'package:flutter/foundation.dart';
import '../data/services/fcm_service.dart';
import '../logic/cubits/user_cubit.dart';

/// Helper class to manage FCM token updates
class FCMTokenManager {
  static final FCMTokenManager _instance = FCMTokenManager._internal();
  factory FCMTokenManager() => _instance;
  FCMTokenManager._internal();

  bool _isInitialized = false;

  /// Initialize FCM token management with automatic refresh handling
  Future<void> initialize(UserCubit userCubit) async {
    if (_isInitialized) {
      debugPrint('⚠️ FCM Token Manager already initialized');
      return;
    }

    try {
      final fcmService = FCMService();

      // Set up token refresh listener
      fcmService.onTokenRefresh((newToken) async {
        debugPrint('🔄 FCM Token refreshed, updating user...');

        // Get current user
        final state = userCubit.state;
        if (state is UserAuthenticated || state is UserLoaded) {
          final user = state is UserAuthenticated
              ? state.user
              : (state as UserLoaded).user;

          if (user.userId != null) {
            await userCubit.updateFCMToken(user.userId!, newToken);
          }
        }
      });

      _isInitialized = true;
      debugPrint('✅ FCM Token Manager initialized');
    } catch (e) {
      debugPrint('❌ FCM Token Manager initialization error: $e');
    }
  }

  /// Manually update FCM token for a user
  Future<void> updateTokenForUser(UserCubit userCubit, int userId) async {
    try {
      final fcmService = FCMService();
      final token = fcmService.fcmToken;

      if (token != null) {
        await userCubit.updateFCMToken(userId, token);
      } else {
        debugPrint('⚠️ No FCM token available to update');
      }
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
    }
  }
}
