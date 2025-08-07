import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isRecurring;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isRecurring,
  });

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isRecurring': isRecurring,
    };
  }

  // Create from Firestore Document
  factory Expense.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      title: data['title'],
      amount: data['amount']?.toDouble() ?? 0.0,
      category: data['category'],
      date: (data['date'] as Timestamp).toDate(),
      isRecurring: data['isRecurring'] ?? false,
    );
  }
}
