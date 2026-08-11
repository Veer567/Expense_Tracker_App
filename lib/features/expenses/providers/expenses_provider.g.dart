// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expensesRepositoryHash() =>
    r'e053d16a4f1e05f34fc1eefc0e6ca417a88acc12';

/// See also [expensesRepository].
@ProviderFor(expensesRepository)
final expensesRepositoryProvider =
    AutoDisposeProvider<ExpensesRepository>.internal(
      expensesRepository,
      name: r'expensesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expensesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpensesRepositoryRef = AutoDisposeProviderRef<ExpensesRepository>;
String _$expensesStreamHash() => r'8581b833a0f91542276e83fa57bb6de6f2eb17b0';

/// See also [expensesStream].
@ProviderFor(expensesStream)
final expensesStreamProvider =
    AutoDisposeStreamProvider<List<Expense>>.internal(
      expensesStream,
      name: r'expensesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expensesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpensesStreamRef = AutoDisposeStreamProviderRef<List<Expense>>;
String _$userBudgetStreamHash() => r'1c795a00e0946e035e3897741de82c3867163730';

/// See also [userBudgetStream].
@ProviderFor(userBudgetStream)
final userBudgetStreamProvider = AutoDisposeStreamProvider<double>.internal(
  userBudgetStream,
  name: r'userBudgetStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userBudgetStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserBudgetStreamRef = AutoDisposeStreamProviderRef<double>;
String _$filteredExpensesHash() => r'e5993ebaf7cde6165f2a12e964822c933f810a1d';

/// See also [filteredExpenses].
@ProviderFor(filteredExpenses)
final filteredExpensesProvider = AutoDisposeProvider<List<Expense>>.internal(
  filteredExpenses,
  name: r'filteredExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredExpensesRef = AutoDisposeProviderRef<List<Expense>>;
String _$expenseFilterNotifierHash() =>
    r'923a6d6c0cd73971e08e73356117b4ed156ec80a';

/// See also [ExpenseFilterNotifier].
@ProviderFor(ExpenseFilterNotifier)
final expenseFilterNotifierProvider =
    AutoDisposeNotifierProvider<
      ExpenseFilterNotifier,
      ExpenseFilterState
    >.internal(
      ExpenseFilterNotifier.new,
      name: r'expenseFilterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseFilterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExpenseFilterNotifier = AutoDisposeNotifier<ExpenseFilterState>;
String _$expensesNotifierHash() => r'b8b177afa65c41351f0eb6e5a8924c0a9ae49bbd';

/// See also [ExpensesNotifier].
@ProviderFor(ExpensesNotifier)
final expensesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ExpensesNotifier, void>.internal(
      ExpensesNotifier.new,
      name: r'expensesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expensesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExpensesNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
