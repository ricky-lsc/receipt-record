import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/l10n/app_localizations.dart';
import 'package:receipt_record/services/locale_service.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:receipt_record/widgets/app_settings_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await LocaleService.instance.init();
  });

  group('AppSettingsDialog Hub Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      );
    }

    testWidgets('Displays all consolidated settings: Appearance, Language, AI, Storage', (tester) async {
      final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

      await tester.pumpWidget(
        buildTestApp(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => AppSettingsDialog.show(context, themeNotifier),
              child: const Text('Open Settings'),
            );
          }),
        ),
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Settings'), findsWidgets);
      expect(find.text('THEME & APPEARANCE'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Cloud AI Settings'), findsOneWidget);
      expect(find.text('Storage Location & Backup'), findsOneWidget);

      // Scroll down to Data Management
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('DATA MANAGEMENT'), findsOneWidget);
      expect(find.text('Export Receipts'), findsOneWidget);
      expect(find.text('Import & Restore'), findsOneWidget);
      expect(find.text('Clear All Data'), findsOneWidget);

      // Verify closing dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AppSettingsDialog), findsNothing);
    });
  });
}
