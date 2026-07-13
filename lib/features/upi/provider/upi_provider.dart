import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/models/account_model.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/Transactions/provider/transaction_provider.dart';

enum UpiPaymentStatus { idle, processing, success, failed }

class RecentUpiContact {
  final String name;
  final String upiId;
  final String initials;
  final Color avatarColor;

  const RecentUpiContact({
    required this.name,
    required this.upiId,
    required this.initials,
    required this.avatarColor,
  });
}

class UpiProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final AccountProvider _accountProvider;

  UpiProvider(this._authProvider, this._accountProvider);

  UpiPaymentStatus _status = UpiPaymentStatus.idle;
  String _lastTransactionId = '';
  double _lastAmount = 0;
  String _lastReceiverName = '';

  UpiPaymentStatus get status => _status;
  String get lastTransactionId => _lastTransactionId;
  double get lastAmount => _lastAmount;
  String get lastReceiverName => _lastReceiverName;

  // ── Current user UPI ID ────────────────────────────────────────
  String get myUpiId =>
      '${_authProvider.currentUser?.phoneNumber ?? "00000"}@profinch';

  String get myName =>
      _authProvider.currentUser?.username ?? 'Card Holder';

  // ── Account matched to logged-in user (read via AccountProvider, ──
  // the single shared source of truth, so balance changes here are
  // reflected everywhere else in the app — Dashboard, transfers, etc.)
  AccountModel get _myAccount {
    final userId = _authProvider.currentUser?.id ?? '';
    return _accountProvider.accounts.firstWhere(
      (a) => a.userId == userId,
      orElse: () => _accountProvider.accounts.first,
    );
  }

  String get _myAccountId => _selectedAccountId ?? _myAccount.id;

  double get accountBalance =>
      _accountProvider.getAccountById(_myAccountId).availableBalance;

  // ── All accounts for the current user (for the account picker) ─
  List<AccountModel> get userAccounts {
    final userId = _authProvider.currentUser?.id ?? '';
    return _accountProvider.accounts
        .where((a) => a.userId == userId)
        .toList();
  }

  // ── Selected account (user can switch while sending) ──────────
  String? _selectedAccountId;

  String get selectedAccountId => _selectedAccountId ?? _myAccount.id;

  void selectAccount(String accountId) {
    _selectedAccountId = accountId;
    notifyListeners();
  }

  // ── Recent UPI contacts ────────────────────────────────────────
  final List<RecentUpiContact> recentContacts = const [
    RecentUpiContact(
      name: 'Priya Nair',
      upiId: '9123456780@profinch',
      initials: 'PN',
      avatarColor: Color(0xFF8B5CF6),
    ),
    RecentUpiContact(
      name: 'Rahul Mehta',
      upiId: '9988776655@profinch',
      initials: 'RM',
      avatarColor: Color(0xFF0EA5E9),
    ),
    RecentUpiContact(
      name: 'Sneha Rao',
      upiId: '9876501234@profinch',
      initials: 'SR',
      avatarColor: Color(0xFFF59E0B),
    ),
    RecentUpiContact(
      name: 'Karan Singh',
      upiId: '9765432109@profinch',
      initials: 'KS',
      avatarColor: Color(0xFF10B981),
    ),
  ];

  // ── Send money ─────────────────────────────────────────────────
  Future<bool> sendMoney({
    required String receiverUpiId,
    required String receiverName,
    required double amount,
    required String note,
  }) async {
    if (amount <= 0) return false;
    if (amount > accountBalance) return false;

    _status = UpiPaymentStatus.processing;
    _lastAmount = amount;
    _lastReceiverName = receiverName;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final success = amount < accountBalance;

    if (success) {
      _status = UpiPaymentStatus.success;
      _lastTransactionId =
          'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final accountId = _myAccountId;
      _accountProvider.debitAccount(accountId, amount);

      TransactionProvider.instance.recordUpiPayment(
        accountId: accountId,
        amount: amount,
        isCredit: false,
        receiverName: receiverName,
        receiverAccount: receiverUpiId,
        balanceAfter: _accountProvider.getAccountById(accountId).availableBalance,
      );
    } else {
      _status = UpiPaymentStatus.failed;
    }

    notifyListeners();
    return success;
  }

  void resetStatus() {
    _status = UpiPaymentStatus.idle;
    _lastTransactionId = '';
    _lastAmount = 0;
    _lastReceiverName = '';
    notifyListeners();
  }
}