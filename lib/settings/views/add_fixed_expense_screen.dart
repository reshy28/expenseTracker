import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../homescreen/views/app_colors.dart';
import '../controllers/payment_methods_controller.dart';
import '../models/payment_models.dart';
import '../../categories/controllers/category_controller.dart';

class AddFixedExpenseScreen extends StatefulWidget {
  const AddFixedExpenseScreen({super.key});

  @override
  State<AddFixedExpenseScreen> createState() => _AddFixedExpenseScreenState();
}

class _AddFixedExpenseScreenState extends State<AddFixedExpenseScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  int _selectedDay = 1;
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PaymentMethodsController>(context);
    final categoryController = Provider.of<CategoryController>(context);
    final categories = categoryController.categories;

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
                    'Add Fixed Expense',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Expense NaMe
                  _buildLabel('EXPENSE NAME'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.textDark.withOpacity(0.05),
                      ),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Monthly Rent',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount
                  _buildLabel('AMOUNT'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.textDark.withOpacity(0.05),
                      ),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        hintText: '0',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Due Day
                  _buildLabel('DUE DAY OF MONTH'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.textLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.textDark.withOpacity(0.05),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedDay,
                        isExpanded: true,
                        items: List.generate(31, (index) => index + 1).map((
                          day,
                        ) {
                          return DropdownMenuItem<int>(
                            value: day,
                            child: Text(
                              'Every $day${_getDaySuffix(day)} of the month',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedDay = value!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // // Category Icon
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
                                        borderRadius: BorderRadius.circular(8),
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

                  // _buildLabel('CATEGORY'),
                  // SizedBox(
                  //   height: 80,
                  //   child: ListView.builder(
                  //     scrollDirection: Axis.horizontal,
                  //     itemCount: categories.length,
                  //     itemBuilder: (context, index) {
                  //       final category = categories[index];
                  //       final isSelected = _selectedCategoryIndex == index;
                  //       return GestureDetector(
                  //         onTap: () =>
                  //             setState(() => _selectedCategoryIndex = index),
                  //         child: Container(
                  //           margin: const EdgeInsets.only(right: 16),
                  //           padding: const EdgeInsets.all(16),
                  //           decoration: BoxDecoration(
                  //             color: isSelected
                  //                 ? AppColors.primaryPurple
                  //                 : AppColors.textLight,
                  //             borderRadius: BorderRadius.circular(20),
                  //             border: Border.all(
                  //               color: AppColors.textDark.withOpacity(0.05),
                  //             ),
                  //           ),
                  //           child: Row(
                  //             children: [
                  //               Icon(
                  //                 category.icon,
                  //                 color: isSelected
                  //                     ? AppColors.textLight
                  //                     : category.iconColor,
                  //                 size: 24,
                  //               ),
                  //               if (isSelected) ...[
                  //                 const SizedBox(width: 8),
                  //                 Text(
                  //                   category.name,
                  //                   style: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontWeight: FontWeight.bold,
                  //                     fontSize: 12,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ],
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _amountController.text.isEmpty ||
                        _selectedCategoryId == null) {
                      return;
                    }

                    final selectedCategory = categories.firstWhere(
                      (c) => c.id == _selectedCategoryId,
                    );
                    final expense = FixedExpenseModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      amount: double.tryParse(_amountController.text) ?? 0,
                      dueDay: _selectedDay,
                      icon: selectedCategory.icon,
                      backgroundColor: selectedCategory.backgroundColor,
                      iconColor: selectedCategory.iconColor,
                    );

                    controller.addFixedExpense(expense);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Add Expense',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textGray,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
