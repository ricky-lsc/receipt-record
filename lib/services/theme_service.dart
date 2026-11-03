import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService instance = ThemeService._internal();
  ThemeService._internal();

  static const String _prefThemeKey = 'app_theme_mode';

  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_prefThemeKey);
      if (modeStr == 'dark') {
        themeModeNotifier.value = ThemeMode.dark;
      } else if (modeStr == 'light') {
        themeModeNotifier.value = ThemeMode.light;
      } else {
        themeModeNotifier.value = ThemeMode.system;
      }
    } catch (e) {
      debugPrint('ThemeService init warning: $e');
      themeModeNotifier.value = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (mode) {
        case ThemeMode.dark:
          await prefs.setString(_prefThemeKey, 'dark');
          break;
        case ThemeMode.light:
          await prefs.setString(_prefThemeKey, 'light');
          break;
        case ThemeMode.system:
          await prefs.setString(_prefThemeKey, 'system');
          break;
      }
    } catch (e) {
      debugPrint('ThemeService save warning: $e');
    }
  }

  Future<void> toggleTheme(bool isCurrentlyDark) async {
    await setThemeMode(isCurrentlyDark ? ThemeMode.light : ThemeMode.dark);
  }
}
