import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../models/summary_data.dart';
import '../services/locale_service.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';
import '../widgets/app_settings_dialog.dart';
import '../widgets/category_drilldown_sheet.dart';
import '../widgets/custom_charts.dart';
import '../widgets/empty_state.dart';
import '../widgets/metric_card.dart';
import '../widgets/share_summary_dialog.dart';

enum SummaryPeriod {
  thisWeek,
  thisMonth,
  lastMonth,
  last30Days,
  thisYear,
  all,
  custom;
}

String getSummaryPeriodLabel(
  SummaryPeriod period,
  AppLocalizations l10n, [
  DateTimeRange? customRange,
]) {
  switch (period) {
    case SummaryPeriod.thisWeek:
      return l10n.filterThisWeek;
    case SummaryPeriod.thisMonth:
      return l10n.filterThisMonth;
    case SummaryPeriod.lastMonth:
      return l10n.filterLastMonth;
    case SummaryPeriod.last30Days:
      return l10n.filterLast30Days;
    case SummaryPeriod.thisYear:
      return l10n.filterThisYear;
    case SummaryPeriod.all:
      return l10n.filterAll;
    case SummaryPeriod.custom:
      if (customRange != null) {
        final f = DateFormat('MM/dd');
        return '${f.format(customRange.start)} - ${f.format(customRange.end)}';
      }
      return l10n.customRange;
  }
}

class SummaryScreen extends StatefulWidget {
  final VoidCallback onNavigateToAdd;
  final ValueNotifier<ThemeMode>? themeModeNotifier;

