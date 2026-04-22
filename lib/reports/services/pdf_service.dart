import 'package:mtracker/settings/models/payment_models.dart';
import 'package:pdf/pdf.dart' show PdfColor, PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../homescreen/models/transaction_model.dart';

class PdfService {
  Future<void> generateAndShareReport({
    required String monthTitle,
    required double totalBudget,
    required double totalSpent,
    required double remaining,
    required bool isExceeded,
    required Map<String, double> categoryBreakdown,
    required Map<String, double> bankBreakdown,
    required List<TransactionModel> transactions,
  }) async {
    final baseFont = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    final theme = pw.ThemeData.withFont(base: baseFont, bold: boldFont);

    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(monthTitle),
          pw.SizedBox(height: 24),
          _buildSummary(totalBudget, totalSpent, remaining, isExceeded),
          pw.SizedBox(height: 32),
          if (categoryBreakdown.isNotEmpty) ...[
            _buildSectionTitle('CATEGORY BREAKDOWN'),
            pw.SizedBox(height: 12),
            _buildCategoryTable(categoryBreakdown),
            pw.SizedBox(height: 32),
          ],
          if (bankBreakdown.isNotEmpty) ...[
            _buildSectionTitle('BANK WISE BREAKDOWN'),
            pw.SizedBox(height: 12),
            _buildBankTable(bankBreakdown),
            pw.SizedBox(height: 32),
          ],
          _buildSectionTitle('TRANSACTION HISTORY'),
          pw.SizedBox(height: 12),
          _buildTransactionTable(transactions),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Financial_Report_${monthTitle.replaceAll(' ', '_')}.pdf',
    );
  }

  pw.Widget _buildHeader(String title) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Monthly Financial Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              title.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColor.fromHex('#FB8C00'), // Orange
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSummary(
    double budget,
    double spent,
    double remaining,
    bool isExceeded,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')), // Grey300
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryBox(
            'TOTAL BUDGET',
            'Rs. ${budget.toStringAsFixed(2)}',
            PdfColor.fromHex('#000000'),
          ), // Black
          _buildSummaryBox(
            'TOTAL SPENT',
            'Rs. ${spent.toStringAsFixed(2)}',
            isExceeded
                ? PdfColor.fromHex('#E53935') /* Red */
                : PdfColor.fromHex('#FB8C00') /* Orange */,
          ),
          _buildSummaryBox(
            isExceeded ? 'EXCEEDING' : 'REMAINING',
            'Rs. ${remaining.abs().toStringAsFixed(2)}',
            isExceeded
                ? PdfColor.fromHex('#E53935') /* Red */
                : PdfColor.fromHex('#43A047') /* Green */,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryBox(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColor.fromHex('#616161'), // Grey700
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#212121'), // Grey900
      ),
    );
  }

  pw.Widget _buildCategoryTable(Map<String, double> breakdown) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#EEEEEE')), // Grey200
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F5F5F5'),
          ), // Grey100
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'CATEGORY',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'TOTAL SPENT',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...breakdown.entries.map(
          (e) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(e.key),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Rs. ${e.value.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildBankTable(Map<String, double> breakdown) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#EEEEEE')), // Grey200
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F5F5F5'),
          ), // Grey100
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'ACCOUNT',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'TOTAL SPENT',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...breakdown.entries.map(
          (e) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(e.key),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Rs. ${e.value.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTransactionTable(List<TransactionModel> transactions) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#EEEEEE')), // Grey200
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F5F5F5'),
          ), // Grey100
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'DATE',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'DESCRIPTION',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'TYPE',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'AMOUNT',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...transactions.map(
          (tx) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(tx.title),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(tx.isExpense ? 'Expense' : 'Income'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${tx.isExpense ? '-' : '+'}Rs. ${tx.amount.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    color: tx.isExpense
                        ? PdfColor.fromHex('#E53935')
                        : PdfColor.fromHex('#43A047'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> generateAndShareSalaryReport({
    required String monthTitle,
    required double salaryAmount,
    required List<FixedExpenseModel> fixedExpenses,
    required List<SalaryExpenseModel> otherExpenses,
    required double balance,
  }) async {
    final baseFont = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final theme = pw.ThemeData.withFont(base: baseFont, bold: boldFont);
    final pdf = pw.Document(theme: theme);

    final totalSpent =
        fixedExpenses.fold(0.0, (sum, e) => sum + e.amount) +
        otherExpenses.fold(0.0, (sum, e) => sum + e.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader('Salary Management Ledger'),
          pw.SizedBox(height: 8),
          pw.Text(
            monthTitle.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#FB8C00'),
            ),
          ),
          pw.SizedBox(height: 24),
          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryBox(
                  'TOTAL SALARY',
                  'Rs. ${salaryAmount.toStringAsFixed(2)}',
                  PdfColor.fromHex('#000000'),
                ),
                _buildSummaryBox(
                  'TOTAL SPENT',
                  'Rs. ${totalSpent.toStringAsFixed(2)}',
                  PdfColor.fromHex('#E53935'),
                ),
                _buildSummaryBox(
                  'REMAINING',
                  'Rs. ${balance.toStringAsFixed(2)}',
                  PdfColor.fromHex('#43A047'),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 32),

          if (fixedExpenses.isNotEmpty) ...[
            _buildSectionTitle('FIXED EXPENSES'),
            pw.SizedBox(height: 12),
            _buildFixedExpensesTable(fixedExpenses),
            pw.SizedBox(height: 32),
          ],

          if (otherExpenses.isNotEmpty) ...[
            _buildSectionTitle('OTHER SALARY EXPENSES'),
            pw.SizedBox(height: 12),
            _buildOtherSalaryExpensesTable(otherExpenses),
          ],
        ],
      ),
    );
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Salary_Report_${monthTitle.replaceAll(' ', '_')}.pdf',
    );
  }

  pw.Widget _buildFixedExpensesTable(List<FixedExpenseModel> expenses) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#EEEEEE')),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F5F5')),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'EXPENSE',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'AMOUNT',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...expenses.map(
          (e) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(e.name),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Rs. ${e.amount.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildOtherSalaryExpensesTable(List<SalaryExpenseModel> expenses) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#EEEEEE')),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F5F5')),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'EXPENSE',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'AMOUNT',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...expenses.map(
          (e) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(e.name),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'Rs. ${e.amount.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
