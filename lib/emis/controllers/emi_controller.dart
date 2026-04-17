import 'package:flutter/material.dart';
import '../../homescreen/models/emi_model.dart';
import '../../homescreen/views/app_colors.dart';
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
    await _firestoreService.saveEmi(emi);
  }

  Future<void> updateEmi(EmiModel updatedEmi) async {
    await _firestoreService.saveEmi(updatedEmi);
  }

  Future<void> payEmi(String id) async {
    final index = _emis.indexWhere((emi) => emi.id == id);
    if (index != -1) {
      final current = _emis[index];
      if (current.monthsPaid < current.totalMonths) {
        final updated = current.copyWith(
          monthsPaid: current.monthsPaid + 1,
          nextPaymentDate: DateTime(
            current.nextPaymentDate.year,
            current.nextPaymentDate.month + 1,
            current.nextPaymentDate.day,
          ),
        );
        await _firestoreService.saveEmi(updated);
      }
    }
  }

  Future<void> deleteEmi(String id) async {
    await _firestoreService.deleteEmi(id);
  }
}
