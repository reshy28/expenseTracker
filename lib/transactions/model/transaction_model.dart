import 'package:flutter/material.dart';

class TransactionModel {
  final String title;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  String get dateSubtitle {
    return "${date.day}/${date.month}/${date.year}";
  }
}
