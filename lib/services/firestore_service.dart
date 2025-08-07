import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user UID
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // Collection reference
  CollectionReference get _expenses =>
      _db.collection('users').doc(uid).collection('expenses');

  // Add Expense
  Future<void> addExpense(Expense expense) async {
    await _expenses.add(expense.toMap());
  }

  // Update Expense
  Future<void> updateExpense(String id, Expense updated) async {
    await _expenses.doc(id).update(updated.toMap());
  }

  // Delete Expense
  Future<void> deleteExpense(String id) async {
    await _expenses.doc(id).delete();
  }

  // Get expenses as a stream
  Stream<List<Expense>> getExpenses() {
    return _expenses.orderBy('date', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) => Expense.fromDocument(doc)).toList();
      },
    );
  }

  // Optional: Filter by category or date
  Stream<List<Expense>> getExpensesByCategory(String category) {
    return _expenses.where('category', isEqualTo: category).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Expense.fromDocument(doc))
              .toList(),
        );
  }
}
