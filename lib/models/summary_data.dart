import 'package:intl/intl.dart';
import 'receipt.dart';

class SummaryData {
  final double totalSpending;
  final int receiptCount;
  final double averageAmount;
  final double highestAmount;
  final Map<String, double> categorySpending;
  final Map<String, double> categoryPercentages;
  final Map<String, int> categoryCounts;
  final List<MapEntry<String, double>> topMerchants;
  final Map<String, double> monthlySpending;
  final Map<String, double> paymentMethodSpending;
  final DateTime? earliestDate;
  final DateTime? latestDate;

  // Tax & Tip aggregates
  final double totalTax;
  final double totalTip;
  final int receiptsWithTaxCount;
  final int receiptsWithTipCount;

  // Split bill & reimbursement metrics
  final double netPersonalSpending;
  final double totalReimbursable;
  final double totalReimbursed;
  final Map<String, double> unpaidBalancesByPerson;

  // Month-over-month / Period comparison
  final double? priorPeriodSpending;
  final double? periodChangePercentage;

  // Full receipts for drill-down
  final List<Receipt> receipts;

  const SummaryData({
    required this.totalSpending,
    required this.receiptCount,
    required this.averageAmount,
    required this.highestAmount,
    required this.categorySpending,
    required this.categoryPercentages,
    required this.categoryCounts,
    required this.topMerchants,
    required this.monthlySpending,
    required this.paymentMethodSpending,
    this.earliestDate,
    this.latestDate,
    this.totalTax = 0.0,
    this.totalTip = 0.0,
    this.receiptsWithTaxCount = 0,
    this.receiptsWithTipCount = 0,
    this.netPersonalSpending = 0.0,
    this.totalReimbursable = 0.0,
    this.totalReimbursed = 0.0,
    this.unpaidBalancesByPerson = const {},
    this.priorPeriodSpending,
    this.periodChangePercentage,
    this.receipts = const [],
  });

  factory SummaryData.empty() {
    return const SummaryData(
      totalSpending: 0,
      receiptCount: 0,
      averageAmount: 0,
      highestAmount: 0,
      categorySpending: {},
      categoryPercentages: {},
      categoryCounts: {},
      topMerchants: [],
      monthlySpending: {},
      paymentMethodSpending: {},
      totalTax: 0,
      totalTip: 0,
      receiptsWithTaxCount: 0,
      receiptsWithTipCount: 0,
      netPersonalSpending: 0,
      totalReimbursable: 0,
      totalReimbursed: 0,
      unpaidBalancesByPerson: {},
      receipts: [],
    );
  }

  factory SummaryData.fromReceipts(
    List<Receipt> receipts, {
    List<Receipt>? priorPeriodReceipts,
  }) {
    if (receipts.isEmpty) {
      return SummaryData.empty();
    }

    double total = 0.0;
    double maxAmount = 0.0;
    double taxTotal = 0.0;
    double tipTotal = 0.0;
    int taxCount = 0;
    int tipCount = 0;

    final Map<String, double> catSpending = {};
    final Map<String, int> catCounts = {};
    final Map<String, double> merchSpending = {};
    final Map<String, double> monthSpending = {};
    final Map<String, double> payMethodSpending = {};

    DateTime? minDate;
    DateTime? maxDate;

    double reimbursable = 0.0;
    double reimbursed = 0.0;
    double otherSharesTotal = 0.0;
    final Map<String, double> unpaidBalances = {};

    for (final r in receipts) {
      final spendAmount = r.effectiveAmount;
      total += spendAmount;
      if (spendAmount > maxAmount) {
        maxAmount = spendAmount;
      }

      // Tax & Tip
      if (r.taxAmount != null && r.taxAmount! > 0) {
        taxTotal += r.taxAmount!;
        taxCount++;
      }
      if (r.tipAmount != null && r.tipAmount! > 0) {
        tipTotal += r.tipAmount!;
        tipCount++;
      }

      // Dates
      if (minDate == null || r.date.isBefore(minDate)) {
        minDate = r.date;
      }
      if (maxDate == null || r.date.isAfter(maxDate)) {
        maxDate = r.date;
      }

      // Category
      catSpending[r.category] = (catSpending[r.category] ?? 0.0) + spendAmount;
      catCounts[r.category] = (catCounts[r.category] ?? 0) + 1;

      // Merchant
      final merchantKey = r.merchant.trim().isEmpty ? 'Unknown' : r.merchant.trim();
      merchSpending[merchantKey] = (merchSpending[merchantKey] ?? 0.0) + spendAmount;

      // Month (e.g. "Oct 2026")
      final monthKey = DateFormat('MMM yyyy').format(r.date);
      monthSpending[monthKey] = (monthSpending[monthKey] ?? 0.0) + spendAmount;

      // Payment method
      final methodKey = r.paymentMethod.isEmpty ? 'Other' : r.paymentMethod;
      payMethodSpending[methodKey] =
          (payMethodSpending[methodKey] ?? 0.0) + spendAmount;

      // Split bill parsing
      if (r.isSplit) {
        for (int i = 0; i < r.split!.participants.length; i++) {
          final p = r.split!.participants[i];
          final pName = p.name.trim();
          final isMe = i == 0 ||
              pName.toLowerCase() == 'me' ||
              pName == '我';
          if (!isMe) {
            otherSharesTotal += p.amount;
            if (p.isPaid) {
              reimbursed += p.amount;
            } else {
              reimbursable += p.amount;
              final displayName = pName.isNotEmpty ? pName : 'Person ${i + 1}';
              unpaidBalances[displayName] =
                  (unpaidBalances[displayName] ?? 0.0) + p.amount;
            }
          }
        }
      }
    }

    final double avg = receipts.isNotEmpty ? (total / receipts.length) : 0.0;
    final double netPersonal = total - otherSharesTotal;

    // Category percentages
    final Map<String, double> catPercentages = {};
    catSpending.forEach((cat, amt) {
      catPercentages[cat] = total > 0 ? (amt / total) * 100 : 0.0;
    });

    // Top merchants sorted descending
    final sortedMerchants = merchSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Prior period calculations
    double? priorTotal;
    double? changePct;
    if (priorPeriodReceipts != null) {
      priorTotal = priorPeriodReceipts.fold<double>(0.0, (sum, r) => sum + r.amount);
      if (priorTotal > 0) {
        changePct = ((total - priorTotal) / priorTotal) * 100;
      }
    }

    return SummaryData(
      totalSpending: total,
      receiptCount: receipts.length,
      averageAmount: avg,
      highestAmount: maxAmount,
      categorySpending: catSpending,
      categoryPercentages: catPercentages,
      categoryCounts: catCounts,
      topMerchants: sortedMerchants.take(5).toList(),
      monthlySpending: monthSpending,
      paymentMethodSpending: payMethodSpending,
      earliestDate: minDate,
      latestDate: maxDate,
      totalTax: taxTotal,
      totalTip: tipTotal,
      receiptsWithTaxCount: taxCount,
      receiptsWithTipCount: tipCount,
      netPersonalSpending: netPersonal >= 0 ? netPersonal : 0.0,
      totalReimbursable: reimbursable,
      totalReimbursed: reimbursed,
      unpaidBalancesByPerson: unpaidBalances,
      priorPeriodSpending: priorTotal,
      periodChangePercentage: changePct,
      receipts: receipts,
    );
  }
}
