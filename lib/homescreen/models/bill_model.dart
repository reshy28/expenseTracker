import 'package:flutter/material.dart';

class BillModel {
  final String title;
  final double amount;
  final String dueDate;
  final String dueInDays;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  BillModel({
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.dueInDays,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}
