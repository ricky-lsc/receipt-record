import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/models/receipt.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('disk_img_test_');
    await StorageService.instance.init();
    await StorageService.instance.setCustomStoragePath(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Disk-Only Image Storage Optimization Tests', () {
    const dummyB64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

    test('Saving receipt with base64 writes file to disk and clears base64 from database', () async {
      final storage = StorageService.instance;

      final receipt = Receipt(
        id: 'rec_disk_1',
        merchant: 'Costco Wholesale',
        amount: 85.50,
        currency: '\$',
        date: DateTime(2026, 11, 2),
        category: 'groceries',
        imageBase64: dummyB64,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await storage.saveReceipt(receipt);

      // 1. Verify in-memory receipt has imagePath pointing to valid file and null imageBase64
      final saved = storage.getReceipt('rec_disk_1');
      expect(saved, isNotNull);
      expect(saved!.imageBase64, isNull);
      expect(saved.imagePath, isNotNull);
      expect(saved.imagePath, contains('Costco_Wholesale'));
      expect(await File(saved.imagePath!).exists(), true);

      // 2. Verify SharedPreferences does NOT store the large base64 string
      final prefs = await SharedPreferences.getInstance();
      final rawData = prefs.getString('saved_receipts_v1');
      expect(rawData, isNotNull);
      expect(rawData!.contains(dummyB64), false);
      expect(rawData.contains('imageBase64'), false);
      expect(rawData.contains('imagePath'), true);
    });

    test('Auto-migrates legacy receipts loaded from SharedPreferences', () async {
      // Simulate existing SharedPreferences containing raw base64 from previous versions
      final legacyJson = json.encode([
        {
          'id': 'legacy_rec_1',
          'merchant': 'Apple Store',
          'amount': 999.0,
          'currency': '\$',
          'date': '2026-11-01T12:00:00.000',
          'category': 'shopping',
          'paymentMethod': 'Credit Card',
          'imageBase64': dummyB64,
          'createdAt': '2026-11-01T12:00:00.000',
          'updatedAt': '2026-11-01T12:00:00.000',
        }
      ]);

      SharedPreferences.setMockInitialValues({'saved_receipts_v1': legacyJson});

      final storage = StorageService.instance;
      await storage.loadReceipts();

      final migrated = storage.getReceipt('legacy_rec_1');
      expect(migrated, isNotNull);
      expect(migrated!.imageBase64, isNull);
      expect(migrated.imagePath, isNotNull);
      expect(await File(migrated.imagePath!).exists(), true);

      // SharedPreferences should now have the base64 stripped
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('saved_receipts_v1');
      expect(raw!.contains(dummyB64), false);
    });
  });
}
