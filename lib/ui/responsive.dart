import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Responsive helpers for hero/banner sizing and typography.
class Responsive {
  /// Computes hero/section banner height based on viewport with sensible clamps.
  /// Breakpoints:
  /// - Desktop (>=1024): ~35vh, min 220, max 280
  /// - Tablet  (768-1023): ~32vh, min 200
  /// - Mobile  (<=767): ~30vh, min 180
  static double heroHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    double targetFraction;
    double minHeight;
    double maxHeight = 240; // Increased to prevent overflow

    if (w >= 1024) {
      targetFraction = 0.30;
      minHeight = 200;
    } else if (w >= 768) {
      targetFraction = 0.26;
      minHeight = 180;
    } else {
      targetFraction = 0.24;
      minHeight = 170;
    }

    final computed = h * targetFraction;
    return math.max(minHeight, math.min(computed, maxHeight));
  }

  /// CSS-like clamp for font sizes: clamp(min, preferred (vw), max)
  static double clampFont(
    BuildContext context, {
    required double min,
    required double vw,
    required double max,
  }) {
    final width = MediaQuery.of(context).size.width;
    final preferred = width * (vw / 100);
    return preferred.clamp(min, max);
  }
}
