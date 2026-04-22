import 'package:flutter/material.dart';

class TransactionModel {
  final String title;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final int iconCode;
  final Color iconColor;
  final Color iconBackgroundColor;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.iconCode,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  /// Reconstruct IconData at runtime (safe for tree shaking)
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  String get dateSubtitle {
    return "${date.day}/${date.month}/${date.year}";
  }
}
