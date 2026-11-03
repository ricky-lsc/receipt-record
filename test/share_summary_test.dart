import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/l10n/app_localizations.dart';
import 'package:receipt_record/models/receipt.dart';
import 'package:receipt_record/models/summary_data.dart';
import 'package:receipt_record/screens/summary_screen.dart';
import 'package:receipt_record/services/locale_service.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:receipt_record/widgets/share_summary_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StorageService.instance.clearAll();
    await LocaleService.instance.init();
  });

  group('Share Summary Feature Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      );
    }

    testWidgets('ShareSummaryDialog renders formatted summary text and copy action', (tester) async {
      final now = DateTime(2026, 11, 2);
      final receipts = [
        Receipt(
          id: 'share_1',
          merchant: 'Trader Joe\'s',
          amount: 60.0,
          date: now,
          category: 'groceries',
          taxAmount: 5.0,
          tipAmount: 3.0,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final summary = SummaryData.fromReceipts(receipts);

      await tester.pumpWidget(
        buildTestApp(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => ShareSummaryDialog.show(
                context,
                summary: summary,
                periodLabel: 'November 2026',
                budget: 500.0,
              ),
              child: const Text('Open Share'),
            );
          }),
        ),
      );

      await tester.tap(find.text('Open Share'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Share Expense Summary'), findsOneWidget);
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.textContaining('Total Spent: \$60.00'), findsOneWidget);
      expect(find.textContaining('Monthly Budget: \$60.00 / \$500.00'), findsOneWidget);
      expect(find.textContaining('Groceries: \$60.00'), findsOneWidget);
      expect(find.textContaining('Shared via Receipt Record'), findsOneWidget);

      // Verify Copy button exists
      expect(find.text('Copy Breakdown'), findsOneWidget);
    });

    testWidgets('SummaryScreen AppBar share button triggers ShareSummaryDialog', (tester) async {
      final now = DateTime.now();
      final receipts = [
        Receipt(
          id: 'rec_s1',
          merchant: 'Starbucks Coffee',
          amount: 15.0,
          date: now,
          category: 'dining',
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Share button in AppBar
      final shareButton = find.byIcon(Icons.share_outlined);
      expect(shareButton, findsOneWidget);

      await tester.tap(shareButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ShareSummaryDialog), findsOneWidget);
      expect(find.text('Share Expense Summary'), findsOneWidget);
      expect(find.textContaining('Starbucks'), findsNothing); // merchant list is not in summary header
      expect(find.textContaining('Total Spent: \$15.00'), findsOneWidget);
    });
  });
}
