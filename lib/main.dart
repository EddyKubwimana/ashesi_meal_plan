import 'package:flutter/material.dart';
import 'package:ashesi_meal_plan/screens/welcome.dart';
import 'package:ashesi_meal_plan/screens/login.dart';
import 'package:ashesi_meal_plan/screens/register.dart';
import 'package:ashesi_meal_plan/repositories/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Plan',
      theme: AppTheme.lightTheme, // Apply light theme
      darkTheme: AppTheme.darkTheme, // Apply dark theme
      themeMode: ThemeMode.system, // Auto switch based on device settings
      home: const SignInScreen(), // Correct placement of home
      debugShowCheckedModeBanner: false, // Optional: Removes debug banner
    );
  }
}
