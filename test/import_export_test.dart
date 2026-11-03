import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/l10n/app_localizations.dart';
import 'package:receipt_record/models/receipt.dart';
import 'package:receipt_record/models/receipt_item.dart';
import 'package:receipt_record/services/export_service.dart';
import 'package:receipt_record/services/locale_service.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:receipt_record/widgets/import_preview_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StorageService.instance.clearAll();
    await LocaleService.instance.init();
  });

  group('ExportService Import Parsing Tests', () {
    test('parseJson correctly decodes snapshot backup JSON', () {
      final now = DateTime(2026, 11, 2);
      final jsonSnapshot = json.encode({
        'version': '1.0',
        'exportedAt': now.toIso8601String(),
        'receipts': [
          {
            'id': 'rec_json_1',
            'merchant': 'Trader Joe\'s',
            'amount': 42.50,
            'currency': '\$',
            'date': now.toIso8601String(),
            'category': 'groceries',
            'paymentMethod': 'Credit Card',
            'items': [
              {'id': 'i1', 'name': 'Milk', 'quantity': 1, 'unitPrice': 4.50}
            ],
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          }
        ]
      });

      final parsed = ExportService.parseJson(jsonSnapshot);
      expect(parsed.length, 1);
      expect(parsed[0].merchant, 'Trader Joe\'s');
      expect(parsed[0].amount, 42.50);
      expect(parsed[0].category, 'groceries');
      expect(parsed[0].items.length, 1);
      expect(parsed[0].items[0].name, 'Milk');
    });

    test('parseCsv correctly decodes exported CSV table', () {
      final now = DateTime(2026, 11, 2);
      final original = [
        Receipt(
          id: 'rec_csv_1',
          merchant: 'Starbucks Coffee',
          amount: 6.75,
          currency: '\$',
          date: now,
          category: 'dining',
          paymentMethod: 'Debit Card',
          items: const [
            ReceiptItem(id: '1', name: 'Latte', quantity: 1, unitPrice: 6.75),
          ],
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final csvString = ExportService.generateCsv(original);
      final parsed = ExportService.parseCsv(csvString);

      expect(parsed.length, 1);
      expect(parsed[0].merchant, 'Starbucks Coffee');
      expect(parsed[0].amount, 6.75);
      expect(parsed[0].category, 'dining');
      expect(parsed[0].paymentMethod, 'Debit Card');
    });
  });

  group('StorageService Import Strategies Tests', () {
    test('Import merge strategy appends new receipts and preserves existing', () async {
      final storage = StorageService.instance;

      final existing = Receipt(
        id: 'existing_1',
        merchant: 'Existing Store',
        amount: 20.0,
        date: DateTime(2026, 11, 1),
        category: 'shopping',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storage.saveReceipt(existing);

      final toImport = [
        Receipt(
          id: 'imported_1',
          merchant: 'Imported Store',
          amount: 50.0,
          date: DateTime(2026, 11, 2),
          category: 'dining',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await storage.importReceipts(toImport, overwrite: false);

      expect(storage.receiptsNotifier.value.length, 2);
      expect(storage.getReceipt('existing_1'), isNotNull);
      expect(storage.getReceipt('imported_1'), isNotNull);
    });

    test('Import overwrite strategy replaces all existing receipts', () async {
      final storage = StorageService.instance;

      final existing = Receipt(
        id: 'existing_old',
        merchant: 'Old Store',
        amount: 100.0,
        date: DateTime(2026, 10, 1),
        category: 'other',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storage.saveReceipt(existing);

      final newSet = [
        Receipt(
          id: 'new_set_1',
          merchant: 'New Store',
          amount: 30.0,
          date: DateTime(2026, 11, 2),
          category: 'groceries',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await storage.importReceipts(newSet, overwrite: true);

      expect(storage.receiptsNotifier.value.length, 1);
      expect(storage.getReceipt('existing_old'), isNull);
      expect(storage.getReceipt('new_set_1'), isNotNull);
    });
  });

  group('ImportPreviewDialog Widget Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      );
    }

    testWidgets('ImportPreviewDialog displays statistics and imports records', (tester) async {
      final toImport = [
        Receipt(
          id: 'prev_1',
          merchant: 'Costco',
          amount: 120.0,
          currency: '\$',
          date: DateTime(2026, 11, 2),
          category: 'groceries',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Receipt(
          id: 'prev_2',
          merchant: 'IKEA',
          amount: 80.0,
          currency: '\$',
          date: DateTime(2026, 11, 2),
          category: 'shopping',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        buildTestApp(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => ImportPreviewDialog.show(
                context,
                receipts: toImport,
                format: 'JSON Backup',
                fileName: 'backup.json',
              ),
              child: const Text('Open Import'),
            );
          }),
        ),
      );

      await tester.tap(find.text('Open Import'));
      await tester.pumpAndSettle();

      expect(find.text('Import Preview'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // 2 receipts
      expect(find.text('\$200.00'), findsOneWidget); // Total spending
      expect(find.text('Merge with Existing'), findsOneWidget);
      expect(find.text('Overwrite All Records'), findsOneWidget);
      expect(find.text('Confirm Import'), findsOneWidget);

      // Confirm import
      await tester.tap(find.text('Confirm Import'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(StorageService.instance.receiptsNotifier.value.length, 2);
      expect(StorageService.instance.getReceipt('prev_1'), isNotNull);
      expect(StorageService.instance.getReceipt('prev_2'), isNotNull);
    });
  });
}
