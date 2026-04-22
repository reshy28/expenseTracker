import 'package:flutter/material.dart';
import 'package:mtracker/root/services/firebase_service.dart';

enum ReportMode { salary, analytics }

class ReportsController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Filtering State
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  ReportMode _selectedMode = ReportMode.salary;

  List<DateTime> _availableMonths = [];
  bool _isLoading = true;

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  ReportMode get selectedMode => _selectedMode;
  List<DateTime> get availableMonths => _availableMonths;
  bool get isLoading => _isLoading;

  ReportsController() {
    refreshAvailableMonths();
  }

  Future<void> refreshAvailableMonths() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Profile for Account Creation Date
      final profile = await _firestoreService.getProfile().first;
      final accountCreated = profile?.createdAt ?? DateTime.now();
      final startMonth = DateTime(accountCreated.year, accountCreated.month, 1);

      // 2. Fetch all document IDs from salary_reports
      final snapshot = await _firestoreService.getSalaryReportsSnapshot();
      final Set<DateTime> monthsSet = {};
      final now = DateTime.now();
      final currentMonthLimit = DateTime(now.year, now.month, 1);

      // Add months with actual reports (STRICTLY WITHIN ACCOUNT LIFETIME)
      for (var doc in snapshot.docs) {
        try {
          final parts = doc.id.split('_');
          if (parts.length == 2) {
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final date = DateTime(year, month, 1);
            
            // Only add if it's not before account creation AND not after today
            if (!date.isBefore(startMonth) && !date.isAfter(currentMonthLimit)) {
              monthsSet.add(date);
            }
          }
        } catch (e) {}
      }

      // 3. Ensure current month and account start are always included in the discovery set
      DateTime current = currentMonthLimit;
      while (!current.isBefore(startMonth)) {
        monthsSet.add(current);
        current = DateTime(current.year, current.month - 1, 1);
      }

      final List<DateTime> months = monthsSet.toList();
      months.sort((a, b) => b.compareTo(a));
      _availableMonths = months;

      if (!availableYears.contains(_selectedYear) && availableYears.isNotEmpty) {
        _selectedYear = availableYears.first;
      }
    } catch (e) {
      print('Error fetching available months: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<int> get availableYears {
    final years = _availableMonths.map((m) => m.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years.isEmpty ? [DateTime.now().year] : years;
  }

  void setYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setMonth(int month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setMode(ReportMode mode) {
    _selectedMode = mode;
    notifyListeners();
  }
}
