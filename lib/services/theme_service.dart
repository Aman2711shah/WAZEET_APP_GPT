import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

/// Service to manage app theme (light/dark mode)
class ThemeService {
  static const String _themePrefKey = 'wazeet.themeMode';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<ThemeMode> _themeController =
      StreamController<ThemeMode>.broadcast();

  ThemeMode _currentTheme = ThemeMode.dark;

  ThemeService() {
    _init();
  }

  /// Initialize theme from SharedPreferences
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themePrefKey) ?? 'dark';

    _currentTheme = _themeModeFromString(themeName);
    _themeController.add(_currentTheme);
  }

  /// Stream of theme changes
  Stream<ThemeMode> get theme$ => _themeController.stream;

  /// Get current theme mode
  ThemeMode get currentTheme => _currentTheme;

  /// Set theme mode
  Future<void> setTheme(ThemeMode mode) async {
    _currentTheme = mode;
    _themeController.add(mode);

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, _themeModeToString(mode));

    // Optionally sync to Firestore if user is logged in
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'preferences': {'theme': _themeModeToString(mode)},
        }, SetOptions(merge: true));
      } catch (e) {
        // Ignore Firestore errors - local preference is saved
        debugPrint('Failed to sync theme to Firestore: $e');
      }
    }
  }

  /// Convert ThemeMode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convert string to ThemeMode
  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  /// Dispose resources
  void dispose() {
    _themeController.close();
  }
}
