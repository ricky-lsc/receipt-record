import 'package:uuid/uuid.dart';
import '../models/receipt_item.dart';

class ExtractedReceiptData {
  final String? merchant;
  final double? totalAmount;
  final double? taxAmount;
  final double? tipAmount;
  final DateTime? date;
  final String? category;
  final List<ReceiptItem> items;
  final String rawText;

  const ExtractedReceiptData({
    this.merchant,
    this.totalAmount,
    this.taxAmount,
    this.tipAmount,
    this.date,
    this.category,
    this.items = const [],
    required this.rawText,
  });

  bool get hasExtractedInfo =>
      merchant != null || totalAmount != null || date != null;
}

class ReceiptParser {
  /// Parses raw OCR text into structured receipt information
  static ExtractedReceiptData parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return const ExtractedReceiptData(rawText: '');
    }

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final merchant = _extractMerchant(lines);
    final total = _extractTotalAmount(lines);
    final tax = _extractTaxAmount(lines);
    final tip = _extractTipAmount(lines);
    final date = _extractDate(lines);
    final items = _extractLineItems(lines);
    final category = _inferCategory(merchant, rawText);

    return ExtractedReceiptData(
      merchant: merchant,
      totalAmount: total,
      taxAmount: tax,
      tipAmount: tip,
      date: date,
      category: category,
      items: items,
      rawText: rawText,
    );
  }

  static String? _extractMerchant(List<String> lines) {
    final noiseKeywords = [
      'receipt',
      'welcome',
      'customer copy',
      'merchant copy',
      'tax invoice',
      'official receipt',
      'tel:',
      'phone',
      'store #',
      'order #',
      'trans #',
      'cashier',
      'register',
      'terminal',
      'http',
      'www.',
      'thank you',
      'duplicate',
    ];

    // Check the first 5 non-empty lines
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();

      // Skip lines that are just numbers, dates, or noise
      if (line.length < 3 || line.length > 40) continue;
      if (RegExp(r'^[0-9\s\-\/\:\.\,\$\#]+$').hasMatch(line)) continue;

      bool isNoise = false;
      for (final noise in noiseKeywords) {
        if (lower.contains(noise)) {
          isNoise = true;
          break;
        }
      }

      if (!isNoise) {
        // Clean up merchant name (strip trailing symbols)
        return line.replaceAll(RegExp(r'[\*\#\-\_\=]+$'), '').trim();
      }
    }

    return null;
  }

  static double? _extractTotalAmount(List<String> lines) {
    final totalKeywords = [
      'total amount',
      'total due',
      'balance due',
      'grand total',
      'final total',
      'amount due',
      'amount paid',
      'total paid',
      'total usd',
      'total cad',
      'total eur',
      'total',
    ];

    final currencyRegex = RegExp(r'\$?\s*([0-9]+[.,][0-9]{2})');

    // 1. First priority: Look for lines explicitly containing total keywords
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      final lower = line.toLowerCase();

      // Skip subtotal or tax lines when looking for total
      if (lower.contains('subtotal') || lower.contains('tax total')) continue;

      for (final keyword in totalKeywords) {
        if (lower.contains(keyword)) {
          final matches = currencyRegex.allMatches(line);
          if (matches.isNotEmpty) {
            final valStr = matches.last.group(1)!.replaceAll(',', '.');
            final val = double.tryParse(valStr);
            if (val != null && val > 0) return val;
          }

          // Sometimes amount is on the next line
          if (i + 1 < lines.length) {
            final nextMatches = currencyRegex.allMatches(lines[i + 1]);
            if (nextMatches.isNotEmpty) {
              final valStr = nextMatches.first.group(1)!.replaceAll(',', '.');
              final val = double.tryParse(valStr);
              if (val != null && val > 0) return val;
            }
          }
        }
      }
    }

    // 2. Fallback: Find maximum price found in the bottom half of the receipt
    double maxFound = 0.0;
    final startIndex = (lines.length / 2).floor();
    for (int i = startIndex; i < lines.length; i++) {
      final matches = currencyRegex.allMatches(lines[i]);
      for (final m in matches) {
        final valStr = m.group(1)!.replaceAll(',', '.');
        final val = double.tryParse(valStr);
        if (val != null && val > maxFound && val < 100000) {
          maxFound = val;
        }
      }
    }

    return maxFound > 0 ? maxFound : null;
  }

  static double? _extractTaxAmount(List<String> lines) {
    final taxKeywords = ['sales tax', 'tax', 'vat', 'gst', 'hst'];
    final currencyRegex = RegExp(r'\$?\s*([0-9]+[.,][0-9]{2})');

    for (final line in lines) {
      final lower = line.toLowerCase();
      // Skip if it says "taxable" or "tax id"
      if (lower.contains('tax id') || lower.contains('taxable')) continue;

      for (final keyword in taxKeywords) {
        if (lower.contains(keyword)) {
          final matches = currencyRegex.allMatches(line);
          if (matches.isNotEmpty) {
            final valStr = matches.last.group(1)!.replaceAll(',', '.');
            final val = double.tryParse(valStr);
            if (val != null && val > 0) return val;
          }
        }
      }
    }

    return null;
  }

  static double? _extractTipAmount(List<String> lines) {
    final tipKeywords = ['tip', 'gratuity'];
    final currencyRegex = RegExp(r'\$?\s*([0-9]+[.,][0-9]{2})');

    for (final line in lines) {
      final lower = line.toLowerCase();
      for (final keyword in tipKeywords) {
        if (lower.contains(keyword)) {
          final matches = currencyRegex.allMatches(line);
          if (matches.isNotEmpty) {
            final valStr = matches.last.group(1)!.replaceAll(',', '.');
            final val = double.tryParse(valStr);
            if (val != null && val > 0) return val;
          }
        }
      }
    }

    return null;
  }

  static DateTime? _extractDate(List<String> lines) {
    // Standard formats: YYYY-MM-DD, MM/DD/YYYY, DD/MM/YYYY, MM-DD-YYYY, etc.
    final datePatterns = [
      // 2026-10-24
      RegExp(r'\b(20[2-3][0-9])[-/.](0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])\b'),
      // 10/24/2026 or 10-24-2026
      RegExp(r'\b(0[1-9]|1[0-2])[-/.](0[1-9]|[12][0-9]|3[01])[-/.](20[2-3][0-9])\b'),
      // Oct 24, 2026 or 24 Oct 2026
      RegExp(r'\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+([0-9]{1,2}),?\s+(20[2-3][0-9])\b', caseSensitive: false),
    ];

    for (final line in lines) {
      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          try {
            if (match.groupCount == 3) {
              final g1 = match.group(1)!;
              final g2 = match.group(2)!;
              final g3 = match.group(3)!;

              // If starts with 4-digit year: YYYY-MM-DD
              if (g1.length == 4) {
                return DateTime(int.parse(g1), int.parse(g2), int.parse(g3));
              }

              // If month name: e.g. Oct 24, 2026
              final monthNames = {
                'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
                'may': 5, 'jun': 6, 'jul': 7, 'aug': 8,
                'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
              };
              final lowerG1 = g1.substring(0, 3).toLowerCase();
              if (monthNames.containsKey(lowerG1)) {
                return DateTime(int.parse(g3), monthNames[lowerG1]!, int.parse(g2));
              }

              // MM/DD/YYYY
              final month = int.parse(g1);
              final day = int.parse(g2);
              final year = int.parse(g3);
              if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
                return DateTime(year, month, day);
              }
            }
          } catch (_) {}
        }
      }
    }

    return null;
  }

  static List<ReceiptItem> _extractLineItems(List<String> lines) {
    final List<ReceiptItem> items = [];
    final itemLineRegex = RegExp(r'^(.+?)\s+(?:x?([1-9][0-9]?)\s+)?\$?\s*([0-9]+[.,][0-9]{2})$');
    final excludeWords = [
      'subtotal', 'total', 'tax', 'tip', 'cash', 'change',
      'visa', 'mastercard', 'debit', 'balance', 'thank you',
      'discount', 'coupon', 'item', 'qty', 'price',
    ];

    for (final line in lines) {
      final lower = line.toLowerCase();
      bool shouldExclude = false;
      for (final exc in excludeWords) {
        if (lower.contains(exc)) {
          shouldExclude = true;
          break;
        }
      }
      if (shouldExclude) continue;

      final match = itemLineRegex.firstMatch(line);
      if (match != null) {
        final name = match.group(1)!.trim();
        final qtyStr = match.group(2);
        final priceStr = match.group(3)!.replaceAll(',', '.');

        final price = double.tryParse(priceStr);
        final qty = qtyStr != null ? (int.tryParse(qtyStr) ?? 1) : 1;

        if (name.length >= 2 && price != null && price > 0 && price < 5000) {
          items.add(ReceiptItem(
            id: const Uuid().v4(),
            name: name,
            quantity: qty,
            unitPrice: price / qty,
          ));
        }
      }
    }

    return items;
  }

  static String _inferCategory(String? merchant, String rawText) {
    final text = '${merchant ?? ''} $rawText'.toLowerCase();

    final categoryKeywords = {
      'groceries': [
        'grocery', 'market', 'supermarket', 'food', 'produce', 'trader joe',
        'whole foods', 'safeway', 'kroger', 'walmart', 'costco', 'aldi',
        'bakery', 'deli', 'fruit', 'vegetable',
      ],
      'dining': [
        'cafe', 'coffee', 'restaurant', 'bistro', 'diner', 'grill', 'bar',
        'starbucks', 'espresso', 'pizza', 'burger', 'taco', 'kitchen',
        'breakfast', 'lunch', 'dinner', 'pub', 'tea',
      ],
      'transport': [
        'gas', 'fuel', 'shell', 'chevron', 'exxon', 'mobil', 'bp',
        'petroleum', 'auto', 'parking', 'uber', 'lyft', 'transit',
        'metro', 'toll',
      ],
      'shopping': [
        'store', 'target', 'apple', 'amazon', 'retail', 'best buy',
        'clothing', 'apparel', 'shoes', 'electronics', 'fashion',
      ],
      'health': [
        'pharmacy', 'cvs', 'walgreens', 'drug', 'clinic', 'hospital',
        'medical', 'dental', 'health', 'rx', 'vitamin',
      ],
      'utilities': [
        'electric', 'power', 'water', 'internet', 'broadband', 'cable',
        'telecom', 'wireless', 'verizon', 'at&t', 't-mobile', 'energy',
      ],
      'office': [
        'office', 'staples', 'depot', 'paper', 'print', 'stationery',
      ],
      'entertainment': [
        'cinema', 'theater', 'movie', 'ticket', 'amusement', 'game',
        'arcade', 'concert',
      ],
    };

    for (final entry in categoryKeywords.entries) {
      for (final kw in entry.value) {
        if (text.contains(kw)) {
          return entry.key;
        }
      }
    }

    return 'other';
  }
}
