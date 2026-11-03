import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/receipt.dart';
import 'export_service.dart';

class StorageService {
  static const String _storageKey = 'saved_receipts_v1';
  static const String _budgetKey = 'app_monthly_budget';
  static const String _customStoragePathKey = 'app_custom_storage_path';
  static const String _autoBackupKey = 'app_auto_backup_enabled';

  static final StorageService instance = StorageService._internal();

  StorageService._internal();

  final ValueNotifier<List<Receipt>> receiptsNotifier =
      ValueNotifier<List<Receipt>>([]);
  final ValueNotifier<double?> budgetNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<String?> customStoragePathNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<bool> autoBackupNotifier = ValueNotifier<bool>(true);

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await loadReceipts();
    await loadBudget();
    await loadStorageSettings();
    _isInitialized = true;
  }

  Future<void> loadBudget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      budgetNotifier.value = prefs.getDouble(_budgetKey);
    } catch (_) {}
  }

  Future<void> setMonthlyBudget(double? budget) async {
    budgetNotifier.value = budget;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (budget == null || budget <= 0) {
        await prefs.remove(_budgetKey);
      } else {
        await prefs.setDouble(_budgetKey, budget);
      }
    } catch (e) {
      debugPrint('Error saving budget: $e');
    }
  }

  // ==========================================
  // Custom Storage Location & Auto-Backup
  // ==========================================

  Future<void> loadStorageSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_customStoragePathKey);
      if (path != null && path.isNotEmpty) {
        final dir = Directory(path);
        if (await dir.exists()) {
          customStoragePathNotifier.value = path;
        } else {
          customStoragePathNotifier.value = null;
        }
      } else {
        customStoragePathNotifier.value = null;
      }
      autoBackupNotifier.value = prefs.getBool(_autoBackupKey) ?? true;
    } catch (e) {
      debugPrint('Error loading storage settings: $e');
    }
  }

  /// Default application sandbox directory
  Future<String> getDefaultStoragePath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } catch (_) {
      return Directory.systemTemp.path;
    }
  }

  /// Returns custom storage path if active and valid, otherwise default sandbox
  Future<String> getEffectiveStoragePath() async {
    final custom = customStoragePathNotifier.value;
    if (custom != null && custom.isNotEmpty) {
      final d = Directory(custom);
      if (await d.exists()) {
        return custom;
      }
    }
    return getDefaultStoragePath();
  }

  Future<void> setCustomStoragePath(String? path) async {
    customStoragePathNotifier.value = path;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path == null || path.isEmpty) {
        await prefs.remove(_customStoragePathKey);
      } else {
        await prefs.setString(_customStoragePathKey, path.trim());
        final dir = Directory(path.trim());
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        await syncBackupFiles();
      }
    } catch (e) {
      debugPrint('Error saving custom storage path: $e');
    }
  }

  Future<void> setAutoBackup(bool enabled) async {
    autoBackupNotifier.value = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoBackupKey, enabled);
      if (enabled) {
        await syncBackupFiles();
      }
    } catch (e) {
      debugPrint('Error saving auto-backup setting: $e');
    }
  }

  /// Saves receipt image to the effective storage directory under receipt_images/
  Future<String?> saveReceiptImageFile({
    required String receiptId,
    String? sourcePath,
    String? base64Data,
    String? merchant,
    DateTime? date,
    String? targetDirectory,
  }) async {
    try {
      final effectiveDir = targetDirectory ?? await getEffectiveStoragePath();
      final imagesDir = Directory('$effectiveDir/receipt_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final datePrefix = DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());
      final cleanMerchant = (merchant ?? 'Receipt')
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');
      final shortId = receiptId.length > 8 ? receiptId.substring(0, 8) : receiptId;

      String extension = '.jpg';
      Uint8List? bytes;

      if (sourcePath != null && sourcePath.isNotEmpty) {
        final srcFile = File(sourcePath);
        if (await srcFile.exists()) {
          final lower = sourcePath.toLowerCase();
          if (lower.endsWith('.png')) {
            extension = '.png';
          } else if (lower.endsWith('.webp')) {
            extension = '.webp';
          }
          bytes = await srcFile.readAsBytes();
        }
      }

      if (bytes == null && base64Data != null && base64Data.isNotEmpty) {
        String cleanB64 = base64Data;
        if (cleanB64.startsWith('data:image/')) {
          final comma = cleanB64.indexOf(',');
          if (comma != -1) cleanB64 = cleanB64.substring(comma + 1);
        }
        if (cleanB64.startsWith('iVBORw0KGgo')) {
          extension = '.png';
        }
        bytes = base64Decode(cleanB64);
      }

      if (bytes == null || bytes.isEmpty) return null;

      final fileName = '${datePrefix}_${cleanMerchant}_$shortId$extension';
      final destFile = File('${imagesDir.path}/$fileName');
      await destFile.writeAsBytes(bytes);
      return destFile.path;
    } catch (e) {
      debugPrint('Error saving receipt image file: $e');
      return null;
    }
  }

  /// Syncs receipts.json and receipts.csv into effective storage directory
  Future<void> syncBackupFiles([List<Receipt>? receiptsToSync]) async {
    if (!autoBackupNotifier.value) return;
    try {
      final list = receiptsToSync ?? receiptsNotifier.value;
      final effectivePath = await getEffectiveStoragePath();
      final dir = Directory(effectivePath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // 1. receipts.json
      final jsonFile = File('$effectivePath/receipts.json');
      final jsonString = const JsonEncoder.withIndent('  ').convert(
        list.map((r) => r.toMap()).toList(),
      );
      await jsonFile.writeAsString(jsonString);

      // 2. receipts.csv
      final csvFile = File('$effectivePath/receipts.csv');
      final csvString = ExportService.generateCsv(list);
      await csvFile.writeAsString(csvString);
    } catch (e) {
      debugPrint('Error syncing backup files: $e');
    }
  }

  /// Migrates existing receipts to a new target path and updates image references
  Future<int> migrateExistingReceiptsToCustomPath(String targetPath) async {
    final targetDir = Directory(targetPath);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    final imagesDir = Directory('$targetPath/receipt_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final current = List<Receipt>.from(receiptsNotifier.value);
    int migratedCount = 0;

    for (int i = 0; i < current.length; i++) {
      final r = current[i];
      if (r.hasImage) {
        final newPath = await saveReceiptImageFile(
          receiptId: r.id,
          sourcePath: r.imagePath,
          base64Data: r.imageBase64,
          merchant: r.merchant,
          date: r.date,
          targetDirectory: targetPath,
        );
        if (newPath != null) {
          current[i] = r.copyWith(imagePath: newPath);
          migratedCount++;
        }
      }
    }

    await setCustomStoragePath(targetPath);
    await _persistReceipts(current);
    await syncBackupFiles(current);
    return migratedCount;
  }

  // ==========================================
  // Core Storage & CRUD
  // ==========================================

  Future<List<Receipt>> loadReceipts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawData = prefs.getString(_storageKey);
      if (rawData == null || rawData.isEmpty) {
        receiptsNotifier.value = [];
        return [];
      }

      final List<dynamic> decodedList = json.decode(rawData) as List<dynamic>;
      final receipts = decodedList
          .map((item) => Receipt.fromMap(item as Map<String, dynamic>))
          .toList();

      // Auto-migrate legacy base64-stored images to disk files
      bool migratedAny = false;
      for (int i = 0; i < receipts.length; i++) {
        final r = receipts[i];
        if (r.imageBase64 != null && r.imageBase64!.isNotEmpty) {
          final fileExists = r.imagePath != null && File(r.imagePath!).existsSync();
          if (!fileExists) {
            final savedPath = await saveReceiptImageFile(
              receiptId: r.id,
              base64Data: r.imageBase64,
              merchant: r.merchant,
              date: r.date,
            );
            receipts[i] = r.copyWith(imagePath: savedPath, clearImageBase64: true);
          } else {
            receipts[i] = r.copyWith(clearImageBase64: true);
          }
          migratedAny = true;
        }
      }

      // Sort newest date first
      receipts.sort((a, b) => b.date.compareTo(a.date));

      if (migratedAny) {
        await _persistReceipts(receipts);
      } else {
        receiptsNotifier.value = List.unmodifiable(receipts);
      }

      return receipts;
    } catch (e) {
      debugPrint('Error loading receipts: $e');
      receiptsNotifier.value = [];
      return [];
    }
  }

  Future<void> _persistReceipts(List<Receipt> receipts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Omit imageBase64 to ensure SharedPreferences remains lightweight (< 100 KB)
      final rawData = json.encode(
        receipts.map((r) {
          final map = r.toMap();
          map.remove('imageBase64');
          return map;
        }).toList(),
      );
      await prefs.setString(_storageKey, rawData);
      receiptsNotifier.value = List.unmodifiable(receipts);
    } catch (e) {
      debugPrint('Error persisting receipts: $e');
    }
  }

  Future<void> saveReceipt(Receipt receipt) async {
    Receipt toSave = receipt;

    // Ensure any image is written to disk and base64 is cleared
    if (toSave.imageBase64 != null && toSave.imageBase64!.isNotEmpty) {
      final fileExists = toSave.imagePath != null && File(toSave.imagePath!).existsSync();
      if (!fileExists) {
        final savedPath = await saveReceiptImageFile(
          receiptId: toSave.id,
          sourcePath: toSave.imagePath,
          base64Data: toSave.imageBase64,
          merchant: toSave.merchant,
          date: toSave.date,
        );
        toSave = toSave.copyWith(imagePath: savedPath, clearImageBase64: true);
      } else {
        toSave = toSave.copyWith(clearImageBase64: true);
      }
    }

    final current = List<Receipt>.from(receiptsNotifier.value);
    final existingIndex = current.indexWhere((r) => r.id == toSave.id);

    if (existingIndex >= 0) {
      current[existingIndex] = toSave;
    } else {
      current.insert(0, toSave);
    }

    current.sort((a, b) => b.date.compareTo(a.date));
    await _persistReceipts(current);
    await syncBackupFiles(current);
  }

  Future<void> deleteReceipt(String id) async {
    final current = List<Receipt>.from(receiptsNotifier.value);
    current.removeWhere((r) => r.id == id);
    await _persistReceipts(current);
    await syncBackupFiles(current);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    receiptsNotifier.value = [];
    await syncBackupFiles([]);
  }

  Receipt? getReceipt(String id) {
    try {
      return receiptsNotifier.value.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> importReceipts(List<Receipt> newReceipts, {bool overwrite = false}) async {
    if (overwrite) {
      final sorted = List<Receipt>.from(newReceipts)
        ..sort((a, b) => b.date.compareTo(a.date));
      await _persistReceipts(sorted);
      await syncBackupFiles(sorted);
      return;
    }

    final currentMap = {
      for (final r in receiptsNotifier.value) r.id: r,
    };

    for (final r in newReceipts) {
      currentMap[r.id] = r;
    }

    final combined = currentMap.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    await _persistReceipts(combined);
    await syncBackupFiles(combined);
  }
}
