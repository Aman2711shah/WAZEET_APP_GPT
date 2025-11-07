import 'package:flutter/material.dart';

/// Responsive font size helper
/// Returns appropriate font size based on screen width breakpoints
double rFont(
  BuildContext context, {
  required double sm,
  required double md,
  required double lg,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 360) return sm;
  if (width < 420) return md;
  return lg;
}
