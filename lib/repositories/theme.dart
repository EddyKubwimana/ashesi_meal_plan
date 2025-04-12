import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF961818);

  static const String fontFamily = 'customfont';

  static final ThemeData lightTheme = ThemeData(
    fontFamily: fontFamily,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontFamily: fontFamily),
      displayMedium: TextStyle(fontFamily: fontFamily),
      displaySmall: TextStyle(fontFamily: fontFamily),
      headlineLarge: TextStyle(fontFamily: fontFamily),
      headlineMedium: TextStyle(fontFamily: fontFamily),
      headlineSmall: TextStyle(fontFamily: fontFamily),
      titleLarge: TextStyle(fontFamily: fontFamily),
      titleMedium: TextStyle(fontFamily: fontFamily),
      titleSmall: TextStyle(fontFamily: fontFamily),
      bodyLarge: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontFamily: fontFamily,
      ),
      labelLarge: TextStyle(fontFamily: fontFamily),
      labelMedium: TextStyle(fontFamily: fontFamily),
      labelSmall: TextStyle(fontFamily: fontFamily),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(fontFamily: fontFamily),
      hintStyle: TextStyle(fontFamily: fontFamily),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontFamily: fontFamily),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    fontFamily: fontFamily,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: fontFamily,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontFamily: fontFamily),
      displayMedium: TextStyle(fontFamily: fontFamily),
      displaySmall: TextStyle(fontFamily: fontFamily),
      headlineLarge: TextStyle(fontFamily: fontFamily),
      headlineMedium: TextStyle(fontFamily: fontFamily),
      headlineSmall: TextStyle(fontFamily: fontFamily),
      titleLarge: TextStyle(fontFamily: fontFamily),
      titleMedium: TextStyle(fontFamily: fontFamily),
      titleSmall: TextStyle(fontFamily: fontFamily),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontFamily: fontFamily,
      ),
      labelLarge: TextStyle(fontFamily: fontFamily),
      labelMedium: TextStyle(fontFamily: fontFamily),
      labelSmall: TextStyle(fontFamily: fontFamily),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(fontFamily: fontFamily),
      hintStyle: TextStyle(fontFamily: fontFamily),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white54, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontFamily: fontFamily),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
