import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode'; // system|light|dark

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeController._(this._themeMode);

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key) ?? 'system';
    return ThemeController._(_fromString(value));
  }

  Future<void> setThemeMode(ThemeMode m) async {
    _themeMode = m;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _toString(m));
  }

  static String _toString(ThemeMode m) => switch (m) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  static ThemeMode _fromString(String s) => switch (s) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
