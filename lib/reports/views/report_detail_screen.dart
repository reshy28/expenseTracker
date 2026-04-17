import 'package:flutter/material.dart';
import '../../homescreen/views/app_colors.dart';
import '../models/report_model.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                          report.title.toUpperCase(),
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
                  Container(
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.textDark.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'TOTAL BUDGET',
                        '₹60,000',
                        AppColors.textDark,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'TOTAL SPENT',
                        '₹42,000',
                        AppColors.progressOrange,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'REMAINING',
                        '₹18,000',
                        AppColors.greenDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Category Breakdown
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
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      Icons.restaurant,
                      AppColors.foodBg,
                      AppColors.foodIcon,
                      'Food',
                      '₹4,500',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      Icons.directions_car,
                      AppColors.transportBg,
                      AppColors.transportIcon,
                      'Transport',
                      '₹2,800',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      Icons.shopping_bag,
                      AppColors.shoppingBg,
                      AppColors.shoppingIcon,
                      'Shopping',
                      '₹6,200',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      Icons.bolt,
                      AppColors.internetBg,
                      AppColors.internetIcon,
                      'Bills',
                      '₹3,100',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // All Transactions
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

              // Table Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          color: AppColors.textGray.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'CATEGORY',
                        style: TextStyle(
                          color: AppColors.textGray.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'AMOUNT',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: AppColors.textGray.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Transaction Rows
              _buildTransactionRow(
                'Starbucks Coffee',
                '16 Apr 2026 • 09:45 AM',
                'FOOD',
                '-₹350',
              ),
              _buildTransactionRow(
                'Uber Ride',
                '15 Apr 2026 • 06:20 PM',
                'TRANSPORT',
                '-₹180',
              ),
              _buildTransactionRow(
                'Grocery Store',
                '14 Apr 2026 • 02:30 PM',
                'FOOD',
                '-₹1,200',
              ),
              _buildTransactionRow(
                'Netflix Subscription',
                '12 Apr 2026 • 08:00 AM',
                'BILLS',
                '-₹499',
              ),
              _buildTransactionRow(
                'Electricity Bill',
                '10 Apr 2026 • 11:30 AM',
                'BILLS',
                '-₹2,450',
              ),
            ],
          ),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textGray.withOpacity(0.6),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textDark.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
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
    String category,
    String amount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textDark.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textGray.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: TextStyle(
                color: AppColors.textGray.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              amount,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.redAlertText,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
