import 'package:dio/dio.dart';
import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/data/models/account_model.dart';

/// Wires up functionality #7 (CASA Summary/Balance), #9 (CASA List and
/// Details — partially), and #10 (CASA Account Statement) from the Phase 1
/// tracker.
class AccountRepository {
  /// GET /digx-common/dda/v1/demandDeposit
  ///
  /// Covers items #7 and #9 (list). There is no separate "account details"
  /// endpoint in the collection — if the UI needs richer per-account detail
  /// than this list returns, either ask the backend team for a
  /// `/demandDeposit/{id}` endpoint, or fall back to filtering this same
  /// list client-side (which is what [getAccountById] below does for now).
  Future<List<AccountModel>> getAccounts({required String userId}) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.demandDeposit,
      queryParameters: {
        'accountType': 'CURRENT,SAVING',
        'status': ['ACTIVE', 'DORMANT'],
      },
    );

    // Confirmed real response shape wraps the list under "accounts".
    final rawList = response['accounts'] ??
        response['demandDeposits'] ??
        response['data'] ??
        [];

    if (rawList is! List) return [];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((json) => AccountModel.fromJson(json, userId: userId))
        .toList();
  }

  /// Best-effort "details" lookup — see note on [getAccounts]. This is a
  /// ⚠️ PARTIAL implementation (tracker item #9 is yellow) since it just
  /// filters the summary list rather than calling a dedicated details API.
  Future<AccountModel?> getAccountById(String accountId, {required String userId}) async {
    final accounts = await getAccounts(userId: userId);
    try {
      return accounts.firstWhere((a) => a.id == accountId || a.accountNumber == accountId);
    } catch (_) {
      return null;
    }
  }

  /// GET /digx-common/dda/v1/demandDeposit/{accountId}/transactions
  /// Covers item #10 (CASA Account Statement).
  Future<List<Map<String, dynamic>>> getStatement({
    required String accountId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.demandDepositTransactions(accountId),
      queryParameters: {
        'searchBy': 'CPR',
        'transactionType': 'A',
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      },
    );

    final rawList = response['transactions'] ?? response['data'] ?? [];
    if (rawList is! List) return [];
    return rawList.whereType<Map<String, dynamic>>().toList();
    // NOTE: intentionally returning raw maps rather than TransactionModel
    // here since the collection has no example response — once you see the
    // real transaction shape, add TransactionModel.fromJson and map here.
  }

  /// GET /digx-common/dda/v1/demandDeposit/{accountId}/transactions
  ///   ?media=application/pdf&mediaFormat=pdf
  /// Downloads the PDF statement as raw bytes.
  Future<List<int>> downloadStatementPdf({required String accountId}) async {
    final dio = ApiClient.instance.raw;
    final response = await dio.get<List<int>>(
      ApiEndpoints.demandDepositTransactions(accountId),
      queryParameters: const {
        'media': 'application/pdf',
        'mediaFormat': 'pdf',
        'searchBy': 'CPR',
        'transactionType': 'A',
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? <int>[];
  }
}