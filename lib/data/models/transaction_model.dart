enum TransactionType { credit, debit }

enum TransactionCategory {
  transfer,
  billPayment,
  upi,
  atm,
  shopping,
  food,
  recharge,
  emi,
  salary,
  refund,
  loan,
  termDeposit,
  wallet,
  insurance,   // ← NEW: covers wallet top-up, wallet-to-bank, wallet payments
}

class TransactionModel {
  final String id;
  final String accountId;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String referenceNumber;
  final double balanceAfter;
  final String? receiverName;
  final String? receiverAccount;

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.referenceNumber,
    required this.balanceAfter,
    this.receiverName,
    this.receiverAccount,
  });

  /// Builds a [TransactionModel] from one entry in the real OBDX
  /// `GET /digx-common/dda/v1/demandDeposit/{accountId}/transactions`
  /// response's `items` array:
  ///
  /// ```json
  /// {
  ///   "postingDate": "2022-12-22T00:00:00",
  ///   "transactionDate": "2022-12-22T00:00:00",
  ///   "accountId": { "displayValue": "xxxxxxxxxxxx0139", "value": "CAA567...2909" },
  ///   "amountInAccountCurrency": { "currency": "GBP", "amount": 5000 },
  ///   "description": "PRINCIPAL Liquidation",
  ///   "userReferenceNumber": "000ZTRF2235606CY",
  ///   "key": { "transactionReferenceNumber": "000ZTRF2235606CY", "subSequenceNumber": "74129" },
  ///   "transactionType": "D",
  ///   "runningBalance": { "currency": "GBP", "amount": 140000 }
  /// }
  /// ```
  ///
  /// Two mapping decisions worth knowing about:
  /// - `transactionType`: `"D"` → debit, `"C"` → credit (confirmed against
  ///   the sample: the one `"C"` entry is the only credit in the
  ///   `summary.creditCount: 1`).
  /// - `category`: OBDX's statement line doesn't carry any category/type
  ///   classification at all — it's just a free-text `description` like
  ///   "PRINCIPAL Liquidation" or "MISCELLANEOUS". Rather than extend the
  ///   shared [TransactionCategory] enum (which would ripple through every
  ///   switch statement across dashboard tiles, filters, and tile icons
  ///   for a category that's really just "bank statement line"), this
  ///   maps every OBDX-sourced transaction to [TransactionCategory.transfer]
  ///   as a neutral default. If you want real bank statement lines
  ///   visually distinct from the in-app simulated categories (UPI, bills,
  ///   etc.), add a dedicated `TransactionCategory.bankStatement` value
  ///   and update the icon/color switches in `transaction_tile_widget.dart`
  ///   and `transaction_tiles.dart` — it's a small, contained change once
  ///   you're ready to spend the time touching every switch site.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

    final accountIdDTO = json['accountId'];
    final amountDTO = json['amountInAccountCurrency'] as Map<String, dynamic>?;
    final runningBalanceDTO = json['runningBalance'] as Map<String, dynamic>?;
    final keyDTO = json['key'] as Map<String, dynamic>?;

    final reference = (json['userReferenceNumber'] ??
            keyDTO?['transactionReferenceNumber'] ??
            '')
        .toString();

    return TransactionModel(
      // transactionReferenceNumber + subSequenceNumber together are the
      // closest thing to a unique row id this endpoint gives us; falls
      // back to the plain reference number if subSequenceNumber is absent.
      id: keyDTO != null
          ? '${keyDTO['transactionReferenceNumber']}-${keyDTO['subSequenceNumber'] ?? ''}'
          : reference,
      accountId: (accountIdDTO is Map ? accountIdDTO['value'] : null)?.toString() ?? '',
      title: (json['description'] ?? 'Transaction').toString(),
      description: reference.isNotEmpty ? 'Ref: $reference' : '',
      amount: toDouble(amountDTO?['amount']),
      type: json['transactionType']?.toString().toUpperCase() == 'C'
          ? TransactionType.credit
          : TransactionType.debit,
      // See class doc above re: no real category data from this endpoint.
      category: TransactionCategory.transfer,
      date: DateTime.tryParse(
            (json['transactionDate'] ?? json['postingDate'])?.toString() ?? '',
          ) ??
          DateTime.now(),
      referenceNumber: reference,
      balanceAfter: toDouble(runningBalanceDTO?['amount']),
      receiverName: null,
      receiverAccount: null,
    );
  }
}