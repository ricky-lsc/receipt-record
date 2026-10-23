import 'dart:convert';
import 'receipt_item.dart';

class Receipt {
  final String id;
  final String merchant;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String paymentMethod;
  final double? taxAmount;
  final double? tipAmount;
  final String? notes;
  final String? imagePath;
  final String? imageBase64;
  final List<ReceiptItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Receipt({
    required this.id,
    required this.merchant,
    required this.amount,
    this.currency = '\$',
    required this.date,
    required this.category,
    this.paymentMethod = 'Credit Card',
    this.taxAmount,
    this.tipAmount,
    this.notes,
    this.imagePath,
    this.imageBase64,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasImage =>
      (imageBase64 != null && imageBase64!.isNotEmpty) ||
      (imagePath != null && imagePath!.isNotEmpty);

  double get itemsSubtotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchant': merchant,
      'amount': amount,
      'currency': currency,
      'date': date.toIso8601String(),
      'category': category,
      'paymentMethod': paymentMethod,
      'taxAmount': taxAmount,
      'tipAmount': tipAmount,
      'notes': notes,
      'imagePath': imagePath,
      'imageBase64': imageBase64,
      'items': items.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'] as String? ?? '',
      merchant: map['merchant'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? '\$',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      category: map['category'] as String? ?? 'other',
      paymentMethod: map['paymentMethod'] as String? ?? 'Credit Card',
      taxAmount: (map['taxAmount'] as num?)?.toDouble(),
      tipAmount: (map['tipAmount'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      imagePath: map['imagePath'] as String?,
      imageBase64: map['imageBase64'] as String?,
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => ReceiptItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Receipt.fromJson(String source) =>
      Receipt.fromMap(json.decode(source) as Map<String, dynamic>);

  Receipt copyWith({
    String? id,
    String? merchant,
    double? amount,
    String? currency,
    DateTime? date,
    String? category,
    String? paymentMethod,
    double? taxAmount,
    double? tipAmount,
    String? notes,
    String? imagePath,
    String? imageBase64,
    List<ReceiptItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      taxAmount: taxAmount ?? this.taxAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      imageBase64: imageBase64 ?? this.imageBase64,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
