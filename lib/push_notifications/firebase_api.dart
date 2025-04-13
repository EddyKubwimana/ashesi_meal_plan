import "dart:convert";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "../screens/eating_goals.dart";
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import "package:ashesi_meal_plan/main.dart" as man;

import 'package:shared_preferences/shared_preferences.dart';

class FirebaseApi {
  FlutterLocalNotificationsPlugin get _localNotifications =>
      man.localNotifications;
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

    if (scheduleDate.isBefore(now)) {
      scheduleDate =
          scheduleDate.add(Duration(days: 1)); // schedule for next day
    }
    await _localNotifications.zonedSchedule(
        id, title, body, scheduleDate, const NotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }
}
