import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../screens/receipt_detail_screen.dart';
import '../services/locale_service.dart';
import '../utils/currency_helper.dart';
import 'receipt_card.dart';

class CategoryDrilldownSheet extends StatelessWidget {
  final String categoryId;
  final List<Receipt> receipts;
  final double categoryTotal;
  final double totalSpending;

  const CategoryDrilldownSheet({
    super.key,
    required this.categoryId,
    required this.receipts,
    required this.categoryTotal,
    required this.totalSpending,
  });

  static void show(
    BuildContext context, {
    required String categoryId,
    required List<Receipt> allReceipts,
    required double categoryTotal,
    required double totalSpending,
  }) {
    final matching = allReceipts
        .where((r) => r.category.toLowerCase() == categoryId.toLowerCase())
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CategoryDrilldownSheet(
        categoryId: categoryId,
        receipts: matching,
        categoryTotal: categoryTotal,
        totalSpending: totalSpending,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final category = ReceiptCategory.fromId(categoryId);
    final pct = totalSpending > 0 ? (categoryTotal / totalSpending) * 100 : 0.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.icon, color: category.color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleService.getCategoryName(categoryId, l10n),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${receipts.length} ${l10n.receiptCountSuffix} • ${pct.toStringAsFixed(1)}% of total',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyHelper.format(categoryTotal),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),

            // Receipts List
            Expanded(
              child: receipts.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noReceiptsFound,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: receipts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final r = receipts[i];
                        return ReceiptCard(
                          receipt: r,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReceiptDetailScreen(receipt: r),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
