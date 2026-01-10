import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

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
  }
}
