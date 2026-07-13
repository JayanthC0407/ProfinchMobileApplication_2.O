class LoanModel {
  final String id;

  final String userId;

  final String loanType;

  final double principalAmount;

  final double interestRate;

  final int tenureMonths;

  final double emiAmount;

  /// True (see [emiAmount] doc) if the EMI figure is an estimate rather
  /// than the exact server-calculated installment amount.
  final bool emiIsEstimated;

  final double outstandingAmount;

  final double totalAmountRepaid;

  final DateTime startDate;

  final DateTime endDate;

  final String repaymentAccountId;

  final bool autoPayEnabled;

  final int autoPayDate;

  final String status;

  /// Masked display id (e.g. "xxxxxxxxxxxx0099") — safe to show in the UI
  /// in place of [id], which is the long opaque value OBDX expects back
  /// as {loanId} on detail/schedule/outstanding calls.
  final String displayId;

  LoanModel({
    required this.id,
    required this.userId,
    required this.loanType,
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.emiAmount,
    this.emiIsEstimated = false,
    required this.outstandingAmount,
    this.totalAmountRepaid = 0.0,
    required this.startDate,
    required this.endDate,
    required this.repaymentAccountId,
    required this.autoPayEnabled,
    required this.autoPayDate,
    required this.status,
    this.displayId = '',
  });

  /// Builds a [LoanModel] from a single entry in the OBDX
  /// `GET /digx-common/loan/v1/loan` response's `accounts` array.
  ///
  /// Confirmed against a real response — this replaces the earlier
  /// best-guess version.
  ///
  /// ```json
  /// {
  ///   "id": { "displayValue": "xxxxxxxxxxxx0099", "value": "5E69...858610E6A9246" },
  ///   "status": "ACTIVE",
  ///   "type": "LON",
  ///   "currencyCode": "GBP",
  ///   "productDTO": { "name": "Vehicle/Personal Loans", "description": "..." },
  ///   "openingDate": "2022-12-22T00:00:00",
  ///   "partyName": "SAHAM BISWA",
  ///   "approvedAmount": { "currency": "GBP", "amount": 100000 },
  ///   "disbursedAmount": { "currency": "GBP", "amount": 100000 },
  ///   "maturityDate": "2023-12-22T00:00:00",
  ///   "numberOfInstallment": 12,
  ///   "interestRate": 6,
  ///   "outstandingAmount": { "currency": "GBP", "amount": 90000 },
  ///   "totalAmountRepaid": { "currency": "GBP", "amount": 10000 }
  /// }
  /// ```
  ///
  /// ⚠️ This "balance overview" endpoint does NOT return an EMI/installment
  /// amount, `repaymentAccountId`, or auto-pay settings — those aren't
  /// available until you wire up [LoanRepository.getLoanSchedule] /
  /// `getLoanDetails`. Rather than showing 0 (which the loan card would
  /// render as "₹0"), [emiAmount] here is a flat estimate
  /// (`disbursedAmount / numberOfInstallment`, ignoring interest/reducing
  /// balance) — [emiIsEstimated] is set so the UI can flag it as
  /// approximate. Swap in the real figure from the schedule endpoint when
  /// you get to full loan details.
  factory LoanModel.fromJson(Map<String, dynamic> json, {String userId = ''}) {
    double toDouble(dynamic v) => v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    int toInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;

    final idDTO = json['id'];
    final productDTO = json['productDTO'] as Map<String, dynamic>?;
    final disbursedAmount = toDouble((json['disbursedAmount'] as Map?)?['amount']);
    final approvedAmount = toDouble((json['approvedAmount'] as Map?)?['amount']);
    final numberOfInstallment = toInt(json['numberOfInstallment']);
    final principal = disbursedAmount != 0 ? disbursedAmount : approvedAmount;

    return LoanModel(
      id: (idDTO is Map ? idDTO['value'] : null)?.toString() ??
          (json['loanAccountNumber'] ?? '').toString(),
      displayId: (idDTO is Map ? idDTO['displayValue'] : null)?.toString() ?? '',
      userId: userId,
      loanType: (productDTO?['name'] ?? productDTO?['description'] ?? '').toString(),
      principalAmount: principal,
      interestRate: toDouble(json['interestRate']),
      tenureMonths: numberOfInstallment,
      emiAmount: numberOfInstallment > 0 ? principal / numberOfInstallment : 0.0,
      emiIsEstimated: true,
      outstandingAmount: toDouble((json['outstandingAmount'] as Map?)?['amount']),
      totalAmountRepaid: toDouble((json['totalAmountRepaid'] as Map?)?['amount']),
      startDate: DateTime.tryParse(json['openingDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['maturityDate']?.toString() ?? '') ?? DateTime.now(),
      // Not present on this endpoint — see class doc.
      repaymentAccountId: (json['repaymentAccountId'] ?? '').toString(),
      autoPayEnabled: json['autoPayEnabled'] == true,
      autoPayDate: toInt(json['autoPayDate']),
      status: (json['status'] ?? 'ACTIVE').toString(),
    );
  }
}