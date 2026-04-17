import 'package:flutter/material.dart';
import '../../homescreen/models/transaction_model.dart';
import '../../homescreen/views/app_colors.dart';
import '../../root/services/firebase_service.dart';

class TransactionsController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  String selectedFilter = 'All'; // Can be 'All', 'Expense', 'Income'
  DateTimeRange? selectedDateRange;
  String searchQuery = '';
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = true;

  TransactionsController() {
    _init();
  }

  void _init() {
    _firestoreService.getTransactions().listen((transactions) {
      _allTransactions = transactions;
      _isLoading = false;
      notifyListeners();
    });
  }

  bool get isLoading => _isLoading;

  List<TransactionModel> get displayedTransactions {
    Iterable<TransactionModel> filtered = _allTransactions;

    if (selectedFilter == 'Expense') {
      filtered = filtered.where((tx) => tx.isExpense);
    } else if (selectedFilter == 'Income') {
      filtered = filtered.where((tx) => !tx.isExpense);
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where(
        (tx) => tx.title.toLowerCase().contains(searchQuery.toLowerCase()),
      );
    }

    if (selectedDateRange != null) {
      filtered = filtered.where((tx) {
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final start = DateTime(
          selectedDateRange!.start.year,
          selectedDateRange!.start.month,
          selectedDateRange!.start.day,
        );
        final end = DateTime(
          selectedDateRange!.end.year,
          selectedDateRange!.end.month,
          selectedDateRange!.end.day,
        );

        return txDate.compareTo(start) >= 0 && txDate.compareTo(end) <= 0;
      });
    }

    return filtered.toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestoreService.saveTransaction(transaction);
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setDateFilter(DateTimeRange? range) {
    selectedDateRange = range;
    notifyListeners();
  }
}
