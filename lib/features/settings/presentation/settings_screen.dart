import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/providers/expenses_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    double currentBudget,
    String currencySymbol,
  ) {
    final controller = TextEditingController(
      text: currentBudget.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Set Monthly Budget Limit'),
          content: CustomTextField(
            controller: controller,
            label: 'Monthly Limit ($currencySymbol)',
            hint: '2500',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newBudget =
                    double.tryParse(controller.text) ?? currentBudget;
                ref
                    .read(expensesNotifierProvider.notifier)
                    .updateBudget(newBudget);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _openCurrencyPicker(BuildContext context, WidgetRef ref) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      theme: CurrencyPickerThemeData(
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      onSelect: (Currency currency) {
        ref.read(currencyNotifierProvider.notifier).setCurrency(currency);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateStreamProvider).valueOrNull;
    final themeMode = ref.watch(themeNotifierProvider);
    final budget = ref.watch(userBudgetStreamProvider).valueOrNull ?? 2500.0;
    final currentCurrency = ref.watch(currencyNotifierProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryIndigo.withValues(
                      alpha: 0.15,
                    ),
                    child: const Icon(
                      LucideIcons.user,
                      color: AppColors.primaryIndigo,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email ?? 'Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Preferences & Controls',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Settings Tile Options
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  // Dark Mode Switch
                  ListTile(
                    leading: const Icon(LucideIcons.moon, size: 22),
                    title: const Text(
                      'Dark Theme',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (val) {
                        ref
                            .read(themeNotifierProvider.notifier)
                            .toggleTheme(val);
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Budget Limit Editor
                  ListTile(
                    leading: const Icon(LucideIcons.target, size: 22),
                    title: const Text(
                      'Monthly Budget Limit',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${currentCurrency.symbol}${budget.toStringAsFixed(0)}',
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18),
                    onTap: () => _showBudgetDialog(
                      context,
                      ref,
                      budget,
                      currentCurrency.symbol,
                    ),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Currency Selector using currency_picker
                  ListTile(
                    leading: const Icon(LucideIcons.globe, size: 22),
                    title: const Text(
                      'Primary Currency',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${currentCurrency.flag} ${currentCurrency.code} (${currentCurrency.symbol}) - ${currentCurrency.name}',
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, size: 18),
                    onTap: () => _openCurrencyPicker(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Sign Out Button
            CustomButton(
              text: 'Sign Out',
              isSecondary: true,
              icon: LucideIcons.logOut,
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
