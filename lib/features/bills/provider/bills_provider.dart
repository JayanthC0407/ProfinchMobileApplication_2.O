import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
// ← NEW: import the shared transaction sink
import 'package:profinch_mobile_application/features/Transactions/provider/transaction_provider.dart';

enum BillCategory {
  electricity,
  water,
  gas,
  dth,
  broadband,
  mobilePostpaid,
}

extension BillCategoryX on BillCategory {
  String get label {
    switch (this) {
      case BillCategory.electricity:    return 'Electricity';
      case BillCategory.water:          return 'Water';
      case BillCategory.gas:            return 'Gas';
      case BillCategory.dth:            return 'DTH';
      case BillCategory.broadband:      return 'Broadband';
      case BillCategory.mobilePostpaid: return 'Mobile Postpaid';
    }
  }

  IconData get icon {
    switch (this) {
      case BillCategory.electricity:    return Icons.electric_bolt_outlined;
      case BillCategory.water:          return Icons.water_drop_outlined;
      case BillCategory.gas:            return Icons.local_fire_department_outlined;
      case BillCategory.dth:            return Icons.satellite_alt_outlined;
      case BillCategory.broadband:      return Icons.wifi_outlined;
      case BillCategory.mobilePostpaid: return Icons.phone_android_outlined;
    }
  }

  Color get color {
    switch (this) {
      case BillCategory.electricity:    return const Color(0xFFF59E0B);
      case BillCategory.water:          return const Color(0xFF0EA5E9);
      case BillCategory.gas:            return const Color(0xFFEF4444);
      case BillCategory.dth:            return const Color(0xFF8B5CF6);
      case BillCategory.broadband:      return const Color(0xFF10B981);
      case BillCategory.mobilePostpaid: return const Color(0xFF0A3D62);
    }
  }
}

enum BillerStatus { paid, unpaid, overdue }

class BillerModel {
  final String id;
  final String nickname;       // e.g. "Home Electricity"
  final String providerName;   // e.g. "BESCOM"
  final BillCategory category;
  final String consumerNumber; // account/consumer ID with provider
  double dueAmount;
  DateTime dueDate;
  BillerStatus status;
  bool reminderEnabled;
  bool autopayEnabled;

  BillerModel({
    required this.id,
    required this.nickname,
    required this.providerName,
    required this.category,
    required this.consumerNumber,
    required this.dueAmount,
    required this.dueDate,
    required this.status,
    this.reminderEnabled = true,
    this.autopayEnabled = false,
  });
}

class BillPaymentRecord {
  final String id;
  final String billerName;
  final BillCategory category;
  final double amount;
  final DateTime paidDate;

  BillPaymentRecord({
    required this.id,
    required this.billerName,
    required this.category,
    required this.amount,
    required this.paidDate,
  });
}

class BillsProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final AccountProvider _accountProvider;

  BillsProvider(this._authProvider, this._accountProvider);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double get accountBalance {
    final userId = _authProvider.currentUser?.id ?? '';
    return _accountProvider.getTotalBalance(userId);
  }

  // ── Saved billers ────────────────────────────────────────────
  final List<BillerModel> _billers = [
    BillerModel(
      id: 'BLR001',
      nickname: 'Home Electricity',
      providerName: 'BESCOM',
      category: BillCategory.electricity,
      consumerNumber: '1234567890',
      dueAmount: 1850.00,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      status: BillerStatus.unpaid,
    ),
    BillerModel(
      id: 'BLR002',
      nickname: 'Mobile Postpaid',
      providerName: 'Airtel',
      category: BillCategory.mobilePostpaid,
      consumerNumber: '9876543210',
      dueAmount: 599.00,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      status: BillerStatus.overdue,
    ),
    BillerModel(
      id: 'BLR003',
      nickname: 'Home WiFi',
      providerName: 'ACT Fibernet',
      category: BillCategory.broadband,
      consumerNumber: 'ACT00112233',
      dueAmount: 999.00,
      dueDate: DateTime.now().add(const Duration(days: 10)),
      status: BillerStatus.unpaid,
      autopayEnabled: true,
    ),
    BillerModel(
      id: 'BLR004',
      nickname: 'DTH Recharge',
      providerName: 'Tata Play',
      category: BillCategory.dth,
      consumerNumber: 'TP998877',
      dueAmount: 350.00,
      dueDate: DateTime.now().add(const Duration(days: 15)),
      status: BillerStatus.paid,
    ),
    BillerModel(
      id: 'BLR005',
      nickname: 'Cooking Gas',
      providerName: 'Indane',
      category: BillCategory.gas,
      consumerNumber: 'IND445566',
      dueAmount: 0.00,
      dueDate: DateTime.now().add(const Duration(days: 28)),
      status: BillerStatus.paid,
    ),
  ];

  List<BillerModel> get billers => _billers;

  List<BillerModel> get unpaidBillers =>
      _billers.where((b) => b.status != BillerStatus.paid).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<BillerModel> get overdueBillers =>
      _billers.where((b) => b.status == BillerStatus.overdue).toList();

  double get totalDueAmount =>
      unpaidBillers.fold(0.0, (sum, b) => sum + b.dueAmount);

  // ── Payment history ──────────────────────────────────────────
  final List<BillPaymentRecord> _history = [
    BillPaymentRecord(
      id: 'BPM001',
      billerName: 'DTH - Tata Play',
      category: BillCategory.dth,
      amount: 350.00,
      paidDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    BillPaymentRecord(
      id: 'BPM002',
      billerName: 'Gas - Indane',
      category: BillCategory.gas,
      amount: 920.00,
      paidDate: DateTime.now().subtract(const Duration(days: 12)),
    ),
    BillPaymentRecord(
      id: 'BPM003',
      billerName: 'Electricity - BESCOM',
      category: BillCategory.electricity,
      amount: 1620.00,
      paidDate: DateTime.now().subtract(const Duration(days: 35)),
    ),
  ];

  List<BillPaymentRecord> get history {
    final sorted = List<BillPaymentRecord>.from(_history);
    sorted.sort((a, b) => b.paidDate.compareTo(a.paidDate));
    return sorted;
  }

  // ── Pay a bill ──────────────────────────────────────────────
  Future<bool> payBill({
    required String billerId,
    required String accountId,
  }) async {
    final index = _billers.indexWhere((b) => b.id == billerId);
    if (index == -1) return false;

    final biller = _billers[index];
    if (biller.dueAmount <= 0) return false;

    final account = _accountProvider.getAccountById(accountId);
    if (biller.dueAmount > account.availableBalance) return false;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // 1. Debit the bank account
    _accountProvider.debitAccount(accountId, biller.dueAmount);

    // 2. Add to bills' own payment history (for BillPaymentHistoryScreen)
    _history.add(BillPaymentRecord(
      id: 'BPM${DateTime.now().millisecondsSinceEpoch}',
      billerName: '${biller.category.label} - ${biller.providerName}',
      category: biller.category,
      amount: biller.dueAmount,
      paidDate: DateTime.now(),
    ));

    // 3. ← NEW: Push into the shared TransactionProvider so this payment
    //    shows up in Transaction History with category "Bill Payment",
    //    is searchable, filterable, and contributes to the debit summary.
    TransactionProvider.instance.recordBillPayment(
      accountId: accountId,
      amount: biller.dueAmount,
      billerName: biller.nickname,
      providerName: biller.providerName,
      billCategory: biller.category.label,
      balanceAfter: _accountProvider.getAccountById(accountId).availableBalance,
    );

    // 4. Mark biller as paid and reset due amount / advance due date
    _billers[index] = BillerModel(
      id: biller.id,
      nickname: biller.nickname,
      providerName: biller.providerName,
      category: biller.category,
      consumerNumber: biller.consumerNumber,
      dueAmount: 0.0,
      dueDate: biller.dueDate.add(const Duration(days: 30)),
      status: BillerStatus.paid,
      reminderEnabled: biller.reminderEnabled,
      autopayEnabled: biller.autopayEnabled,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ── Toggle reminder ─────────────────────────────────────────
  void toggleReminder(String billerId) {
    final index = _billers.indexWhere((b) => b.id == billerId);
    if (index == -1) return;
    _billers[index].reminderEnabled = !_billers[index].reminderEnabled;
    notifyListeners();
  }

  // ── Toggle autopay ──────────────────────────────────────────
  void toggleAutopay(String billerId) {
    final index = _billers.indexWhere((b) => b.id == billerId);
    if (index == -1) return;
    _billers[index].autopayEnabled = !_billers[index].autopayEnabled;
    notifyListeners();
  }

  // ── Add new biller ──────────────────────────────────────────
  void addBiller(BillerModel biller) {
    _billers.add(biller);
    notifyListeners();
  }

  // ── Remove biller ───────────────────────────────────────────
  void removeBiller(String billerId) {
    _billers.removeWhere((b) => b.id == billerId);
    notifyListeners();
  }
}