import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/l10n/app_localizations.dart';
import 'package:receipt_record/models/receipt.dart';
import 'package:receipt_record/models/receipt_item.dart';
import 'package:receipt_record/services/locale_service.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:receipt_record/widgets/storage_settings_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempTestDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempTestDir = await Directory.systemTemp.createTemp('receipt_test_storage_');
    await StorageService.instance.init();
    await LocaleService.instance.init();
  });

  tearDown(() async {
    if (await tempTestDir.exists()) {
      await tempTestDir.delete(recursive: true);
    }
  });

  group('StorageService Custom Storage & Auto-Backup Tests', () {
    test('Default vs custom storage path management', () async {
      final storage = StorageService.instance;
      expect(storage.customStoragePathNotifier.value, isNull);

      final defaultPath = await storage.getEffectiveStoragePath();
      expect(defaultPath.isNotEmpty, true);

      // Set custom directory
      final customDir = Directory('${tempTestDir.path}/custom_receipts');
      await storage.setCustomStoragePath(customDir.path);

      expect(storage.customStoragePathNotifier.value, customDir.path);
      expect(await storage.getEffectiveStoragePath(), customDir.path);
      expect(await customDir.exists(), true);

      // Reset to default
      await storage.setCustomStoragePath(null);
      expect(storage.customStoragePathNotifier.value, isNull);
      expect(await storage.getEffectiveStoragePath(), defaultPath);
    });

    test('Auto-backup creates receipts.json and receipts.csv in storage folder', () async {
      final storage = StorageService.instance;
      final customDir = Directory('${tempTestDir.path}/backup_test');
      await storage.setCustomStoragePath(customDir.path);

      final receipt = Receipt(
        id: 'rec_backup_1',
        merchant: 'Whole Foods Market',
        amount: 48.75,
        currency: '\$',
        date: DateTime(2026, 11, 2),
        category: 'groceries',
        items: const [
          ReceiptItem(id: 'i1', name: 'Apples', quantity: 3, unitPrice: 1.50),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await storage.saveReceipt(receipt);

      // Verify receipts.json exists and contains receipt
      final jsonFile = File('${customDir.path}/receipts.json');
      expect(await jsonFile.exists(), true);
      final jsonContent = await jsonFile.readAsString();
      expect(jsonContent, contains('Whole Foods Market'));
      expect(jsonContent, contains('48.75'));

      // Verify receipts.csv exists and contains receipt
      final csvFile = File('${customDir.path}/receipts.csv');
      expect(await csvFile.exists(), true);
      final csvContent = await csvFile.readAsString();
      expect(csvContent, contains('Whole Foods Market'));
      expect(csvContent, contains('48.75'));
    });

    test('Saves receipt image file into receipt_images/ subfolder', () async {
      final storage = StorageService.instance;
      final customDir = Directory('${tempTestDir.path}/images_test');
      await storage.setCustomStoragePath(customDir.path);

      // Dummy 1x1 base64 png
      const dummyB64 =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

      final savedPath = await storage.saveReceiptImageFile(
        receiptId: 'test_img_rec_12345',
        base64Data: dummyB64,
        merchant: 'Target Store',
        date: DateTime(2026, 11, 2),
      );

      expect(savedPath, isNotNull);
      expect(savedPath!, contains(customDir.path));
      expect(savedPath, contains('receipt_images'));
      expect(savedPath, contains('Target_Store'));
      expect(await File(savedPath).exists(), true);
    });

    test('Migrates existing receipts to new custom directory', () async {
      final storage = StorageService.instance;

      // Create a receipt with a dummy image file
      final oldDir = Directory('${tempTestDir.path}/old_dir');
      await oldDir.create(recursive: true);
      final oldImageFile = File('${oldDir.path}/sample.png');
      await oldImageFile.writeAsBytes(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      ));

      final receipt = Receipt(
        id: 'rec_migrate_1',
        merchant: 'Costco',
        amount: 120.0,
        currency: '\$',
        date: DateTime(2026, 11, 2),
        category: 'groceries',
        imagePath: oldImageFile.path,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storage.saveReceipt(receipt);

      final newTargetDir = Directory('${tempTestDir.path}/new_target_dir');
      final count = await storage.migrateExistingReceiptsToCustomPath(newTargetDir.path);

      expect(count, 1);
      final migratedReceipt = storage.getReceipt('rec_migrate_1');
      expect(migratedReceipt, isNotNull);
      expect(migratedReceipt!.imagePath, contains(newTargetDir.path));
      expect(await File(migratedReceipt.imagePath!).exists(), true);
    });
  });

  group('StorageSettingsDialog Widget Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      );
    }

    testWidgets('StorageSettingsDialog displays mode options and auto-backup switch', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => StorageSettingsDialog.show(context),
              child: const Text('Open'),
            );
          }),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Storage Location & Backup'), findsOneWidget);
      expect(find.text('Default App Storage'), findsOneWidget);
      expect(find.text('Custom Directory'), findsWidgets);
      expect(find.text('Choose Folder'), findsOneWidget);
      expect(find.text('Auto-Sync Live Backup'), findsOneWidget);

      // Drag down in dialog to make switch visible and tap
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(StorageService.instance.autoBackupNotifier.value, false);
    });
  });
}
