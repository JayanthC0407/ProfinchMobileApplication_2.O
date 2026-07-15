/// Builds from `GET /digx-common/user/v1/profileConfig`, confirmed shape:
/// ```json
/// {
///   "status": {...},
///   "userProfileConfigDTO": {
///     "version": 1,
///     "generatedPackageId": false,
///     "auditSequence": 1,
///     "personalDetails": [],
///     "contactDetails": []
///   }
/// }
/// ```
/// ⚠️ `personalDetails` and `contactDetails` came back as empty arrays in
/// the sample response, so their item shape is still unknown — this
/// class exposes them as raw `List<dynamic>` rather than typed field
/// lists. If this account has no field-level config set up yet, that
/// might just be how it always looks; if you get a response with actual
/// entries in either list, share it and I'll add a proper
/// `ProfileFieldConfig` (whatever fields it turns out to carry — likely
/// something like field name + editable/visible flags, going by what
/// "profileConfig" usually means in OBDX, but that's a guess until
/// confirmed).
class ProfileConfigModel {
  final int version;
  final bool generatedPackageId;
  final int auditSequence;
  final List<dynamic> personalDetails;
  final List<dynamic> contactDetails;

  ProfileConfigModel({
    required this.version,
    required this.generatedPackageId,
    required this.auditSequence,
    required this.personalDetails,
    required this.contactDetails,
  });

  factory ProfileConfigModel.fromJson(Map<String, dynamic> json) {
    final config =
        (json['userProfileConfigDTO'] as Map<String, dynamic>?) ?? json;
    return ProfileConfigModel(
      version: int.tryParse(config['version']?.toString() ?? '') ?? 0,
      generatedPackageId: config['generatedPackageId'] == true,
      auditSequence:
          int.tryParse(config['auditSequence']?.toString() ?? '') ?? 0,
      personalDetails: (config['personalDetails'] as List?) ?? [],
      contactDetails: (config['contactDetails'] as List?) ?? [],
    );
  }
}
