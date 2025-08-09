import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController customCategoryController =
      TextEditingController();

  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  bool isSaving = false;

  // Map categories to icons for visual feedback
  final Map<String, IconData> categoryIcons = {
    'Food': Icons.fastfood_outlined,
    'Transport': Icons.directions_bus_outlined,
    'Rent': Icons.home_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Other': Icons.category_outlined,
  };

  List<String> categories = ['Food', 'Transport', 'Rent', 'Shopping', 'Other'];

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .add({
            'title': titleController.text.trim(),
            'amount': double.parse(amountController.text.trim()),
            'category': selectedCategory,
            'date': selectedDate,
          });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade800,
              onPrimary: Colors.white,
              surface: Colors.indigo.shade100,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _addCustomCategory() {
    if (customCategoryController.text.trim().isNotEmpty) {
      setState(() {
        final newCategory = customCategoryController.text.trim();
        if (!categories.contains(newCategory)) {
          categories.add(newCategory);
          categoryIcons[newCategory] = Icons.category_outlined;
        }
        selectedCategory = newCategory;
        customCategoryController.clear();
        Navigator.pop(context); // Close the dialog
      });
    }
  }

  void _showCustomCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom Category'),
        content: TextField(
          controller: customCategoryController,
          decoration: InputDecoration(
            labelText: 'Category Name',
            hintText: 'Enter a new category',
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: Colors.indigo.shade800),
          ),
          style: TextStyle(color: Colors.indigo.shade800),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.indigo.shade800),
            ),
          ),
          ElevatedButton(
            onPressed: _addCustomCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade800,
              foregroundColor: Colors.white,
            ),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade300, Colors.indigo.shade800],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'e.g., Grocery Shopping',
                          prefixIcon: Icon(
                            Icons.description_outlined,
                            color: Colors.white70,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: Colors.white70),
                            onPressed: () => titleController.clear(),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: TextStyle(color: Colors.white70),
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Enter a title'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          hintText: 'e.g., 25.99',
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Colors.white70,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: Colors.white70),
                            onPressed: () => amountController.clear(),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: TextStyle(color: Colors.white70),
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty)
                            return 'Enter an amount';
                          if (double.tryParse(val.trim()) == null)
                            return 'Enter a valid number';
                          if (double.parse(val.trim()) <= 0)
                            return 'Amount must be greater than 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCategory,
                              items: categories
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Row(
                                        children: [
                                          Icon(
                                            categoryIcons[cat],
                                            color: Colors.white70,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            cat,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => selectedCategory = val!),
                              decoration: InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(
                                  Icons.category_outlined,
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                labelStyle: TextStyle(color: Colors.white70),
                              ),
                              style: TextStyle(color: Colors.white),
                              dropdownColor: Colors.indigo.shade700,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: Colors.white70,
                            ),
                            tooltip: 'Add Custom Category',
                            onPressed: _showCustomCategoryDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: TextStyle(color: Colors.white70),
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                        style: TextStyle(color: Colors.white),
                        controller: TextEditingController(
                          text: DateFormat('yyyy-MM-dd').format(selectedDate),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving ? null : _saveExpense,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.indigo.shade800,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                'Save Expense',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white70),
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
