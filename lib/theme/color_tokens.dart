import 'package:flutter/material.dart';

/// Semantic design tokens and custom surfaces exposed via ThemeExtension.
class AppColors extends ThemeExtension<AppColors> {
  final Color positive;
  final Color warning;
  final Color danger;
  final Gradient primaryGradient;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;

  const AppColors({
    required this.positive,
    required this.warning,
    required this.danger,
    required this.primaryGradient,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  static AppColors light(ColorScheme scheme) => AppColors(
    positive: const Color(0xFF2BB673),
    warning: const Color(0xFFF0B429),
    danger: const Color(0xFFE53935),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      // Brighter purple → soft pink/purple for the light theme
      colors: [Color(0xFF7B5CF9), Color(0xFFE29BFF)],
    ),
    surfaceContainer: scheme.surface.withValues(alpha: 0.9),
    surfaceContainerHigh: scheme.surfaceContainerHigh,
    surfaceContainerHighest: scheme.surfaceContainerHighest,
  );

  static AppColors dark(ColorScheme scheme) => AppColors(
    positive: const Color(0xFF35D19B),
    warning: const Color(0xFFFFCC66),
    danger: const Color(0xFFFF6B6B),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      // Slightly cooler gradient for dark mode
      colors: [Color(0xFF9D85FF), Color(0xFF7B5CF9)],
    ),
    surfaceContainer: scheme.surfaceContainer,
    surfaceContainerHigh: scheme.surfaceContainerHigh,
    surfaceContainerHighest: scheme.surfaceContainerHighest,
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? positive,
    Color? warning,
    Color? danger,
    Gradient? primaryGradient,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
  }) {
    return AppColors(
      positive: positive ?? this.positive,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      positive: Color.lerp(positive, other.positive, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      primaryGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
            (primaryGradient as LinearGradient).colors.first,
            (other.primaryGradient as LinearGradient).colors.first,
            t,
          )!,
          Color.lerp(
            (primaryGradient as LinearGradient).colors.last,
            (other.primaryGradient as LinearGradient).colors.last,
            t,
          )!,
        ],
      ),
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      )!,
      surfaceContainerHighest: Color.lerp(
        surfaceContainerHighest,
        other.surfaceContainerHighest,
        t,
      )!,
    );
  }
}
