import 'receipt_item.dart';

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
