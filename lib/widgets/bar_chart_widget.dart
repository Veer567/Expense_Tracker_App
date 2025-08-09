import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;
  final Map<String, Color> categoryColors;

  const BarChartWidget({
    Key? key,
    required this.expenses,
    required this.categoryColors,
  }) : super(key: key);

  Map<String, double> _calculateCategoryTotals() {
    final Map<String, double> categoryTotals = {};
    for (var exp in expenses) {
      final category = exp['category'] ?? 'Other';
      final amount = (exp['amount'] as num).toDouble();
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }
    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _calculateCategoryTotals();
    final barGroups = categoryTotals.entries.map((entry) {
      final color = categoryColors[entry.key] ?? Colors.grey;
      return BarChartGroupData(
        x: categoryTotals.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: color,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: categoryTotals.values.isNotEmpty
            ? categoryTotals.values.reduce((a, b) => a > b ? a : b) * 1.2
            : 10,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                final category = categoryTotals.keys.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    category,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, horizontalInterval: 10),
        barGroups: barGroups,
      ),
    );
  }
}
