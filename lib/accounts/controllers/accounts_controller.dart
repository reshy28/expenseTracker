import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../../homescreen/views/app_colors.dart';
import '../../root/services/firebase_service.dart';

class AccountsController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<AccountModel> _accounts = [];
  bool _isLoading = true;

  AccountsController() {
    _init();
  }

  void _init() {
    _firestoreService.getAccounts().listen((accounts) {
      _accounts = accounts;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<AccountModel> get accounts => List.unmodifiable(_accounts);
  bool get isLoading => _isLoading;

  Future<void> addAccount(AccountModel account) async {
    await _firestoreService.saveAccount(account);
  }

  Future<void> updateAccount(AccountModel updatedAccount) async {
    await _firestoreService.saveAccount(updatedAccount);
  }

  Future<void> deleteAccount(String id) async {
    await _firestoreService.deleteAccount(id);
  }
}
