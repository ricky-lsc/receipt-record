import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/l10n/app_localizations.dart';
import 'package:receipt_record/screens/add_edit_receipt_screen.dart';
import 'package:receipt_record/services/locale_service.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:receipt_record/widgets/quick_receipt_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StorageService.instance.clearAll();
    await LocaleService.instance.init();
  });

  group('QuickReceiptActionSheet Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      );
    }

    testWidgets('QuickReceiptActionSheet displays camera, gallery, and manual entry options', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => QuickReceiptActionSheet.show(context),
              child: const Text('Add Receipt'),
            );
          }),
        ),
      );

      await tester.tap(find.text('Add Receipt'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Record Receipt'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.text('Manual Entry (No Photo)'), findsOneWidget);

      // Tap Manual Entry
      await tester.tap(find.text('Manual Entry (No Photo)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify AddEditReceiptScreen opened
      expect(find.byType(AddEditReceiptScreen), findsOneWidget);
      expect(find.text('MERCHANT / STORE NAME'), findsOneWidget);
    });

    testWidgets('AddEditReceiptScreen initializes with initialImagePath attached', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const AddEditReceiptScreen(
            initialImagePath: '/dummy/receipt/path.jpg',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Receipt Attached'), findsOneWidget);
      expect(find.text('AI Extract'), findsOneWidget);
      expect(find.text('Scan OCR'), findsOneWidget);
    });
  });
}
