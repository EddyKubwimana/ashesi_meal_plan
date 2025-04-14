import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:ashesi_meal_plan/main.dart' as man;

class FirebaseApi {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _eatingGoalsChannel =
      AndroidNotificationChannel(
    'eating_goals_channel',
    'Eating Goals Reminders',
    description: 'Channel for eating goals reminders',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    // Timezone setup
    tz.initializeTimeZones();

    // Android init
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await _localNotifications.initialize(initSettings);

    // Create notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_eatingGoalsChannel);

    // Request permission for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleNotifs({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    Future<void> showTestNotif() async {
      await man.localNotifications.show(
        999, // ID (unique)
        ' Test Notification',
        'If you see this, notifications are working!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'eating_goals_channel',
            'Eating Goals Reminders',
            channelDescription: 'Daily reminders to achieve eating goals',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    print("Notification scheduled for: $scheduleDate");

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduleDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'eating_goals_channel',
          'Eating Goals Reminders',
          channelDescription: 'Channel for eating goals reminders',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
