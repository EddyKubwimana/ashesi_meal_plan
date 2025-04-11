import "dart:convert";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "package:firebase_messaging/firebase_messaging.dart" ;
import "../screens/eating_goals.dart";
import 'package:get/get.dart';
import '../screens/eating_goals.dart';
import 'package:timezone/timezone.dart' as tz;
import "package:flutter_timezone/flutter_timezone.dart";

import 'package:shared_preferences/shared_preferences.dart';

class FirebaseApi {
  late SharedPreferences tokens;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
    "high_importance_channel",
    "High Importance Notifications",
    description: "This channel is used for important notifications",
    importance: Importance.defaultImportance,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();
  Future <void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken() ?? "";
    tokens = await SharedPreferences.getInstance();
  
    if (!tokens.containsKey("device") && fCMToken != "") {
      tokens.setString("device", fCMToken);
    }

    initPushNotifications();
    initLocalNotifications();
  }
  void handleMessage(RemoteMessage? message){
    if(message == null) return;
    Get.to(() => const MyCLPage());
  }
  Future initPushNotifications() async {
    await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      //if app opened from notification
      FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
      //if app in background
      FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
      FirebaseMessaging.onMessage.listen((message){
        final notification = message.notification;
        if (notification == null) return;
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id, _androidChannel.name
              ),
          ),
          payload: jsonEncode(message.toMap()),
        );


      });
  }
  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings("../assets/images/ashesi_logo.webp");
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(payload));
          handleMessage(message);
        }
      },
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin> ();
    await platform?.createNotificationChannel(_androidChannel);
  }
  Future <void> scheduleNotifs({ 
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,}) async{
      final now = tz.TZDateTime.now(tz.local);
      var scheduleDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduleDate,
        const NotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
}   