import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final double amount;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  CategoryModel({
    required this.name,
    required this.amount,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'iconCode': icon.codePoint,
      'backgroundColor': backgroundColor.value,
      'iconColor': iconColor.value,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      icon: IconData(map['iconCode'] ?? 0xe0b0, fontFamily: 'MaterialIcons'),
      backgroundColor: Color(map['backgroundColor'] ?? 0xFFFFFFFF),
      iconColor: Color(map['iconColor'] ?? 0xFF000000),
    );
  }
}
