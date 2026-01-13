import 'package:flutter/material.dart';
import 'package:frontend/logic/cubits/user_cubit.dart';
import 'package:frontend/data/services/fcm_service.dart';

/// Manages FCM token refresh and updates to the backend
class FCMTokenManager {
  /// Initialize the token refresh handler
  /// This sets up a listener for FCM token changes and updates the backend
  Future<void> initialize(UserCubit userCubit) async {
    try {
      final fcmService = FCMService();

      // Set up callback for token refresh
      fcmService.onTokenRefresh((newToken) async {
        debugPrint('🔄 FCM Token refreshed, updating backend: $newToken');

        // Get current user from cubit
        final state = userCubit.state;
        if (state is UserAuthenticated) {
          final userId = state.user.userId;
          if (userId != null) {
            await updateTokenForUser(userId, newToken, userCubit);
          }
        }
      });

      debugPrint('✅ FCM token refresh handler initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize FCM token manager: $e');
    }
  }

  /// Update FCM token for a specific user
  Future<void> updateTokenForUser(
    int userId,
    String fcmToken,
    UserCubit userCubit,
  ) async {
    try {
      await userCubit.updateFCMToken(userId, fcmToken);
      debugPrint('✅ FCM token updated for user $userId');
    } catch (e) {
      debugPrint('❌ Failed to update FCM token: $e');
    }
  }
}
