import 'package:flutter/material.dart';

/// Spacing constants for consistent layout
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border radius constants
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 100.0;
}

/// Elevation constants
class AppElevation {
  static const double none = 0.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 16.0;
}

/// Typography scale
class AppTextStyle {
  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.22,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
}

class AppColors {
  // Modern brand colors with enhanced palette
  static const purple = Color(0xFF6D5DF6);
  static const purpleLight = Color(0xFF8A7CF8);
  static const purpleDark = Color(0xFF5547D9);
  static const primary = purple;

  // Accent colors
  static const blue = Color(0xFF4A90E2);
  static const blueLight = Color(0xFF64A5F2);
  static const green = Color(0xFF2BB673);
  static const greenLight = Color(0xFF3FCC87);
  static const gold = Color(0xFFF0B429);
  static const goldLight = Color(0xFFF5C543);
  static const cyan = Color(0xFF00BCD4);
  static const cyanLight = Color(0xFF26C6DA);
  static const orange = Color(0xFFFF6F00);
  static const orangeLight = Color(0xFFFF8F00);

  // Semantic colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Text colors
  static const dark = Color(0xFF1C1C1E);
  static const text = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const greyText = Color(0xFF9CA3AF);

  // Background colors
  static const background = Color(0xFFF9FAFB);
  static const backgroundSecondary = Color(0xFFF3F4F6);
  static const card = Colors.white;
  static const cardElevated = Color(0xFFFEFEFE);
  static const accent = purple;

  // Border colors
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);

  // Modern gradients
  static const gradientHeader = LinearGradient(
    colors: [Color(0xFF6D5DF6), Color(0xFF8A7CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientPurple = LinearGradient(
    colors: [Color(0xFF6D5DF6), Color(0xFF5547D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientBlue = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientGreen = LinearGradient(
    colors: [Color(0xFF2BB673), Color(0xFF239A5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCyan = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientOrange = LinearGradient(
    colors: [Color(0xFFFF6F00), Color(0xFFE65100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientGold = LinearGradient(
    colors: [Color(0xFFF0B429), Color(0xFFD9A021)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
      scaffoldBackgroundColor: AppColors.background,

      // Enhanced text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.text,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.text,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyLarge: TextStyle(color: AppColors.text),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
        bodySmall: TextStyle(color: AppColors.greyText),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        labelMedium: TextStyle(color: AppColors.textSecondary),
        labelSmall: TextStyle(color: AppColors.greyText),
      ),

      // Enhanced input decoration
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.purple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.greyText),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.greyText,
        suffixIconColor: AppColors.greyText,
      ),

      // Enhanced card theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Enhanced app bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        iconTheme: IconThemeData(color: AppColors.text),
      ),

      // Enhanced bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.purple,
        unselectedItemColor: AppColors.greyText,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Enhanced dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),

      // Enhanced button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.purple,
          side: const BorderSide(color: AppColors.purple),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.purple,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      // Enhanced chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        selectedColor: AppColors.purple.withValues(alpha: 0.2),
        disabledColor: AppColors.backgroundSecondary.withValues(alpha: 0.5),
        labelStyle: const TextStyle(color: AppColors.text),
        secondaryLabelStyle: const TextStyle(color: AppColors.textSecondary),
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Enhanced floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      // Enhanced snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.text,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Enhanced divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Enhanced progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.purple,
        circularTrackColor: AppColors.borderLight,
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
