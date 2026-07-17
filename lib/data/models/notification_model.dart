enum NotificationType {
  transaction,
  loan,
  termDeposit,
  card,
  upi,
  wallet,
  offer,
  security,
  system,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  bool isRead;

  /// Set only for notifications fetched from the real mailbox API
  /// (alerts/mails/mailers) — null for the locally-generated mock
  /// notifications created after bill pay / send money / transfer
  /// actions. Used to know which API call to make when marking as read,
  /// and to distinguish server-sourced items when refreshing (so a
  /// reload doesn't duplicate or wipe out local ones).
  final String? serverMessageIdValue;
  final String? serverMessageIdDisplayValue;
  final String? rawMessageType; // 'A' (alert), 'M'/'B' (mail), as sent by OBDX

  /// Which mailbox endpoint this came from: 'alert' | 'mail' | 'mailer' |
  /// null (locally-generated). Deliberately separate from [rawMessageType]
  /// — that's OBDX's own message-type code and isn't guaranteed to be
  /// distinct/consistent across the three endpoints, so tab-filtering in
  /// the UI keys off this instead of trying to infer source from it.
  final String? serverSource;

  bool get isServerSourced => serverSource != null;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.serverMessageIdValue,
    this.serverMessageIdDisplayValue,
    this.rawMessageType,
    this.serverSource,
  });

  /// Builds a [NotificationModel] from one entry in the confirmed live
  /// `alertDTOs` array (GET /digx-common/collaboration/v1/mailbox/alerts).
  factory NotificationModel.fromAlertJson(
    Map<String, dynamic> json, {
    required String userId,
  }) {
    final messageId = json['messageId'];
    final value = messageId is Map ? messageId['value']?.toString() : null;
    final displayValue =
        messageId is Map ? messageId['displayValue']?.toString() : null;

    final mappings = json['messageUserMappings'];
    String? status;
    if (mappings is List && mappings.isNotEmpty && mappings.first is Map) {
      status = (mappings.first as Map)['status']?.toString();
    }

    return NotificationModel(
      id: 'alert_${value ?? displayValue ?? json['creationDate']}',
      userId: userId,
      title: (json['subject'] ?? 'Alert').toString(),
      body: _stripHtml((json['messageBody'] ?? '').toString()),
      type: NotificationType.security,
      createdAt: DateTime.tryParse(json['creationDate']?.toString() ?? '') ??
          DateTime.now(),
      isRead: status == 'R',
      serverMessageIdValue: value,
      serverMessageIdDisplayValue: displayValue,
      rawMessageType: (json['messageType'] ?? 'A').toString(),
      serverSource: 'alert',
    );
  }

  /// Builds a [NotificationModel] from one entry in the `mails` array
  /// (GET /digx-common/collaboration/v1/mailbox/mails).
  ///
  /// ⚠️ The sample response had an empty `mails` array, so the individual
  /// item shape is assumed to mirror `alertDTOs` (same collaboration
  /// module, same messageId/subject/messageBody/messageUserMappings
  /// pattern) — verify field names once a real populated response is
  /// available and adjust if they differ.
  factory NotificationModel.fromMailJson(
    Map<String, dynamic> json, {
    required String userId,
  }) {
    // Reuses the same parsing logic as alerts since the shape is assumed
    // identical; only the resulting NotificationType differs.
    final base = NotificationModel.fromAlertJson(json, userId: userId);
    return NotificationModel(
      id: 'mail_${base.serverMessageIdValue ?? base.createdAt.toIso8601String()}',
      userId: userId,
      title: base.title,
      body: base.body,
      type: NotificationType.system,
      createdAt: base.createdAt,
      isRead: base.isRead,
      serverMessageIdValue: base.serverMessageIdValue,
      serverMessageIdDisplayValue: base.serverMessageIdDisplayValue,
      rawMessageType: (json['messageType'] ?? 'M').toString(),
      serverSource: 'mail',
    );
  }

  /// Builds a [NotificationModel] from one entry in the `mailerUserMapDTOs`
  /// array (GET /digx-common/collaboration/v1/mailbox/mailers) — this is
  /// what backs the "Notifications" tab, matching OBDX's own web portal
  /// where Mails/Alerts/Notifications are three separate mailbox
  /// endpoints, not a locally-invented category.
  ///
  /// ⚠️ Same caveat as mails: the sample response had an empty
  /// `mailerUserMapDTOs` array, so this assumes the same
  /// messageId/subject/messageBody/messageUserMappings shape as alerts —
  /// verify against a populated response and adjust field names if they
  /// differ.
  factory NotificationModel.fromMailerJson(
    Map<String, dynamic> json, {
    required String userId,
  }) {
    final base = NotificationModel.fromAlertJson(json, userId: userId);
    return NotificationModel(
      id: 'mailer_${base.serverMessageIdValue ?? base.createdAt.toIso8601String()}',
      userId: userId,
      title: base.title,
      body: base.body,
      type: NotificationType.system,
      createdAt: base.createdAt,
      isRead: base.isRead,
      serverMessageIdValue: base.serverMessageIdValue,
      serverMessageIdDisplayValue: base.serverMessageIdDisplayValue,
      rawMessageType: (json['messageType'] ?? 'B').toString(),
      serverSource: 'mailer',
    );
  }

  static String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}