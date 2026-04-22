import 'package:flutter/material.dart';
import '../../root/utils/app_icons.dart';

class EmiModel {
  final String id;
  final String title;
  final double monthlyAmount;
  final double totalAmount;
  final int totalMonths;
  final int monthsPaid;
  final DateTime nextPaymentDate;
  final String iconName;
  final Color color;
  final String ownerName; // Who this EMI is for (Self, Friend Name, etc.)
  final String? accountId; // Linked account for payments
  final String? categoryId; // Linked category
  final double downpayment;
  final bool isNewPurchase;
  final String? downpaymentAccountId;

  EmiModel({
    required this.id,
    required this.title,
    required this.monthlyAmount,
    required this.totalAmount,
    required this.totalMonths,
    required this.monthsPaid,
    required this.nextPaymentDate,
    required this.iconName,
    required this.color,
    this.ownerName = 'Self',
    this.accountId,
    this.categoryId,
    this.downpayment = 0.0,
    this.isNewPurchase = false,
    this.downpaymentAccountId,
  });

  /// Reconstruct IconData at runtime (safe for tree shaking)
  IconData get icon => AppIcons.get(iconName);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'monthlyAmount': monthlyAmount,
      'totalAmount': totalAmount,
      'totalMonths': totalMonths,
      'monthsPaid': monthsPaid,
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'iconName': iconName,
      'color': color.value,
      'ownerName': ownerName,
      'accountId': accountId,
      'categoryId': categoryId,
      'downpayment': downpayment,
      'isNewPurchase': isNewPurchase,
      'downpaymentAccountId': downpaymentAccountId,
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
      iconName: map['iconName'] ?? map['iconCode']?.toString() ?? 'pie_chart',
      color: Color(map['color'] ?? 0xFF000000),
      ownerName: map['ownerName'] ?? 'Self',
      accountId: map['accountId'],
      categoryId: map['categoryId'],
      downpayment: (map['downpayment'] ?? 0.0).toDouble(),
      isNewPurchase: map['isNewPurchase'] ?? false,
      downpaymentAccountId: map['downpaymentAccountId'],
    );
  }

  double get percentagePaid => monthsPaid / totalMonths;
  double get amountLeft => totalAmount - (monthlyAmount * monthsPaid);
  int get monthsLeft => totalMonths - monthsPaid;

  DateTime get endDate {
    if (monthsLeft > 0) {
      return DateTime(
        nextPaymentDate.year,
        nextPaymentDate.month + (monthsLeft - 1),
        nextPaymentDate.day,
      );
    }
    return nextPaymentDate;
  }

  EmiModel copyWith({
    String? id,
    String? title,
    double? monthlyAmount,
    double? totalAmount,
    int? totalMonths,
    int? monthsPaid,
    DateTime? nextPaymentDate,
    String? iconName,
    Color? color,
    String? ownerName,
    String? accountId,
    String? categoryId,
    double? downpayment,
    bool? isNewPurchase,
    String? downpaymentAccountId,
  }) {
    return EmiModel(
      id: id ?? this.id,
      title: title ?? this.title,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      totalMonths: totalMonths ?? this.totalMonths,
      monthsPaid: monthsPaid ?? this.monthsPaid,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      ownerName: ownerName ?? this.ownerName,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      downpayment: downpayment ?? this.downpayment,
      isNewPurchase: isNewPurchase ?? this.isNewPurchase,
      downpaymentAccountId: downpaymentAccountId ?? this.downpaymentAccountId,
    );
  }
}