  const SummaryScreen({
    super.key,
    required this.onNavigateToAdd,
    this.themeModeNotifier,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  SummaryPeriod _selectedPeriod = SummaryPeriod.thisMonth;
  DateTimeRange? _customRange;

  (List<Receipt>, List<Receipt>?) _filterReceiptsWithPrior(List<Receipt> receipts) {
    final now = DateTime.now();
    List<Receipt> current = [];
    List<Receipt>? prior;

    switch (_selectedPeriod) {
      case SummaryPeriod.thisWeek:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek = DateTime(monday.year, monday.month, monday.day);
        final startOfPriorWeek = startOfWeek.subtract(const Duration(days: 7));
        current = receipts.where((r) => !r.date.isBefore(startOfWeek)).toList();
        prior = receipts.where((r) => !r.date.isBefore(startOfPriorWeek) && r.date.isBefore(startOfWeek)).toList();
        break;

      case SummaryPeriod.thisMonth:
        final startOfPriorMonth = DateTime(now.year, now.month - 1, 1);
        current = receipts.where((r) => r.date.year == now.year && r.date.month == now.month).toList();
        prior = receipts.where((r) => r.date.year == startOfPriorMonth.year && r.date.month == startOfPriorMonth.month).toList();
        break;

      case SummaryPeriod.lastMonth:
        final lastMonthDate = DateTime(now.year, now.month - 1, 1);
        final twoMonthsAgoDate = DateTime(now.year, now.month - 2, 1);
        current = receipts.where((r) => r.date.year == lastMonthDate.year && r.date.month == lastMonthDate.month).toList();
        prior = receipts.where((r) => r.date.year == twoMonthsAgoDate.year && r.date.month == twoMonthsAgoDate.month).toList();
        break;

      case SummaryPeriod.last30Days:
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        final sixtyDaysAgo = now.subtract(const Duration(days: 60));
        current = receipts.where((r) => r.date.isAfter(thirtyDaysAgo)).toList();
        prior = receipts.where((r) => r.date.isAfter(sixtyDaysAgo) && !r.date.isAfter(thirtyDaysAgo)).toList();
        break;

      case SummaryPeriod.thisYear:
        current = receipts.where((r) => r.date.year == now.year).toList();
        prior = receipts.where((r) => r.date.year == now.year - 1).toList();
        break;

      case SummaryPeriod.all:
        current = receipts;
        prior = null;
        break;

      case SummaryPeriod.custom:
        if (_customRange != null) {
          final start = DateTime(_customRange!.start.year, _customRange!.start.month, _customRange!.start.day);
          final end = DateTime(_customRange!.end.year, _customRange!.end.month, _customRange!.end.day, 23, 59, 59);
          current = receipts.where((r) => !r.date.isBefore(start) && !r.date.isAfter(end)).toList();
        } else {
          current = receipts;
        }
        prior = null;
        break;
    }

    return (current, prior);
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _customRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 14)),
            end: now,
          ),
    );

    if (picked != null) {
      setState(() {
        _customRange = picked;
        _selectedPeriod = SummaryPeriod.custom;
      });
    }
  }

  void _showSetBudgetDialog(BuildContext context, double? currentBudget) {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(
      text: currentBudget != null && currentBudget > 0 ? currentBudget.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(currentBudget != null ? l10n.editBudget : l10n.setBudget),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.noBudgetSet, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.budgetAmount,
                prefixText: '\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          if (currentBudget != null)
            TextButton(
              onPressed: () async {
                await StorageService.instance.setMonthlyBudget(null);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(ctrl.text.trim());
              await StorageService.instance.setMonthlyBudget(val);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<List<Receipt>>(
      valueListenable: StorageService.instance.receiptsNotifier,
      builder: (context, allReceipts, _) {
        if (allReceipts.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.expenseSummary)),
            body: EmptyState(
              icon: Icons.analytics_outlined,
              title: l10n.noExpenseData,
              message: l10n.noExpenseDataDesc,
            ),
          );
        }

        final (filteredReceipts, priorReceipts) = _filterReceiptsWithPrior(allReceipts);
        final summary = SummaryData.fromReceipts(filteredReceipts, priorPeriodReceipts: priorReceipts);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.expenseSummary),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: l10n.shareSummary,
                onPressed: () {
                  final budget = StorageService.instance.budgetNotifier.value;
                  ShareSummaryDialog.show(
                    context,
                    summary: summary,
                    periodLabel: getSummaryPeriodLabel(_selectedPeriod, l10n, _customRange),
                    budget: budget,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.date_range),
                tooltip: l10n.customRange,
                onPressed: _pickCustomDateRange,
              ),
              if (widget.themeModeNotifier != null)
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: l10n.settingsHub,
                  onPressed: () => AppSettingsDialog.show(context, widget.themeModeNotifier!),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Period Filter Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Row(
                  children: SummaryPeriod.values.map((period) {
                    final isSelected = _selectedPeriod == period;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(getSummaryPeriodLabel(period, l10n, _customRange)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            if (period == SummaryPeriod.custom) {
                              _pickCustomDateRange();
                            } else {
                              setState(() => _selectedPeriod = period);
                            }
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // KPI Metric Cards Grid (with MoM Comparison Indicator)
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

                  String? trendSubtitle;
                  if (summary.periodChangePercentage != null) {
                    final pct = summary.periodChangePercentage!;
                    final isUp = pct > 0;
                    trendSubtitle = isUp
                        ? '↑ ${pct.toStringAsFixed(1)}% ${l10n.spendingUp}'
                        : '↓ ${pct.abs().toStringAsFixed(1)}% ${l10n.spendingDown}';
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: constraints.maxWidth > 600 ? 1.4 : 1.25,
                    children: [
                      MetricCard(
                        title: l10n.totalSpent,
                        value: CurrencyHelper.format(summary.totalSpending),
                        subtitle: trendSubtitle ?? '${summary.receiptCount} ${l10n.receiptCountSuffix}',
                        icon: Icons.account_balance_wallet,
                        iconColor: const Color(0xFF0F766E),
                      ),
                      MetricCard(
                        title: l10n.navReceipts,
                        value: '${summary.receiptCount}',
                        subtitle: getSummaryPeriodLabel(_selectedPeriod, l10n, _customRange),
                        icon: Icons.receipt_long,
                        iconColor: const Color(0xFF3B82F6),
                      ),
                      MetricCard(
                        title: l10n.dailyAverage,
                        value: CurrencyHelper.format(summary.averageAmount),
                        subtitle: l10n.totalAmount,
                        icon: Icons.query_stats,
                        iconColor: const Color(0xFF8B5CF6),
                      ),
                      MetricCard(
                        title: l10n.totalAmount,
                        value: CurrencyHelper.format(summary.highestAmount),
                        subtitle: l10n.topCategory,
                        icon: Icons.trending_up,
                        iconColor: const Color(0xFFF59E0B),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Monthly Budget Target & Progress Card
              ValueListenableBuilder<double?>(
                valueListenable: StorageService.instance.budgetNotifier,
                builder: (context, budget, _) {
                  final now = DateTime.now();
                  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
                  final daysLeft = daysInMonth - now.day;

                  if (budget == null || budget <= 0) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.savings_outlined, color: Color(0xFF0F766E), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(l10n.monthlyBudget, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text(l10n.noBudgetSet, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _showSetBudgetDialog(context, budget),
                              icon: const Icon(Icons.add, size: 14),
                              label: Text(l10n.setBudget),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Calculate month-to-date spending
                  final mtdSpending = allReceipts
                      .where((r) => r.date.year == now.year && r.date.month == now.month)
                      .fold<double>(0.0, (sum, r) => sum + r.amount);

                  final pct = (mtdSpending / budget).clamp(0.0, 1.0);
                  final remaining = budget - mtdSpending;
                  final isExceeded = remaining < 0;
                  final dailyAllowance = daysLeft > 0 && !isExceeded ? (remaining / daysLeft) : 0.0;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.savings_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(l10n.monthlyBudget, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 16),
                                tooltip: l10n.editBudget,
                                onPressed: () => _showSetBudgetDialog(context, budget),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${CurrencyHelper.format(mtdSpending)} / ${CurrencyHelper.format(budget)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${(pct * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isExceeded ? Colors.red : (pct > 0.85 ? Colors.amber : const Color(0xFF0F766E)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 8,
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isExceeded ? Colors.red : (pct > 0.85 ? Colors.amber : const Color(0xFF0F766E)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isExceeded
                                    ? '${l10n.budgetExceeded}: ${CurrencyHelper.format(remaining.abs())}'
                                    : '${l10n.budgetRemaining}: ${CurrencyHelper.format(remaining)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isExceeded ? Colors.red : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                ),
                              ),
                              if (!isExceeded && daysLeft > 0)
                                Text(
                                  '$daysLeft ${l10n.daysRemaining} (${CurrencyHelper.format(dailyAllowance)}/day)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Split Bill & Reimbursement Tracking Card (if any splits present)
              if (summary.totalReimbursable > 0 || summary.totalReimbursed > 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.people_outline, color: Color(0xFF0F766E), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.splitAndReimbursements,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.netPersonal, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyHelper.format(summary.netPersonalSpending),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(l10n.unsettledFromFriends, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyHelper.format(summary.totalReimbursable),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (summary.unpaidBalancesByPerson.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 12),
                          ...summary.unpaidBalancesByPerson.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.account_circle_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  Text(
                                    '${CurrencyHelper.format(e.value)} (${l10n.markUnpaid})',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.amber),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tax & Tip Deductibles Summary Card
              if (summary.totalTax > 0 || summary.totalTip > 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.receipt_outlined, color: Colors.blue, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.taxAndTipSummary,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(l10n.totalTaxPaid, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyHelper.format(summary.totalTax),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${summary.receiptsWithTaxCount} ${l10n.receiptCountSuffix}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 36, color: Colors.grey.withValues(alpha: 0.3)),
                            Column(
                              children: [
                                Text(l10n.totalTipPaid, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyHelper.format(summary.totalTip),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${summary.receiptsWithTipCount} ${l10n.receiptCountSuffix}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Category Breakdown Chart Section with Interactive Drill-Down
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.categoryBreakdown,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${summary.categorySpending.length} ${l10n.category}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.tapCategoryToInspect,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Divider(height: 20),
                      CategoryPieChart(
                        summary: summary,
                        onCategoryTap: (catId) {
                          CategoryDrilldownSheet.show(
                            context,
                            categoryId: catId,
                            allReceipts: filteredReceipts,
                            categoryTotal: summary.categorySpending[catId] ?? 0.0,
                            totalSpending: summary.totalSpending,
                          );
                        },
                      ),
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
                        Text(
                          l10n.spendingOverTime,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.monthlySpending,
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
                        Text(
                          l10n.merchantName,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                        Text(
                          l10n.paymentMethod,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                                    LocaleService.getPaymentMethodName(entry.key, l10n),
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
            ],
          ),
        );
      },
    );
  }
}
