/// One entry from OBDX's `GET /digx-common/user/v1/me/sessions` response
/// (`userSessionDTOList`), confirmed live shape:
/// ```json
/// {
///   "creationDate": "2026-07-15T11:39:53.000Z",
///   "lastUpdatedDate": "2026-07-15T12:21:05.000Z",
///   "ipAddress": "10.1.0.76",
///   "accessPointId": "APINTERNET",
///   "userName": "obdxretail",
///   "sessionId": "13ogaV3YuRlL4E224BWOkLKQ8rTOPd"
/// }
/// ```
///
/// Notably absent compared to the dummy UI this replaces: no location
/// (city/country) and no device/browser name — just an IP address. Don't
/// synthesize a location from the IP client-side; show the IP as-is.
/// `lastUpdatedDate` is also optional — a session with no activity since
/// creation simply omits it.
class UserSessionModel {
  final String sessionId;
  final String ipAddress;
  final String accessPointId;
  final DateTime creationDate;
  final DateTime? lastUpdatedDate;

  UserSessionModel({
    required this.sessionId,
    required this.ipAddress,
    required this.accessPointId,
    required this.creationDate,
    this.lastUpdatedDate,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      sessionId: (json['sessionId'] ?? '').toString(),
      ipAddress: (json['ipAddress'] ?? '').toString(),
      accessPointId: (json['accessPointId'] ?? '').toString(),
      creationDate:
          DateTime.tryParse(json['creationDate']?.toString() ?? '') ??
              DateTime.now(),
      lastUpdatedDate: json['lastUpdatedDate'] != null
          ? DateTime.tryParse(json['lastUpdatedDate'].toString())
          : null,
    );
  }

  /// Most recent activity on this session — falls back to [creationDate]
  /// if it's never had activity since starting.
  DateTime get lastActive => lastUpdatedDate ?? creationDate;
}