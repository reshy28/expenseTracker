import 'package:flutter/material.dart';
import '../models/report_model.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsController extends ChangeNotifier {
  // Chart Mock Data
  final List<FlSpot> incomeSpots = const [
    FlSpot(0, 48),
    FlSpot(1, 42),
    FlSpot(2, 55),
    FlSpot(3, 50),
    FlSpot(4, 60),
  ];

  final List<FlSpot> expenseSpots = const [
    FlSpot(0, 30),
    FlSpot(1, 35),
    FlSpot(2, 40),
    FlSpot(3, 25),
    FlSpot(4, 32),
  ];

  // Filtering State
  int _selectedYear = 2026;
  int _selectedMonth = 4; // April

  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;

  void setYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setMonth(int month) {
    _selectedMonth = month;
    notifyListeners();
  }

  // Downloadable Reports List
  final List<ReportModel> _allReports = [
    ReportModel(
      title: 'April 2026',
      format: 'PDF REPORT',
      size: '2.4 MB',
      date: DateTime(2026, 4, 1),
    ),
    ReportModel(
      title: 'March 2026',
      format: 'PDF REPORT',
      size: '2.4 MB',
      date: DateTime(2026, 3, 1),
    ),
    ReportModel(
      title: 'February 2026',
      format: 'PDF REPORT',
      size: '2.2 MB',
      date: DateTime(2026, 2, 1),
    ),
    ReportModel(
      title: 'January 2026',
      format: 'PDF REPORT',
      size: '2.5 MB',
      date: DateTime(2026, 1, 1),
    ),
    ReportModel(
      title: 'December 2025',
      format: 'PDF REPORT',
      size: '2.8 MB',
      date: DateTime(2025, 12, 1),
    ),
    ReportModel(
      title: 'November 2025',
      format: 'PDF REPORT',
      size: '2.1 MB',
      date: DateTime(2025, 11, 1),
    ),
  ];

  List<ReportModel> get availableReports {
    return _allReports
        .where(
          (r) => r.date.year == _selectedYear && r.date.month == _selectedMonth,
        )
        .toList();
  }

  List<int> get availableYears => [2026, 2025];
}
