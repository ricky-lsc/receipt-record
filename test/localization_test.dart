import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/l10n/app_localizations.dart';
import 'package:receipt_record/main.dart';
import 'package:receipt_record/services/locale_service.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await LocaleService.instance.init();
  });

  group('LocaleService and Localizations Tests', () {
    test('LocaleService default is null (Follow System)', () {
      expect(LocaleService.instance.localeNotifier.value, isNull);
    });

    test('LocaleService persists and restores selected locale', () async {
      final service = LocaleService.instance;

      await service.setLocale(LocaleService.localeSimplifiedChinese);
      expect(service.localeNotifier.value, LocaleService.localeSimplifiedChinese);

      // Re-initialize from storage
      await service.init();
      expect(service.localeNotifier.value, LocaleService.localeSimplifiedChinese);

      await service.setLocale(LocaleService.localeTraditionalChinese);
      expect(service.localeNotifier.value, LocaleService.localeTraditionalChinese);

      await service.init();
      expect(service.localeNotifier.value, LocaleService.localeTraditionalChinese);

      await service.setLocale(LocaleService.localeEnglish);
      expect(service.localeNotifier.value, LocaleService.localeEnglish);

      await service.setLocale(null);
      expect(service.localeNotifier.value, isNull);
    });

    testWidgets('AppLocalizations loads correct translations for each locale', (tester) async {
      late AppLocalizations enL10n;
      late AppLocalizations hansL10n;
      late AppLocalizations hantL10n;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(builder: (context) {
            enL10n = AppLocalizations.of(context);
            return const SizedBox();
          }),
        ),
      );
      expect(enL10n.appTitle, 'Receipt Record');
      expect(enL10n.navReceipts, 'Receipts');
      expect(enL10n.categoryGroceries, 'Groceries');

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
          home: Builder(builder: (context) {
            hansL10n = AppLocalizations.of(context);
            return const SizedBox();
          }),
        ),
      );
      expect(hansL10n.appTitle, '收据记账');
      expect(hansL10n.navReceipts, '收据明细');
      expect(hansL10n.categoryGroceries, '日常买菜');

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
          home: Builder(builder: (context) {
            hantL10n = AppLocalizations.of(context);
            return const SizedBox();
          }),
        ),
      );
      expect(hantL10n.appTitle, '收據記帳');
      expect(hantL10n.navReceipts, '收據明細');
      expect(hantL10n.categoryGroceries, '日常採買');
    });

    testWidgets('Switching locale dynamically changes the UI strings across app', (tester) async {
      await tester.pumpWidget(const ReceiptRecordApp());
      await tester.pumpAndSettle();

      // Default (English in test environment)
      expect(find.text('Receipts'), findsWidgets);
      expect(find.text('Summary'), findsWidgets);

      // Switch to Traditional Chinese
      await LocaleService.instance.setLocale(LocaleService.localeTraditionalChinese);
      await tester.pumpAndSettle();

      expect(find.text('收據明細'), findsWidgets);
      expect(find.text('支出統計'), findsWidgets);

      // Switch to Simplified Chinese
      await LocaleService.instance.setLocale(LocaleService.localeSimplifiedChinese);
      await tester.pumpAndSettle();

      expect(find.text('收据明细'), findsWidgets);
      expect(find.text('支出统计'), findsWidgets);

      // Switch back to English
      await LocaleService.instance.setLocale(LocaleService.localeEnglish);
      await tester.pumpAndSettle();

      expect(find.text('Receipts'), findsWidgets);
      expect(find.text('Summary'), findsWidgets);
    });

    testWidgets('LanguageSelectionDialog displays options and changes language', (tester) async {
      await tester.pumpWidget(const ReceiptRecordApp());
      await tester.pumpAndSettle();

      // Open Settings Dialog via Settings Icon
      final settingsButton = find.byIcon(Icons.settings_outlined);
      expect(settingsButton, findsWidgets);
      await tester.tap(settingsButton.first);
      await tester.pumpAndSettle();

      // Tap Language tile inside Settings
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Language'), findsOneWidget);
      expect(find.text('Follow System'), findsWidgets);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Traditional Chinese (繁體中文)'), findsOneWidget);
      expect(find.text('Simplified Chinese (简体中文)'), findsOneWidget);

      // Select Traditional Chinese
      await tester.tap(find.text('Traditional Chinese (繁體中文)'));
      await tester.pumpAndSettle();

      expect(LocaleService.instance.localeNotifier.value, LocaleService.localeTraditionalChinese);
      expect(find.text('收據明細'), findsWidgets);
    });
  });
}
