import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/data/models/loan_model.dart';

/// Wires up functionality #8 (Loan and Finance — Balance Overview) from the
/// Phase 1 tracker. Only the dashboard summary is in scope here — apply
/// loan / repay loan / full loan management stay on dummy data since they
/// weren't part of the collected API set.
class LoanRepository {
  /// GET /digx-common/loan/v1/loan
  /// (Postman's "Loan and Finance - Balance Overview" request.)
  Future<List<LoanModel>> getLoanBalanceOverview({required String userId}) async {
    final response = await ApiClient.instance.get(ApiEndpoints.loanList);

    // Confirmed real response shape wraps the list under "accounts" (same
    // key name as the demandDeposit endpoint) — NOT "loans", which was
    // the earlier guess and would have silently returned an empty list.
    final rawList = response['accounts'] ?? response['loans'] ?? response['data'] ?? [];
    if (rawList is! List) return [];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((json) => LoanModel.fromJson(json, userId: userId))
        .toList();
  }

  /// GET /digx-common/loan/v1/loan/{loanId} — full loan details.
  /// Present in the collection under "Loan and Finance - details" but not
  /// part of the Phase 1 scope you picked; included here for when you're
  /// ready to expand into full loan management.
  Future<Map<String, dynamic>> getLoanDetails(String loanId) {
    return ApiClient.instance.get(ApiEndpoints.loanById(loanId));
  }

  Future<Map<String, dynamic>> getLoanSchedule(String loanId) {
    return ApiClient.instance.get(ApiEndpoints.loanSchedule(loanId));
  }

  Future<Map<String, dynamic>> getLoanOutstanding(String loanId) {
    return ApiClient.instance.get(ApiEndpoints.loanOutstanding(loanId));
  }
}