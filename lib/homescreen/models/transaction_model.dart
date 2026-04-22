import 'package:flutter/material.dart';
import '../../root/utils/app_icons.dart';

class TransactionModel {
  final String id;
  final String title;
  final String dateSubtitle;
  final DateTime date;
  final double amount;
  final String iconName;
  final Color iconBackgroundColor;
  final Color iconColor;
  final bool isExpense;
  final String? description;
  final String? accountId;
  final String? accountName;
  final String? categoryId;
  final String? categoryName;

  TransactionModel({
    required this.id,
    required this.title,
    required this.dateSubtitle,
    required this.date,
    required this.amount,
    required this.iconName,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.isExpense = true,
    this.description,
    this.accountId,
    this.accountName,
    this.categoryId,
    this.categoryName,
  });

  /// Reconstruct IconData at runtime (safe for tree shaking)
  IconData get icon => AppIcons.get(iconName);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateSubtitle': dateSubtitle,
      'date': date.toIso8601String(),
      'amount': amount,
      'iconName': iconName,
      'iconBackgroundColor': iconBackgroundColor.value,
      'iconColor': iconColor.value,
      'isExpense': isExpense,
      'description': description,
      'accountId': accountId,
      'accountName': accountName,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return TransactionModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      dateSubtitle: map['dateSubtitle'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      amount: (map['amount'] ?? 0.0).toDouble(),
      iconName: map['iconName'] ?? map['iconCode']?.toString() ?? 'category',
      iconBackgroundColor: Color(map['iconBackgroundColor'] ?? 0xFFFFFFFF),
      iconColor: Color(map['iconColor'] ?? 0xFF000000),
      isExpense: map['isExpense'] ?? true,
      description: map['description'],
      accountId: map['accountId'],
      accountName: map['accountName'],
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
    );
  }
}
