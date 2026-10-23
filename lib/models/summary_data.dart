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
    );
  }

  factory SummaryData.fromReceipts(List<Receipt> receipts) {
    if (receipts.isEmpty) {
      return SummaryData.empty();
    }

    double total = 0.0;
    double maxAmount = 0.0;
    final Map<String, double> catSpending = {};
    final Map<String, int> catCounts = {};
    final Map<String, double> merchSpending = {};
    final Map<String, double> monthSpending = {};
    final Map<String, double> payMethodSpending = {};

    DateTime? minDate;
    DateTime? maxDate;

    for (final r in receipts) {
      total += r.amount;
      if (r.amount > maxAmount) {
        maxAmount = r.amount;
      }

      // Dates
      if (minDate == null || r.date.isBefore(minDate)) {
        minDate = r.date;
      }
      if (maxDate == null || r.date.isAfter(maxDate)) {
        maxDate = r.date;
      }

      // Category
      catSpending[r.category] = (catSpending[r.category] ?? 0.0) + r.amount;
      catCounts[r.category] = (catCounts[r.category] ?? 0) + 1;

      // Merchant
      final merchantKey = r.merchant.trim().isEmpty ? 'Unknown' : r.merchant.trim();
      merchSpending[merchantKey] = (merchSpending[merchantKey] ?? 0.0) + r.amount;

      // Month (e.g. "Oct 2026")
      final monthKey = DateFormat('MMM yyyy').format(r.date);
      monthSpending[monthKey] = (monthSpending[monthKey] ?? 0.0) + r.amount;

      // Payment method
      final methodKey = r.paymentMethod.isEmpty ? 'Other' : r.paymentMethod;
      payMethodSpending[methodKey] =
          (payMethodSpending[methodKey] ?? 0.0) + r.amount;
    }

    final double avg = receipts.isNotEmpty ? (total / receipts.length) : 0.0;

    // Category percentages
    final Map<String, double> catPercentages = {};
    catSpending.forEach((cat, amt) {
      catPercentages[cat] = total > 0 ? (amt / total) * 100 : 0.0;
    });

    // Top merchants sorted descending
    final sortedMerchants = merchSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
    );
  }
}
