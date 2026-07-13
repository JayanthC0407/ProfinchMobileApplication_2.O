class LoanStatementModel {

  final String id;

  final String loanId;

  final DateTime paymentDate;

  final double emiAmount;

  final double principalComponent;

  final double interestComponent;

  final double remainingOutstanding;

  final String status;

  LoanStatementModel({
    required this.id,
    required this.loanId,
    required this.paymentDate,
    required this.emiAmount,
    required this.principalComponent,
    required this.interestComponent,
    required this.remainingOutstanding,
    required this.status,
  });
}