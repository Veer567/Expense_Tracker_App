import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('expenses')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data?.docs ?? [];

          if (expenses.isEmpty) {
            return const Center(child: Text("No expenses found."));
          }

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final doc = expenses[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title'] ?? '';
              final amount = data['amount'] ?? 0.0;
              final category = data['category'] ?? '';
              final date = (data['date'] as Timestamp).toDate();

              return ListTile(
                leading: CircleAvatar(child: Text(category[0])),
                title: Text(title),
                subtitle: Text(
                  '${category.toUpperCase()} - ${date.toLocal().toString().split(" ")[0]}',
                ),
                trailing: Text('\$${amount.toStringAsFixed(2)}'),
                onTap: () {
                  // Later: navigate to EditExpenseScreen
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to AddExpenseScreen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
