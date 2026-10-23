import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receipt_record/main.dart';
import 'package:receipt_record/models/receipt.dart';
import 'package:receipt_record/models/receipt_item.dart';
import 'package:receipt_record/models/summary_data.dart';
import 'package:receipt_record/services/export_service.dart';
import 'package:receipt_record/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  test('Receipt model calculations and serialization', () {
    final now = DateTime(2026, 10, 24, 12, 0);
    final receipt = Receipt(
      id: 'test-1',
      merchant: 'Test Grocery',
      amount: 45.50,
      currency: '\$',
      date: now,
      category: 'groceries',
      paymentMethod: 'Credit Card',
      taxAmount: 3.50,
      items: const [
        ReceiptItem(id: 'i1', name: 'Apples', quantity: 2, unitPrice: 5.00),
        ReceiptItem(id: 'i2', name: 'Bread', quantity: 1, unitPrice: 3.50),
      ],
      createdAt: now,
      updatedAt: now,
    );

    expect(receipt.itemsSubtotal, 13.50);
    expect(receipt.hasImage, false);

    final map = receipt.toMap();
    final restored = Receipt.fromMap(map);

    expect(restored.id, 'test-1');
    expect(restored.merchant, 'Test Grocery');
    expect(restored.amount, 45.50);
    expect(restored.items.length, 2);
  });

  test('SummaryData calculation from receipts', () {
    final now = DateTime(2026, 10, 24);
    final receipts = [
      Receipt(
        id: 'r1',
        merchant: 'Store A',
        amount: 100.0,
        date: now,
        category: 'groceries',
        createdAt: now,
        updatedAt: now,
      ),
      Receipt(
        id: 'r2',
        merchant: 'Store B',
        amount: 50.0,
        date: now,
        category: 'dining',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final summary = SummaryData.fromReceipts(receipts);
    expect(summary.totalSpending, 150.0);
    expect(summary.receiptCount, 2);
    expect(summary.averageAmount, 75.0);
    expect(summary.highestAmount, 100.0);
    expect(summary.categorySpending['groceries'], 100.0);
    expect(summary.categorySpending['dining'], 50.0);
  });

  test('ExportService generates valid CSV and JSON', () {
    final now = DateTime(2026, 10, 24);
    final receipts = [
      Receipt(
        id: 'r1',
        merchant: 'Costco',
        amount: 89.99,
        date: now,
        category: 'groceries',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final csvContent = ExportService.generateCsv(receipts);
    expect(csvContent.contains('Costco'), true);
    expect(csvContent.contains('89.99'), true);
    expect(csvContent.contains('ID,Date,Time,Merchant'), true);

    final jsonContent = ExportService.generateJson(receipts);
    expect(jsonContent.contains('"merchant": "Costco"'), true);
    expect(jsonContent.contains('"amount": 89.99'), true);

    final mdContent = ExportService.generateMarkdownReport(receipts);
    expect(mdContent.contains('# 🧾 Expense & Receipts Report'), true);
    expect(mdContent.contains('Costco'), true);
  });

  testWidgets('ReceiptRecordApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ReceiptRecordApp());
    await tester.pumpAndSettle();

    // Verify main screen has navigation destinations
    expect(find.text('Receipts'), findsWidgets);
    expect(find.text('Summary'), findsWidgets);
    expect(find.text('Export'), findsWidgets);

    // Verify Add Receipt floating button exists
    expect(find.byIcon(Icons.add_a_photo), findsWidgets);
  });
}
