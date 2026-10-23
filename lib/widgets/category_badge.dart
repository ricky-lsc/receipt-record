import 'package:flutter/material.dart';
import '../models/receipt_category.dart';

class CategoryBadge extends StatelessWidget {
  final String categoryId;
  final bool compact;

  const CategoryBadge({
    super.key,
    required this.categoryId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final category = ReceiptCategory.fromId(categoryId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? category.color.withValues(alpha: 0.18)
        : category.color.withValues(alpha: 0.12);

    final textColor = isDark
        ? category.color.withAlpha(240)
        : category.color;

    if (compact) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          category.icon,
          size: 14,
          color: textColor,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: category.color.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 5),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
