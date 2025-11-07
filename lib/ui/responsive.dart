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
    double maxHeight = 140; // Reduced from 280

    if (w >= 1024) {
      targetFraction = 0.18; // Reduced from 0.35 for compact header
      minHeight = 120; // Reduced from 220
    } else if (w >= 768) {
      targetFraction = 0.16; // Reduced from 0.32
      minHeight = 110; // Reduced from 200
    } else {
      targetFraction = 0.15; // Reduced from 0.30
      minHeight = 100; // Reduced from 180
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
