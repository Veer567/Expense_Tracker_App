import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditExpenseScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> expenseData;

  const EditExpenseScreen({
    super.key,
    required this.docId,
    required this.expenseData,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController customCategoryController;

  late String selectedCategory;
  late DateTime selectedDate;
  bool isSaving = false;
  bool isDeleting = false;

  // Map categories to icons (consistent with AddExpenseScreen and HomeScreen)
  final Map<String, IconData> categoryIcons = {
    'Food': Icons.fastfood_outlined,
    'Transport': Icons.directions_bus_outlined,
    'Rent': Icons.home_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Other': Icons.category_outlined,
  };

  List<String> categories = ['Food', 'Transport', 'Rent', 'Shopping', 'Other'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    titleController = TextEditingController(
      text: widget.expenseData['title'] ?? '',
    );
    amountController = TextEditingController(
      text: widget.expenseData['amount']?.toStringAsFixed(2) ?? '0.00',
    );
    customCategoryController = TextEditingController();
    selectedCategory = widget.expenseData['category'] ?? 'Other';
    selectedDate = (widget.expenseData['date'] as Timestamp).toDate();

    // Add custom category if it exists but isn't in the default list
    if (!categories.contains(selectedCategory)) {
      categories.add(selectedCategory);
      categoryIcons[selectedCategory] = Icons.category_outlined;
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .doc(widget.docId)
          .update({
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

  Future<void> _deleteExpense() async {
    setState(() => isDeleting = true);

    final String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .doc(widget.docId)
          .delete();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isDeleting = false);
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
                        'Edit Expense',
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
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.white70,
                              ),
                              SizedBox(width: 12),
                              Text(
                                DateFormat('yyyy-MM-dd').format(selectedDate),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving || isDeleting
                                  ? null
                                  : _saveExpense,
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
                                'Save Changes',
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
                              onPressed: isSaving || isDeleting
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
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: isSaving || isDeleting
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Expense'),
                                    content: Text(
                                      'Are you sure you want to delete this expense?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.indigo.shade800,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: _deleteExpense,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        child: Text(
                          'Delete Expense',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isSaving || isDeleting)
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
