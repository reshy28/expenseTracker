import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../homescreen/views/app_colors.dart';
import 'set_budget_screen.dart';
import 'fixed_expense_list_screen.dart';
import 'salary_management_screen.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.textDark.withOpacity(0.05),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Payment Methods',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildOptionCard(
                    context,
                    title: 'Set Monthly Budget',
                    subtitle: 'PLAN YOUR SPENDING',
                    icon: Icons.adjust,
                    iconColor: const Color(0xFF1ABC9C),
                    bgColor: const Color(0xFFECF9F1),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetBudgetScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    context,
                    title: 'Fixed Expense',
                    subtitle: 'MANAGE RECURRING COSTS',
                    icon: IconlyLight.time_circle,
                    iconColor: const Color(0xFFFF7A00),
                    bgColor: const Color(0xFFFFF0E0),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FixedExpenseListScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    context,
                    title: 'Salary Management',
                    subtitle: 'TRACK SALARY & EXPENSES',
                    icon: IconlyLight.document,
                    iconColor: AppColors.primaryPurple,
                    bgColor: AppColors.primaryPurple.withOpacity(0.1),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SalaryManagementScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.textLight,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.textDark.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textGray.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              IconlyLight.arrow_right_2,
              color: AppColors.textGray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
