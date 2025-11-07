import 'package:flutter/material.dart';

/// Custom page route with slide transition from right
class SlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideRightRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      );
}

/// Custom page route with fade transition
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: curve));
          var opacityAnimation = animation.drive(tween);

          return FadeTransition(opacity: opacityAnimation, child: child);
        },
      );
}

/// Custom page route with scale and fade transition
class ScaleFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleFadeRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOutCubic;

          var scaleTween = Tween(
            begin: 0.92,
            end: 1.0,
          ).chain(CurveTween(curve: curve));
          var scaleAnimation = animation.drive(scaleTween);

          var fadeTween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: curve));
          var fadeAnimation = animation.drive(fadeTween);

          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(scale: scaleAnimation, child: child),
          );
        },
      );
}

/// Custom page route with slide from bottom transition (for modal-like pages)
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      );
}

/// Extension method on BuildContext for easy navigation with custom transitions
extension NavigationExtensions on BuildContext {
  /// Navigate with slide from right transition
  Future<T?> pushWithSlide<T>(Widget page) {
    return Navigator.of(this).push<T>(SlideRightRoute(page: page));
  }

  /// Navigate with fade transition
  Future<T?> pushWithFade<T>(Widget page) {
    return Navigator.of(this).push<T>(FadeRoute(page: page));
  }

  /// Navigate with scale and fade transition
  Future<T?> pushWithScale<T>(Widget page) {
    return Navigator.of(this).push<T>(ScaleFadeRoute(page: page));
  }

  /// Navigate with slide up transition (modal style)
  Future<T?> pushWithSlideUp<T>(Widget page) {
    return Navigator.of(this).push<T>(SlideUpRoute(page: page));
  }
}
