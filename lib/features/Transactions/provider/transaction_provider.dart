import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/models/transaction_model.dart';
import 'package:profinch_mobile_application/data/dummy/dummy_transactions.dart';
import 'package:profinch_mobile_application/data/repositories/transaction_repository.dart';
import 'package:profinch_mobile_application/data/repositories/common_repository.dart';

enum TransactionFilter { all, credit, debit }

class TransactionProvider extends ChangeNotifier {
  // ── Singleton ─────────────────────────────────────────────────
  // One shared instance for the whole app. Any flow — UPI payment,
  // account transfer, debit card withdrawal, loan reimbursement,
  // term deposit, EMI deduction, bill payment, wallet — can call
  // TransactionProvider.instance.addTransaction(...) (or one of the
  // convenience recorders below) and it will immediately appear on
  // the Dashboard and in Transaction History.
  //
  // ── Real data ────────────────────────────────────────────────
  // [_allTransactions] starts seeded with dummy data (so the UI has
  // something to show before login completes) and gets replaced with
  // real OBDX transaction history via [loadFromApi], called once after
  // login (see login_screen.dart) for every CASA account the user has —
  // same convention as AccountProvider.loadAccounts. Anything added
  // in-session afterwards via addTransaction()/the recorders above still
  // layers on top of that real snapshot as usual.
  TransactionProvider._internal();
  static final TransactionProvider instance = TransactionProvider._internal();

  final TransactionRepository _transactionRepository = TransactionRepository();
  final CommonRepository _commonRepository = CommonRepository();

  List<TransactionModel> _allTransactions =
      List.from(DummyTransactions.allTransactions);

  bool isLoading = false;

  /// Set if the last [loadFromApi] call failed — UI can show a retry
  /// banner instead of silently showing stale/dummy data.
  String? loadError;

  List<String> _lastAccountIds = [];

  // ── Active filters ────────────────────────────────────────────
  TransactionFilter _typeFilter = TransactionFilter.all;
  TransactionCategory? _categoryFilter;
  DateTimeRange? _dateRange;
  String _searchQuery = '';

  // ── Getters ───────────────────────────────────────────────────
  TransactionFilter get typeFilter => _typeFilter;
  TransactionCategory? get categoryFilter => _categoryFilter;
  DateTimeRange? get dateRange => _dateRange;
  String get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _typeFilter != TransactionFilter.all ||
      _categoryFilter != null ||
      _dateRange != null ||
      _searchQuery.isNotEmpty;

