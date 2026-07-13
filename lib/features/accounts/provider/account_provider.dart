import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/dummy/dummy_accounts.dart';
import 'package:profinch_mobile_application/data/models/account_model.dart';
import 'package:profinch_mobile_application/data/repositories/account_repository.dart';

class AccountProvider extends ChangeNotifier {
  final AccountRepository _repository = AccountRepository();

  List<AccountModel> _accounts = List.from(DummyAccounts.allAccounts);

  bool isLoading = false;

  /// Set if the last [loadAccounts] call failed — UI can show a retry
  /// banner instead of silently showing stale/dummy data.
  String? loadError;

  /// Fetches CASA accounts (#7 Summary/Balance, #9 List) from the real
  /// OBDX `demandDeposit` API and replaces the in-memory list. Call this
  /// once after login (see login_screen.dart) and again on pull-to-refresh.
  ///
  /// Falls back to keeping whatever was already in [_accounts] (dummy data
  /// on first run) if the call fails, so every other still-mocked feature
  /// (transfers, wallet, UPI, bills, etc.) that reads from this same list
  /// keeps working rather than breaking app-wide.
  Future<void> loadAccounts({required String userId}) async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      final fetched = await _repository.getAccounts(userId: userId);
      if (fetched.isNotEmpty) {
        _accounts = fetched;
      }
    } catch (e) {
      loadError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<AccountModel> get accounts => _accounts;

  List<AccountModel> getAccountsByUserId(String userId) {
    return _accounts
        .where((account) => account.userId == userId)
        .toList();
  }

  double getTotalBalance(String userId) {
    return _accounts
        .where((account) => account.userId == userId)
        .fold(0, (sum, account) => sum + account.availableBalance);
  }

  AccountModel getAccountById(String accountId) {
    return _accounts.firstWhere(
      (account) => account.id == accountId,
    );
  }

  void debitAccount(String accountId, double amount) {
    final index = _accounts.indexWhere(
      (account) => account.id == accountId,
    );
    if (index == -1) return;
    final account = _accounts[index];
    _accounts[index] = account.copyWith(
      balance: account.balance - amount,
      availableBalance: account.availableBalance - amount,
    );
    notifyListeners();
  }

  void creditAccount(String accountId, double amount) {
    final index = _accounts.indexWhere(
      (account) => account.id == accountId,
    );
    if (index == -1) return;
    final account = _accounts[index];
    _accounts[index] = account.copyWith(
      balance: account.balance + amount,
      availableBalance: account.availableBalance + amount,
    );
    notifyListeners();
  }
}