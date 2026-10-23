import 'package:flutter/material.dart';

enum PaymentMethod {
  creditCard('Credit Card', Icons.credit_card),
  debitCard('Debit Card', Icons.payment),
  cash('Cash', Icons.payments),
  digitalWallet('Digital Wallet (Apple/Google Pay)', Icons.contactless),
  bankTransfer('Bank Transfer', Icons.account_balance),
  other('Other', Icons.more_horiz);

  final String label;
  final IconData icon;
  const PaymentMethod(this.label, this.icon);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (m) => m.name == value || m.label == value,
      orElse: () => PaymentMethod.other,
    );
  }
}

class ReceiptCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ReceiptCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<ReceiptCategory> defaults = [
    ReceiptCategory(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.local_grocery_store,
      color: Color(0xFF10B981), // Emerald green
    ),
    ReceiptCategory(
      id: 'dining',
      name: 'Dining & Cafes',
      icon: Icons.restaurant,
      color: Color(0xFFF59E0B), // Amber
    ),
    ReceiptCategory(
      id: 'transport',
      name: 'Transportation & Gas',
      icon: Icons.directions_car,
      color: Color(0xFF3B82F6), // Blue
    ),
    ReceiptCategory(
      id: 'shopping',
      name: 'Shopping & Retail',
      icon: Icons.shopping_bag,
      color: Color(0xFF8B5CF6), // Purple
    ),
    ReceiptCategory(
      id: 'utilities',
      name: 'Utilities & Bills',
      icon: Icons.receipt_long,
      color: Color(0xFFEC4899), // Pink
    ),
    ReceiptCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.local_movies,
      color: Color(0xFF06B6D4), // Cyan
    ),
    ReceiptCategory(
      id: 'health',
      name: 'Health & Pharmacy',
      icon: Icons.health_and_safety,
      color: Color(0xFFEF4444), // Red
    ),
    ReceiptCategory(
      id: 'office',
      name: 'Office & Business',
      icon: Icons.business_center,
      color: Color(0xFF6366F1), // Indigo
    ),
    ReceiptCategory(
      id: 'other',
      name: 'Other',
      icon: Icons.category,
      color: Color(0xFF64748B), // Slate
    ),
  ];

  static ReceiptCategory fromId(String id) {
    return defaults.firstWhere(
      (cat) => cat.id.toLowerCase() == id.toLowerCase() || cat.name.toLowerCase() == id.toLowerCase(),
      orElse: () => defaults.last,
    );
  }
}
