import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/expenses_provider.dart';
import 'widgets/expense_card.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = ref.watch(filteredExpensesProvider);
    final filterState = ref.watch(expenseFilterNotifierProvider);
    final filterNotifier = ref.read(expenseFilterNotifierProvider.notifier);
    final expensesAsync = ref.watch(expensesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCcw),
            onPressed: () {
              _searchController.clear();
              filterNotifier.clearFilters();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: CustomTextField(
              controller: _searchController,
              label: '',
              hint: 'Search expenses, categories, or notes...',
              prefixIcon: LucideIcons.search,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        filterNotifier.setSearchQuery('');
                      },
                    )
                  : null,
              onChanged: (val) => filterNotifier.setSearchQuery(val),
            ),
          ),

          // Horizontal Category Filters
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: AppCategories.categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final String categoryName = index == 0 ? 'All' : AppCategories.categories[index - 1].name;
                final isSelected = filterState.selectedCategory == categoryName;

                return ChoiceChip(
                  label: Text(categoryName),
                  selected: isSelected,
                  onSelected: (_) => filterNotifier.setCategory(categoryName),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // List Body View
          Expanded(
            child: expensesAsync.when(
              data: (_) {
                if (filteredList.isEmpty) {
                  return EmptyStateWidget(
                    title: 'No Matching Transactions',
                    message: 'Try adjusting your search query or category filters.',
                    buttonText: 'Reset Filters',
                    onAction: () {
                      _searchController.clear();
                      filterNotifier.clearFilters();
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return ExpenseCard(
                      expense: item,
                      onDelete: () {
                        ref.read(expensesNotifierProvider.notifier).deleteExpense(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaction deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ShimmerListLoading(itemCount: 6),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
