// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: const TimestampConverter().fromJson(json['date']),
      isIncome: json['isIncome'] as bool? ?? false,
      isRecurring: json['isRecurring'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'category': instance.category,
      'date': const TimestampConverter().toJson(instance.date),
      'isIncome': instance.isIncome,
      'isRecurring': instance.isRecurring,
      'notes': instance.notes,
      'paymentMethod': instance.paymentMethod,
    };
