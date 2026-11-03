import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/l10n/app_localizations.dart';
import 'package:receipt_record/models/receipt.dart';
import 'package:receipt_record/models/receipt_split.dart';
import 'package:receipt_record/models/summary_data.dart';
import 'package:receipt_record/screens/summary_screen.dart';
import 'package:receipt_record/services/locale_service.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:receipt_record/widgets/category_drilldown_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await LocaleService.instance.init();
  });

  group('SummaryData Upgrades Calculations', () {
    test('Calculates tax and tip aggregates accurately', () {
      final now = DateTime(2026, 11, 2);
      final receipts = [
        Receipt(
          id: '1',
          merchant: 'Bistro',
          amount: 50.0,
          date: now,
          category: 'dining',
          taxAmount: 4.50,
          tipAmount: 8.00,
          createdAt: now,
          updatedAt: now,
        ),
        Receipt(
          id: '2',
          merchant: 'Market',
          amount: 30.0,
          date: now,
          category: 'groceries',
          taxAmount: 2.10,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final summary = SummaryData.fromReceipts(receipts);
      expect(summary.totalTax, 6.60);
      expect(summary.totalTip, 8.00);
      expect(summary.receiptsWithTaxCount, 2);
      expect(summary.receiptsWithTipCount, 1);
    });

    test('Calculates split reimbursement and personal net spend', () {
      final now = DateTime(2026, 11, 2);
      final splitReceipt = Receipt(
        id: 'split_1',
        merchant: 'Dinner Party',
        amount: 100.0,
        date: now,
        category: 'dining',
        split: ReceiptSplit(
          participants: [
            SplitParticipant(id: '1', name: 'Me', amount: 40.0, isPaid: true),
            SplitParticipant(id: '2', name: 'Alice', amount: 35.0, isPaid: false),
            SplitParticipant(id: '3', name: 'Bob', amount: 25.0, isPaid: true),
          ],
        ),
        createdAt: now,
        updatedAt: now,
      );

      final summary = SummaryData.fromReceipts([splitReceipt]);
      expect(summary.totalSpending, 100.0);
      expect(summary.netPersonalSpending, 40.0);
      expect(summary.totalReimbursable, 35.0); // Alice unpaid
      expect(summary.totalReimbursed, 25.0); // Bob paid
      expect(summary.unpaidBalancesByPerson['Alice'], 35.0);
      expect(summary.unpaidBalancesByPerson.containsKey('Bob'), false);
    });

    test('Calculates period change percentage against prior period', () {
      final now = DateTime(2026, 11, 2);
      final current = [
        Receipt(id: 'c1', merchant: 'A', amount: 120.0, date: now, category: 'dining', createdAt: now, updatedAt: now),
      ];
      final prior = [
        Receipt(id: 'p1', merchant: 'B', amount: 100.0, date: now, category: 'dining', createdAt: now, updatedAt: now),
      ];

      final summary = SummaryData.fromReceipts(current, priorPeriodReceipts: prior);
      expect(summary.priorPeriodSpending, 100.0);
      // (120 - 100) / 100 = +20.0%
      expect(summary.periodChangePercentage, closeTo(20.0, 0.01));
    });
  });

  group('Monthly Budget Persistence in StorageService', () {
    test('Saves, loads, and clears monthly budget', () async {
      final storage = StorageService.instance;
      expect(storage.budgetNotifier.value, isNull);

      await storage.setMonthlyBudget(1500.0);
      expect(storage.budgetNotifier.value, 1500.0);

      // Re-init loads from SharedPreferences
      await storage.loadBudget();
      expect(storage.budgetNotifier.value, 1500.0);

      await storage.setMonthlyBudget(null);
      expect(storage.budgetNotifier.value, isNull);
    });
  });

  group('SummaryScreen Widget Interactions', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: child,
      );
    }

    testWidgets('Displays budget card and allows setting monthly budget', (tester) async {
      final now = DateTime.now();
      final receipts = [
        Receipt(
          id: 'rec_b1',
          merchant: 'Supermarket',
          amount: 250.0,
          date: now,
          category: 'groceries',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      await StorageService.instance.saveReceipt(receipts[0]);

      await tester.pumpWidget(
        buildTestApp(
          SummaryScreen(
            onNavigateToAdd: () {},
            onNavigateToExport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Monthly Budget'), findsOneWidget);
      expect(find.text('Set Budget'), findsOneWidget);

      // Tap Set Budget
      await tester.tap(find.text('Set Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Budget Amount'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1000');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(StorageService.instance.budgetNotifier.value, 1000.0);
      expect(find.text('\$250.00 / \$1,000.00'), findsOneWidget);
    });

    testWidgets('Tapping category in breakdown opens CategoryDrilldownSheet', (tester) async {
      final now = DateTime.now();
      final receipts = [
        Receipt(
          id: 'drill_1',
          merchant: 'Trader Joe\'s',
          amount: 75.0,
          date: now,
          category: 'groceries',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      await StorageService.instance.saveReceipt(receipts[0]);

      await tester.pumpWidget(
        buildTestApp(
          SummaryScreen(
            onNavigateToAdd: () {},
            onNavigateToExport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag list down to make category breakdown visible
      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();

      final groceriesTile = find.text('Groceries').first;
      await tester.tap(groceriesTile);
      await tester.pumpAndSettle();

      // Verify CategoryDrilldownSheet opens
      expect(find.byType(CategoryDrilldownSheet), findsOneWidget);
      expect(find.text('Trader Joe\'s'), findsWidgets);
      expect(find.text('\$75.00'), findsWidgets);
    });
  });
}
