import "dart:convert";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "package:firebase_messaging/firebase_messaging.dart" ;
import "../screens/eating_goals.dart";
import 'package:get/get.dart';

class FirebaseApi {
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
    final fCMToken = await _firebaseMessaging.getToken();
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
}   