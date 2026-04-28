import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mtracker/root/services/firebase_service.dart';
import '../models/payment_models.dart';
import '../../homescreen/views/app_colors.dart';
import '../../homescreen/models/bill_model.dart';
import '../../root/utils/currency_util.dart';

class PaymentMethodsController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // State
  BudgetModel _budget = BudgetModel(amount: 0, accountId: null);
  double _salaryAmount = 0.0;
  List<SalaryExpenseModel> _additionalSalaryExpenses = [];
  List<String> _salaryFixedExpenseIds = [];
  List<FixedExpenseModel> _fixedExpenses = [];
  bool _isLoading = true;

  StreamSubscription? _salarySubscription;
  StreamSubscription? _fixedExpensesSubscription;

  PaymentMethodsController() {
    _init();
  }

  void _init() {
    // Listen to fixed expenses (global)
    _fixedExpensesSubscription = _firestoreService.getFixedExpenses().listen((
      expenses,
    ) {
      _fixedExpenses = expenses;

      notifyListeners();
    });

    // Listen to Salary (Reverted to Global)
    _salarySubscription = _firestoreService.getSalaryConfig().listen((data) {
      if (data.containsKey('budget')) {
        _budget = BudgetModel.fromMap(data['budget']);
      }

      _salaryAmount = (data['salaryAmount'] ?? 0.0).toDouble();

      if (data.containsKey('salaryFixedExpenseIds')) {
        _salaryFixedExpenseIds = List<String>.from(
          data['salaryFixedExpenseIds'],
        );
      }

      if (data.containsKey('additionalSalaryExpenses')) {
        _additionalSalaryExpenses = (data['additionalSalaryExpenses'] as List)
            .map((e) => SalaryExpenseModel.fromMap(e))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _salarySubscription?.cancel();
    _fixedExpensesSubscription?.cancel();
    super.dispose();
  }

  // Getters

  // Header shows current month automatically
  String get currentMonthHeader =>
      DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase();

  BudgetModel get budget => _budget;
  List<FixedExpenseModel> get fixedExpenses =>
      List.unmodifiable(_fixedExpenses);
  double get salaryAmount => _salaryAmount;
  List<SalaryExpenseModel> get additionalSalaryExpenses =>
      List.unmodifiable(_additionalSalaryExpenses);
  List<String> get salaryFixedExpenseIds =>
      List.unmodifiable(_salaryFixedExpenseIds);
  bool get isLoading => _isLoading;

  double get remainingSalaryBalance {
    double fixedTotal = _fixedExpenses
        .where((e) => _salaryFixedExpenseIds.contains(e.id))
        .fold(0.0, (sum, expense) => sum + expense.amount);
    double additionalTotal = _additionalSalaryExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    return _salaryAmount - fixedTotal - additionalTotal;
  }

  List<BillModel> get upcomingBills {
    final bills = _fixedExpenses
        .where((expense) {
          final daysLeft = expense.daysUntilDue;
          return daysLeft >= 0 && daysLeft <= 10;
        })
        .map((expense) {
          return BillModel(
            title: expense.name,
            amount: expense.amount,
            dueDate:
                'Due on ${expense.nextDueDate.day} ${_getMonthName(expense.nextDueDate.month)}',
            dueInDays: expense.daysUntilDue == 0
                ? 'Due Today'
                : 'Due in ${expense.daysUntilDue} days',
            iconName: expense.iconName,
            backgroundColor: expense.backgroundColor,
            iconColor: expense.iconColor,
          );
        })
        .toList();

    bills.sort((a, b) {
      final aDays = _extractDays(a.dueInDays);
      final bDays = _extractDays(b.dueInDays);
      return aDays.compareTo(bDays);
    });

    return bills;
  }

  Future<void> setBudget(double amount, String? accountId) async {
    _budget = BudgetModel(amount: amount, accountId: accountId);
    notifyListeners();
    await _firestoreService.saveSalaryConfig({'budget': _budget.toMap()});
  }

  Future<void> addFixedExpense(FixedExpenseModel expense) async {
    await _firestoreService.saveFixedExpense(expense);
  }

  Future<void> deleteFixedExpense(String id) async {
    await _firestoreService.deleteFixedExpense(id);
  }

  Future<void> setSalaryAmount(double amount) async {
    _salaryAmount = amount;
    notifyListeners();
    await _firestoreService.saveSalaryConfig({'salaryAmount': amount});
  }

  Future<void> addSalaryExpense(SalaryExpenseModel expense) async {
    final newList = List<SalaryExpenseModel>.from(_additionalSalaryExpenses)
      ..add(expense);
    await _firestoreService.saveSalaryConfig({
      'additionalSalaryExpenses': newList.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> updateSalaryExpense(SalaryExpenseModel updatedExpense) async {
    final newList = _additionalSalaryExpenses.map((e) {
      return e.id == updatedExpense.id ? updatedExpense : e;
    }).toList();
    await _firestoreService.saveSalaryConfig({
      'additionalSalaryExpenses': newList.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> deleteSalaryExpense(String id) async {
    final newList = _additionalSalaryExpenses.where((e) => e.id != id).toList();
    await _firestoreService.saveSalaryConfig({
      'additionalSalaryExpenses': newList.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> toggleFixedExpenseInSalary(String id) async {
    final newList = List<String>.from(_salaryFixedExpenseIds);
    if (newList.contains(id)) {
      newList.remove(id);
    } else {
      newList.add(id);
    }
    await _firestoreService.saveSalaryConfig({
      'salaryFixedExpenseIds': newList,
    });
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  int _extractDays(String text) {
    if (text == 'Due Today') return 0;
    final match = RegExp(r'\d+').firstMatch(text);
    return match != null ? int.parse(match.group(0)!) : 999;
  }
}
