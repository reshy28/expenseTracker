import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../root/utils/currency_util.dart';
import '../../../root/controllers/navigation_controller.dart';

import '../../models/transaction_model.dart';
import '../app_colors.dart';

class RecentTransactions extends StatelessWidget {
  final List<TransactionModel> transactions;

  const RecentTransactions({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<NavigationController>(
                  context,
                  listen: false,
                ).setIndex(1);
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...transactions.take(5).map((transaction) {
          return InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              transaction.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'TRANSACTION NOTE',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          transaction.description ?? 'No note added',
                          style: TextStyle(
                            color: transaction.description != null
                                ? AppColors.textDark
                                : AppColors.textGray.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: transaction.description != null
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: AppColors.premiumCardDecoration,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: transaction.iconBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      transaction.icon,
                      color: transaction.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.dateSubtitle,
                              style: TextStyle(
                                color: AppColors.textGray.withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (transaction.accountName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                "BANK: ${transaction.accountName!.toUpperCase()}",
                                style: TextStyle(
                                  color: AppColors.textGray.withOpacity(0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${transaction.isExpense ? '-' : '+'}${CurrencyUtil.format(transaction.amount)}',
                    style: TextStyle(
                      color: transaction.isExpense
                          ? AppColors.redAlertText
                          : AppColors.greenDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
