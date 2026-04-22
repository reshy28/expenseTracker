import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../settings/models/user_model.dart';
import '../models/transaction_model.dart';

import '../../root/services/firebase_service.dart';

class HomeController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserModel _user = UserModel(
    name: 'User',
    email: '',
  );

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  HomeController() {
    _init();
  }

  void _init() {
    // 1. Initial sync with Firebase Auth for immediate display
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user = _user.copyWith(
        name: currentUser.displayName ?? 'User',
        email: currentUser.email ?? '',
      );
    }

    // 2. Listen to profile/settings from the specialized Firestore subcollection
    _firestoreService.getProfile().listen((user) {
      if (user != null) {
        _user = user;
        notifyListeners();
      } else if (currentUser != null) {
        // Fallback to Auth data if Firestore doc doesn't exist
        _user = _user.copyWith(
          name: currentUser.displayName ?? 'User',
          email: currentUser.email ?? '',
        );
        notifyListeners();
      }
    });

    // Listen to transactions
    _firestoreService.getTransactions().listen((transactions) {
      _transactions = transactions;
      _isLoading = false;
      notifyListeners();
    });
  }

  UserModel get user => _user;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  double get budgetSpent {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.date.month == now.month &&
            t.date.year == now.year &&
            t.dateSubtitle != 'EMI Installment' &&
            t.dateSubtitle != 'Loan Initiation')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    // Note: It's better to use TransactionsController for this, 
    // but we keep a pass-through here for Home Screen quick-delete if needed.
    await _firestoreService.deleteTransactionAndUpdateBalance(transaction);
  }
}
