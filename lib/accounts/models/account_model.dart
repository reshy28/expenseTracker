import 'package:flutter/material.dart';

enum AccountType { bank, credit, cash }

class AccountModel {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final double? limit;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.limit,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance': balance,
      'limit': limit,
      'iconCode': icon.codePoint,
      'iconColor': iconColor.value,
      'backgroundColor': backgroundColor.value,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'bank'),
        orElse: () => AccountType.bank,
      ),
      balance: (map['balance'] ?? 0.0).toDouble(),
      limit: map['limit']?.toDouble(),
      icon: IconData(map['iconCode'] ?? 0xe0b0, fontFamily: 'MaterialIcons'),
      iconColor: Color(map['iconColor'] ?? 0xFF000000),
      backgroundColor: Color(map['backgroundColor'] ?? 0xFFFFFFFF),
    );
  }

  String get typeLabel {
    switch (type) {
      case AccountType.bank:
        return 'BANK ACCOUNT';
      case AccountType.credit:
        return 'CREDIT CARD';
      case AccountType.cash:
        return 'CASH';
    }
  }
}
