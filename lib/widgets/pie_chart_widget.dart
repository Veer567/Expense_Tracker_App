import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;
  final Map<String, Color> categoryColors;

  const PieChartWidget({
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
    final totalAmount = categoryTotals.values.fold(
      0.0,
      (sum, item) => sum + item,
    );

    final sections = categoryTotals.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      final color = categoryColors[category] ?? Colors.grey;
      final percentage = totalAmount == 0 ? 0 : (amount / totalAmount) * 100;

      return PieChartSectionData(
        color: color,
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
