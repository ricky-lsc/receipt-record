import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receipt_record/models/receipt.dart';
import 'package:receipt_record/models/receipt_category.dart';
import 'package:receipt_record/models/receipt_item.dart';
import 'package:receipt_record/models/summary_data.dart';
import 'package:receipt_record/services/export_service.dart';
import 'package:receipt_record/services/ocr_service.dart';
import 'package:receipt_record/services/receipt_parser.dart';
import 'package:receipt_record/services/sample_data_service.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:receipt_record/utils/currency_helper.dart';
import 'package:receipt_record/utils/date_helper.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StorageService.instance.clearAll();
  });

  group('Category & Payment Method Tests', () {
    test('ReceiptCategory defaults and fromId lookup', () {
      expect(ReceiptCategory.defaults.length, greaterThanOrEqualTo(8));
      expect(ReceiptCategory.fromId('groceries').name, 'Groceries');
      expect(ReceiptCategory.fromId('DINING').name, 'Dining & Cafes');
      expect(ReceiptCategory.fromId('non-existent-cat').name, 'Other');
    });

    test('PaymentMethod fromString parsing', () {
      expect(PaymentMethod.fromString('Credit Card'), PaymentMethod.creditCard);
      expect(PaymentMethod.fromString('cash'), PaymentMethod.cash);
      expect(PaymentMethod.fromString('Unknown'), PaymentMethod.other);
    });
  });

  group('StorageService CRUD Tests', () {
    test('Can save, update, retrieve, and delete receipts', () async {
      final now = DateTime.now();
      final r1 = Receipt(
        id: 'r-1',
        merchant: 'Target',
        amount: 32.50,
        date: now,
        category: 'shopping',
        createdAt: now,
        updatedAt: now,
      );

      await StorageService.instance.saveReceipt(r1);
      var receipts = StorageService.instance.receiptsNotifier.value;
      expect(receipts.length, 1);
      expect(receipts.first.merchant, 'Target');
      expect(receipts.first.amount, 32.50);

      // Update same receipt
      final updatedR1 = r1.copyWith(merchant: 'Super Target', amount: 40.00);
      await StorageService.instance.saveReceipt(updatedR1);
      receipts = StorageService.instance.receiptsNotifier.value;
      expect(receipts.length, 1);
      expect(receipts.first.merchant, 'Super Target');
      expect(receipts.first.amount, 40.00);

      // Delete receipt
      await StorageService.instance.deleteReceipt('r-1');
      receipts = StorageService.instance.receiptsNotifier.value;
      expect(receipts.isEmpty, true);
    });

    test('Can import receipts and clear all', () async {
      final now = DateTime.now();
      final samples = [
        Receipt(
          id: 's-1',
          merchant: 'Store 1',
          amount: 10.0,
          date: now,
          category: 'groceries',
          createdAt: now,
          updatedAt: now,
        ),
        Receipt(
          id: 's-2',
          merchant: 'Store 2',
          amount: 20.0,
          date: now,
          category: 'dining',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await StorageService.instance.importReceipts(samples);
      expect(StorageService.instance.receiptsNotifier.value.length, 2);

      await StorageService.instance.clearAll();
      expect(StorageService.instance.receiptsNotifier.value.isEmpty, true);
    });
  });

  group('SampleDataService & Canvas Rendering Tests', () {
    test('Renders simulated receipt image via canvas to base64', () async {
      final base64Image = await SampleDataService.generateReceiptImage(
        merchant: 'Trader Joe\'s',
        date: DateTime(2026, 10, 24, 14, 30),
        items: const [
          ReceiptItem(id: '1', name: 'Bananas', quantity: 2, unitPrice: 0.99),
        ],
        total: 1.98,
        currency: '\$',
        category: 'groceries',
      );

      expect(base64Image, isNotEmpty);
      expect(base64Image.length, greaterThan(100));
    });

    test('Generates preloaded sample receipts with images and items', () async {
      final samples = await SampleDataService.getPreloadedSampleReceipts();
      expect(samples.length, greaterThanOrEqualTo(5));
      for (final s in samples) {
        expect(s.merchant, isNotEmpty);
        expect(s.amount, greaterThan(0));
        expect(s.hasImage, true);
        expect(s.imageBase64, isNotNull);
        expect(s.items, isNotEmpty);
      }
    });
  });

  group('SummaryData & Formatting Tests', () {
    test('Calculates multi-category and multi-merchant metrics correctly', () {
      final now = DateTime(2026, 10, 24);
      final receipts = [
        Receipt(
          id: '1',
          merchant: 'Whole Foods',
          amount: 60.0,
          date: now,
          category: 'groceries',
          createdAt: now,
          updatedAt: now,
        ),
        Receipt(
          id: '2',
          merchant: 'Whole Foods',
          amount: 40.0,
          date: now,
          category: 'groceries',
          createdAt: now,
          updatedAt: now,
        ),
        Receipt(
          id: '3',
          merchant: 'Starbucks',
          amount: 15.0,
          date: now,
          category: 'dining',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final summary = SummaryData.fromReceipts(receipts);
      expect(summary.totalSpending, 115.0);
      expect(summary.receiptCount, 3);
      expect(summary.averageAmount, closeTo(38.33, 0.01));
      expect(summary.highestAmount, 60.0);
      expect(summary.categorySpending['groceries'], 100.0);
      expect(summary.categorySpending['dining'], 15.0);
      expect(summary.categoryCounts['groceries'], 2);
      expect(summary.categoryCounts['dining'], 1);

      // Top merchants
      expect(summary.topMerchants.first.key, 'Whole Foods');
      expect(summary.topMerchants.first.value, 100.0);
      expect(summary.topMerchants[1].key, 'Starbucks');
      expect(summary.topMerchants[1].value, 15.0);
    });

    test('CurrencyHelper formats normal and compact amounts', () {
      expect(CurrencyHelper.format(25.50), '\$25.50');
      expect(CurrencyHelper.format(1250.00), '\$1,250.00');
      expect(CurrencyHelper.format(15.00, symbol: '€'), '€15.00');
      expect(CurrencyHelper.formatCompact(1500), '\$1.5k');
      expect(CurrencyHelper.formatCompact(2500000), '\$2.5M');
    });

    test('DateHelper relative format works for today and historical', () {
      final now = DateTime.now();
      expect(DateHelper.formatReceiptDate(now).contains('Today'), true);
      expect(DateHelper.formatDateIso(DateTime(2026, 10, 24)), '2026-10-24');
    });
  });

  group('ExportService Tests', () {
    test('CSV export has standard headers and escaping', () {
      final receipts = [
        Receipt(
          id: 'id-123',
          merchant: 'Best Buy, Inc.',
          amount: 199.99,
          date: DateTime(2026, 10, 20, 15, 30),
          category: 'shopping',
          paymentMethod: 'Credit Card',
          taxAmount: 16.50,
          notes: 'Keyboard, mouse & cables',
          items: const [
            ReceiptItem(id: 'i1', name: 'Keyboard', quantity: 1, unitPrice: 150.00),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final csv = ExportService.generateCsv(receipts);
      expect(csv.contains('Best Buy, Inc.'), true);
      expect(csv.contains('199.99'), true);
      expect(csv.contains('Shopping & Retail'), true);
      expect(csv.contains('Keyboard'), true);
    });
  });

  group('ReceiptParser OCR Extraction Tests', () {
    test('Parses total, merchant, tax, date, and category from realistic receipt text', () {
      const sampleText = '''
TRADER JOE'S
Store #402 - Main St
2026-10-24 14:32
----------------------------
Organic Milk x2       6.50
Sourdough Bread       4.99
Fresh Salmon         14.50
----------------------------
Subtotal             25.99
Sales Tax             2.15
TOTAL AMOUNT         28.14
Payment: Visa Card
Thank you for shopping!
''';

      final extracted = ReceiptParser.parse(sampleText);
      expect(extracted.merchant, "TRADER JOE'S");
      expect(extracted.totalAmount, 28.14);
      expect(extracted.taxAmount, 2.15);
      expect(extracted.date, DateTime(2026, 10, 24));
      expect(extracted.category, 'groceries');
      expect(extracted.items.length, greaterThanOrEqualTo(2));
      expect(extracted.hasExtractedInfo, true);
    });

    test('Parses alternative receipt date and balance due formats', () {
      const sampleText = '''
BLUE BOTTLE COFFEE
Official Receipt
Date: Oct 20, 2026
Pour Over Coffee      5.75
BALANCE DUE: \$5.75
''';

      final extracted = ReceiptParser.parse(sampleText);
      expect(extracted.merchant, 'BLUE BOTTLE COFFEE');
      expect(extracted.totalAmount, 5.75);
      expect(extracted.date, DateTime(2026, 10, 20));
      expect(extracted.category, 'dining');
    });

    test('Handles empty and noisy text gracefully', () {
      final extracted = ReceiptParser.parse('   ');
      expect(extracted.hasExtractedInfo, false);
      expect(extracted.totalAmount, isNull);
    });
  });

  group('OcrService Apple Vision Integration Tests', () {
    test('Non-existent file returns empty result safely', () async {
      final extracted = await OcrService.instance.scanAndExtract('/non/existent/path/receipt.jpg');
      expect(extracted.rawText, '');
      expect(extracted.hasExtractedInfo, false);
    });

    test('Apple Vision channel mock returns parsed receipt data', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const MethodChannel channel = MethodChannel('receipt_record/apple_vision');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'recognizeText') {
            return '''
STARBUCKS COFFEE
2026-10-24
Caffe Latte 4.95
TOTAL 4.95
''';
          }
          return null;
        },
      );

      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test_receipt.jpg');
      await tempFile.writeAsString('dummy');

      try {
        final result = await OcrService.instance.recognizeText(tempFile.path);
        if (Platform.isMacOS || Platform.isIOS) {
          expect(result.contains('STARBUCKS COFFEE'), true);
          final extracted = await OcrService.instance.scanAndExtract(tempFile.path);
          expect(extracted.merchant, 'STARBUCKS COFFEE');
          expect(extracted.totalAmount, 4.95);
        }
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
      }
    });
  });
}

