import 'package:flutter/material.dart';
import '../../root/utils/app_icons.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final Color backgroundColor;
  final Color iconColor;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.backgroundColor,
    required this.iconColor,
  });

  IconData get icon => AppIcons.get(iconName);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'backgroundColor': backgroundColor.value,
      'iconColor': iconColor.value,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconName: map['iconName'] ?? map['iconCode']?.toString() ?? 'category',
      backgroundColor: Color(map['backgroundColor'] ?? 0xFFFFFFFF),
      iconColor: Color(map['iconColor'] ?? 0xFF000000),
    );
  }
}
