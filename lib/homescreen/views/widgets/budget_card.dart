import 'package:mtracker/root/utils/currency_util.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';

class BudgetCard extends StatelessWidget {
  final double spent;
  final double total;

  const BudgetCard({super.key, required this.spent, required this.total});

  @override
  Widget build(BuildContext context) {
    double percentage = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    bool isOverBudget = spent > total && total > 0;
    double left = total - spent;
    int percentageInt = (percentage * 100).toInt();

    // Use precision formatting for a cleaner look (no decimals)
    String spentStr = CurrencyUtil.formatWithPrecision(spent, decimals: 0);
    String totalStr = CurrencyUtil.formatWithPrecision(total, decimals: 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDarkBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardDarkBackground.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONTHLY BUDGET',
                style: TextStyle(
                  color: AppColors.textGray.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOverBudget ? Icons.warning_amber_rounded : Icons.account_balance_wallet_outlined,
                  color: isOverBudget ? AppColors.redAlertText : AppColors.textLight,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                spentStr,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '/ $totalStr',
                  style: TextStyle(
                    color: AppColors.textGray.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOverBudget ? 'Budget Exceeded' : '$percentageInt% Spent',
                style: TextStyle(
                  color: isOverBudget ? AppColors.redAlertText : AppColors.textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                isOverBudget 
                    ? '${CurrencyUtil.formatWithPrecision(left.abs(), decimals: 0)} overspent' 
                    : '${CurrencyUtil.formatWithPrecision(left, decimals: 0)} left',
                style: TextStyle(
                  color: isOverBudget ? AppColors.redAlertText : AppColors.progressOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.progressRemaining,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOverBudget 
                          ? [AppColors.redAlertText, const Color(0xFFFF6B6B)]
                          : [AppColors.progressOrange, const Color(0xFFFFAA33)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: (isOverBudget ? AppColors.redAlertText : AppColors.progressOrange).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
