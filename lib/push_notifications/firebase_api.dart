import "package:firebase_messaging/firebase_messaging.dart" ;
import "../screens/eating_goals.dart";
import 'package:get/get.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future <void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    initPushNotifications();
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
  }
} 