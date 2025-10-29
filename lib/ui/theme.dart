import 'package:flutter/material.dart';

class AppColors {
  // Unified primary brand color (purple)
  static const purple = Color(0xFF6D5DF6);
  static const blue = Color(0xFF4A90E2);
  static const green = Color(0xFF2BB673);
  static const gold = Color(0xFFF0B429);
  static const dark = Color(0xFF1C1C1E);
  static const text = Color(0xFF222222);

  // Unified header gradient derived from the purple brand color
  static const gradientHeader = LinearGradient(
    colors: [Color(0xFF6D5DF6), Color(0xFF8A7CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const background = Color(0xFFF5F6FA);
  static const card = Colors.white;
  static const accent = Color(0xFF6D5DF6);
  static const greyText = Color(0xFF777777);

  // Dark mode colors
  static const darkBackground = Color(0xFF121212);
  static const darkCard = Color(0xFF1E1E1E);
  static const darkText = Color(0xFFE0E0E0);
  static const darkGreyText = Color(0xFFB0B0B0);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.purple,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.purple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: AppColors.purple,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: AppColors.darkCard,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCard,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        selectedItemColor: AppColors.purple,
        unselectedItemColor: AppColors.darkGreyText,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
