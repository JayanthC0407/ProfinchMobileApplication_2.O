class LoanModel {

  final String id;

  final String userId;

  final String loanType;

  final double principalAmount;

  final double interestRate;

  final int tenureMonths;

  final double emiAmount;

  final double outstandingAmount;

  final DateTime startDate;

  final DateTime endDate;

  final String repaymentAccountId;

  final bool autoPayEnabled;

  final int autoPayDate;

  final String status;

  LoanModel({
    required this.id,
    required this.userId,
    required this.loanType,
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.emiAmount,
    required this.outstandingAmount,
    required this.startDate,
    required this.endDate,
    required this.repaymentAccountId,
    required this.autoPayEnabled,
    required this.autoPayDate,
    required this.status,
  });

  /// Builds a [LoanModel] from a single entry in the OBDX
  /// `GET /digx-common/loan/v1/loan` response array.
  ///
  /// ⚠️ No example response was saved in the Postman collection. Field
  /// names are best-guess OBDX conventions — verify against a real
  /// response before trusting this in production.
  factory LoanModel.fromJson(Map<String, dynamic> json, {String userId = ''}) {
    double toDouble(dynamic v) => v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    int toInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;

    return LoanModel(
      id: (json['id'] ?? json['loanAccountNumber'] ?? '').toString(),
      userId: userId,
      loanType: (json['loanType'] ?? json['productName'] ?? '').toString(),
      principalAmount: toDouble(json['principalAmount'] ?? json['sanctionedAmount']),
      interestRate: toDouble(json['interestRate']),
      tenureMonths: toInt(json['tenureMonths'] ?? json['tenure']),
      emiAmount: toDouble(json['emiAmount'] ?? json['installmentAmount']),
      outstandingAmount: toDouble(json['outstandingAmount'] ?? json['outstandingBalance']),
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? json['maturityDate']?.toString() ?? '') ??
          DateTime.now(),
      repaymentAccountId: (json['repaymentAccountId'] ?? '').toString(),
      autoPayEnabled: json['autoPayEnabled'] == true,
      autoPayDate: toInt(json['autoPayDate']),
      status: (json['status'] ?? 'ACTIVE').toString(),
    );
  }
}