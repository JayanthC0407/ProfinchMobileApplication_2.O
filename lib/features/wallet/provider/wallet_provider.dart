import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/dummy/dummy_wallet.dart';
import 'package:profinch_mobile_application/data/models/wallet_model.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/Transactions/provider/transaction_provider.dart';

enum WalletTransactionType { topup, transfer, payment }

class WalletTransaction {
  final String id;
  final String title;
  final double amount;
  final WalletTransactionType type;
  final DateTime date;
  final bool isCredit;

  WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.isCredit,
  });
}

class WalletProvider extends ChangeNotifier {
  final AuthProvider _authProvider;
  final AccountProvider _accountProvider;

  WalletProvider(this._authProvider, this._accountProvider);

  WalletModel _wallet = DummyWallet.wallet;
  bool _isLoading = false;

  WalletModel get wallet => _wallet;
  bool get isLoading => _isLoading;

  double get walletBalance => _wallet.balance;
  double get dailyLimit => _wallet.dailyLimit;
  double get remainingDailyLimit => _wallet.remainingDailyLimit;

  double get accountBalance {
    final userId = _authProvider.currentUser?.id ?? '';
    return _accountProvider.getTotalBalance(userId);
  }

  // Used only by sendFromWallet, which doesn't receive an accountId —
  // wallet payments don't move bank balance, but are still tagged to
  // the user's primary account for transaction history bookkeeping.
  String get _myAccountId {
    final userId = _authProvider.currentUser?.id ?? '';
    return _accountProvider.accounts
        .firstWhere(
          (a) => a.userId == userId,
          orElse: () => _accountProvider.accounts.first,
        )
        .id;
  }

  final List<WalletTransaction> _history = [
    WalletTransaction(
      id: 'WTX001',
      title: 'Top-up from Savings Account',
      amount: 1000.00,
      type: WalletTransactionType.topup,
      date: DateTime(2026, 5, 20, 10, 0),
      isCredit: true,
    ),
    WalletTransaction(
      id: 'WTX002',
      title: 'Swiggy Payment',
      amount: 350.00,
      type: WalletTransactionType.payment,
      date: DateTime(2026, 5, 21, 13, 30),
      isCredit: false,
    ),
    WalletTransaction(
      id: 'WTX003',
      title: 'Transfer to Bank Account',
      amount: 500.00,
      type: WalletTransactionType.transfer,
      date: DateTime(2026, 5, 22, 15, 0),
      isCredit: false,
    ),
    WalletTransaction(
      id: 'WTX004',
      title: 'Top-up from Savings Account',
      amount: 2000.00,
      type: WalletTransactionType.topup,
      date: DateTime(2026, 5, 25, 9, 0),
      isCredit: true,
    ),
    WalletTransaction(
      id: 'WTX005',
      title: 'Amazon Pay',
      amount: 499.00,
      type: WalletTransactionType.payment,
      date: DateTime(2026, 5, 28, 11, 0),
      isCredit: false,
    ),
  ];

  List<WalletTransaction> get history {
    final sorted = List<WalletTransaction>.from(_history);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  // ── Top-up wallet from bank account ───────────────────────────
  Future<bool> topUpWallet({
    required String accountId,
    required double amount,
  }) async {
    if (amount <= 0) return false;
    if (amount > _accountProvider.getAccountById(accountId).availableBalance) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _accountProvider.debitAccount(accountId, amount);

    _wallet = WalletModel(
      id: _wallet.id,
      userId: _wallet.userId,
      balance: _wallet.balance + amount,
      dailyLimit: _wallet.dailyLimit,
      usedTodayLimit: _wallet.usedTodayLimit,
      isActive: _wallet.isActive,
    );

    _history.add(WalletTransaction(
      id: 'WTX${DateTime.now().millisecondsSinceEpoch}',
      title: 'Top-up from Bank Account',
      amount: amount,
      type: WalletTransactionType.topup,
      date: DateTime.now(),
      isCredit: true,
    ));

    TransactionProvider.instance.recordWalletTopUp(
      accountId: accountId,
      amount: amount,
      balanceAfter: _accountProvider.getAccountById(accountId).availableBalance,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ── Transfer wallet balance to bank account ────────────────────
  Future<bool> transferToBank({
    required String accountId,
    required double amount,
  }) async {
    if (amount <= 0) return false;
    if (amount > _wallet.balance) return false;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _wallet = WalletModel(
      id: _wallet.id,
      userId: _wallet.userId,
      balance: _wallet.balance - amount,
      dailyLimit: _wallet.dailyLimit,
      usedTodayLimit: _wallet.usedTodayLimit + amount,
      isActive: _wallet.isActive,
    );

    _accountProvider.creditAccount(accountId, amount);

    _history.add(WalletTransaction(
      id: 'WTX${DateTime.now().millisecondsSinceEpoch}',
      title: 'Transfer to Bank Account',
      amount: amount,
      date: DateTime.now(),
      type: WalletTransactionType.transfer,
      isCredit: false,
    ));

    TransactionProvider.instance.recordWalletTransferToBank(
      accountId: accountId,
      amount: amount,
      balanceAfter: _accountProvider.getAccountById(accountId).availableBalance,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ── ✅ NEW: Send from wallet (used by Send & Scan QR buttons) ──
  Future<bool> sendFromWallet({
    required String receiverName,
    required String receiverUpiId,
    required double amount,
    required String note,
  }) async {
    if (amount <= 0) return false;
    if (amount > _wallet.balance) return false;      // ← checks wallet balance
    if (amount > remainingDailyLimit) return false;  // ← checks daily limit

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // ✅ Debit wallet balance
    _wallet = WalletModel(
      id: _wallet.id,
      userId: _wallet.userId,
      balance: _wallet.balance - amount,
      dailyLimit: _wallet.dailyLimit,
      usedTodayLimit: _wallet.usedTodayLimit + amount,
      isActive: _wallet.isActive,
    );

    // ✅ Add to wallet history
    _history.add(WalletTransaction(
      id: 'WTX${DateTime.now().millisecondsSinceEpoch}',
      title: 'Paid to $receiverName',
      amount: amount,
      type: WalletTransactionType.payment,
      date: DateTime.now(),
      isCredit: false,
    ));

    TransactionProvider.instance.recordWalletPayment(
      accountId: _myAccountId,
      amount: amount,
      receiverName: receiverName,
      balanceAfter: _accountProvider.getAccountById(_myAccountId).availableBalance,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }
}