import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.tryParse(json) ?? DateTime.now();
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime object) => Timestamp.fromDate(object);
}

@freezed
class Expense with _$Expense {
  const Expense._();

  const factory Expense({
    required String id,
    required String title,
    required double amount,
    required String category,
    @TimestampConverter() required DateTime date,
    @Default(false) bool isIncome,
    @Default(false) bool isRecurring,
    @Default('') String notes,
    @Default('') String paymentMethod,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

  factory Expense.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Expense.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toDocument() {
    final map = toJson();
    map.remove('id'); // ID is the document path ID in Firestore
    return map;
  }
}
