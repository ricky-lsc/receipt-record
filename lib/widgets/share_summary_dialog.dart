import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/summary_data.dart';
import '../services/export_service.dart';
import '../services/locale_service.dart';
import '../utils/currency_helper.dart';

class ShareSummaryDialog extends StatelessWidget {
  final SummaryData summary;
  final String periodLabel;
  final double? budget;

  const ShareSummaryDialog({
    super.key,
    required this.summary,
    required this.periodLabel,
    this.budget,
  });

  static void show(
    BuildContext context, {
    required SummaryData summary,
    required String periodLabel,
    double? budget,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ShareSummaryDialog(
        summary: summary,
        periodLabel: periodLabel,
        budget: budget,
      ),
    );
  }

  String _generateSummaryText(AppLocalizations l10n) {
    final buffer = StringBuffer();
    buffer.writeln('📊 ${l10n.expenseSummary}: $periodLabel');
    buffer.writeln('💰 ${l10n.totalSpent}: ${CurrencyHelper.format(summary.totalSpending)} (${summary.receiptCount} ${l10n.receiptCountSuffix})');

    // Period Comparison Trend
    if (summary.periodChangePercentage != null) {
      final pct = summary.periodChangePercentage!;
      final trendStr = pct > 0
          ? '↑ ${pct.toStringAsFixed(1)}% ${l10n.spendingUp}'
          : '↓ ${pct.abs().toStringAsFixed(1)}% ${l10n.spendingDown}';
      buffer.writeln('📈 ${l10n.vsPreviousPeriod}: $trendStr');
    }

    // Monthly Budget
    if (budget != null && budget! > 0) {
      final pct = (summary.totalSpending / budget!) * 100;
      buffer.writeln('🎯 ${l10n.monthlyBudget}: ${CurrencyHelper.format(summary.totalSpending)} / ${CurrencyHelper.format(budget!)} (${pct.toStringAsFixed(0)}%)');
    }

    // Top Categories
    final sortedCats = summary.categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sortedCats.isNotEmpty) {
      buffer.writeln('--------------------------------');
      buffer.writeln('📁 ${l10n.topCategoriesHeader}:');
      for (final e in sortedCats.take(4)) {
        final catName = LocaleService.getCategoryName(e.key, l10n);
        final pct = summary.categoryPercentages[e.key]?.toStringAsFixed(1) ?? '0.0';
        buffer.writeln('• $catName: ${CurrencyHelper.format(e.value)} ($pct%)');
      }
    }

    // Split & Reimbursements
    if (summary.totalReimbursable > 0 || summary.totalReimbursed > 0) {
      buffer.writeln('--------------------------------');
      buffer.writeln('👥 ${l10n.splitAndReimbursements}:');
      buffer.writeln('• ${l10n.netPersonal}: ${CurrencyHelper.format(summary.netPersonalSpending)}');
      if (summary.totalReimbursable > 0) {
        final friendList = summary.unpaidBalancesByPerson.entries
            .map((entry) => '${entry.key}: ${CurrencyHelper.format(entry.value)}')
            .join(', ');
        buffer.writeln('• ${l10n.unsettledFromFriends}: ${CurrencyHelper.format(summary.totalReimbursable)} ($friendList)');
      }
    }

    // Tax & Tips
    if (summary.totalTax > 0 || summary.totalTip > 0) {
      buffer.writeln('--------------------------------');
      buffer.writeln('🧾 ${l10n.taxAndTipSummary}:');
      if (summary.totalTax > 0) {
        buffer.write('${l10n.totalTaxPaid}: ${CurrencyHelper.format(summary.totalTax)}  ');
      }
      if (summary.totalTip > 0) {
        buffer.write('${l10n.totalTipPaid}: ${CurrencyHelper.format(summary.totalTip)}');
      }
      buffer.writeln();
    }

    buffer.writeln('--------------------------------');
    buffer.writeln(l10n.shareViaReceiptRecord);
    return buffer.toString();
  }

  Future<void> _copySummary(BuildContext context, AppLocalizations l10n) async {
    final text = _generateSummaryText(l10n);
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.summaryCopied),
          backgroundColor: const Color(0xFF0F766E),
        ),
      );
    }
  }

  Future<void> _saveReportAsMarkdown(BuildContext context, AppLocalizations l10n) async {
    final result = await ExportService.exportToFile(
      receipts: summary.receipts,
      format: ExportFormat.markdown,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? l10n.exportSuccess),
          backgroundColor: result.success ? const Color(0xFF0F766E) : Colors.amber,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summaryText = _generateSummaryText(l10n);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: Color(0xFF0F766E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.shareSummaryTitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          periodLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Formatted Text Preview Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      summaryText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _saveReportAsMarkdown(context, l10n),
                    icon: const Icon(Icons.save_alt, size: 16),
                    label: Text(l10n.saveMarkdownReport),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _copySummary(context, l10n),
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text(l10n.copyBreakdown),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
