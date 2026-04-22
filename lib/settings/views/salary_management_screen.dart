import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../root/utils/currency_util.dart';
import '../../homescreen/views/app_colors.dart';
import '../controllers/payment_methods_controller.dart';
import '../models/payment_models.dart';
import '../../root/utils/app_icons.dart';

import '../../reports/views/reports_screen.dart';

class SalaryManagementScreen extends StatefulWidget {
  const SalaryManagementScreen({super.key});

  @override
  State<SalaryManagementScreen> createState() => _SalaryManagementScreenState();
}

class _SalaryManagementScreenState extends State<SalaryManagementScreen> {
  final _salaryController = TextEditingController();
  final _expenseNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = context.read<PaymentMethodsController>();
    _salaryController.text = controller.salaryAmount.toString();
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  void _showAddExpenseBottomSheet({SalaryExpenseModel? expenseToEdit}) {
    if (expenseToEdit != null) {
      _expenseNameController.text = expenseToEdit.name;
      _expenseAmountController.text = expenseToEdit.amount.toString();
    } else {
      _expenseNameController.clear();
      _expenseAmountController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expenseToEdit != null ? 'Edit Expense' : 'Add New Expense',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  _expenseNameController,
                  'Expense Name',
                  'e.g. Phone Display',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _expenseAmountController,
                  'Amount',
                  '₹ 0',
                  isNumber: true,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_expenseNameController.text.isNotEmpty &&
                          _expenseAmountController.text.isNotEmpty) {
                        final amount =
                            double.tryParse(_expenseAmountController.text) ?? 0.0;
                        final expense = SalaryExpenseModel(
                          id:
                              expenseToEdit?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _expenseNameController.text,
                          amount: amount,
                          iconName: AppIcons.receiptlong,
                          backgroundColor: AppColors.primaryPurple.withOpacity(
                            0.1,
                          ),
                          iconColor: AppColors.primaryPurple,
                          dateAdded: expenseToEdit?.dateAdded ?? DateTime.now(),
                        );

                        if (expenseToEdit != null) {
                          context
                              .read<PaymentMethodsController>()
                              .updateSalaryExpense(expense);
                        } else {
                          context
                              .read<PaymentMethodsController>()
                              .addSalaryExpense(expense);
                        }

                        _expenseNameController.clear();
                        _expenseAmountController.clear();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      expenseToEdit != null ? 'Update Expense' : 'Add Expense',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFixedExpenseSelectionSheet(PaymentMethodsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<PaymentMethodsController>(
        builder: (context, controller, child) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Fixed Expenses',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add recurring costs to your salary budget',
                style: TextStyle(color: AppColors.textGray, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: controller.fixedExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: AppColors.textGray.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No fixed expenses found',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add them in My Accounts > Fixed Expenses',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textGray.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.fixedExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = controller.fixedExpenses[index];
                          final isSelected = controller.salaryFixedExpenseIds
                              .contains(expense.id);
                          return GestureDetector(
                            onTap: () => controller.toggleFixedExpenseInSalary(
                              expense.id,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryPurple.withOpacity(0.05)
                                    : AppColors.textLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : AppColors.softBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: expense.backgroundColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      expense.icon,
                                      color: expense.iconColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.name,
                                          style: const TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          CurrencyUtil.format(expense.amount),
                                          style: const TextStyle(
                                            color: AppColors.textGray,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.add_circle_outline,
                                    color: isSelected
                                        ? AppColors.primaryPurple
                                        : AppColors.textGray,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSalaryDialog() {
    final controller = context.read<PaymentMethodsController>();
    _salaryController.text = controller.salaryAmount.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Set Salary Budget',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _salaryController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Enter salary amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_salaryController.text) ?? 0.0;
              context.read<PaymentMethodsController>().setSalaryAmount(amount);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentMethodsController>();

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
                  const Expanded(
                    child: Text(
                      'Salary Management',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Salary Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${controller.currentMonthHeader} BUDGET',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                    const SizedBox(height: 8),
                                    Text(
                                      CurrencyUtil.format(
                                        controller.salaryAmount,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _showEditSalaryDialog,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'REMAINING BALANCE',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      CurrencyUtil.format(
                                        controller.remainingSalaryBalance,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${controller.salaryAmount > 0 ? ((controller.remainingSalaryBalance / controller.salaryAmount) * 100).toInt() : 0}% LEFT',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Fixed Expenses Section
                      _buildSectionHeader(
                        'FIXED EXPENSES',
                        controller.fixedExpenses
                            .where(
                              (e) => controller.salaryFixedExpenseIds.contains(
                                e.id,
                              ),
                            )
                            .length,
                        onAdd: () =>
                            _showFixedExpenseSelectionSheet(controller),
                      ),
                      const SizedBox(height: 16),
                      if (controller.salaryFixedExpenseIds.isEmpty)
                        _buildEmptyState('No fixed expenses selected.')
                      else
                        ...controller.fixedExpenses
                            .where(
                              (e) => controller.salaryFixedExpenseIds.contains(
                                e.id,
                              ),
                            )
                            .map(
                              (expense) => Dismissible(
                                key: Key('fixed_${expense.id}'),
                                direction: DismissDirection.endToStart,
                                background: _buildDismissBackground(
                                  Icons.link_off,
                                ),
                                onDismissed: (_) {
                                  controller.toggleFixedExpenseInSalary(
                                    expense.id,
                                  );
                                },
                                child: _buildExpenseTile(
                                  title: expense.name,
                                  amount: expense.amount,
                                  icon: expense.icon,
                                  bgColor: expense.backgroundColor,
                                  iconColor: expense.iconColor,
                                  date: 'Due on day ${expense.dueDay}',
                                ),
                              ),
                            ),

                      const SizedBox(height: 32),

                      // Additional Expenses Section
                      _buildSectionHeader(
                        'OTHER EXPENSES',
                        controller.additionalSalaryExpenses.length,
                      ),
                      const SizedBox(height: 16),
                      if (controller.additionalSalaryExpenses.isEmpty)
                        _buildEmptyState('No additional expenses added yet.')
                      else
                        ...controller.additionalSalaryExpenses.map(
                          (expense) => Dismissible(
                            key: Key('other_${expense.id}'),
                            direction: DismissDirection.endToStart,
                            background: _buildDismissBackground(
                              Icons.delete_outline,
                            ),
                            onDismissed: (_) {
                              controller.deleteSalaryExpense(expense.id);
                            },
                            child: _buildExpenseTile(
                              title: expense.name,
                              amount: expense.amount,
                              icon: expense.icon,
                              bgColor: expense.backgroundColor,
                              iconColor: expense.iconColor,
                              date: DateFormat(
                                'MMM dd, yyyy',
                              ).format(expense.dateAdded),
                              onEdit: () => _showAddExpenseBottomSheet(
                                expenseToEdit: expense,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseBottomSheet(),
        backgroundColor: AppColors.primaryPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(IconData icon) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.redAlertText.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, color: AppColors.redAlertText),
    );
  }

  Widget _buildSectionHeader(String title, int count, {VoidCallback? onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.softBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (onAdd != null)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primaryPurple,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpenseTile({
    required String title,
    required double amount,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String date,
    VoidCallback? onEdit,
  }) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: AppColors.premiumCardDecoration,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: AppColors.textGray.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              CurrencyUtil.format(amount),
              style: const TextStyle(
                color: AppColors.redAlertText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          message,
          style: TextStyle(
            color: AppColors.textGray.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.softBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textGray.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
