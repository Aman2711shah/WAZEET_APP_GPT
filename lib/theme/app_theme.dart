import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

class AppTheme {
  // Updated seed to a more vivid purple to better match the app gradient
  static const seed = Color(0xFF7B5CF9);

  static ThemeData _base(ColorScheme scheme) {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Use background for overall page background; surface is for cards/surfaces
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onSecondaryContainer,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        scheme.brightness == Brightness.dark
            ? AppColors.dark(scheme)
            : AppColors.light(scheme),
      ],
    );
  }

  static ThemeData get light => _base(
    ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
  );

  static ThemeData get dark =>
      _base(ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark));
}
