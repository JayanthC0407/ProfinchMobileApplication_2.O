import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/models/loan_statement_model.dart';
import 'package:profinch_mobile_application/data/repositories/loan_repository.dart';

import '../../../data/dummy/dummy_loans.dart';
import '../../../data/models/loan_model.dart';

class LoanProvider extends ChangeNotifier {
  final LoanRepository _repository = LoanRepository();

  List<LoanModel> _loans = List.from(DummyLoans.loans);

  final List<LoanStatementModel> _statements = [];

  bool isLoading = false;
  String? loadError;

  /// Fetches the loan balance overview (#8 Dashboard item) from the real
  /// OBDX `/loan` API and replaces the in-memory list. Falls back to
  /// whatever was already loaded (dummy data on first run) on failure, so
  /// apply/repay loan flows — still mocked, out of Phase 1 API scope —
  /// keep working.
  Future<void> loadLoanBalanceOverview({required String userId}) async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      final fetched = await _repository.getLoanBalanceOverview(userId: userId);
      if (fetched.isNotEmpty) {
        _loans = fetched;
      }
    } catch (e) {
      loadError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<LoanModel> getLoansByUser(String userId) {
    return _loans.where((loan) => loan.userId == userId).toList();
  }

  void addLoan(LoanModel loan) {
    _loans.add(loan);

    notifyListeners();
  }

  void repayLoan(String loanId, double emiAmount) {
    final index = _loans.indexWhere((loan) => loan.id == loanId);

    if (index == -1) return;

    final loan = _loans[index];

    final principalComponent = emiAmount * 0.7;

    final interestComponent = emiAmount * 0.3;

    final updatedOutstanding = loan.outstandingAmount - principalComponent;

    _statements.add(
      LoanStatementModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),

        loanId: loan.id,

        paymentDate: DateTime.now(),

        emiAmount: emiAmount,

        principalComponent: principalComponent,

        interestComponent: interestComponent,

        remainingOutstanding: updatedOutstanding,

        status: "PAID",
      ),
    );

    _loans[index] = LoanModel(
      id: loan.id,
      userId: loan.userId,
      loanType: loan.loanType,
      principalAmount: loan.principalAmount,
      interestRate: loan.interestRate,
      tenureMonths: loan.tenureMonths,
      emiAmount: loan.emiAmount,

      outstandingAmount: updatedOutstanding <= 0 ? 0 : updatedOutstanding,

      startDate: loan.startDate,

      endDate: loan.endDate,

      repaymentAccountId: loan.repaymentAccountId,

      autoPayEnabled: loan.autoPayEnabled,

      autoPayDate: loan.autoPayDate,

      status: updatedOutstanding <= 0 ? "CLOSED" : "ACTIVE", 
      
      currencyCode: '',
    );

    notifyListeners();
  }

  LoanModel? getLoanById(String loanId) {
    try {
      return _loans.firstWhere((loan) => loan.id == loanId);
    } catch (_) {
      return null;
    }
  }

  List<LoanStatementModel> getStatementsByLoan(String loanId) {
    return _statements
        .where((statement) => statement.loanId == loanId)
        .toList();
  }
}
