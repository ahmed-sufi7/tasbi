import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF6C63FF); // Soft purple
  static const Color lightSecondary = Color(0xFF4ECDC4); // Turquoise
  static const Color lightAccent = Color(0xFFFF6B9D); // Soft pink
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);
  
  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF6C63FF);
  static const Color darkSecondary = Color(0xFF4ECDC4);
  static const Color darkAccent = Color(0xFFFF6B9D);
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkTextPrimary = Color(0xFFECECEC);
  static const Color darkTextSecondary = Color(0xFFB2B2B2);
  
  // Shared Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);
  static const Color info = Color(0xFF74B9FF);
  
  // iOS-style Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      tertiary: lightAccent,
      surface: lightSurface,
      background: lightBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
      onBackground: lightTextPrimary,
      onError: Colors.white,
    ),
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: lightBackground,
      foregroundColor: lightTextPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
        letterSpacing: -0.4,
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      elevation: 0,
      color: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // ElevatedButton Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
    ),
    
    // TextButton Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.3,
        ),
      ),
    ),
    
    // FloatingActionButton Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(
        color: lightTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: lightTextPrimary, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: lightTextPrimary, letterSpacing: -0.5),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightTextPrimary, letterSpacing: -0.3),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: lightTextPrimary, letterSpacing: -0.3),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: lightTextPrimary, letterSpacing: -0.3),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightTextPrimary, letterSpacing: -0.2),
      titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: lightTextPrimary, letterSpacing: -0.4),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: lightTextPrimary, letterSpacing: -0.3),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: lightTextPrimary, letterSpacing: -0.2),
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: lightTextPrimary, letterSpacing: -0.4),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: lightTextPrimary, letterSpacing: -0.3),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: lightTextSecondary, letterSpacing: -0.2),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: lightTextPrimary, letterSpacing: -0.3),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: lightTextPrimary, letterSpacing: -0.2),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: lightTextSecondary, letterSpacing: -0.1),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 0.5,
      space: 1,
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: lightTextPrimary,
      size: 24,
    ),
  );
  
  // iOS-style Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      tertiary: darkAccent,
      surface: darkSurface,
      background: darkBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
      onError: Colors.white,
    ),
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: darkBackground,
      foregroundColor: darkTextPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        letterSpacing: -0.4,
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      elevation: 0,
      color: darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // ElevatedButton Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
    ),
    
    // TextButton Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.3,
        ),
      ),
    ),
    
    // FloatingActionButton Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: darkPrimary,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(
        color: darkTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: darkTextPrimary, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkTextPrimary, letterSpacing: -0.5),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkTextPrimary, letterSpacing: -0.3),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: darkTextPrimary, letterSpacing: -0.3),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkTextPrimary, letterSpacing: -0.3),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkTextPrimary, letterSpacing: -0.2),
      titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: darkTextPrimary, letterSpacing: -0.4),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: darkTextPrimary, letterSpacing: -0.3),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkTextPrimary, letterSpacing: -0.2),
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: darkTextPrimary, letterSpacing: -0.4),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: darkTextPrimary, letterSpacing: -0.3),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: darkTextSecondary, letterSpacing: -0.2),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: darkTextPrimary, letterSpacing: -0.3),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: darkTextPrimary, letterSpacing: -0.2),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: darkTextSecondary, letterSpacing: -0.1),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
      thickness: 0.5,
      space: 1,
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: darkTextPrimary,
      size: 24,
    ),
  );
  
  // iOS-style CupertinoTheme for Light Mode
  static CupertinoThemeData lightCupertinoTheme = const CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    barBackgroundColor: lightSurface,
    textTheme: CupertinoTextThemeData(
      primaryColor: lightTextPrimary,
      textStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: lightTextPrimary,
        letterSpacing: -0.4,
      ),
      navTitleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: lightTextPrimary,
        letterSpacing: -0.4,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: lightTextPrimary,
        letterSpacing: -0.5,
      ),
    ),
  );
  
  // iOS-style CupertinoTheme for Dark Mode
  static CupertinoThemeData darkCupertinoTheme = const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    barBackgroundColor: darkSurface,
    textTheme: CupertinoTextThemeData(
      primaryColor: darkTextPrimary,
      textStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: darkTextPrimary,
        letterSpacing: -0.4,
      ),
      navTitleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: darkTextPrimary,
        letterSpacing: -0.4,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: darkTextPrimary,
        letterSpacing: -0.5,
      ),
    ),
  );
}
