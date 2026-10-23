import 'package:flutter/material.dart';
import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../models/summary_data.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';
import '../widgets/custom_charts.dart';
import '../widgets/empty_state.dart';
import '../widgets/metric_card.dart';

enum SummaryPeriod {
  all('All Time'),
  thisMonth('This Month'),
  last30Days('Last 30 Days'),
  thisYear('This Year');

  final String label;
  const SummaryPeriod(this.label);
}

class SummaryScreen extends StatefulWidget {
  final VoidCallback onNavigateToAdd;
  final VoidCallback onNavigateToExport;

  const SummaryScreen({
    super.key,
    required this.onNavigateToAdd,
    required this.onNavigateToExport,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  SummaryPeriod _selectedPeriod = SummaryPeriod.all;

  List<Receipt> _filterByPeriod(List<Receipt> receipts) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case SummaryPeriod.all:
        return receipts;
      case SummaryPeriod.thisMonth:
        return receipts.where((r) => r.date.year == now.year && r.date.month == now.month).toList();
      case SummaryPeriod.last30Days:
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        return receipts.where((r) => r.date.isAfter(thirtyDaysAgo)).toList();
      case SummaryPeriod.thisYear:
        return receipts.where((r) => r.date.year == now.year).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<List<Receipt>>(
      valueListenable: StorageService.instance.receiptsNotifier,
      builder: (context, allReceipts, _) {
        if (allReceipts.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Expense Summary')),
            body: EmptyState(
              icon: Icons.analytics_outlined,
              title: 'No Data for Summary',
              message: 'Accumulate your receipt photos and records to see comprehensive financial analytics, category charts, and trends.',
              primaryActionLabel: 'Record a Receipt',
              onPrimaryAction: widget.onNavigateToAdd,
            ),
          );
        }

        final filteredReceipts = _filterByPeriod(allReceipts);
        final summary = SummaryData.fromReceipts(filteredReceipts);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expense Summary'),
            actions: [
              IconButton(
                icon: const Icon(Icons.file_download_outlined),
                tooltip: 'Export Report',
                onPressed: widget.onNavigateToExport,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Period Filter Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: SummaryPeriod.values.map((period) {
                    final isSelected = _selectedPeriod == period;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(period.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedPeriod = period);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // KPI Metric Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.35,
                    children: [
                      MetricCard(
                        title: 'Total Spent',
                        value: CurrencyHelper.format(summary.totalSpending),
                        subtitle: '${summary.receiptCount} receipts',
                        icon: Icons.account_balance_wallet,
                        iconColor: const Color(0xFF0F766E),
                      ),
                      MetricCard(
                        title: 'Receipts',
                        value: '${summary.receiptCount}',
                        subtitle: _selectedPeriod.label,
                        icon: Icons.receipt_long,
                        iconColor: const Color(0xFF3B82F6),
                      ),
                      MetricCard(
                        title: 'Average',
                        value: CurrencyHelper.format(summary.averageAmount),
                        subtitle: 'per receipt',
                        icon: Icons.query_stats,
                        iconColor: const Color(0xFF8B5CF6),
                      ),
                      MetricCard(
                        title: 'Largest Bill',
                        value: CurrencyHelper.format(summary.highestAmount),
                        subtitle: 'single purchase',
                        icon: Icons.trending_up,
                        iconColor: const Color(0xFFF59E0B),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Category Breakdown Chart Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Spending by Category',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${summary.categorySpending.length} categories',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      CategoryPieChart(summary: summary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Monthly Trend Bar Chart
              if (summary.monthlySpending.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spending Over Time',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monthly totals overview',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const Divider(height: 24),
                        MonthlySpendingBarChart(summary: summary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Top Merchants Leaderboard
              if (summary.topMerchants.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Merchants',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 24),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: summary.topMerchants.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final m = summary.topMerchants[idx];
                            final pct = summary.totalSpending > 0
                                ? (m.value / summary.totalSpending) * 100
                                : 0.0;
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                    child: Text(
                                      '${idx + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.key,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(3),
                                          child: LinearProgressIndicator(
                                            value: pct / 100,
                                            minHeight: 4,
                                            backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyHelper.format(m.value),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        '${pct.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Payment Methods Breakdown Card
              if (summary.paymentMethodSpending.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Methods',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: summary.paymentMethodSpending.entries.map((entry) {
                            final method = PaymentMethod.fromString(entry.key);
                            final pct = summary.totalSpending > 0
                                ? (entry.value / summary.totalSpending) * 100
                                : 0.0;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(method.icon, size: 16, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${CurrencyHelper.format(entry.value)} (${pct.toStringAsFixed(0)}%)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Export Button CTA
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: widget.onNavigateToExport,
                  icon: const Icon(Icons.download),
                  label: const Text('Export Summary & Records to File'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
