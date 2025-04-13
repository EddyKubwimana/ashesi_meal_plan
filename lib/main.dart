import 'package:ashesi_meal_plan/screens/eating_goals.dart';
import 'package:ashesi_meal_plan/screens/login.dart';
import 'package:ashesi_meal_plan/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ashesi_meal_plan/controllers/auth_controller.dart';
import 'package:ashesi_meal_plan/screens/register.dart';
import 'package:ashesi_meal_plan/repositories/theme.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await localNotifications.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),

  );
  
  runApp(MyApp());
}

class AppRoutes {
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String dashboard = '/dashboard';
  static const String eatingGoals = "/eating_goals";

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.signUp,
      getPages: [
        GetPage(
          name: AppRoutes.signIn,
          page: () => const SignInScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
<<<<<<< HEAD
            name: AppRoutes.splash,
            page: () => const WelcomeScreen(),
            transition: Transition.circularReveal),
        GetPage(
=======
>>>>>>> 17b39edc1526ca6195c5f637d683a25d2cb9219e
          name: AppRoutes.signUp,
          page: () => SignUpScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: AppRoutes.dashboard,
          page: () => DashboardScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(name: AppRoutes.eatingGoals, 
        page:() => MyCLPage(),
        transition: Transition.fadeIn,
        )
      ],
    );
  }
}
