import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/receipt.dart';

class StorageService {
  static const String _storageKey = 'saved_receipts_v1';
  static final StorageService instance = StorageService._internal();

  StorageService._internal();

  final ValueNotifier<List<Receipt>> receiptsNotifier =
      ValueNotifier<List<Receipt>>([]);

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await loadReceipts();
    _isInitialized = true;
  }

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

      // Sort newest date first
      receipts.sort((a, b) => b.date.compareTo(a.date));

      receiptsNotifier.value = receipts;
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
      final rawData = json.encode(receipts.map((r) => r.toMap()).toList());
      await prefs.setString(_storageKey, rawData);
      receiptsNotifier.value = List.unmodifiable(receipts);
    } catch (e) {
      debugPrint('Error persisting receipts: $e');
    }
  }

  Future<void> saveReceipt(Receipt receipt) async {
    final current = List<Receipt>.from(receiptsNotifier.value);
    final existingIndex = current.indexWhere((r) => r.id == receipt.id);

    if (existingIndex >= 0) {
      current[existingIndex] = receipt;
    } else {
      current.insert(0, receipt);
    }

    current.sort((a, b) => b.date.compareTo(a.date));
    await _persistReceipts(current);
  }

  Future<void> deleteReceipt(String id) async {
    final current = List<Receipt>.from(receiptsNotifier.value);
    current.removeWhere((r) => r.id == id);
    await _persistReceipts(current);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    receiptsNotifier.value = [];
  }

  Future<void> importReceipts(List<Receipt> newReceipts, {bool overwrite = false}) async {
    if (overwrite) {
      final sorted = List<Receipt>.from(newReceipts)
        ..sort((a, b) => b.date.compareTo(a.date));
      await _persistReceipts(sorted);
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
  }
}
