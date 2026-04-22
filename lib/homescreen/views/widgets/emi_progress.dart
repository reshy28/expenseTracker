import 'package:mtracker/accounts/controllers/accounts_controller.dart';
import 'package:mtracker/accounts/models/account_model.dart';
import 'package:mtracker/emis/controllers/emi_controller.dart';
import 'package:mtracker/emis/views/emi_manager_screen.dart';
import 'package:mtracker/root/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/emi_model.dart';

import '../app_colors.dart';

class EmiProgress extends StatelessWidget {
  final List<EmiModel> emis;

  const EmiProgress({super.key, required this.emis});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EMI Progress',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Pending: ${CurrencyUtil.format(emis.fold(0.0, (sum, emi) => sum + emi.amountLeft))}',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EmiManagerScreen(),
                  ),
                );
              },
              child: const Text(
                'Manage',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (var i = 0; i < emis.length; i++) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppColors.premiumCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: emis[i].color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            emis[i].icon,
                            color: emis[i].color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                emis[i].title,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${CurrencyUtil.format(emis[i].amountLeft)} left • Monthly: ${CurrencyUtil.format(emis[i].monthlyAmount)}',
                                style: TextStyle(
                                  color: AppColors.textGray.withOpacity(0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        color: AppColors.textGray.withOpacity(
                                          0.6,
                                        ),
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        emis[i].ownerName,
                                        style: TextStyle(
                                          color:
                                              emis[i].ownerName.toLowerCase() ==
                                                  'self'
                                              ? AppColors.primaryPurple
                                              : AppColors.progressOrange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (emis[i].accountId != null) ...[
                                    const SizedBox(height: 4),
                                    Builder(
                                      builder: (context) {
                                        final accounts =
                                            Provider.of<AccountsController>(
                                              context,
                                              listen: false,
                                            ).accounts;
                                        final matches = accounts.where(
                                          (a) => a.id == emis[i].accountId,
                                        );
                                        if (matches.isEmpty)
                                          return const SizedBox();
                                        final account = matches.first;
                                        return Row(
                                          children: [
                                            Icon(
                                              account.icon,
                                              color: account.iconColor,
                                              size: 10,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              account.name,
                                              style: TextStyle(
                                                color: AppColors.textGray
                                                    .withOpacity(0.7),
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(emis[i].percentagePaid * 100).toInt()}% Paid',
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${emis[i].monthsLeft} months left',
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                          widthFactor: emis[i].percentagePaid,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  emis[i].color,
                                  emis[i].color.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NEXT DUE',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat(
                                'MMMM dd',
                              ).format(emis[i].nextPaymentDate),
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ENDS ON',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(emis[i].endDate),
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () async {
                            final emiController = Provider.of<EmiController>(
                              context,
                              listen: false,
                            );
                            final accountsController =
                                Provider.of<AccountsController>(
                                  context,
                                  listen: false,
                                );
                            final emi = emis[i];

                            AccountModel? linkedAccount;
                            if (emi.accountId != null) {
                              final matches = accountsController.accounts.where(
                                (a) => a.id == emi.accountId,
                              );
                              linkedAccount = matches.isNotEmpty
                                  ? matches.first
                                  : null;
                            }

                            await emiController.payEmi(emi, linkedAccount);

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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurpleLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Mark Paid',
                              style: TextStyle(
                                color: AppColors.primaryPurple,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < emis.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      ],
    );
  }
}
