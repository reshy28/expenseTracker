import 'package:mtracker/settings/controllers/payment_methods_controller.dart';
import 'package:mtracker/transactions/controllers/transactions_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../homescreen/views/app_colors.dart';
import '../controllers/reports_controller.dart';
import '../models/report_model.dart';
import 'report_detail_screen.dart';
import 'salary_report_detail_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReportsController>(context);
    final txController = Provider.of<TransactionsController>(context);
    final paymentController = Provider.of<PaymentMethodsController>(context);

    final now = DateTime.now();
    final months = controller.availableMonths
        .where((m) => m.year == controller.selectedYear)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Insights',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Analyze your spending and budget archives',
                    style: TextStyle(
                      color: AppColors.textGray.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Toggle Section (MATCHING EXACT DESIGN)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildModeToggleCard(
                            context,
                            title: 'Salary Management',
                            isActive: controller.selectedMode == ReportMode.salary,
                            onTap: () => controller.setMode(ReportMode.salary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildModeToggleCard(
                            context,
                            title: 'Detailed Analytics',
                            isActive: controller.selectedMode == ReportMode.analytics,
                            onTap: () => controller.setMode(ReportMode.analytics),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Year Selector
                  Row(
                    children: [
                      const Text(
                        'SHOWING RECORDS FOR',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: controller.selectedYear,
                        dropdownColor: AppColors.textLight,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppColors.primaryPurple,
                        ),
                        underline: const SizedBox(),
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        items: controller.availableYears.map((year) {
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (year) {
                          if (year != null) controller.setYear(year);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                ],
              ),
            ),

            // Monthly List
            Expanded(
              child: controller.isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
              : months.isEmpty
                ? Center(child: Text('No reports found for ${controller.selectedYear}', style: TextStyle(color: AppColors.textGray.withOpacity(0.5))))
                : ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final monthDate = months[index];
                  final monthName = DateFormat('MMMM').format(monthDate);
                  final isSalaryMode = controller.selectedMode == ReportMode.salary;

                  return _buildMonthItem(
                    context,
                    monthDate: monthDate,
                    monthName: monthName,
                    subtitle: isSalaryMode ? 'Salary Ledger' : 'Detailed Analysis',
                    icon: isSalaryMode ? Icons.account_balance_wallet_outlined : Icons.analytics_outlined,
                    iconColor: isSalaryMode ? AppColors.primaryPurple : AppColors.progressOrange,
                    onTap: () {
                      final report = ReportModel(
                        title: '$monthName ${monthDate.year}',
                        format: 'PDF REPORT',
                        size: '--',
                        date: monthDate,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => isSalaryMode 
                            ? SalaryReportDetailScreen(report: report)
                            : ReportDetailScreen(report: report),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggleCard(
    BuildContext context, {
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryPurple : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive ? [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textGray,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthItem(
    BuildContext context, {
    required DateTime monthDate,
    required String monthName,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppColors.premiumCardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          '$monthName ${monthDate.year}',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textGray.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textGray.withOpacity(0.3),
        ),
      ),
    );
  }
}
