import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📨 Background message received: ${message.messageId}');
  debugPrint('📨 Title: ${message.notification?.title}');
  debugPrint('📨 Body: ${message.notification?.body}');
}

/// Firebase Cloud Messaging Service
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ FCM: User granted permission');

        // Get FCM token
        _fcmToken = await _fcm.getToken();
        debugPrint('📱 FCM Token: $_fcmToken');

        // Configure local notifications
        await _configureLocalNotifications();

        // Set up message handlers
        _setupMessageHandlers();

        // Handle token refresh
        _fcm.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('🔄 FCM Token refreshed: $newToken');
          // TODO: Send token to backend
        });
      } else {
        debugPrint('❌ FCM: User declined permission');
      }
    } catch (e) {
      debugPrint('❌ FCM initialization error: $e');
    }
  }

  /// Configure local notifications for Android
  Future<void> _configureLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medigo_channel',
      'MediGo Notifications',
      description: 'Important medication and pharmacy notifications',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Set up message handlers for different states
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Foreground message: ${message.messageId}');
      _showLocalNotification(message);
    });

    // Background/Terminated - message tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📨 Message opened app: ${message.messageId}');
      _handleNotificationTap(message.data);
    });

    // Check if app was opened from terminated state
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📨 App opened from terminated state: ${message.messageId}');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Display local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medigo_channel',
            'MediGo Notifications',
            channelDescription:
                'Important medication and pharmacy notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Local notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload
  }

  /// Handle FCM notification tap
  void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('📱 FCM notification tapped with data: $data');

    // Route based on notification type
    String? type = data['type'];
    switch (type) {
      case 'medication_reminder':
        // TODO: Navigate to medication details
        break;
      case 'reservation_update':
        // TODO: Navigate to reservation screen
        break;
      case 'pharmacy_alert':
        // TODO: Navigate to pharmacy screen
        break;
      default:
        // TODO: Navigate to home
        break;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Send token to backend
  Future<void> sendTokenToBackend(int userId) async {
    if (_fcmToken == null) return;

    try {
      // TODO: Implement API call to backend
      debugPrint('📤 Sending FCM token to backend for user $userId');
      // Example:
      // await dio.post('/users/$userId/fcm-token', data: {'token': _fcmToken});
    } catch (e) {
      debugPrint('❌ Error sending FCM token: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _fcm.deleteToken();
      _fcmToken = null;
      debugPrint('✅ FCM token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }
}
