import 'package:currency_picker/currency_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/expenses/providers/expenses_provider.dart';

final Currency defaultCurrency = CurrencyService().findByCode('USD') ??
    Currency(
      code: 'USD',
      name: 'United States Dollar',
      symbol: '\$',
      flag: '🇺🇸',
      number: 840,
      decimalDigits: 2,
      namePlural: 'US dollars',
      symbolOnLeft: true,
      decimalSeparator: '.',
      thousandsSeparator: ',',
      spaceBetweenAmountAndSymbol: false,
    );

final userCurrencyStreamProvider = StreamProvider<String>((ref) {
  final user = ref.watch(authStateStreamProvider).valueOrNull;
  if (user == null) return Stream.value('USD');
  final repo = ref.watch(expensesRepositoryProvider);
  return repo.watchUserCurrency(user.uid);
});

class CurrencyNotifier extends StateNotifier<Currency> {
  final Ref _ref;
  CurrencyNotifier(this._ref) : super(defaultCurrency) {
    _ref.listen<AsyncValue<String>>(userCurrencyStreamProvider, (previous, next) {
      final code = next.valueOrNull ?? 'USD';
      final currency = CurrencyService().findByCode(code);
      if (currency != null && currency != state) {
        state = currency;
      }
    });
  }

  Future<void> setCurrency(Currency currency) async {
    state = currency;
    final user = _ref.read(authStateStreamProvider).valueOrNull;
    if (user != null) {
      final repo = _ref.read(expensesRepositoryProvider);
      await repo.updateUserCurrency(user.uid, currency.code);
    }
  }
}

final currencyNotifierProvider =
    StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier(ref);
});
