import 'package:flutter/material.dart';
import '../../root/utils/app_icons.dart';

class CategoryModel {
  final String name;
  final double amount;
  final String iconName;
  final Color backgroundColor;
  final Color iconColor;

  CategoryModel({
    required this.name,
    required this.amount,
    required this.iconName,
    required this.backgroundColor,
    required this.iconColor,
  });

  /// Reconstruct IconData at runtime (safe for tree shaking)
  IconData get icon => AppIcons.get(iconName);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'iconName': iconName,
      'backgroundColor': backgroundColor.value,
      'iconColor': iconColor.value,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      iconName: map['iconName'] ?? map['iconCode']?.toString() ?? 'category',
      backgroundColor: Color(map['backgroundColor'] ?? 0xFFFFFFFF),
      iconColor: Color(map['iconColor'] ?? 0xFF000000),
    );
  }
}

