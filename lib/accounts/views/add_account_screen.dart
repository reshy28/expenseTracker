import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../homescreen/views/app_colors.dart';
import '../controllers/accounts_controller.dart';
import '../models/account_model.dart';

class AddAccountScreen extends StatefulWidget {
  final AccountModel? account;
  const AddAccountScreen({super.key, this.account});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _limitController;
  late AccountType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _amountController = TextEditingController(
      text: widget.account?.balance.toStringAsFixed(0) ?? '0',
    );
    _limitController = TextEditingController(
      text: widget.account?.limit?.toStringAsFixed(0) ?? '',
    );
    _selectedType = widget.account?.type ?? AccountType.bank;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.account != null;

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
                  Text(
                    isEditing ? 'Edit Account' : 'Add New Account',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppColors.premiumCardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('ACCOUNT NAME'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _nameController,
                        hint: 'e.g. HDFC Savings',
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('ACCOUNT TYPE'),
                      const SizedBox(height: 12),
                      _buildDropdown(),
                      const SizedBox(height: 24),
                      _buildLabel('BALANCE AMOUNT'),
                      const SizedBox(height: 12),
                      _buildAmountField(_amountController),

                      if (_selectedType == AccountType.credit) ...[
                        const SizedBox(height: 24),
                        _buildLabel('CREDIT LIMIT'),
                        const SizedBox(height: 12),
                        _buildAmountField(
                          _limitController,
                          hint: 'e.g. 1,00,000',
                        ),
                      ],
                      const SizedBox(height: 40),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.isEmpty) return;

                            final double amount =
                                double.tryParse(_amountController.text) ?? 0.0;
                            final double? limit = double.tryParse(
                              _limitController.text,
                            );

                            IconData icon;
                            Color iconColor;
                            Color bgColor;

                            switch (_selectedType) {
                              case AccountType.bank:
                                icon = Icons.account_balance_wallet;
                                iconColor = AppColors.primaryPurple;
                                bgColor = AppColors.primaryPurpleLight;
                                break;
                              case AccountType.credit:
                                icon = Icons.credit_card;
                                iconColor = AppColors.shoppingIcon;
                                bgColor = AppColors.shoppingBg;
                                break;
                              case AccountType.cash:
                                icon = Icons.bolt;
                                iconColor = AppColors.progressOrange;
                                bgColor = AppColors.foodBg;
                                break;
                            }

                            if (isEditing) {
                              final updatedAccount = AccountModel(
                                id: widget.account!.id,
                                name: _nameController.text,
                                type: _selectedType,
                                balance: amount,
                                limit: limit,
                                icon: icon,
                                iconColor: iconColor,
                                backgroundColor: bgColor,
                              );
                              Provider.of<AccountsController>(
                                context,
                                listen: false,
                              ).updateAccount(updatedAccount);
                            } else {
                              final newAccount = AccountModel(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                name: _nameController.text,
                                type: _selectedType,
                                balance: amount,
                                limit: limit,
                                icon: icon,
                                iconColor: iconColor,
                                backgroundColor: bgColor,
                              );
                              Provider.of<AccountsController>(
                                context,
                                listen: false,
                              ).addAccount(newAccount);
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPurple.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.textLight,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isEditing ? 'UPDATE DETAILS' : 'SAVE ACCOUNT',
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textGray,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textGray.withOpacity(0.4),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildAmountField(
    TextEditingController controller, {
    String hint = '0',
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Row(
        children: [
          const Text(
            '₹',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textGray.withOpacity(0.3),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AccountType>(
          value: _selectedType,
          isExpanded: true,
          borderRadius: BorderRadius.circular(20),
          dropdownColor: AppColors.textLight,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primaryPurple.withOpacity(0.5),
          ),
          onChanged: (AccountType? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedType = newValue;
              });
            }
          },
          items: [
            const DropdownMenuItem(
              value: AccountType.bank,
              child: Text('Bank Account'),
            ),
            const DropdownMenuItem(
              value: AccountType.credit,
              child: Text('Credit Card'),
            ),
            const DropdownMenuItem(
              value: AccountType.cash,
              child: Text('Cash'),
            ),
          ],
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
