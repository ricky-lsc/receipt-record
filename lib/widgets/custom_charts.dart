import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/receipt_category.dart';
import '../models/summary_data.dart';
import '../utils/currency_helper.dart';

class CategoryPieChart extends StatefulWidget {
  final SummaryData summary;

  const CategoryPieChart({super.key, required this.summary});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = widget.summary.categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty || widget.summary.totalSpending <= 0) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text('No spending data to display in chart'),
        ),
      );
    }

    final sections = List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final entry = entries[i];
      final category = ReceiptCategory.fromId(entry.key);
      final double percentage = widget.summary.categoryPercentages[entry.key] ?? 0.0;
      final radius = isTouched ? 65.0 : 54.0;

      return PieChartSectionData(
        color: category.color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black45, blurRadius: 2),
          ],
        ),
      );
    });

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 42,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Breakdown List with progress bars
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final entry = entries[i];
            final category = ReceiptCategory.fromId(entry.key);
            final percentage = widget.summary.categoryPercentages[entry.key] ?? 0.0;
            final count = widget.summary.categoryCounts[entry.key] ?? 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$count ${count == 1 ? 'receipt' : 'receipts'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        CurrencyHelper.format(entry.value),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(category.color),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class MonthlySpendingBarChart extends StatelessWidget {
  final SummaryData summary;

  const MonthlySpendingBarChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = summary.monthlySpending.entries.toList();

    if (entries.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No monthly data available')),
      );
    }

    double maxY = 0;
    for (final e in entries) {
      if (e.value > maxY) maxY = e.value;
    }
    maxY = maxY == 0 ? 100 : maxY * 1.25;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final month = entries[group.x.toInt()].key;
                return BarTooltipItem(
                  '$month\n${CurrencyHelper.format(rod.toY)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      CurrencyHelper.formatCompact(value),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[index].key,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(entries.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value,
                  color: const Color(0xFF0F766E),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
