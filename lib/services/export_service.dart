import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../models/summary_data.dart';
import '../utils/currency_helper.dart';

enum ExportFormat {
  csv('CSV Spreadsheet (.csv)', 'csv', 'text/csv'),
  json('JSON Backup (.json)', 'json', 'application/json'),
  markdown('Summary Report (.md)', 'md', 'text/markdown');

  final String label;
  final String extension;
  final String mimeType;
  const ExportFormat(this.label, this.extension, this.mimeType);
}

class ExportResult {
  final bool success;
  final String? filePath;
  final String content;
  final String? message;

  const ExportResult({
    required this.success,
    this.filePath,
    required this.content,
    this.message,
  });
}

class ImportResult {
  final bool success;
  final List<Receipt> receipts;
  final String format;
  final String? message;

  const ImportResult({
    required this.success,
    this.receipts = const [],
    this.format = 'JSON',
    this.message,
  });
}

class ExportService {
  /// Generates CSV content from a list of receipts
  static String generateCsv(List<Receipt> receipts) {
    final List<List<dynamic>> rows = [
      [
        'ID',
        'Date',
        'Time',
        'Merchant',
        'Category',
        'Payment Method',
        'Amount',
        'Currency',
        'Tax',
        'Tip',
        'Notes',
        'Has Photo',
        'Items Count',
        'Itemized Details',
      ]
    ];

    for (final r in receipts) {
      final category = ReceiptCategory.fromId(r.category).name;
      final dateStr = DateFormat('yyyy-MM-dd').format(r.date);
      final timeStr = DateFormat('HH:mm').format(r.date);

      final itemsSummary = r.items
          .map((i) => '${i.name} (x${i.quantity} @ ${r.currency}${i.unitPrice.toStringAsFixed(2)})')
          .join('; ');

      rows.add([
        r.id,
        dateStr,
        timeStr,
        r.merchant,
        category,
        r.paymentMethod,
        r.amount.toStringAsFixed(2),
        r.currency,
        r.taxAmount?.toStringAsFixed(2) ?? '',
        r.tipAmount?.toStringAsFixed(2) ?? '',
        r.notes ?? '',
        r.hasImage ? 'Yes' : 'No',
        r.items.length,
        itemsSummary,
      ]);
    }

    return const CsvEncoder().convert(rows);
  }

