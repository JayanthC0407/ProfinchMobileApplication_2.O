import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';

/// Wires up the "Notifications" folder from the Postman collection:
/// mailbox count, alerts, mails, mailers, and marking an alert as read.
///
/// Confirmed live response shapes (see conversation history / the
/// notifications.docx sample responses provided):
///   count   → { status, summary: { items: [ {messageType, unReadCount} ] } }
///   alerts  → { status, alertDTOs: [ {messageId:{displayValue,value},
///               messageType, subject, messageBody, creationDate,
///               messageUserMappings:[{status:'R'|'U'}], ...} ] }
///   mails   → { status, mails: [] }  (empty in the sample — shape for
///               individual mail items wasn't confirmed, so
///               [NotificationRepository.getMails] is best-effort; verify
///               field names once a non-empty response is available)
///   mailers → { status, mailerUserMapDTOs: [] }
class NotificationRepository {
  /// GET /digx-common/collaboration/v1/mailbox/count
  /// Returns unread counts keyed by messageType ('M', 'A', 'B', ...) —
  /// used for a fast badge count without loading full alert/mail bodies.
  Future<Map<String, int>> getUnreadCounts() async {
    final response = await ApiClient.instance.get(ApiEndpoints.mailboxCount);
    final items = response['summary']?['items'];
    final counts = <String, int>{};
    if (items is List) {
      for (final item in items) {
        if (item is Map) {
          final type = item['messageType']?.toString();
          final count = int.tryParse(item['unReadCount']?.toString() ?? '') ?? 0;
          if (type != null) {
            // Sum rather than overwrite — the sample response has two
            // separate 'M' entries, so a plain assignment would drop one.
            counts[type] = (counts[type] ?? 0) + count;
          }
        }
      }
    }
    return counts;
  }

  /// GET /digx-common/collaboration/v1/mailbox/alerts
  Future<List<Map<String, dynamic>>> getAlerts() async {
    final response = await ApiClient.instance.get(ApiEndpoints.mailboxAlerts);
    final list = response['alertDTOs'];
    if (list is! List) return [];
    return list.whereType<Map<String, dynamic>>().toList();
  }

  /// GET /digx-common/collaboration/v1/mailbox/mails
  Future<List<Map<String, dynamic>>> getMails() async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.mailboxMails,
      queryParameters: {'msgFlag': 'T'},
    );
    final list = response['mails'];
    if (list is! List) return [];
    return list.whereType<Map<String, dynamic>>().toList();
  }

  /// GET /digx-common/collaboration/v1/mailbox/mailers
  /// Not currently surfaced in the UI — available for when sender-based
  /// filtering/display is needed.
  Future<List<Map<String, dynamic>>> getMailers() async {
    final response = await ApiClient.instance.get(ApiEndpoints.mailboxMailers);
    final list = response['mailerUserMapDTOs'];
    if (list is! List) return [];
    return list.whereType<Map<String, dynamic>>().toList();
  }

  /// PUT /digx-common/collaboration/v1/mailbox/alerts/{alertId}
  /// Marks a single alert as read. [alertId] is the opaque `messageId.value`
  /// (NOT the masked displayValue) — confirmed from the Postman collection's
  /// {{alertId}} path variable and request body.
  Future<void> markAlertAsRead({
    required String alertId,
    required String displayValue,
  }) async {
    await ApiClient.instance.put(
      ApiEndpoints.mailboxAlertById(alertId),
      data: {
        'messageId': {'displayValue': displayValue, 'value': alertId},
        'messageUserMappings': [
          {'status': 'R'},
        ],
      },
    );
  }
}