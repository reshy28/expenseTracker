import 'package:flutter/material.dart';
import '../../homescreen/views/app_colors.dart';
import '../../root/utils/currency_util.dart';
import '../../root/services/firebase_service.dart';
import '../../settings/models/payment_models.dart';
import '../models/report_model.dart';
import '../services/pdf_service.dart';
import 'package:intl/intl.dart';

class SalaryReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const SalaryReportDetailScreen({super.key, required this.report});

  @override
  State<SalaryReportDetailScreen> createState() =>
      _SalaryReportDetailScreenState();
}

class _SalaryReportDetailScreenState extends State<SalaryReportDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  double _salaryAmount = 0.0;
  List<SalaryExpenseModel> _otherSalaryExpenses = [];
  List<FixedExpenseModel> _salaryFixedExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    final monthKey = DateFormat('yyyy_MM').format(widget.report.date);

    // 1. Load Monthly Config
    final data = await _firestoreService.getMonthlySalaryConfig(monthKey).first;

    // 2. Load Global Fixed Expenses to match IDs
    final allFixed = await _firestoreService.getFixedExpenses().first;

    setState(() {
      _salaryAmount = (data['salaryAmount'] ?? 0.0).toDouble();

      if (data.containsKey('additionalSalaryExpenses')) {
        _otherSalaryExpenses = (data['additionalSalaryExpenses'] as List)
            .map((e) => SalaryExpenseModel.fromMap(e))
            .toList();
      }

      if (data.containsKey('salaryFixedExpenseIds')) {
        final ids = List<String>.from(data['salaryFixedExpenseIds']);
        _salaryFixedExpenses = allFixed
            .where((e) => ids.contains(e.id))
            .toList();
      }

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryPurple),
        ),
      );
    }

    final fixedTotal = _salaryFixedExpenses.fold(
      0.0,
      (sum, e) => sum + e.amount,
    );
    final otherTotal = _otherSalaryExpenses.fold(
      0.0,
      (sum, e) => sum + e.amount,
    );
    final balance = _salaryAmount - fixedTotal - otherTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Salary Ledger',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.report.title.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.textGray.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      await PdfService().generateAndShareSalaryReport(
                        monthTitle: widget.report.title,
                        salaryAmount: _salaryAmount,
                        fixedExpenses: _salaryFixedExpenses,
                        otherExpenses: _otherSalaryExpenses,
                        balance: balance,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.file_download_outlined,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Summary Card
              Container(
                width: double.infinity,
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
                    const Text(
                      'TOTAL SALARY BUDGET',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyUtil.format(_salaryAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          'TOTAL EXPENSES',
                          fixedTotal + otherTotal,
                          Colors.white,
                        ),
                        _buildSummaryItem(
                          'FINAL BALANCE',
                          balance,
                          Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Fixed Expenses Section
              if (_salaryFixedExpenses.isNotEmpty) ...[
                _buildSectionHeader(
                  'FIXED EXPENSES',
                  _salaryFixedExpenses.length,
                ),
                const SizedBox(height: 16),
                ..._salaryFixedExpenses.map(
                  (e) => _buildSimpleTile(e.name, e.amount, 'Recurring'),
                ),
                const SizedBox(height: 32),
              ],

              // Other Expenses Section
              if (_otherSalaryExpenses.isNotEmpty) ...[
                _buildSectionHeader(
                  'OTHER EXPENSES',
                  _otherSalaryExpenses.length,
                ),
                const SizedBox(height: 16),
                ..._otherSalaryExpenses.map(
                  (e) => _buildSimpleTile(
                    e.name,
                    e.amount,
                    DateFormat('dd MMM yyyy').format(e.dateAdded),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              if (_salaryFixedExpenses.isEmpty && _otherSalaryExpenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64),
                    child: Text(
                      'No salary expenses recorded for this month.',
                      style: TextStyle(
                        color: AppColors.textGray.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
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

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyUtil.format(amount),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
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
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.softBorder,
            borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _buildSimpleTile(String title, double amount, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: AppColors.premiumCardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.textGray.withOpacity(0.6),
                    fontSize: 12,
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
    );
  }
}