  /// Generates JSON formatted content
  static String generateJson(List<Receipt> receipts) {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
      'totalReceipts': receipts.length,
      'totalSpending': receipts.fold<double>(0.0, (sum, r) => sum + r.amount),
      'receipts': receipts.map((r) => r.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Generates Markdown financial report
  static String generateMarkdownReport(List<Receipt> receipts) {
    final summary = SummaryData.fromReceipts(receipts);
    final now = DateTime.now();
    final buffer = StringBuffer();

    buffer.writeln('# 🧾 Expense & Receipts Report');
    buffer.writeln('**Generated on:** ${DateFormat('MMMM d, yyyy h:mm a').format(now)}\n');

    buffer.writeln('## Executive Summary');
    buffer.writeln('- **Total Expenses:** ${CurrencyHelper.format(summary.totalSpending)}');
    buffer.writeln('- **Total Receipts:** ${summary.receiptCount}');
    buffer.writeln('- **Average Receipt:** ${CurrencyHelper.format(summary.averageAmount)}');
    buffer.writeln('- **Highest Receipt:** ${CurrencyHelper.format(summary.highestAmount)}');
    if (summary.earliestDate != null && summary.latestDate != null) {
      buffer.writeln('- **Date Range:** ${DateFormat('MMM d, yyyy').format(summary.earliestDate!)} – ${DateFormat('MMM d, yyyy').format(summary.latestDate!)}');
    }
    buffer.writeln();

    buffer.writeln('## Spending by Category');
    buffer.writeln('| Category | Receipts | Total Spent | % of Total |');
    buffer.writeln('| :--- | :---: | :---: | :---: |');
    final sortedCategories = summary.categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedCategories) {
      final catName = ReceiptCategory.fromId(entry.key).name;
      final count = summary.categoryCounts[entry.key] ?? 0;
      final pct = summary.categoryPercentages[entry.key]?.toStringAsFixed(1) ?? '0.0';
      buffer.writeln('| $catName | $count | ${CurrencyHelper.format(entry.value)} | $pct% |');
    }
    buffer.writeln();

    buffer.writeln('## Top Merchants');
    buffer.writeln('| Merchant | Total Spent |');
    buffer.writeln('| :--- | :---: |');
    for (final m in summary.topMerchants) {
      buffer.writeln('| ${m.key} | ${CurrencyHelper.format(m.value)} |');
    }
    buffer.writeln();

    buffer.writeln('## Detailed Receipts Ledger');
    buffer.writeln('| Date | Merchant | Category | Payment | Amount |');
    buffer.writeln('| :--- | :--- | :--- | :--- | :---: |');
    for (final r in receipts) {
      final dateStr = DateFormat('yyyy-MM-dd').format(r.date);
      final catName = ReceiptCategory.fromId(r.category).name;
      buffer.writeln('| $dateStr | ${r.merchant} | $catName | ${r.paymentMethod} | ${CurrencyHelper.format(r.amount, symbol: r.currency)} |');
    }

    return buffer.toString();
  }

  /// Saves the export to a file using the file selector dialog, or app documents directory
  static Future<ExportResult> exportToFile({
    required List<Receipt> receipts,
    required ExportFormat format,
    String? customFileName,
  }) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final defaultFileName = customFileName ?? 'receipts_export_$timestamp.${format.extension}';

    String content;
    switch (format) {
      case ExportFormat.csv:
        content = generateCsv(receipts);
        break;
      case ExportFormat.json:
        content = generateJson(receipts);
        break;
      case ExportFormat.markdown:
        content = generateMarkdownReport(receipts);
        break;
    }

    try {
      // 1. Try file selector dialog (cross platform: desktop, mobile, web)
      final typeGroup = XTypeGroup(
        label: format.label,
        extensions: [format.extension],
        mimeTypes: [format.mimeType],
      );

      final FileSaveLocation? saveLocation = await getSaveLocation(
        suggestedName: defaultFileName,
        acceptedTypeGroups: [typeGroup],
      );

      if (saveLocation != null) {
        final Uint8List fileData = Uint8List.fromList(utf8.encode(content));
        final XFile xFile = XFile.fromData(
          fileData,
          name: defaultFileName,
          mimeType: format.mimeType,
        );
        await xFile.saveTo(saveLocation.path);
        return ExportResult(
          success: true,
          filePath: saveLocation.path,
          content: content,
          message: 'Saved to ${saveLocation.path}',
        );
      }
    } catch (e) {
      debugPrint('File picker save error (falling back): $e');
    }

    // Fallback: If running on native platforms without picker or user cancels selector,
    // write directly to user's documents/downloads directory
    if (!kIsWeb) {
      try {
        Directory? dir;
        try {
          dir = await getDownloadsDirectory();
        } catch (_) {}
        dir ??= await getApplicationDocumentsDirectory();

        final fallbackPath = '${dir.path}/$defaultFileName';
        final file = File(fallbackPath);
        await file.writeAsString(content);

        return ExportResult(
          success: true,
          filePath: fallbackPath,
          content: content,
          message: 'Saved to $fallbackPath',
        );
      } catch (e) {
        debugPrint('Fallback file write error: $e');
      }
    }

    return ExportResult(
      success: false,
      content: content,
      message: 'File save cancelled or unavailable. You can copy the content to clipboard.',
    );
  }

