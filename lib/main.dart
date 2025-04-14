import 'package:ashesi_meal_plan/push_notifications/firebase_api.dart';
import 'package:ashesi_meal_plan/screens/login.dart';
import 'package:ashesi_meal_plan/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ashesi_meal_plan/controllers/auth_controller.dart';
import 'package:ashesi_meal_plan/screens/register.dart';
import 'package:ashesi_meal_plan/repositories/theme.dart';
import 'package:ashesi_meal_plan/routes/app_routes.dart';
import 'package:ashesi_meal_plan/screens/welcome.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ashesi_meal_plan/services/notification_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await FirebaseApi().initialize();
  await NotificationService.init();
  await NotificationService.configure();

  final String timeZoneName = await FlutterTimezone.getLocalTimezone();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    Get.put(AuthController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ashesi Meal Plan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'customfont',
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 14.0),
        ),
      ),
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(
          name: AppRoutes.signIn,
          page: () => const SignInScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
            name: AppRoutes.splash,
            page: () => const WelcomeScreen(),
            transition: Transition.circularReveal),
        GetPage(
          name: AppRoutes.signUp,
          page: () => SignUpScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: AppRoutes.dashboard,
          page: () => DashboardScreen(),
          transition: Transition.fadeIn,
        )
      ],
    );
  }
}
