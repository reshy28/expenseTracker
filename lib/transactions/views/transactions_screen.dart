import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../root/utils/currency_util.dart';
import '../../homescreen/views/app_colors.dart';
import '../controllers/transactions_controller.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TransactionsController>(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'Transactions',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Search & Date Range Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: AppColors.premiumCardDecoration,
              child: Column(
                children: [
                  // Search Field
                  Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: AppColors.primaryPurple.withOpacity(0.5),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (value) =>
                              controller.setSearchQuery(value),
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search transactions...',
                            hintStyle: TextStyle(
                              color: AppColors.textGray.withOpacity(0.4),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: AppColors.softBorder, height: 32),
                  // Date Range Selector
                  GestureDetector(
                    onTap: () async {
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                        initialDateRange: controller.selectedDateRange,
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
                      controller.setDateFilter(picked);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.primaryPurple,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.selectedDateRange != null
                                ? '${_formatDate(controller.selectedDateRange!.start)} - ${_formatDate(controller.selectedDateRange!.end)}'
                                : 'Filter by date range',
                            style: TextStyle(
                              color: controller.selectedDateRange != null
                                  ? AppColors.textDark
                                  : AppColors.textGray.withOpacity(0.4),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (controller.selectedDateRange != null)
                          GestureDetector(
                            onTap: () => controller.setDateFilter(null),
                            child: Icon(
                              Icons.close,
                              color: AppColors.textGray.withOpacity(0.6),
                              size: 18,
                            ),
                          )
                        else
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textGray.withOpacity(0.3),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Filters Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                _buildFilterChip('All', controller),
                const SizedBox(width: 12),
                _buildFilterChip('Expense', controller),
                const SizedBox(width: 12),
                _buildFilterChip('Income', controller),
              ],
            ),
          ),
          const SizedBox(height: 12),

          const SizedBox(height: 12),

          // Transaction Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              '${controller.displayedTransactions.length} TRANSACTIONS FOUND',
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Transactions List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refresh(),
              color: AppColors.primaryPurple,
              backgroundColor: Colors.white,
              displacement: 20,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                itemCount: controller.displayedTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.displayedTransactions[index];
                  return Dismissible(
                    key: Key(transaction.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      controller.deleteTransaction(transaction);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${transaction.title} deleted'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.textDark,
                        ),
                      );
                    },
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: AppColors.redAlertText,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: AppColors.textLight,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(32),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        transaction.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.close, size: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'TRANSACTION NOTE',
                                  style: TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    transaction.description ?? 'No note added',
                                    style: TextStyle(
                                      color: transaction.description != null
                                          ? AppColors.textDark
                                          : AppColors.textGray.withOpacity(0.5),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: transaction.description != null
                                          ? FontStyle.normal
                                          : FontStyle.italic,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // 1. BRAND/CATEGORY ICON
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: transaction.iconBackgroundColor
                                    .withOpacity(0.15),
                                child: Icon(
                                  transaction.icon,
                                  color: transaction.iconColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // 2. TITLE & DATE/TIME
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatFullDateTime(transaction.date),
                                      style: TextStyle(
                                        color: AppColors.textGray.withOpacity(
                                          0.6,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 3. AMOUNT & CHEVRON
                              Row(
                                children: [
                                  Text(
                                    '${transaction.isExpense ? '-' : '+'}${CurrencyUtil.format(transaction.amount)}',
                                    style: TextStyle(
                                      color: transaction.isExpense
                                          ? AppColors.redAlertText
                                          : AppColors.greenDark,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textGray.withOpacity(0.3),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionsController controller) {
    bool isSelected = controller.selectedFilter == label;
    return GestureDetector(
      onTap: () {
        controller.setFilter(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : AppColors.textLight,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? null
              : Border.all(color: AppColors.textDark.withOpacity(0.05)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.textLight
                : AppColors.textGray.withOpacity(0.8),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatFullDateTime(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    String day = date.day.toString();
    String month = months[date.month - 1];
    String year = date.year.toString();

    // Time formatting (12h format)
    int hour = date.hour % 12;
    if (hour == 0) hour = 12;
    String minute = date.minute.toString().padLeft(2, '0');
    String period = date.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year • $hour:$minute $period';
  }
}
