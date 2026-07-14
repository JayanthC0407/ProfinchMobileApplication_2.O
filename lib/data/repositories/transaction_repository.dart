import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/data/models/transaction_model.dart';

/// Fetches real transaction history from OBDX, to replace the client-side
/// filtering of [TransactionProvider]'s dummy ledger on the account
/// statement screen. [TransactionProvider] itself is left untouched — it's
/// still the right mechanism for locally-simulated in-app actions (UPI,
/// bill pay, etc.) elsewhere in the app.
class TransactionRepository {
  /// GET /digx-common/dda/v1/demandDeposit/{accountId}/transactions
  ///
  /// [accountId] must be the opaque `id.value` from the demandDeposit
  /// response (i.e. `AccountModel.id`), not the masked display number.
  ///
  /// Sends `fromDate`/`toDate` as `yyyy-MM-dd` — confirmed working. Note
  /// OBDX validates these against its own core banking business date
  /// (see `CommonRepository.getCurrentDate`), NOT the device's wall-clock
  /// time — a `fromDate`/`toDate` later than that business date is
  /// rejected with `DIGX_DDA_051`. Callers should source `fromDate`/
  /// `toDate` from that business date, not `DateTime.now()`.
  Future<List<TransactionModel>> getAccountTransactions({
    required String accountId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

    final query = <String, dynamic>{
      // CPR = "current period" search, matching the Postman example.
      'searchBy': 'CPR',
      // A = All (both debit and credit); OBDX also supports 'D'/'C' alone
      // if you ever want a server-side filtered variant instead of
      // filtering the returned list client-side.
      'transactionType': 'A',
      'locale': 'en',
      if (fromDate != null) 'fromDate': fmt(fromDate),
      if (toDate != null) 'toDate': fmt(toDate),
    };

    final response = await ApiClient.instance.get(
      ApiEndpoints.demandDepositTransactions(accountId),
      queryParameters: query,
    );

    final rawList = response['items'] ?? [];
    if (rawList is! List) return [];

    return rawList
        .whereType<Map>()
        .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Convenience: opening/closing balance + debit/credit totals from the
  /// same response's `summary` block, in case you want to show these on
  /// the statement screen instead of (or alongside) recomputing them
  /// client-side from the transaction list.
  Future<TransactionStatementSummary> getStatementSummary({
    required String accountId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

    final response = await ApiClient.instance.get(
      ApiEndpoints.demandDepositTransactions(accountId),
      queryParameters: {
        'searchBy': 'CPR',
        'transactionType': 'A',
        'locale': 'en',
        if (fromDate != null) 'fromDate': fmt(fromDate),
        if (toDate != null) 'toDate': fmt(toDate),
      },
    );

    return TransactionStatementSummary.fromJson(
      Map<String, dynamic>.from(response['summary'] ?? {}),
    );
  }
}

class TransactionStatementSummary {
  final double openingBalance;
  final double closingBalance;
  final int debitCount;
  final int creditCount;
  final double debitAmount;
  final double creditAmount;

  TransactionStatementSummary({
    required this.openingBalance,
    required this.closingBalance,
    required this.debitCount,
    required this.creditCount,
    required this.debitAmount,
    required this.creditAmount,
  });

  factory TransactionStatementSummary.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    int toInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;

    return TransactionStatementSummary(
      openingBalance: toDouble((json['openingBalance'] as Map?)?['amount']),
      closingBalance: toDouble((json['closingBalance'] as Map?)?['amount']),
      debitCount: toInt(json['debitCount']),
      creditCount: toInt(json['creditCount']),
      debitAmount: toDouble((json['debitAmount'] as Map?)?['amount']),
      creditAmount: toDouble((json['creditAmount'] as Map?)?['amount']),
    );
  }
}