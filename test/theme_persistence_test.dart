import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ThemeService.instance.init();
  });

  group('ThemeService Persistence Tests', () {
    test('Default theme mode is ThemeMode.system', () {
      expect(ThemeService.instance.themeModeNotifier.value, ThemeMode.system);
    });

    test('Persists and restores dark mode', () async {
      final theme = ThemeService.instance;

      await theme.setThemeMode(ThemeMode.dark);
      expect(theme.themeModeNotifier.value, ThemeMode.dark);

      // Re-initialize from storage
      await theme.init();
      expect(theme.themeModeNotifier.value, ThemeMode.dark);
    });

    test('Persists and restores light mode', () async {
      final theme = ThemeService.instance;

      await theme.setThemeMode(ThemeMode.light);
      expect(theme.themeModeNotifier.value, ThemeMode.light);

      await theme.init();
      expect(theme.themeModeNotifier.value, ThemeMode.light);
    });

    test('Toggles theme mode correctly', () async {
      final theme = ThemeService.instance;

      // When currently dark, toggle sets light
      await theme.toggleTheme(true);
      expect(theme.themeModeNotifier.value, ThemeMode.light);

      // When currently light, toggle sets dark
      await theme.toggleTheme(false);
      expect(theme.themeModeNotifier.value, ThemeMode.dark);
    });
  });
}
