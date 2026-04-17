import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFAFAFC);
  static const Color cardDarkBackground = Color(0xFF1E243B);
  static const Color primaryPurple = Color(0xFF5544FF);
  static const Color primaryPurpleLight = Color(0x225544FF);
  static const Color progressOrange = Color(0xFFFF7A00);
  static const Color progressRemaining = Color(0xFF333E5D);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGray = Color(0xFF888888);

  static const Color foodBg = Color(0xFFFFF0E0);
  static const Color foodIcon = Color(0xFFFF7A00);
  static const Color transportBg = Color(0xFFE4EFFF);
  static const Color transportIcon = Color(0xFF3388FF);
  static const Color shoppingBg = Color(0xFFF3E2FF);
  static const Color shoppingIcon = Color(0xFFAA33FF);
  static const Color billsBg = Color(0xFFFFF7DB);
  static const Color billsIcon = Color(0xFFFFD300);

  static const Color rentBg = Color(0xFFEEF0FF);
  static const Color rentIcon = Color(0xFF5544FF);
  static const Color gymBg = Color(0xFFFFEEEE);
  static const Color gymIcon = Color(0xFFFF4861);
  static const Color internetBg = Color(0xFFFFF7DB);
  static const Color internetIcon = Color(0xFFFFD300);

  static const Color greenLight = Color(0xFFECF9F1);
  static const Color greenDark = Color(0xFF1ABC9C);
  static const Color incomeBg = Color(0xFFECF9F1);
  static const Color incomeText = Color(0xFF1ABC9C);
  static const Color redLight = Color(0xFFFFF0F0);
  static const Color redAlertText = Color(0xFFFF3B30);
  static const Color orangeAlertText = Color(0xFFFF7A00);

  // Premium UI Tokens
  static const Color cardShadow = Color(0x0A000000);
  static const Color softBorder = Color(0xFFF0F0F5);
  static const Color glassWhite = Color(0xAAFFFFFF);
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, Color(0xFF7066FF)],
  );

  static BoxDecoration premiumCardDecoration = BoxDecoration(
    color: textLight,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: softBorder),
    boxShadow: [
      BoxShadow(
        color: cardShadow,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
