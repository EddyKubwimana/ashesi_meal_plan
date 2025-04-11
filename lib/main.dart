import 'package:ashesi_meal_plan/push_notifications/firebase_api.dart';
import 'package:ashesi_meal_plan/screens/login.dart';
import 'package:ashesi_meal_plan/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ashesi_meal_plan/controllers/auth_controller.dart';
import 'package:ashesi_meal_plan/screens/register.dart';
import 'package:ashesi_meal_plan/repositories/theme.dart';
import './routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  final firebaseApi = FirebaseApi();
  await Firebase.initializeApp();
  await firebaseApi.initNotifications();
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.signIn,
      getPages: [
        GetPage(
          name: AppRoutes.signIn,
          page: () => const SignInScreen(),
          transition: Transition.fadeIn,
        ),
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
