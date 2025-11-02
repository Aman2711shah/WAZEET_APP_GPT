import 'package:flutter/material.dart';

class AppColors {
  // Unified primary brand color (purple)
  static const purple = Color(0xFF6D5DF6);
  static const primary = purple; // Alias for primary color
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

  // Dark mode colors - Enhanced
  static const darkBackground = Color(0xFF0A0A0A);
  static const darkCard = Color(0xFF1C1C1E);
  static const darkCardElevated = Color(0xFF2C2C2E);
  static const darkText = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFE0E0E0);
  static const darkGreyText = Color(0xFF8E8E93);
  static const darkBorder = Color(0xFF38383A);
  static const darkPurple = Color(0xFF8A7CF8);
  static const darkPurpleLight = Color(0xFFA69AF8);
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
      colorSchemeSeed: AppColors.darkPurple,
      scaffoldBackgroundColor: AppColors.darkBackground,

      // Enhanced text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextSecondary,
        ),
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
        bodySmall: TextStyle(color: AppColors.darkGreyText),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        labelMedium: TextStyle(color: AppColors.darkTextSecondary),
        labelSmall: TextStyle(color: AppColors.darkGreyText),
      ),

      // Enhanced input decoration
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        isDense: true,
        filled: true,
        fillColor: AppColors.darkCard,
        hintStyle: const TextStyle(color: AppColors.darkGreyText),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        prefixIconColor: AppColors.darkGreyText,
        suffixIconColor: AppColors.darkGreyText,
      ),

      // Enhanced card theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Enhanced app bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        iconTheme: IconThemeData(color: AppColors.darkText),
      ),

      // Enhanced bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        selectedItemColor: AppColors.darkPurple,
        unselectedItemColor: AppColors.darkGreyText,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Enhanced dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.darkTextSecondary,
        ),
      ),

      // Enhanced popup menu
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        textStyle: const TextStyle(color: AppColors.darkText),
      ),

      // Enhanced list tile theme
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.darkText,
        iconColor: AppColors.darkTextSecondary,
        selectedColor: AppColors.darkPurple,
        selectedTileColor: Color(0xFF2C2C2E),
      ),

      // Enhanced divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 0.5,
        space: 1,
      ),

      // Enhanced chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.darkPurple.withValues(alpha: 0.2),
        disabledColor: AppColors.darkCard.withValues(alpha: 0.5),
        labelStyle: const TextStyle(color: AppColors.darkText),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
        ),
        brightness: Brightness.dark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),

      // Enhanced button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPurple,
          side: const BorderSide(color: AppColors.darkPurple),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPurple,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      // Enhanced icon theme
      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
        size: 24,
      ),

      // Enhanced floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Enhanced switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPurple;
          }
          return AppColors.darkGreyText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPurple.withValues(alpha: 0.5);
          }
          return AppColors.darkBorder;
        }),
      ),

      // Enhanced progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkPurple,
        circularTrackColor: AppColors.darkBorder,
      ),

      // Enhanced snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCardElevated,
        contentTextStyle: const TextStyle(color: AppColors.darkText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
    );
  }
}
