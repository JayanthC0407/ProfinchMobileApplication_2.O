/// Builds from `POST /digx-common/sr/v1/servicerequest`, confirmed live
/// shape:
/// ```json
/// {
///   "status": {
///     "result": "SUCCESSFUL",
///     "referenceNumber": "2026197004305465",
///     "contextID": "...",
///     "message": {"code": "0", "type": "INFO"},
///     "apiType": "sr"
///   },
///   "referenceNumber": "53"
/// }
/// ```
/// ⚠️ Note there are **two different** `referenceNumber` values here —
/// one inside `status` (long, `"2026197004305465"`) and one at the top
/// level (short, `"53"`). Only one real submission was seen, so which one
/// is "the" reference number to show the user isn't confirmed. This
/// exposes both; [displayReferenceNumber] defaults to the one under
/// `status` since its format (long, date-prefixed-looking) matches what
/// reference numbers typically look like elsewhere in banking UIs — the
/// top-level `"53"` looks more like an internal sequence/count. Worth
/// confirming against a second submission before shipping this to
/// production, since a wrong choice here just means showing a real but
/// unintended value from the response, not a broken app.
class ServiceRequestSubmissionResult {
  final String statusReferenceNumber;
  final String topLevelReferenceNumber;

  ServiceRequestSubmissionResult({
    required this.statusReferenceNumber,
    required this.topLevelReferenceNumber,
  });

  factory ServiceRequestSubmissionResult.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] as Map<String, dynamic>?) ?? {};
    return ServiceRequestSubmissionResult(
      statusReferenceNumber: (status['referenceNumber'] ?? '').toString(),
      topLevelReferenceNumber: (json['referenceNumber'] ?? '').toString(),
    );
  }

  String get displayReferenceNumber => statusReferenceNumber.isNotEmpty
      ? statusReferenceNumber
      : topLevelReferenceNumber;
}
