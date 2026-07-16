import 'package:profinch_mobile_application/core/network/api_config.dart';

/// One entry from `userAccessPointRelationship[]` — which channels
/// (internet banking, mobile app, chatbot, etc.) this user has enabled.
/// Not touched by the primary-account flow, but round-tripped as-is since
/// the PUT payload sends the whole object back.
class AccessPointRelationship {
  final String accessPointId;
  final bool status;
  final String determinantValue;

  AccessPointRelationship({
    required this.accessPointId,
    required this.status,
    required this.determinantValue,
  });

  factory AccessPointRelationship.fromJson(Map<String, dynamic> json) {
    return AccessPointRelationship(
      accessPointId: (json['accessPointId'] ?? '').toString(),
      status: json['status'] == true,
      determinantValue: (json['determinantValue'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessPointId': accessPointId,
        'status': status,
        'determinantValue': determinantValue,
      };
}

/// The account id shape used inside `operativeAccount[].accountId` — same
/// `{displayValue, value}` pairing as `demandDeposit`'s `id` field
/// (`AccountModel.accountNumber` / `AccountModel.id`).
class OperativeAccountId {
  final String displayValue;
  final String value;

  OperativeAccountId({required this.displayValue, required this.value});

  factory OperativeAccountId.fromJson(Map<String, dynamic> json) {
    return OperativeAccountId(
      displayValue: (json['displayValue'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'displayValue': displayValue,
        'value': value,
      };
}

/// One entry from `operativeAccount[]` — the primary/default account for
/// a given access-point group (`determinantValue`, e.g. `"OBDX_BU"`). The
/// confirmed sample only has one entry, but this is modeled as a list
/// since that's what the API returns.
class OperativeAccount {
  final String determinantValue;
  final OperativeAccountId accountId;

  OperativeAccount({required this.determinantValue, required this.accountId});

  factory OperativeAccount.fromJson(Map<String, dynamic> json) {
    return OperativeAccount(
      determinantValue: (json['determinantValue'] ?? '').toString(),
      accountId: OperativeAccountId.fromJson(
          (json['accountId'] as Map<String, dynamic>?) ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'determinantValue': determinantValue,
        'accountId': accountId.toJson(),
      };

  OperativeAccount copyWith({OperativeAccountId? accountId}) {
    return OperativeAccount(
      determinantValue: determinantValue,
      accountId: accountId ?? this.accountId,
    );
  }
}

/// Builds from `GET /digx-admin/sms/v1/userPreferences`, confirmed live
/// shape (the whole response body, no wrapper key — unlike party/
/// profileConfig, `status` sits alongside these fields directly rather
/// than nesting them under something like `userPreferencesDTO`):
/// ```json
/// {
///   "status": {...},
///   "userId": "OBDXRETAIL",
///   "feedbackEnabled": true,
///   "liveExpEnabled": true,
///   "userAccessPointRelationship": [ {accessPointId, status, determinantValue}, ... ],
///   "operativeAccount": [ {determinantValue, accountId: {displayValue, value}} ],
///   "otpDeliveryMode": "BOTH"
/// }
/// ```
/// The confirmed PUT payload is this same object with `status` dropped —
/// [toJson] here reflects exactly that (5 fields, no `status` key), copied
/// from the real "Request Payload" you captured.
class UserPreferencesModel {
  final String userId;
  final bool feedbackEnabled;
  final bool liveExpEnabled;
  final List<AccessPointRelationship> userAccessPointRelationship;
  final List<OperativeAccount> operativeAccount;
  final String otpDeliveryMode;

  UserPreferencesModel({
    required this.userId,
    required this.feedbackEnabled,
    required this.liveExpEnabled,
    required this.userAccessPointRelationship,
    required this.operativeAccount,
    required this.otpDeliveryMode,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    final relationships = json['userAccessPointRelationship'];
    final operative = json['operativeAccount'];

    return UserPreferencesModel(
      userId: (json['userId'] ?? '').toString(),
      feedbackEnabled: json['feedbackEnabled'] == true,
      liveExpEnabled: json['liveExpEnabled'] == true,
      userAccessPointRelationship: relationships is List
          ? relationships
              .whereType<Map<String, dynamic>>()
              .map(AccessPointRelationship.fromJson)
              .toList()
          : [],
      operativeAccount: operative is List
          ? operative
              .whereType<Map<String, dynamic>>()
              .map(OperativeAccount.fromJson)
              .toList()
          : [],
      otpDeliveryMode: (json['otpDeliveryMode'] ?? '').toString(),
    );
  }

  /// Exact shape of the confirmed PUT payload — same 5 fields, `status`
  /// left out (it's server-generated on GET, never sent back).
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'feedbackEnabled': feedbackEnabled,
        'liveExpEnabled': liveExpEnabled,
        'operativeAccount': operativeAccount.map((o) => o.toJson()).toList(),
        'otpDeliveryMode': otpDeliveryMode,
        'userAccessPointRelationship':
            userAccessPointRelationship.map((r) => r.toJson()).toList(),
      };

  /// Returns a copy with the operative account for [determinantValue]
  /// (defaults to `OBDX_BU`, the only value seen so far — matches
  /// `ApiConfig.targetUnit`) pointed at the newly selected account.
  /// [accountNumber]/[accountId] should come straight from the selected
  /// `AccountModel` (`.accountNumber` is the masked `displayValue`,
  /// `.id` is the opaque `value` token — same pairing `demandDeposit`
  /// returns them in).
  UserPreferencesModel copyWithPrimaryAccount({
    required String accountNumber,
    required String accountId,
    String determinantValue = ApiConfig.targetUnit,
  }) {
    final newAccountId =
        OperativeAccountId(displayValue: accountNumber, value: accountId);

    final updatedOperative = operativeAccount
        .map((o) => o.determinantValue == determinantValue
            ? o.copyWith(accountId: newAccountId)
            : o)
        .toList();

    return UserPreferencesModel(
      userId: userId,
      feedbackEnabled: feedbackEnabled,
      liveExpEnabled: liveExpEnabled,
      userAccessPointRelationship: userAccessPointRelationship,
      operativeAccount: updatedOperative,
      otpDeliveryMode: otpDeliveryMode,
    );
  }
}
