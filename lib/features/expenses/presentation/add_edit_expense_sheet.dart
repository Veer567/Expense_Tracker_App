import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_categories.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/expense_model.dart';
import '../providers/expenses_provider.dart';

class AddEditExpenseSheet extends ConsumerStatefulWidget {
  final Expense? expenseToEdit;

  const AddEditExpenseSheet({
    super.key,
    this.expenseToEdit,
  });

  @override
  ConsumerState<AddEditExpenseSheet> createState() => _AddEditExpenseSheetState();
}

class _AddEditExpenseSheetState extends ConsumerState<AddEditExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  late String _selectedCategory;
  late DateTime _selectedDate;
  late bool _isIncome;
  late bool _isRecurring;

  @override
  void initState() {
    super.initState();
    final edit = widget.expenseToEdit;

    _titleController = TextEditingController(text: edit?.title ?? '');
    _amountController = TextEditingController(
        text: edit != null ? edit.amount.toStringAsFixed(2) : '');
    _notesController = TextEditingController(text: edit?.notes ?? '');

    _selectedCategory = edit?.category ?? 'Food & Dining';
    _selectedDate = edit?.date ?? DateTime.now();
    _isIncome = edit?.isIncome ?? false;
    _isRecurring = edit?.isRecurring ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final expense = Expense(
      id: widget.expenseToEdit?.id ?? '',
      title: _titleController.text.trim(),
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      isIncome: _isIncome,
      isRecurring: _isRecurring,
      notes: _notesController.text.trim(),
    );

    final notifier = ref.read(expensesNotifierProvider.notifier);
    final bool success;

    if (widget.expenseToEdit != null) {
      success = await notifier.updateExpense(expense);
    } else {
      success = await notifier.addExpense(expense);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.expenseToEdit != null;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 16,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Handle Indicator Bar
              Center(
                child: Container(
                  width: 38,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Type Switch Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Transaction' : 'New Transaction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  // Income vs Expense Segment Switcher
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isIncome = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: !_isIncome ? AppColors.expenseRed : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !_isIncome ? Colors.white : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isIncome = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isIncome ? AppColors.incomeGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              'Income',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isIncome ? Colors.white : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title Input
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g. Grocery Store, Netflix, Salary',
                prefixIcon: LucideIcons.tag,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter title' : null,
              ),
              const SizedBox(height: 16),

              // Amount Input
              CustomTextField(
                controller: _amountController,
                label: 'Amount (${ref.watch(currencyNotifierProvider).symbol})',
                hint: '0.00',
                prefixIcon: LucideIcons.dollarSign,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter amount';
                  if (double.tryParse(val) == null) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector Chips
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppCategories.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = AppCategories.categories[index];
                    final isSelected = _selectedCategory == cat.name;

                    return ChoiceChip(
                      label: Row(
                        children: [
                          Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.color),
                          const SizedBox(width: 6),
                          Text(cat.name),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: cat.color,
                      backgroundColor: theme.colorScheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat.name),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Date Picker & Recurring Toggle
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.calendar, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    avatar: const Icon(LucideIcons.repeat, size: 14),
                    label: const Text('Recurring'),
                    selected: _isRecurring,
                    onSelected: (val) => setState(() => _isRecurring = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes Input
              CustomTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Additional notes or receipt tag',
                prefixIcon: LucideIcons.fileText,
              ),
              const SizedBox(height: 28),

              // Save Button
              CustomButton(
                text: isEditing ? 'Update Transaction' : 'Add Transaction',
                onPressed: _saveExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
