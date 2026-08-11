import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/connectivity/connectivity_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../expenses/presentation/add_edit_expense_sheet.dart';
import '../../expenses/presentation/widgets/expense_card.dart';
import '../../expenses/providers/expenses_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(dashboardSummaryProvider);
    final expensesAsync = ref.watch(expensesStreamProvider);
    final selectedCurrency = ref.watch(currencyNotifierProvider);
    final currencyFormatter = NumberFormat.currency(symbol: selectedCurrency.symbol, decimalDigits: 2);
    final isOnline = ref.watch(connectivityStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(expensesStreamProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isOnline) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.wifiOff, size: 18, color: theme.colorScheme.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You are currently offline. New transactions will sync when reconnected.',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Hero Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryIndigo,
                      AppColors.primaryViolet,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOnline
                                ? Colors.white.withValues(alpha: 0.18)
                                : theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: isOnline
                                ? null
                                : Border.all(color: theme.colorScheme.error, width: 0.5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isOnline ? LucideIcons.shieldCheck : LucideIcons.wifiOff,
                                size: 14,
                                color: isOnline ? Colors.white : theme.colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOnline ? 'Synced' : 'Offline',
                                style: TextStyle(
                                  color: isOnline ? Colors.white : theme.colorScheme.onErrorContainer,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormatter.format(summary.totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Income vs Expense Totals
                    Row(
                      children: [
                        // Income Total Box
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.arrowDownLeft, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Income',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currencyFormatter.format(summary.totalIncome),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Expense Total Box
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.arrowUpRight, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expenses',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currencyFormatter.format(summary.totalExpense),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Monthly Budget Progress Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.target, size: 18, color: AppColors.primaryIndigo),
                            const SizedBox(width: 8),
                            Text(
                              'Monthly Budget Limit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${summary.budgetSpentPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: summary.budgetSpentPercentage >= 90
                                ? AppColors.expenseRed
                                : AppColors.primaryIndigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: summary.budgetSpentPercentage / 100,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          summary.budgetSpentPercentage >= 90
                              ? AppColors.expenseRed
                              : summary.budgetSpentPercentage >= 75
                                  ? AppColors.warningAmber
                                  : AppColors.primaryIndigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/transactions'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Transactions List Stream Builder
              expensesAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return EmptyStateWidget(
                      title: 'No Transactions Yet',
                      message: 'Tap the + button below to add your first expense or income.',
                      buttonText: 'Add Expense',
                      onAction: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddEditExpenseSheet(),
                        );
                      },
                    );
                  }

                  final recentList = expenses.take(5).toList();

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = recentList[index];
                      return ExpenseCard(
                        expense: item,
                        onDelete: () {
                          ref.read(expensesNotifierProvider.notifier).deleteExpense(item.id);
                        },
                      );
                    },
                  );
                },
                loading: () => const ShimmerListLoading(itemCount: 4),
                error: (err, stack) => Center(child: Text('Error loading transactions: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
