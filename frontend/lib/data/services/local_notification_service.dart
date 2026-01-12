import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;


import 'package:flutter/foundation.dart';

/// Service for local scheduled notifications (medicine reminders)
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      // fallback to UTC if local zone not found
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
    // Ensure Android notification channel exists
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        const channel = AndroidNotificationChannel(
          'medigo_channel',
          'MediGo Notifications',
          description: 'Notifications for MediGo app',
          importance: Importance.high,
        );
        await androidPlugin.createNotificationChannel(channel);
      }
    } catch (_) {}
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    await initialize();

    final androidDetails = AndroidNotificationDetails(
      'medigo_channel',
      'MediGo Notifications',
      channelDescription: 'Notifications for MediGo app',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

    // helper to schedule a single time if it's in the future
    Future<void> _scheduleIfFuture(int nid, tz.TZDateTime when) async {
      try {
        final now = tz.TZDateTime.now(tz.local);
        if (!when.isAfter(now)) {
          // skip scheduling past times
          // ignore: avoid_print
          print('⏭️ Skipping scheduling for $when (in the past)');
          return;
        }
        // ignore: avoid_print
        print('⏰ Scheduling notification id=$nid at $when');
        await _plugin.zonedSchedule(
          nid,
          title,
          body,
          when,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (e) {
        // ignore: avoid_print
        print('⚠️ Failed to schedule notification id=$nid at $when: $e');
      }
    }

    // Schedule 1 hour before
    final oneHourBefore = tzDate.subtract(const Duration(hours: 1));
    final idBefore = (id + 1) % 2147483647;
    await _scheduleIfFuture(idBefore, oneHourBefore);

    // Schedule at exact time
    await _scheduleIfFuture(id, tzDate);
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

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

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      debugPrint('✅ Local notifications initialized');
    } catch (e) {
      debugPrint('❌ Local notification initialization error: $e');
    }
  }

  /// Schedule a medicine reminder notification
  Future<void> scheduleMedicineReminder({
    required int id,
    required String medicineName,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    if (!_initialized) await initialize();

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'medicine_reminders',
            'Medicine Reminders',
            channelDescription: 'Scheduled reminders for taking medicines',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      // Only schedule if time is in the future
      if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
        await _notifications.zonedSchedule(
          id,
          '💊 Time to take your medicine',
          '$medicineName - $dosage',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );

        debugPrint(
          '✅ Scheduled reminder for $medicineName at $scheduledTime (ID: $id)',
        );
      } else {
        debugPrint('⚠️ Cannot schedule past notification: $scheduledTime');
      }
    } catch (e) {
      debugPrint('❌ Failed to schedule reminder: $e');
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('✅ Cancelled notification ID: $id');
    } catch (e) {
      debugPrint('❌ Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('✅ Cancelled all notifications');
    } catch (e) {
      debugPrint('❌ Failed to cancel all notifications: $e');
    }
  }

  /// Show immediate notification
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'medigo_general',
            'General Notifications',
            channelDescription: 'General notifications from MediGo',
            importance: Importance.high,
            priority: Priority.high,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, notificationDetails);

      debugPrint('✅ Showed notification: $title');
    } catch (e) {
      debugPrint('❌ Failed to show notification: $e');
    }
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // TODO: Navigate to medication tracking screen
  }
}