  /// Parses JSON content into a list of Receipts
  static List<Receipt> parseJson(String jsonString) {
    final decoded = json.decode(jsonString);
    final List<dynamic> list;
    if (decoded is Map && decoded['receipts'] != null) {
      list = decoded['receipts'] as List<dynamic>;
    } else if (decoded is List) {
      list = decoded;
    } else {
      throw const FormatException('Invalid JSON backup format. Expected a list of receipts or a backup snapshot.');
    }

    return list
        .map((item) => Receipt.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Parses CSV content into a list of Receipts
  static List<Receipt> parseCsv(String csvString) {
    final rows = const CsvDecoder().convert(csvString);
    if (rows.length < 2) {
      throw const FormatException('CSV file is empty or missing headers.');
    }

    final headers = rows[0].map((h) => h.toString().trim().toLowerCase()).toList();
    final idIdx = headers.indexOf('id');
    final dateIdx = headers.indexOf('date');
    final merchIdx = headers.indexOf('merchant');
    final catIdx = headers.indexOf('category');
    final payIdx = headers.indexOf('payment method');
    final amtIdx = headers.indexOf('amount');
    final currIdx = headers.indexOf('currency');
    final taxIdx = headers.indexOf('tax');
    final tipIdx = headers.indexOf('tip');
    final notesIdx = headers.indexOf('notes');

    if (merchIdx == -1 || amtIdx == -1) {
      throw const FormatException('CSV missing required columns (Merchant, Amount).');
    }

    const uuid = Uuid();
    final List<Receipt> receipts = [];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      final merchant = row[merchIdx].toString().trim();
      if (merchant.isEmpty) continue;

      final amountStr = row[amtIdx].toString().replaceAll(RegExp(r'[^\d.]'), '');
      final amount = double.tryParse(amountStr) ?? 0.0;

      final id = (idIdx != -1 && idIdx < row.length && row[idIdx].toString().trim().isNotEmpty)
          ? row[idIdx].toString().trim()
          : uuid.v4();

      DateTime date = DateTime.now();
      if (dateIdx != -1 && dateIdx < row.length) {
        final parsed = DateTime.tryParse(row[dateIdx].toString().trim());
        if (parsed != null) date = parsed;
      }

      String category = 'other';
      if (catIdx != -1 && catIdx < row.length) {
        category = ReceiptCategory.fromId(row[catIdx].toString().trim()).id;
      }

      String payment = 'Credit Card';
      if (payIdx != -1 && payIdx < row.length) {
        final rawPay = row[payIdx].toString().trim();
        if (rawPay.isNotEmpty) payment = rawPay;
      }

      String currency = '\$';
      if (currIdx != -1 && currIdx < row.length) {
        final rawCurr = row[currIdx].toString().trim();
        if (rawCurr.isNotEmpty) currency = rawCurr;
      }

      double? tax;
      if (taxIdx != -1 && taxIdx < row.length) {
        tax = double.tryParse(row[taxIdx].toString().replaceAll(RegExp(r'[^\d.]'), ''));
      }

      double? tip;
      if (tipIdx != -1 && tipIdx < row.length) {
        tip = double.tryParse(row[tipIdx].toString().replaceAll(RegExp(r'[^\d.]'), ''));
      }

      String? notes;
      if (notesIdx != -1 && notesIdx < row.length) {
        final rawNotes = row[notesIdx].toString().trim();
        if (rawNotes.isNotEmpty) notes = rawNotes;
      }

      receipts.add(Receipt(
        id: id,
        merchant: merchant,
        amount: amount,
        currency: currency,
        date: date,
        category: category,
        paymentMethod: payment,
        taxAmount: tax,
        tipAmount: tip,
        notes: notes,
        createdAt: date,
        updatedAt: DateTime.now(),
      ));
    }

    return receipts;
  }

  /// Opens file picker to choose a backup file and parses it
  static Future<ImportResult> pickAndParseBackupFile() async {
    try {
      const typeGroup = XTypeGroup(
        label: 'Receipt Backups (*.json, *.csv)',
        extensions: ['json', 'csv'],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: const [typeGroup],
      );

      if (file == null) {
        return const ImportResult(
          success: false,
          message: 'No file selected.',
        );
      }

      final content = await file.readAsString();
      final lowerName = file.name.toLowerCase();

      List<Receipt> receipts;
      String format = 'JSON';

      if (lowerName.endsWith('.csv')) {
        format = 'CSV';
        receipts = parseCsv(content);
      } else {
        receipts = parseJson(content);
      }

      return ImportResult(
        success: true,
        receipts: receipts,
        format: format,
        message: 'Loaded ${receipts.length} receipts from ${file.name}',
      );
    } catch (e) {
      debugPrint('Error picking/parsing backup file: $e');
      return ImportResult(
        success: false,
        message: 'Failed to parse backup file: $e',
      );
    }
  }
}
