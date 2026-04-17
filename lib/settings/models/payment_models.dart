import 'package:flutter/material.dart';

class FixedExpenseModel {
  final String id;
  final String name;
  final double amount;
  final String? accountId; // The account intended for payment
  final int dueDay; // Day of the month (1-31)
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  FixedExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    this.accountId,
    required this.dueDay,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'accountId': accountId,
      'dueDay': dueDay,
      'iconCode': icon.codePoint,
      'backgroundColor': backgroundColor.value,
      'iconColor': iconColor.value,
    };
  }

  factory FixedExpenseModel.fromMap(Map<String, dynamic> map) {
    return FixedExpenseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      accountId: map['accountId'],
      dueDay: map['dueDay'] ?? 1,
      icon: IconData(map['iconCode'] ?? 0xe0b0, fontFamily: 'MaterialIcons'),
      backgroundColor: Color(map['backgroundColor'] ?? 0xFFFFFFFF),
      iconColor: Color(map['iconColor'] ?? 0xFF000000),
    );
  }

  DateTime get nextDueDate {
    final now = DateTime.now();
    DateTime dueDate = DateTime(now.year, now.month, dueDay);

    // If the due day has passed this month, the next one is next month
    if (dueDate.isBefore(DateTime(now.year, now.month, now.day))) {
      dueDate = DateTime(now.year, now.month + 1, dueDay);
    }
    return dueDate;
  }

  int get daysUntilDue {
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return nextDueDate.difference(now).inDays;
  }
}

class BudgetModel {
  final double amount;
  final String? accountId;

  BudgetModel({required this.amount, this.accountId});

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'accountId': accountId,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      amount: (map['amount'] ?? 0.0).toDouble(),
      accountId: map['accountId'],
    );
  }
}

class SalaryExpenseModel {
  final String id;
  final String name;
  final double amount;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final DateTime dateAdded;

  SalaryExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'iconCode': icon.codePoint,
      'backgroundColor': backgroundColor.value,
      'iconColor': iconColor.value,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory SalaryExpenseModel.fromMap(Map<String, dynamic> map) {
    return SalaryExpenseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      icon: IconData(map['iconCode'] ?? 0xe0b0, fontFamily: 'MaterialIcons'),
      backgroundColor: Color(map['backgroundColor'] ?? 0xFFFFFFFF),
      iconColor: Color(map['iconColor'] ?? 0xFF000000),
      dateAdded: DateTime.parse(
          map['dateAdded'] ?? DateTime.now().toIso8601String()),
    );
  }
}
