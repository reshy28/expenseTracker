import 'package:mtracker/homescreen/models/emi_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../root/utils/currency_util.dart';
import '../../homescreen/views/app_colors.dart';
import '../controllers/emi_controller.dart';
import '../../accounts/controllers/accounts_controller.dart';
import '../../accounts/models/account_model.dart';
import 'add_emi_screen.dart';
import 'completed_emis_screen.dart';

class EmiManagerScreen extends StatefulWidget {
  const EmiManagerScreen({super.key});

  @override
  State<EmiManagerScreen> createState() => _EmiManagerScreenState();
}

//killall -9 Xcode Xcodebuild 2>/dev/null; flutter clean; flutter pub get; cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
class _EmiManagerScreenState extends State<EmiManagerScreen> {
  String _selectedFilter = 'Self'; // 'All', 'Self', 'Others'

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<EmiController>(context);

    // Filtering logic
    List<EmiModel> filteredEmis;
    if (_selectedFilter == 'Self') {
      filteredEmis = controller.activeEmis
          .where((e) => e.ownerName.toLowerCase() == 'self')
          .toList();
    } else if (_selectedFilter == 'Others') {
      filteredEmis = controller.activeEmis
          .where((e) => e.ownerName.toLowerCase() != 'self')
          .toList();
    } else {
      filteredEmis = controller.activeEmis;
    }

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
                    'EMI Manager',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompletedEmisScreen(),
                        ),
                      );
                    },
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
                        Icons.inventory_2_outlined,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _buildFilterChip('Self'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Others'),
                  const SizedBox(width: 8),
                  _buildFilterChip('All'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // EMI Lists
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  if (filteredEmis.isNotEmpty) ...[
                    Text(
                      '${_selectedFilter.toUpperCase()} ACTIVE EMIs',
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...filteredEmis.map(
                      (emi) => _buildEmiCard(context, emi, controller),
                    ),
                  ] else ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Text(
                          'No active EMIs found for ${_selectedFilter}',
                          style: TextStyle(
                            color: AppColors.textGray.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Completed EMIs Option (only show if any exist)
                  if (controller.completedEmis.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildCompletedOption(
                      context,
                      controller.completedEmis.length,
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Add Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEmiScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColors.textLight, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add New EMI',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : AppColors.textLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.textDark.withOpacity(0.05),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textLight : AppColors.textGray,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedOption(BuildContext context, int count) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CompletedEmisScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.incomeBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.incomeText.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.incomeBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.history_edu,
                color: AppColors.incomeText,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Completed EMIs',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count loans successfully paid off',
                    style: TextStyle(
                      color: AppColors.incomeText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.incomeText),
          ],
        ),
      ),
    );
  }

  Widget _buildEmiCard(
    BuildContext context,
    EmiModel emi,
    EmiController controller,
  ) {
    return Dismissible(
      key: Key(emi.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 32),
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.redAlertText,
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
      ),
      onDismissed: (direction) {
        controller.deleteEmi(emi.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${emi.title} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => controller.addEmi(emi),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _showEmiOptions(context, emi, controller),
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: AppColors.premiumCardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: emi.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(emi.icon, color: emi.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emi.title,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: AppColors.textGray.withOpacity(0.6),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  emi.ownerName,
                                  style: TextStyle(
                                    color: emi.ownerName.toLowerCase() == 'self'
                                        ? AppColors.primaryPurple
                                        : AppColors.progressOrange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // ADDED LINKED ACCOUNT INFO UNDERNEATH
                            if (emi.accountId != null) ...[
                              const SizedBox(height: 6),
                              Builder(
                                builder: (context) {
                                  final accounts =
                                      Provider.of<AccountsController>(
                                        context,
                                        listen: false,
                                      ).accounts;
                                  final matches = accounts.where(
                                    (a) => a.id == emi.accountId,
                                  );
                                  if (matches.isEmpty) return const SizedBox();
                                  final account = matches.first;

                                  return Row(
                                    children: [
                                      Icon(
                                        account.icon,
                                        color: account.iconColor,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        account.name,
                                        style: TextStyle(
                                          color: AppColors.textGray.withOpacity(
                                            0.8,
                                          ),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: emi.monthsLeft == 0
                          ? AppColors.greenLight
                          : AppColors.primaryPurpleLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      emi.monthsLeft == 0
                          ? 'COMPLETED'
                          : '${emi.monthsLeft} MONTHS LEFT',
                      style: TextStyle(
                        color: emi.monthsLeft == 0
                            ? AppColors.greenDark
                            : AppColors.primaryPurple,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BALANCE LEFT',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyUtil.format(emi.amountLeft),
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'MONTHLY',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyUtil.format(emi.monthlyAmount),
                        style: TextStyle(
                          color: AppColors.textDark.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(emi.percentagePaid * 100).toInt()}% PAID',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${emi.monthsPaid} / ${emi.totalMonths} MONTHS',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.softBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: emi.percentagePaid,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [emi.color, emi.color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: AppColors.softBorder),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: emi.monthsLeft == 0
                          ? AppColors.greenLight
                          : AppColors.softBorder,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      emi.monthsLeft == 0
                          ? Icons.check_circle_outline
                          : Icons.calendar_today_outlined,
                      color: emi.monthsLeft == 0
                          ? AppColors.greenDark
                          : AppColors.textGray,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emi.monthsLeft == 0 ? 'STATUS' : 'NEXT INSTALLMENT',
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        emi.monthsLeft == 0
                            ? 'Fully Paid 🎉'
                            : DateFormat(
                                'MMMM dd, yyyy',
                              ).format(emi.nextPaymentDate),
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (emi.monthsLeft > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Ends on: ${DateFormat('MMM dd, yyyy').format(emi.endDate)}',
                          style: TextStyle(
                            color: AppColors.textGray.withOpacity(0.6),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  if (emi.monthsLeft > 0)
                    _buildPayButton(context, emi, controller),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton(
    BuildContext context,
    EmiModel emi,
    EmiController controller,
  ) {
    return ElevatedButton(
      onPressed: () async {
        final accountsController = Provider.of<AccountsController>(
          context,
          listen: false,
        );

        AccountModel? linkedAccount;
        if (emi.accountId != null) {
          final matches = accountsController.accounts.where(
            (a) => a.id == emi.accountId,
          );
          linkedAccount = matches.isNotEmpty ? matches.first : null;
        }

        await controller.payEmi(emi, linkedAccount);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'EMI marked as paid${linkedAccount != null && linkedAccount.type == AccountType.credit ? " and updated ${linkedAccount.name}" : ""}',
              ),
              backgroundColor: AppColors.greenDark,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Text(
        'MARK PAID',
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showEmiOptions(
    BuildContext context,
    EmiModel emi,
    EmiController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.softBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emi.title,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.edit_outlined,
              title: 'Edit EMI',
              color: AppColors.primaryPurple,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEmiScreen(emiToEdit: emi),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              icon: Icons.delete_outline,
              title: 'Delete EMI',
              color: AppColors.redAlertText,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, emi, controller);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    EmiModel emi,
    EmiController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete EMI',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${emi.title}?',
          style: const TextStyle(color: AppColors.textGray),
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
              controller.deleteEmi(emi.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redAlertText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
