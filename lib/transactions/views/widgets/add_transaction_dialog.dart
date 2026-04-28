import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../homescreen/models/transaction_model.dart';
import '../../../homescreen/views/app_colors.dart';
import '../../../root/utils/currency_util.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../../categories/controllers/category_controller.dart';
import '../../controllers/transactions_controller.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  bool _isExpense = true;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  bool _useUserPhoto = false;
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryPurple,
                onPrimary: Colors.white,
                onSurface: AppColors.textDark,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Amount Header (Primary focus)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isExpense ? 'New Expense' : 'New Income',
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: AppColors.textGray.withValues(alpha: 0.5),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹',
                        style: TextStyle(
                          color: _isExpense
                              ? AppColors.redAlertText
                              : AppColors.greenDark,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isExpense
                                ? AppColors.redAlertText
                                : AppColors.greenDark,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: AppColors.softBorder,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // 2. Type Toggle
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeButton(
                          'Expense',
                          _isExpense,
                          Icons.north_east,
                          () => setState(() => _isExpense = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeButton(
                          'Income',
                          !_isExpense,
                          Icons.south_west,
                          () => setState(() => _isExpense = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 3. Simple Inputs Stack
                  _buildMinimalInput(
                    icon: Icons.edit_note,
                    hint: 'Transaction Title',
                    controller: _nameController,
                  ),
                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: AppColors.background,
                  ),

                  // Category Selection
                  Consumer<CategoryController>(
                    builder: (context, controller, _) {
                      final categories = controller.categories;
                      final selected = categories.firstWhere(
                        (c) => c.id == _selectedCategoryId,
                        orElse: () => categories.first,
                      );

                      return _buildSelectionTile(
                        icon: selected.icon,
                        label: selected.name,
                        iconColor: selected.iconColor,
                        bgColor: selected.backgroundColor,
                        onTap: () => _showCategoryPicker(context, controller),
                      );
                    },
                  ),
                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: AppColors.background,
                  ),

                  // Account Selection
                  Consumer<AccountsController>(
                    builder: (context, controller, _) {
                      final accounts = controller.accounts;
                      if (_selectedAccountId == null && accounts.isNotEmpty)
                        _selectedAccountId = accounts.first.id;
                      final selected = accounts.firstWhere(
                        (a) => a.id == _selectedAccountId,
                        orElse: () => accounts.first,
                      );

                      return _buildSelectionTile(
                        icon: Icons.account_balance_wallet_outlined,
                        label: selected.name,
                        onTap: () => _showAccountPicker(context, controller),
                      );
                    },
                  ),
                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: AppColors.background,
                  ),

                  // Date Selection
                  _buildSelectionTile(
                    icon: Icons.calendar_today_outlined,
                    label: DateFormat(
                      'MMM dd, yyyy • hh:mm a',
                    ).format(_selectedDate),
                    onTap: () => _pickDateTime(context),
                  ),

                  const SizedBox(height: 40),

                  // 4. Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add Transaction',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildTypeButton(
    String label,
    bool isActive,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryPurple : AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppColors.textGray,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textGray,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalInput({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.textGray.withValues(alpha: 0.4)),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textGray.withValues(alpha: 0.3),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor ?? AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.textGray.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textGray.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  //category picker function
  void _showCategoryPicker(
    BuildContext context,
    CategoryController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cat.backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(cat.icon, color: cat.iconColor, size: 20),
                      ),
                      title: Text(
                        cat.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        setState(() => _selectedCategoryId = cat.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccountPicker(BuildContext context, AccountsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.accounts.length,
                  itemBuilder: (context, index) {
                    final acc = controller.accounts[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primaryPurple,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        acc.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Text(
                        CurrencyUtil.format(acc.balance),
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () {
                        setState(() => _selectedAccountId = acc.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty) return;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final catController = context.read<CategoryController>();
    final selectedCat = catController.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => catController.categories.first,
    );

    final accController = context.read<AccountsController>();
    final selectedAccount = accController.accounts.firstWhere(
      (a) => a.id == _selectedAccountId,
      orElse: () => accController.accounts.first,
    );

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _nameController.text.isEmpty
          ? selectedCat.name
          : _nameController.text,
      amount: amount,
      date: _selectedDate,
      dateSubtitle: DateFormat('MMM dd, yyyy').format(_selectedDate),
      isExpense: _isExpense,
      iconName: selectedCat.iconName,
      iconBackgroundColor: selectedCat.backgroundColor,
      iconColor: selectedCat.iconColor,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      accountId: selectedAccount.id,
      accountName: selectedAccount.name,
      categoryId: selectedCat.id,
      categoryName: selectedCat.name,
    );

    await context.read<TransactionsController>().addTransaction(transaction);
    if (mounted) Navigator.pop(context);
  }
}
