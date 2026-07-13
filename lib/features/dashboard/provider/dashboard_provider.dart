import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  // ── Account selection ──────────────────────────────────────────
  String? selectedAccountId;

  void selectAccount(String accountId) {
    selectedAccountId = accountId;
    notifyListeners();
  }

  void resetToPrimary(String accountId) {
    selectedAccountId = accountId;
    notifyListeners();
  }

  // ── More / Less services toggle ────────────────────────────────
  bool _showMoreServices = false;
  bool get showMoreServices => _showMoreServices;

  void toggleMoreServices() {
    _showMoreServices = !_showMoreServices;
    notifyListeners();
  }

  bool _isBalanceHidden = true;
  bool get isBalanceHidden => _isBalanceHidden;

  void toggleBalanceVisibility() {
    _isBalanceHidden = !_isBalanceHidden;
    notifyListeners();
  }

  // ── Recent transactions ────────────────────────────────────────
  List<Map<String, dynamic>> transactions = [
    {
      'title': 'Salary Credit',
      'subtitle': 'Salary for May',
      'amount': '+ ₹75,000',
      'color': const Color.fromARGB(255, 94, 194, 97),
      'icon': Icons.arrow_downward,
      'bgColor': const Color(0xffDDF7E3),
    },
  ];
}
