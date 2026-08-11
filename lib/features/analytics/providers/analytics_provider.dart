import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../expenses/providers/expenses_provider.dart';

part 'analytics_provider.g.dart';

class CategoryAnalyticsData {
  final String categoryName;
  final double totalAmount;
  final double percentage;

  const CategoryAnalyticsData({
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
  });
}

class DashboardSummary {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double monthlyBudget;
  final double budgetSpentPercentage;

  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.monthlyBudget,
    required this.budgetSpentPercentage,
  });
}

@riverpod
DashboardSummary dashboardSummary(DashboardSummaryRef ref) {
  final expenses = ref.watch(expensesStreamProvider).valueOrNull ?? [];
  final budget = ref.watch(userBudgetStreamProvider).valueOrNull ?? 2500.0;

  final now = DateTime.now();
  
  double incomeSum = 0;
  double expenseSum = 0;
  double currentMonthExpenseSum = 0;

  for (final item in expenses) {
    if (item.isIncome) {
      incomeSum += item.amount;
    } else {
      expenseSum += item.amount;
      if (item.date.month == now.month && item.date.year == now.year) {
        currentMonthExpenseSum += item.amount;
      }
    }
  }

  final totalBalance = incomeSum - expenseSum;
  final spentPercentage = budget > 0 ? (currentMonthExpenseSum / budget * 100).clamp(0.0, 100.0) : 0.0;

  return DashboardSummary(
    totalBalance: totalBalance,
    totalIncome: incomeSum,
    totalExpense: expenseSum,
    monthlyBudget: budget,
    budgetSpentPercentage: spentPercentage,
  );
}

@riverpod
List<CategoryAnalyticsData> categoryAnalytics(CategoryAnalyticsRef ref) {
  final expenses = ref.watch(expensesStreamProvider).valueOrNull ?? [];
  final expenseOnly = expenses.where((e) => !e.isIncome).toList();

  final double totalExpense = expenseOnly.fold(0.0, (sum, item) => sum + item.amount);
  if (totalExpense == 0) return [];

  final Map<String, double> categoryTotals = {};
  for (final item in expenseOnly) {
    categoryTotals[item.category] = (categoryTotals[item.category] ?? 0) + item.amount;
  }

  final List<CategoryAnalyticsData> list = [];
  categoryTotals.forEach((category, amount) {
    final percentage = (amount / totalExpense) * 100;
    list.add(CategoryAnalyticsData(
      categoryName: category,
      totalAmount: amount,
      percentage: percentage,
    ));
  });

  list.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  return list;
}
