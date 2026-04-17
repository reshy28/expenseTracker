import 'package:flutter/material.dart';

class TransactionModel {
  final String title;
  final String dateSubtitle;
  final DateTime date;
  final double amount;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final bool isExpense;

  TransactionModel({
    required this.title,
    required this.dateSubtitle,
    required this.date,
    required this.amount,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.isExpense = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateSubtitle': dateSubtitle,
      'date': date.toIso8601String(),
      'amount': amount,
      'iconCode': icon.codePoint,
      'iconBackgroundColor': iconBackgroundColor.value,
      'iconColor': iconColor.value,
      'isExpense': isExpense,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      title: map['title'] ?? '',
      dateSubtitle: map['dateSubtitle'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      amount: (map['amount'] ?? 0.0).toDouble(),
      icon: IconData(map['iconCode'] ?? 0xe0b0, fontFamily: 'MaterialIcons'),
      iconBackgroundColor: Color(map['iconBackgroundColor'] ?? 0xFFFFFFFF),
      iconColor: Color(map['iconColor'] ?? 0xFF000000),
      isExpense: map['isExpense'] ?? true,
    );
  }
}
