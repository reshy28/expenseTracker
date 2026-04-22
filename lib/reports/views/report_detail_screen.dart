import 'package:mtracker/root/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../homescreen/views/app_colors.dart';
import '../../root/utils/currency_util.dart';
import '../../transactions/controllers/transactions_controller.dart';
import '../../categories/controllers/category_controller.dart';
import '../../root/services/firebase_service.dart';
import '../../settings/models/payment_models.dart';
import '../models/report_model.dart';
import '../services/pdf_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSalaryLoading = true;
  double _monthlyBudget = 0.0;
  List<FixedExpenseModel> _salaryFixedExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadSalaryForMonth();
  }

  Future<void> _loadSalaryForMonth() async {
    // Fetch global budget
    final config = await _firestoreService.getSalaryConfig().first;

    // Fetch global fixed expenses
    final allFixed = await _firestoreService.getFixedExpenses().first;

    setState(() {
      _monthlyBudget = (config['salaryAmount'] ?? 0.0).toDouble();

      if (config.containsKey('salaryFixedExpenseIds')) {
        final ids = List<String>.from(config['salaryFixedExpenseIds']);
        _salaryFixedExpenses = allFixed
            .where((e) => ids.contains(e.id))
            .toList();
      }

      _isSalaryLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSalaryLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryPurple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<TransactionsController, CategoryController>(
          builder: (context, txController, catController, _) {
            // 1. Calculate Budget (Use the historical budget we just loaded)
            final totalBudget = _monthlyBudget;

            final monthlyTransactions = txController.displayedTransactions
                .where((tx) {
                  final isInMonth =
                      tx.date.year == widget.report.date.year &&
                      tx.date.month == widget.report.date.month;
                  // Filter out Fixed Expenses/Bills from the bottom list
                  final isFixed =
                      tx.categoryName?.toLowerCase().contains('emi') == true ||
                      tx.categoryName?.toLowerCase().contains('bill') == true;
                  return isInMonth && !isFixed;
                })
                .toList();

            final variableExpenses = monthlyTransactions
                .where((tx) => tx.isExpense)
                .fold(0.0, (sum, tx) => sum + tx.amount);

            // 3. Totals
            final fixedExpensesTotal = _salaryFixedExpenses.fold(
              0.0,
              (sum, e) => sum + e.amount,
            );

            final totalSpent = variableExpenses + fixedExpensesTotal;
            final remaining = totalBudget - totalSpent;
            final isExceeded = remaining < 0;

            // 4. Group by Category for Breakdown
            final categoryAggregates = <String, Map<String, dynamic>>{};
            for (var tx in monthlyTransactions.where((tx) => tx.isExpense)) {
              final groupKey = tx.categoryId ?? tx.title;
              if (!categoryAggregates.containsKey(groupKey)) {
                categoryAggregates[groupKey] = {
                  'name': tx.categoryName ?? tx.title,
                  'amount': 0.0,
                  'iconName': tx.iconName,
                  'bgColor': tx.iconBackgroundColor,
                  'iconColor': tx.iconColor,
                };
              }
              categoryAggregates[groupKey]!['amount'] += tx.amount;
            }

            // 5. Group by Bank Account
            final bankTotals = <String, double>{};
            for (var tx in monthlyTransactions.where(
              (tx) =>
                  tx.isExpense &&
                  tx.accountName != null &&
                  tx.accountName!.isNotEmpty,
            )) {
              final account = tx.accountName!;
              bankTotals[account] = (bankTotals[account] ?? 0) + tx.amount;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Monthly Financial Report',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.report.title.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.progressOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await PdfService().generateAndShareReport(
                            monthTitle: widget.report.title,
                            totalBudget: totalBudget,
                            totalSpent: totalSpent,
                            remaining: remaining,
                            isExceeded: isExceeded,
                            categoryBreakdown: categoryAggregates.map(
                              (k, v) => MapEntry(
                                v['name'] as String,
                                v['amount'] as double,
                              ),
                            ),
                            bankBreakdown: bankTotals,
                            transactions: monthlyTransactions,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.textLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.textDark.withOpacity(0.05),
                            ),
                          ),
                          child: const Icon(
                            Icons.file_download_outlined,
                            color: AppColors.textGray,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.textLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.textDark.withOpacity(0.05),
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.textGray,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Summary Cards
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.softBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          'TOTAL BUDGET',
                          CurrencyUtil.format(totalBudget),
                          AppColors.textDark,
                        ),
                        _buildSummaryItem(
                          'TOTAL SPENT',
                          CurrencyUtil.format(totalSpent),
                          AppColors.progressOrange,
                        ),
                        _buildSummaryItem(
                          'REMAINING',
                          CurrencyUtil.format(remaining.abs()),
                          AppColors.greenDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Category Breakdown
                  if (categoryAggregates.isNotEmpty) ...[
                    const Text(
                      'CATEGORY BREAKDOWN',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.8,
                          ),
                      itemCount: categoryAggregates.length,
                      itemBuilder: (context, index) {
                        final entry = categoryAggregates.values.elementAt(
                          index,
                        );
                        return _buildCategoryCard(
                          entry['iconName'] != null
                              ? AppIcons.get(entry['iconName'])
                              : Icons.category,
                          entry['bgColor'],
                          entry['iconColor'],
                          entry['name'],
                          CurrencyUtil.format(entry['amount']),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],

                  // Bank Breakdown
                  if (bankTotals.isNotEmpty) ...[
                    const Text(
                      'BANK WISE BREAKDOWN',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...bankTotals.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.softBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppColors.primaryPurple,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              CurrencyUtil.format(entry.value),
                              style: const TextStyle(
                                color: AppColors.redAlertText,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 40),
                  ],

                  const Text(
                    'ALL TRANSACTIONS',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (monthlyTransactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No transactions',
                          style: TextStyle(color: AppColors.textGray),
                        ),
                      ),
                    )
                  else
                    ...monthlyTransactions.map((tx) {
                      return _buildTransactionRow(
                        tx.title,
                        DateFormat('dd MMM yyyy • hh:mm a').format(tx.date),
                        tx.accountName ?? '',
                        '${tx.isExpense ? '-' : '+'}${CurrencyUtil.format(tx.amount)}',
                        isExpense: tx.isExpense,
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textGray.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    IconData icon,
    Color bgColor,
    Color iconColor,
    String name,
    String amount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(
    String title,
    String subtitle,
    String bank,
    String amount, {
    bool isExpense = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textGray.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bank,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textGray.withOpacity(0.5),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: TextStyle(
              color: isExpense ? AppColors.redAlertText : AppColors.greenDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
