import 'package:flutter/material.dart';
import '../../homescreen/models/emi_model.dart';
import '../../accounts/models/account_model.dart';
import '../../root/services/firebase_service.dart';

class EmiController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<EmiModel> _emis = [];
  bool _isLoading = true;

  EmiController() {
    _init();
  }

  void _init() {
    _firestoreService.getEmis().listen((emis) {
      _emis = emis;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<EmiModel> get emis => List.unmodifiable(_emis);
  bool get isLoading => _isLoading;

  List<EmiModel> get activeEmis =>
      _emis.where((e) => e.monthsPaid < e.totalMonths).toList();
  List<EmiModel> get completedEmis =>
      _emis.where((e) => e.monthsPaid == e.totalMonths).toList();

  Future<void> addEmi(EmiModel emi) async {
    await _firestoreService.saveEmiWithInitialDeduction(emi);
  }

  Future<void> updateEmi(EmiModel updatedEmi) async {
    await _firestoreService.saveEmi(updatedEmi);
  }

  Future<void> payEmi(EmiModel emi, AccountModel? account) async {
    await _firestoreService.payEmiAndUpdateBalance(emi, account);
  }

  Future<void> deleteEmi(String id) async {
    await _firestoreService.deleteEmi(id);
  }
}
