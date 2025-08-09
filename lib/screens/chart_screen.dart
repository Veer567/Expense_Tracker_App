// lib/screens/chart_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';

enum TimeFilter { week, month, year }

class ChartScreen extends StatefulWidget {
  /// Optional: if provided, ChartScreen will use this list instead of fetching from Firestore.
  /// Each map should contain: 'amount' (num/double), 'category' (String), 'date' (Timestamp or DateTime), optional 'id'
  final List<Map<String, dynamic>>? expenses;

  const ChartScreen({Key? key, this.expenses}) : super(key: key);

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  TimeFilter _selectedFilter = TimeFilter.month;
  List<Map<String, dynamic>> _allExpenses = [];
  bool _loading = true;

  // Shared category colors
  final Map<String, Color> categoryColors = {
    'Food': Colors.orange,
    'Rent': Colors.blue,
    'Shopping': Colors.purple,
    'Travel': Colors.green,
    'Transport': Colors.teal,
    'Bills': Colors.deepOrange,
    'Other': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    if (widget.expenses != null) {
      // Use provided expenses (keep raw date type for normalization later)
      _allExpenses = widget.expenses!.map((e) {
        final amount = (e['amount'] as num).toDouble();
        return {
          'id': e['id'] ?? '',
          'amount': amount,
          'category': e['category'] ?? 'Other',
          'date': e['date'],
        };
      }).toList();
      _loading = false;
    } else {
      _fetchExpenses();
    }
  }

  void _fetchExpenses() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
          setState(() {
            _allExpenses = snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'amount': (data['amount'] as num).toDouble(),
                'category': data['category'] ?? 'Other',
                'date': data['date'], // Firestore Timestamp
              };
            }).toList();
            _loading = false; // ✅ This line fixes the endless spinner
          });
        });
  }

  DateTime _normalizeDate(dynamic dateField) {
    if (dateField is Timestamp) return dateField.toDate();
    if (dateField is DateTime) return dateField;
    // If date is a String, try parsing (optional)
    if (dateField is String)
      return DateTime.tryParse(dateField) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    // fallback
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  List<Map<String, dynamic>> _getFilteredExpenses() {
    final now = DateTime.now();
    Duration range;
    switch (_selectedFilter) {
      case TimeFilter.week:
        range = const Duration(days: 7);
        break;
      case TimeFilter.month:
        range = const Duration(days: 30);
        break;
      case TimeFilter.year:
        range = const Duration(days: 365);
        break;
    }

    return _allExpenses.where((exp) {
      final date = _normalizeDate(exp['date']);
      return date.isAfter(now.subtract(range));
    }).toList();
  }

  void _onFilterChanged(TimeFilter? filter) {
    if (filter != null) {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _getFilteredExpenses();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade300, Colors.indigo.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHeader(filteredExpenses),
                      const SizedBox(height: 16),
                      Expanded(
                        child: filteredExpenses.isEmpty
                            ? _buildEmptyState()
                            : ListView(
                                children: [
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Spending by Category',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 300,
                                    child: BarChartWidget(
                                      expenses: filteredExpenses,
                                      categoryColors: categoryColors,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Category Distribution',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 300,
                                    child: PieChartWidget(
                                      expenses: filteredExpenses,
                                      categoryColors: categoryColors,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Map<String, dynamic>> filteredExpenses) {
    final totalSpent = filteredExpenses.fold<double>(
      0.0,
      (s, it) => s + (it['amount'] as double),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Expense Insights',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            DropdownButton<TimeFilter>(
              dropdownColor: Colors.indigo.shade700,
              value: _selectedFilter,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: const SizedBox(),
              onChanged: _onFilterChanged,
              items: const [
                DropdownMenuItem(
                  value: TimeFilter.week,
                  child: Text('Week', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: TimeFilter.month,
                  child: Text('Month', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: TimeFilter.year,
                  child: Text('Year', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '\$${totalSpent.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'No expenses to display for this period.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo.shade800,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
