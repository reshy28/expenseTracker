import 'package:mtracker/emis/controllers/emi_controller.dart';
import 'package:mtracker/settings/controllers/payment_methods_controller.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import 'app_colors.dart';
import 'widgets/budget_card.dart';
import 'widgets/upcoming_bills.dart';
import 'widgets/emi_progress.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/total_liabilities_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final _controller = Provider.of<HomeController>(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _controller.user.name,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('EEEE').format(DateTime.now()).toUpperCase(),
                      style: TextStyle(
                        color: AppColors.textGray.withOpacity(0.6),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM dd').format(DateTime.now()),
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Budget Card
            Consumer<PaymentMethodsController>(
              builder: (context, paymentController, _) => BudgetCard(
                spent: _controller.budgetSpent,
                total: paymentController.budget.amount,
              ),
            ),
            const SizedBox(height: 20),

            // Liabilities Card
            Consumer<EmiController>(
              builder: (context, emiController, _) {
                final myActiveEmis = emiController.activeEmis
                    .where((e) => e.ownerName.toLowerCase() == 'self')
                    .toList();

                return TotalLiabilitiesCard(
                  totalAmount: myActiveEmis.fold(
                    0.0,
                    (sum, emi) => sum + emi.amountLeft,
                  ),
                  activeLoansCount: myActiveEmis.length,
                );
              },
            ),
            const SizedBox(height: 40),

            // Upcoming Bills
            Consumer<PaymentMethodsController>(
              builder: (context, paymentController, _) {
                final bills = paymentController.upcomingBills;
                if (bills.isEmpty) return const SizedBox.shrink();
                
                return Column(
                  children: [
                    UpcomingBills(bills: bills),
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),

            // EMI Progress
            Consumer<EmiController>(
              builder: (context, emiController, _) {
                final activeEmis = emiController.activeEmis;
                if (activeEmis.isEmpty) return const SizedBox.shrink();

                return Column(
                  children: [
                    EmiProgress(emis: activeEmis),
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),

            // Recent Transactions
            RecentTransactions(transactions: _controller.transactions),
            const SizedBox(height: 100), // Extra padding for fixed bottom area
          ],
        ),
      ),
    );
  }
}
