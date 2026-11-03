import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/l10n/app_localizations.dart';
import 'package:receipt_record/models/receipt.dart';
import 'package:receipt_record/models/receipt_split.dart';
import 'package:receipt_record/screens/receipt_detail_screen.dart';
import 'package:receipt_record/services/locale_service.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:receipt_record/widgets/receipt_card.dart';
import 'package:receipt_record/widgets/split_bill_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await LocaleService.instance.init();
  });

  group('ReceiptSplit Model Tests', () {
    test('ReceiptSplit serialization and calculations', () {
      final p1 = SplitParticipant(id: 'p1', name: 'Alice', amount: 25.0, isPaid: true);
      final p2 = SplitParticipant(id: 'p2', name: 'Bob', amount: 15.0, isPaid: false);
      final split = ReceiptSplit(participants: [p1, p2], isCustomized: true);

      expect(split.totalAllocated, 40.0);
      expect(split.isCustomized, true);

      final map = split.toMap();
      final restored = ReceiptSplit.fromMap(map);

      expect(restored.participants.length, 2);
      expect(restored.participants[0].name, 'Alice');
      expect(restored.participants[0].amount, 25.0);
      expect(restored.participants[0].isPaid, true);
      expect(restored.participants[1].name, 'Bob');
      expect(restored.participants[1].amount, 15.0);
      expect(restored.participants[1].isPaid, false);
      expect(restored.totalAllocated, 40.0);
    });

    test('Receipt model serializes and restores split field', () {
      final receipt = Receipt(
        id: 'r_split_1',
        merchant: 'Olive Garden',
        amount: 60.0,
        currency: '\$',
        date: DateTime(2026, 11, 2),
        category: 'dining',
        split: ReceiptSplit(
          participants: [
            SplitParticipant(id: '1', name: 'Me', amount: 30.0, isPaid: true),
            SplitParticipant(id: '2', name: 'Charlie', amount: 30.0, isPaid: false),
          ],
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(receipt.isSplit, true);
      expect(receipt.split?.participants.length, 2);

      final map = receipt.toMap();
      final restored = Receipt.fromMap(map);

      expect(restored.isSplit, true);
      expect(restored.split?.participants.length, 2);
      expect(restored.split?.totalAllocated, 60.0);
    });
  });

  group('SplitBillDialog Widget Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      );
    }

    testWidgets('SplitBillDialog initializes with 2 people and equal amounts', (tester) async {
      final receipt = Receipt(
        id: 'test_rec_1',
        merchant: 'Starbucks',
        amount: 20.0,
        currency: '\$',
        date: DateTime(2026, 11, 2),
        category: 'dining',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildTestApp(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => SplitBillDialog.show(context, receipt),
              child: const Text('Open'),
            );
          }),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Split Receipt Bill'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Equal Split'), findsOneWidget);
      expect(find.text('Custom Split'), findsOneWidget);

      // Total is $20.00 / 2 = $10.00 each
      expect(find.text('10.00'), findsNWidgets(2));
    });

    testWidgets('Increasing participants recalculates equal split', (tester) async {
      final receipt = Receipt(
        id: 'test_rec_2',
        merchant: 'Target',
        amount: 30.0,
        currency: '\$',
        date: DateTime(2026, 11, 2),
        category: 'shopping',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildTestApp(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => SplitBillDialog.show(context, receipt),
              child: const Text('Open'),
            );
          }),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap + button to change from 2 to 3 people
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      // $30 / 3 = $10.00 each
      expect(find.text('10.00'), findsNWidgets(3));
    });

    testWidgets('Saving split persists onto receipt in StorageService', (tester) async {
      final receipt = Receipt(
        id: 'rec_save_split',
        merchant: 'Pizzeria',
        amount: 50.0,
        currency: '\$',
        date: DateTime(2026, 11, 2),
        category: 'dining',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await StorageService.instance.saveReceipt(receipt);

      await tester.pumpWidget(
        buildTestApp(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => SplitBillDialog.show(context, receipt),
              child: const Text('Open'),
            );
          }),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Save Split
      await tester.tap(find.text('Save Split'));
      await tester.pumpAndSettle();

      final saved = StorageService.instance.getReceipt('rec_save_split');
      expect(saved, isNotNull);
      expect(saved!.isSplit, true);
      expect(saved.split!.participants.length, 2);
      expect(saved.split!.totalAllocated, 50.0);
    });

    testWidgets('ReceiptDetailScreen shows Split Bill button and displays split list', (tester) async {
      final splitReceipt = Receipt(
        id: 'rec_detail_split',
        merchant: 'Bistro Cafe',
        amount: 40.0,
        currency: '\$',
        date: DateTime(2026, 11, 2),
        category: 'dining',
        split: ReceiptSplit(
          participants: [
            SplitParticipant(id: '1', name: 'Me', amount: 25.0, isPaid: true),
            SplitParticipant(id: '2', name: 'Friend', amount: 15.0, isPaid: false),
          ],
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await StorageService.instance.saveReceipt(splitReceipt);

      await tester.pumpWidget(buildTestApp(ReceiptDetailScreen(receipt: splitReceipt)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.call_split), findsWidgets);
      expect(find.text('Split Receipt Bill'), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);
      expect(find.text('Friend'), findsOneWidget);
      expect(find.text('\$25.00'), findsWidgets);
      expect(find.text('\$15.00'), findsWidgets);
    });

    testWidgets('ReceiptCard displays split participant count badge', (tester) async {
      final splitReceipt = Receipt(
        id: 'rec_card_split',
        merchant: 'Taco Bar',
        amount: 30.0,
        currency: '\$',
        date: DateTime(2026, 11, 2),
        category: 'dining',
        split: ReceiptSplit(
          participants: [
            SplitParticipant(id: '1', name: 'Me', amount: 10.0),
            SplitParticipant(id: '2', name: 'Alex', amount: 10.0),
            SplitParticipant(id: '3', name: 'Sam', amount: 10.0),
          ],
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildTestApp(
          ReceiptCard(
            receipt: splitReceipt,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.call_split), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
