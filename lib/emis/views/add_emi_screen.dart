import 'package:mtracker/root/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/emi_controller.dart';
import '../../accounts/controllers/accounts_controller.dart';
import '../../homescreen/views/app_colors.dart';
import '../../homescreen/models/emi_model.dart';
import '../../accounts/models/account_model.dart';
import '../../categories/controllers/category_controller.dart';
import '../../homescreen/models/category_model.dart';
import '../../root/utils/app_icons.dart';

class AddEmiScreen extends StatefulWidget {
  final EmiModel? emiToEdit;

  const AddEmiScreen({super.key, this.emiToEdit});

  @override
  State<AddEmiScreen> createState() => _AddEmiScreenState();
}

class _AddEmiScreenState extends State<AddEmiScreen> {
  final _nameController = TextEditingController();
  final _monthlyController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _durationController = TextEditingController();
  final _ownerController = TextEditingController(text: 'Self');
  final _downpaymentController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String _ownerType = 'Self'; // 'Self' or 'Other'
  bool _isNewPurchase = false;

  @override
  void initState() {
    super.initState();
    if (widget.emiToEdit != null) {
      final emi = widget.emiToEdit!;
      _nameController.text = emi.title;
      _monthlyController.text = emi.monthlyAmount.toString();
      _totalAmountController.text = emi.totalAmount.toString();
      _durationController.text = emi.totalMonths.toString();
      _selectedDate = emi.nextPaymentDate;
      _selectedAccountId = emi.accountId;
      _selectedCategoryId = emi.categoryId;

      if (emi.ownerName.toLowerCase() == 'self') {
        _ownerType = 'Self';
        _ownerController.text = 'Self';
      } else {
        _ownerType = 'Other';
        _ownerController.text = emi.ownerName;
      }
    }

    // Add listeners for automatic calculation
    _monthlyController.addListener(_calculateTotalAmount);
    _durationController.addListener(_calculateTotalAmount);

    // Initial account selection for downpayment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountsController = context.read<AccountsController>();
      final cashAccount = accountsController.accounts.firstWhere(
        (a) =>
            a.name.toLowerCase().contains('cash') ||
            a.name.toLowerCase().contains('hand'),
        orElse:
            () =>
                accountsController.accounts.isNotEmpty
                    ? accountsController.accounts.first
                    : AccountModel(
                      id: '',
                      name: '',
                      balance: 0,
                      iconName: '',
                      iconColor: Colors.black,
                      backgroundColor: Colors.white,
                      type: AccountType.bank,
                    ),
      );

      if (cashAccount.id.isNotEmpty) {
        setState(() {
          // No longer needed
        });
      }
    });
  }

  void _calculateTotalAmount() {
    final monthly = double.tryParse(_monthlyController.text) ?? 0.0;
    final duration = int.tryParse(_durationController.text) ?? 0;

    if (monthly > 0 && duration > 0) {
      final total = monthly * duration;
      // Use text formatting to avoid issues with trailing zeros
      final totalStr = total == total.toInt()
          ? total.toInt().toString()
          : total.toStringAsFixed(1);

      // Update the totalAmountController without triggering its own listener if it had one
      if (_totalAmountController.text != totalStr) {
        _totalAmountController.text = totalStr;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _monthlyController.dispose();
    _totalAmountController.dispose();
    _durationController.dispose();
    _ownerController.dispose();
    _downpaymentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: AppColors.textLight,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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
                  Text(
                    widget.emiToEdit != null ? 'Edit EMI' : 'Add New EMI',
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
                      _buildLabel('LOAN TYPE'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeChip(
                              'Existing Loan',
                              !_isNewPurchase,
                              () => setState(() => _isNewPurchase = false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTypeChip(
                              'New Purchase',
                              _isNewPurchase,
                              () => setState(() => _isNewPurchase = true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildLabel('EMI NAME'),
                      const SizedBox(height: 12),
                      _buildTextField(_nameController, hint: 'e.g. Car Loan'),

                      const SizedBox(height: 24),

                      _buildLabel('EMI FOR'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            value: _ownerType,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            dropdownColor: AppColors.background,
                            items: const [
                              DropdownMenuItem(
                                value: 'Self',
                                child: Text(
                                  'Self',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text(
                                  'Other Person',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                            onChanged: (value) => setState(() {
                              _ownerType = value!;
                              if (_ownerType == 'Self')
                                _ownerController.text = 'Self';
                              else
                                _ownerController.clear();
                            }),
                          ),
                        ),
                      ),

                      if (_ownerType == 'Other') ...[
                        const SizedBox(height: 16),
                        _buildLabel('PERSON NAME'),
                        const SizedBox(height: 12),
                        _buildTextField(
                          _ownerController,
                          hint: 'e.g. Rahul, Sameer',
                        ),
                      ],

                      const SizedBox(height: 24),

                      _buildLabel('SELECT CATEGORY'),
                      const SizedBox(height: 12),
                      Consumer<CategoryController>(
                        builder: (context, categoryController, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategoryId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                dropdownColor: AppColors.background,
                                items: categoryController.categories.map((
                                  category,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: category.id,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: category.backgroundColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            category.icon,
                                            color: category.iconColor,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          category.name,
                                          style: const TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    setState(() => _selectedCategoryId = value),
                                hint: Text(
                                  'Select category',
                                  style: TextStyle(
                                    color: AppColors.textGray.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      _buildLabel('LINKED ACCOUNT'),
                      const SizedBox(height: 12),
                      Consumer<AccountsController>(
                        builder: (context, accountsController, _) {
                          // Safety check: ensure selected account still exists
                          if (_selectedAccountId != null &&
                              !accountsController.accounts.any(
                                (a) => a.id == _selectedAccountId,
                              )) {
                            _selectedAccountId = null;
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                value: _selectedAccountId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                dropdownColor: AppColors.background,
                                items: accountsController.accounts.map((
                                  account,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: account.id,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: account.backgroundColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            account.icon,
                                            color: account.iconColor,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          account.name,
                                          style: const TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    setState(() => _selectedAccountId = value),
                                hint: Text(
                                  'Select account/card',
                                  style: TextStyle(
                                    color: AppColors.textGray.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('MONTHLY EMI'),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  _monthlyController,
                                  hint: '₹ 0',
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('TOTAL DURATION (MONTHS)'),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  _durationController,
                                  hint: 'e.g. 48',
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _buildLabel('TOTAL LOAN AMOUNT'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _totalAmountController,
                        hint: '₹ 0',
                        isNumber: true,
                      ),

                      if (_isNewPurchase) ...[
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('DOWNPAYMENT (OPTIONAL)'),
                            const SizedBox(height: 12),
                            _buildTextField(
                              _downpaymentController,
                              hint: '₹ 0',
                              isNumber: true,
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      _buildLabel('NEXT DUE DATE'),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.softBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'MMMM dd, yyyy',
                                ).format(_selectedDate),
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.primaryPurple.withOpacity(0.5),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.isEmpty ||
                                _monthlyController.text.isEmpty)
                              return;

                            final categoryController = context
                                .read<CategoryController>();
                            final selectedCategory = _selectedCategoryId != null
                                ? categoryController.categories.firstWhere(
                                    (cat) => cat.id == _selectedCategoryId,
                                  )
                                : null;

                            final newEmi = EmiModel(
                              id:
                                  widget.emiToEdit?.id ??
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              title: _nameController.text,
                              ownerName: _ownerController.text.isEmpty
                                  ? 'Self'
                                  : _ownerController.text,
                              accountId: _selectedAccountId,
                              categoryId: _selectedCategoryId,
                              monthlyAmount:
                                  double.tryParse(_monthlyController.text) ??
                                  0.0,
                              totalAmount:
                                  double.tryParse(
                                    _totalAmountController.text,
                                  ) ??
                                  0.0,
                              totalMonths:
                                  int.tryParse(_durationController.text) ?? 0,
                              monthsPaid: widget.emiToEdit?.monthsPaid ?? 0,
                              nextPaymentDate: _selectedDate,
                              iconName:
                                  selectedCategory?.iconName ??
                                  widget.emiToEdit?.iconName ??
                                  AppIcons.piechart,
                              color:
                                  selectedCategory?.iconColor ??
                                  widget.emiToEdit?.color ??
                                  AppColors.primaryPurple,
                                downpayment:
                                    double.tryParse(_downpaymentController.text) ??
                                    0.0,
                                isNewPurchase: _isNewPurchase,
                                downpaymentAccountId: null,
                              );

                            if (widget.emiToEdit != null) {
                              context.read<EmiController>().updateEmi(newEmi);
                            } else {
                              context.read<EmiController>().addEmi(newEmi);
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
                                  widget.emiToEdit != null
                                      ? 'UPDATE LOAN DETAILS'
                                      : 'SAVE LOAN DETAILS',
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
    bool isNumber = false,
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
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : AppColors.softBorder,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.textLight : AppColors.textGray,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
