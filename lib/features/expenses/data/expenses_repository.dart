import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpensesRepository {
  final FirebaseFirestore _firestore;

  ExpensesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _expensesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('expenses');
  }

  Stream<List<Expense>> watchExpenses(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    
    return _expensesRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromDocument(doc)).toList();
    });
  }

  Future<void> addExpense(String userId, Expense expense) async {
    if (userId.isEmpty) throw Exception('User not authenticated');
    await _expensesRef(userId).add(expense.toDocument());
  }

  Future<void> updateExpense(String userId, Expense expense) async {
    if (userId.isEmpty) throw Exception('User not authenticated');
    await _expensesRef(userId).doc(expense.id).update(expense.toDocument());
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    if (userId.isEmpty) throw Exception('User not authenticated');
    await _expensesRef(userId).doc(expenseId).delete();
  }

  Stream<double> watchUserBudget(String userId) {
    if (userId.isEmpty) return Stream.value(2500.0);

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 2500.0;
      final data = doc.data();
      return (data?['budgetLimit'] as num?)?.toDouble() ?? 2500.0;
    });
  }

  Future<void> updateUserBudget(String userId, double newBudget) async {
    if (userId.isEmpty) throw Exception('User not authenticated');
    await _firestore.collection('users').doc(userId).set(
      {'budgetLimit': newBudget},
      SetOptions(merge: true),
    );
  }

  Stream<String> watchUserCurrency(String userId) {
    if (userId.isEmpty) return Stream.value('USD');

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 'USD';
      final data = doc.data();
      return data?['currencyCode'] as String? ?? 'USD';
    });
  }

  Future<void> updateUserCurrency(String userId, String currencyCode) async {
    if (userId.isEmpty) throw Exception('User not authenticated');
    await _firestore.collection('users').doc(userId).set(
      {'currencyCode': currencyCode},
      SetOptions(merge: true),
    );
  }
}
