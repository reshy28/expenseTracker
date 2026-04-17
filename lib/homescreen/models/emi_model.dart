import 'package:flutter/material.dart';

class EmiModel {
  final String id;
  final String title;
  final double monthlyAmount;
  final double totalAmount;
  final int totalMonths;
  final int monthsPaid;
  final DateTime nextPaymentDate;
  final IconData icon;
  final Color color;
  final String ownerName; // Who this EMI is for (Self, Friend Name, etc.)
  final String? accountId; // Linked account for payments
  final String? categoryId; // Linked category

  EmiModel({
    required this.id,
    required this.title,
    required this.monthlyAmount,
    required this.totalAmount,
    required this.totalMonths,
    required this.monthsPaid,
    required this.nextPaymentDate,
    required this.icon,
    required this.color,
    this.ownerName = 'Self',
    this.accountId,
    this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'monthlyAmount': monthlyAmount,
      'totalAmount': totalAmount,
      'totalMonths': totalMonths,
      'monthsPaid': monthsPaid,
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'iconCode': icon.codePoint,
      'color': color.value,
      'ownerName': ownerName,
      'accountId': accountId,
      'categoryId': categoryId,
    };
  }

  factory EmiModel.fromMap(Map<String, dynamic> map) {
    return EmiModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      monthlyAmount: (map['monthlyAmount'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      totalMonths: map['totalMonths'] ?? 0,
      monthsPaid: map['monthsPaid'] ?? 0,
      nextPaymentDate: DateTime.parse(
          map['nextPaymentDate'] ?? DateTime.now().toIso8601String()),
      icon: IconData(map['iconCode'] ?? 0xe0b0, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] ?? 0xFF000000),
      ownerName: map['ownerName'] ?? 'Self',
      accountId: map['accountId'],
      categoryId: map['categoryId'],
    );
  }

  double get percentagePaid => monthsPaid / totalMonths;
  double get amountLeft => totalAmount - (monthlyAmount * monthsPaid);
  int get monthsLeft => totalMonths - monthsPaid;

  EmiModel copyWith({
    String? id,
    String? title,
    double? monthlyAmount,
    double? totalAmount,
    int? totalMonths,
    int? monthsPaid,
    DateTime? nextPaymentDate,
    IconData? icon,
    Color? color,
    String? ownerName,
    String? accountId,
    String? categoryId,
  }) {
    return EmiModel(
      id: id ?? this.id,
      title: title ?? this.title,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      totalMonths: totalMonths ?? this.totalMonths,
      monthsPaid: monthsPaid ?? this.monthsPaid,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      ownerName: ownerName ?? this.ownerName,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
