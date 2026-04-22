import 'package:flutter/material.dart';
import '../../root/utils/app_icons.dart';

class BillModel {
  final String title;
  final double amount;
  final String dueDate;
  final String dueInDays;
  final String iconName;
  final Color backgroundColor;
  final Color iconColor;

  BillModel({
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.dueInDays,
    required this.iconName,
    required this.backgroundColor,
    required this.iconColor,
  });

  /// Reconstruct IconData at runtime (safe for tree shaking)
  IconData get icon => AppIcons.get(iconName);
}

