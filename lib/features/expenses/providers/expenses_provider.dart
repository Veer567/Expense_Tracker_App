import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/expenses_repository.dart';
import '../models/expense_model.dart';

part 'expenses_provider.g.dart';

@riverpod
ExpensesRepository expensesRepository(ExpensesRepositoryRef ref) {
  return ExpensesRepository();
}

@riverpod
Stream<List<Expense>> expensesStream(ExpensesStreamRef ref) {
  final user = ref.watch(authStateStreamProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  final repo = ref.watch(expensesRepositoryProvider);
  return repo.watchExpenses(user.uid);
}

@riverpod
Stream<double> userBudgetStream(UserBudgetStreamRef ref) {
  final user = ref.watch(authStateStreamProvider).valueOrNull;
  if (user == null) return Stream.value(2500.0);
  final repo = ref.watch(expensesRepositoryProvider);
  return repo.watchUserBudget(user.uid);
}

class ExpenseFilterState {
  final String searchQuery;
  final String selectedCategory;
  final bool? isIncome;

  const ExpenseFilterState({
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.isIncome,
  });

  ExpenseFilterState copyWith({
    String? searchQuery,
    String? selectedCategory,
    bool? isIncome,
  }) {
    return ExpenseFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isIncome: isIncome,
    );
  }
}

@riverpod
class ExpenseFilterNotifier extends _$ExpenseFilterNotifier {
  @override
  ExpenseFilterState build() => const ExpenseFilterState();

  void setSearchQuery(String query) {
    state = ExpenseFilterState(
      searchQuery: query,
      selectedCategory: state.selectedCategory,
      isIncome: state.isIncome,
    );
  }

  void setCategory(String category) {
    state = ExpenseFilterState(
      searchQuery: state.searchQuery,
      selectedCategory: category,
      isIncome: state.isIncome,
    );
  }

  void setTypeFilter(bool? isIncome) {
    state = ExpenseFilterState(
      searchQuery: state.searchQuery,
      selectedCategory: state.selectedCategory,
      isIncome: isIncome,
    );
  }

  void clearFilters() {
    state = const ExpenseFilterState();
  }
}

@riverpod
List<Expense> filteredExpenses(FilteredExpensesRef ref) {
  final allExpenses = ref.watch(expensesStreamProvider).valueOrNull ?? [];
  final filter = ref.watch(expenseFilterNotifierProvider);

  return allExpenses.where((expense) {
    // Search query matching title, category or notes
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      final matchTitle = expense.title.toLowerCase().contains(query);
      final matchCategory = expense.category.toLowerCase().contains(query);
      final matchNotes = expense.notes.toLowerCase().contains(query);
      if (!matchTitle && !matchCategory && !matchNotes) return false;
    }

    // Category filter
    if (filter.selectedCategory != 'All') {
      if (expense.category.toLowerCase() != filter.selectedCategory.toLowerCase()) {
        return false;
      }
    }

    // Income vs Expense filter
    if (filter.isIncome != null) {
      if (expense.isIncome != filter.isIncome) {
        return false;
      }
    }

    return true;
  }).toList();
}

@riverpod
class ExpensesNotifier extends _$ExpensesNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> addExpense(Expense expense) async {
    state = const AsyncValue.loading();
    final user = ref.read(authStateStreamProvider).valueOrNull;
    if (user == null) return false;

    state = await AsyncValue.guard(() async {
      final repo = ref.read(expensesRepositoryProvider);
      await repo.addExpense(user.uid, expense);
    });
    return !state.hasError;
  }

  Future<bool> updateExpense(Expense expense) async {
    state = const AsyncValue.loading();
    final user = ref.read(authStateStreamProvider).valueOrNull;
    if (user == null) return false;

    state = await AsyncValue.guard(() async {
      final repo = ref.read(expensesRepositoryProvider);
      await repo.updateExpense(user.uid, expense);
    });
    return !state.hasError;
  }

  Future<bool> deleteExpense(String expenseId) async {
    state = const AsyncValue.loading();
    final user = ref.read(authStateStreamProvider).valueOrNull;
    if (user == null) return false;

    state = await AsyncValue.guard(() async {
      final repo = ref.read(expensesRepositoryProvider);
      await repo.deleteExpense(user.uid, expenseId);
    });
    return !state.hasError;
  }

  Future<void> updateBudget(double newBudget) async {
    final user = ref.read(authStateStreamProvider).valueOrNull;
    if (user == null) return;
    final repo = ref.read(expensesRepositoryProvider);
    await repo.updateUserBudget(user.uid, newBudget);
  }
}