  // ── All transactions, newest first (ignores active filters) ────
  // Used by the Dashboard, which should always show the latest
  // activity regardless of whatever filters are set on the
  // Transaction History screen.
  List<TransactionModel> get allTransactionsSorted {
    final sorted = List<TransactionModel>.from(_allTransactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Latest [count] transactions — used by the Dashboard's
  /// "Recent Transactions" section.
  List<TransactionModel> recentTransactions({int count = 5}) =>
      allTransactionsSorted.take(count).toList();

  // ── Filtered transactions ─────────────────────────────────────
  List<TransactionModel> get filteredTransactions {
    List<TransactionModel> result = List.from(_allTransactions);

    // Filter by type
    if (_typeFilter == TransactionFilter.credit) {
      result = result.where((t) => t.type == TransactionType.credit).toList();
    } else if (_typeFilter == TransactionFilter.debit) {
      result = result.where((t) => t.type == TransactionType.debit).toList();
    }

    // Filter by category
    if (_categoryFilter != null) {
      result = result.where((t) => t.category == _categoryFilter).toList();
    }

    // Filter by date range
    if (_dateRange != null) {
      result = result.where((t) =>
        t.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
        t.date.isBefore(_dateRange!.end.add(const Duration(days: 1)))
      ).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) =>
        t.title.toLowerCase().contains(q) ||
        t.description.toLowerCase().contains(q) ||
        (t.receiverName?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    // Sort by date descending
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  // ── Total credit / debit for filtered results ──────────────────
  double get totalCredit => filteredTransactions
      .where((t) => t.type == TransactionType.credit)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalDebit => filteredTransactions
      .where((t) => t.type == TransactionType.debit)
      .fold(0.0, (sum, t) => sum + t.amount);

  // ── Filter setters ────────────────────────────────────────────
  void setTypeFilter(TransactionFilter filter) {
    _typeFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(TransactionCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearAllFilters() {
    _typeFilter = TransactionFilter.all;
    _categoryFilter = null;
    _dateRange = null;
    _searchQuery = '';
    notifyListeners();
  }

  // ── Real OBDX transaction history ───────────────────────────────
  /// Fetches transactions for every given CASA account over the last
  /// [lookbackDays] days and replaces [_allTransactions] with the merged,
  /// date-sorted result — feeding both the Dashboard's "Recent
  /// Transactions" and the Transaction History screen, since both just
  /// read off this same list.
  ///
  /// Anchors the date range to OBDX's own business date (via
  /// [CommonRepository]) rather than the device clock — see
  /// `CommonRepository`/`AccountStatementScreen` for why: the server
  /// rejects date ranges past its own "today" (DIGX_DDA_051), which in
  /// this sandbox is 2022-12-22, not the real current date.
  ///
  /// Falls back to keeping whatever was already loaded (dummy data on
  /// first run) if the call fails, same as [AccountProvider.loadAccounts]
  /// — so the rest of the app doesn't break if this one call fails.
  Future<void> loadFromApi({
    required List<String> accountIds,
    int lookbackDays = 30,
  }) async {
    if (accountIds.isEmpty) return;
    _lastAccountIds = accountIds;

    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      final today = await _commonRepository.getCurrentDate();
      final fromDate = today.subtract(Duration(days: lookbackDays));

      // One call per account, in parallel, then merge.
      final perAccountResults = await Future.wait(
        accountIds.map(
          (id) => _transactionRepository.getAccountTransactions(
            accountId: id,
            fromDate: fromDate,
            toDate: today,
          ),
        ),
      );

      final merged = perAccountResults.expand((list) => list).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (merged.isNotEmpty) {
        _allTransactions = merged;
      }
    } catch (e) {
      loadError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Re-runs [loadFromApi] with whichever account ids were used last —
  /// for a "Retry" button after a failed load, without the caller needing
  /// to re-supply the account list.
  Future<void> refresh() => loadFromApi(accountIds: _lastAccountIds);


  // ── Record a new transaction ────────────────────────────────────
  // The generic entry point. Call this from any flow once it has
  // actually succeeded (after the API/local update confirms it),
  // never optimistically before that.
  TransactionModel addTransaction({
    required String accountId,
    required String title,
    required String description,
    required double amount,
    required TransactionType type,
    required TransactionCategory category,
    double? balanceAfter,
    String? receiverName,
    String? receiverAccount,
    DateTime? date,
  }) {
    final txn = TransactionModel(
      id: 'TXN${DateTime.now().microsecondsSinceEpoch}',
      accountId: accountId,
      title: title,
      description: description,
      amount: amount,
      type: type,
      category: category,
      date: date ?? DateTime.now(),
      referenceNumber: 'REF${DateTime.now().microsecondsSinceEpoch}',
      balanceAfter: balanceAfter ?? 0.0,
      receiverName: receiverName,
      receiverAccount: receiverAccount,
    );
    _allTransactions.insert(0, txn);
    notifyListeners();
    return txn;
  }

  // ── Convenience recorders for each flow ─────────────────────────
  // Thin wrappers around addTransaction so the call site at each
  // flow's "success" step stays short, and category/type can't be
  // set inconsistently by accident.

  /// UPI send or receive (Pay to anyone, Receive Money, Scan & Pay).
  void recordUpiPayment({
    required String accountId,
    required double amount,
    required bool isCredit,
    String? receiverName,
    String? receiverAccount,
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: isCredit ? 'UPI Received' : 'UPI Transfer',
      description: isCredit
          ? 'Received from ${receiverName ?? 'UPI contact'}'
          : 'Sent to ${receiverName ?? 'UPI contact'}',
      amount: amount,
      type: isCredit ? TransactionType.credit : TransactionType.debit,
      category: TransactionCategory.upi,
      receiverName: receiverName,
      receiverAccount: receiverAccount,
      balanceAfter: balanceAfter,
    );
  }

  /// Account-to-account / beneficiary transfer (NEFT, IMPS, etc.).
  void recordAccountTransfer({
    required String accountId,
    required double amount,
    required String receiverName,
    String? receiverAccount,
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: 'Money Transfer',
      description: 'Transferred to $receiverName',
      amount: amount,
      type: TransactionType.debit,
      category: TransactionCategory.transfer,
      receiverName: receiverName,
      receiverAccount: receiverAccount,
      balanceAfter: balanceAfter,
    );
  }

  /// Debit card ATM cash withdrawal.
  void recordCardWithdrawal({
    required String accountId,
    required double amount,
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: 'ATM Withdrawal',
      description: 'Cash withdrawal using debit card',
      amount: amount,
      type: TransactionType.debit,
      category: TransactionCategory.atm,
      balanceAfter: balanceAfter,
    );
  }

  /// Loan amount disbursed/reimbursed to the account.
  void recordLoanReimbursement({
    required String accountId,
    required double amount,
    String? loanId,
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: 'Loan Disbursement',
      description:
          loanId != null ? 'Loan amount credited for $loanId' : 'Loan amount credited',
      amount: amount,
      type: TransactionType.credit,
      category: TransactionCategory.loan,
      balanceAfter: balanceAfter,
    );
  }

  /// Money moved out of the account into a new term deposit.
  void recordTermDepositDeduction({
    required String accountId,
    required double amount,
    String? depositId,
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: 'Term Deposit',
      description: depositId != null
          ? 'Amount moved to term deposit $depositId'
          : 'Amount moved to term deposit',
      amount: amount,
      type: TransactionType.debit,
      category: TransactionCategory.termDeposit,
      balanceAfter: balanceAfter,
    );
  }

  /// Term deposit matured and proceeds credited back to the account.
  void recordTermDepositRedemption({
    required String accountId,
    required double amount,
    String? depositId,
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: 'Term Deposit Redeemed',
      description: depositId != null
          ? 'Maturity proceeds for $depositId'
          : 'Term deposit maturity proceeds',
      amount: amount,
      type: TransactionType.credit,
      category: TransactionCategory.termDeposit,
      balanceAfter: balanceAfter,
    );
  }

  /// Monthly EMI deduction against a loan.
  void recordEmiDeduction({
    required String accountId,
    required double amount,
    String? loanId,
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: 'EMI Deduction',
      description: loanId != null ? 'EMI for $loanId' : 'Monthly EMI deduction',
      amount: amount,
      type: TransactionType.debit,
      category: TransactionCategory.emi,
      balanceAfter: balanceAfter,
    );
  }

  // ── Bill payment recorder ──────────────────────────────────────
  /// Called by BillsProvider.payBill() once a bill is successfully
  /// paid. Maps every BillCategory to TransactionCategory.billPayment
  /// so it appears correctly in Transaction History and filtering.
  void recordBillPayment({
    required String accountId,
    required double amount,
    required String billerName,      // e.g. "Home Electricity"
    required String providerName,    // e.g. "BESCOM"
    required String billCategory,    // human-readable label, e.g. "Electricity"
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: '$billCategory Bill — $providerName',
      description: 'Bill payment for $billerName',
      amount: amount,
      type: TransactionType.debit,
      category: TransactionCategory.billPayment,
      receiverName: billerName,
      balanceAfter: balanceAfter,
    );
  }

  // ── Wallet recorders ───────────────────────────────────────────
  /// Bank → Wallet top-up (debit from bank account).
  void recordWalletTopUp({
    required String accountId,
    required double amount,
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: 'Wallet Top-Up',
      description: 'Funds transferred from bank account to wallet',
      amount: amount,
      type: TransactionType.debit,
      category: TransactionCategory.wallet,
      balanceAfter: balanceAfter,
    );
  }

  /// Wallet → Bank transfer (credit back to bank account).
  void recordWalletTransferToBank({
    required String accountId,
    required double amount,
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: 'Wallet to Bank',
      description: 'Funds transferred from wallet to bank account',
      amount: amount,
      type: TransactionType.credit,
      category: TransactionCategory.wallet,
      balanceAfter: balanceAfter,
    );
  }

  /// Payment made from wallet (scan, send).
  void recordWalletPayment({
    required String accountId,
    required double amount,
    String? receiverName,
    double? balanceAfter,
  }) {
    addTransaction(
      accountId: accountId,
      title: 'Wallet Payment',
      description: receiverName != null
          ? 'Paid to $receiverName via wallet'
          : 'Payment from wallet',
      amount: amount,
      type: TransactionType.debit,
      category: TransactionCategory.wallet,
      receiverName: receiverName,
      balanceAfter: balanceAfter,
    );
  }
}