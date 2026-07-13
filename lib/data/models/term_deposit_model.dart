class TermDepositModel {

  final String id;

  final String userId;

  final String sourceAccountId;

  final double principalAmount;

  final double interestRate;

  final int tenureMonths;

  final DateTime startDate;

  final DateTime maturityDate;

  final double maturityAmount;

  final String status;

  TermDepositModel({
    required this.id,
    required this.userId,
    required this.sourceAccountId,
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.startDate,
    required this.maturityDate,
    required this.maturityAmount,
    required this.status,
  });

  TermDepositModel copyWith({
    String? status,
  }) {
    return TermDepositModel(
      id: id,
      userId: userId,
      sourceAccountId: sourceAccountId,
      principalAmount: principalAmount,
      interestRate: interestRate,
      tenureMonths: tenureMonths,
      startDate: startDate,
      maturityDate: maturityDate,
      maturityAmount: maturityAmount,
      status: status ?? this.status,
    );
  }
}