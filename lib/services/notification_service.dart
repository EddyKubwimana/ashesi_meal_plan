import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    try {
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Check if notifications are enabled (default to true if not set)
      bool notificationsEnabled =
          _prefs.getBool('notifications_enabled') ?? true;

      if (!notificationsEnabled) return;

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          // Save the last opened notification
          if (details.payload != null) {
            _prefs.setString('last_notification', details.payload!);
          }
        },
      );
    } catch (e) {
      print('Notification initialization error: $e');
    }
  }

  static Future<bool> get notificationsEnabled async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getBool('notifications_enabled') ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool('notifications_enabled', enabled);

    if (enabled) {
      await _requestPermissions();
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Check if notifications are enabled
      bool enabled = await notificationsEnabled;
      if (!enabled) return;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'cafeteria_notifications',
        'Cafeteria Proximity Alerts',
        channelDescription: 'Notifications when near cafeterias',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
        autoCancel: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Save notification to history
      await _saveNotificationToHistory(title, body);

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  static Future<void> _saveNotificationToHistory(
      String title, String body) async {
    try {
      final String notificationJson =
          '{"title": "$title", "body": "$body", "time": "${DateTime.now().toIso8601String()}"}';
      List<String> history = _prefs.getStringList('notification_history') ?? [];
      history.add(notificationJson);

      // Keep only the last 50 notifications
      if (history.length > 50) {
        history = history.sublist(history.length - 50);
      }

      await _prefs.setStringList('notification_history', history);
    } catch (e) {
      print('Error saving notification to history: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      List<String> history = _prefs.getStringList('notification_history') ?? [];
      return history.map((jsonString) {
        try {
          // Simple JSON parsing (for demo purposes)
          final cleanString = jsonString
              .replaceAll('\\"', '"')
              .replaceAll('"{', '{')
              .replaceAll('}"', '}');
          final parts = cleanString.split(',');
          final title = parts[0].split(':')[1].trim().replaceAll('"', '');
          final body = parts[1].split(':')[1].trim().replaceAll('"', '');
          final time = parts[2]
              .split(':')[1]
              .trim()
              .replaceAll('"', '')
              .replaceAll('}', '');

          return {
            'title': title,
            'body': body,
            'time': DateTime.parse(time),
          };
        } catch (e) {
          return {
            'title': 'Error',
            'body': 'Could not parse notification',
            'time': DateTime.now()
          };
        }
      }).toList();
    } catch (e) {
      print('Error getting notification history: $e');
      return [];
    }
  }

  static Future<void> clearNotificationHistory() async {
    try {
      await _prefs.remove('notification_history');
    } catch (e) {
      print('Error clearing notification history: $e');
    }
  }

  static Future<void> configure() async {
    await _requestPermissions();
    await init();
  }

  static Future<void> _requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
}
