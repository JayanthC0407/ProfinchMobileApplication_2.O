/// A single country entry from
/// `GET /digx-retail/origination/v1/enumerations/country`.
///
/// Confirmed against a real response — shape is:
/// ```json
/// {
///   "status": {...},
///   "enumRepresentations": [
///     { "data": [ {"code": "AD", "value": "AD", "description": "Andorra", "ordinal": 1}, ... ] }
///   ]
/// }
/// ```
/// `code` and `value` are identical in every entry seen so far (both the
/// ISO 3166-1 alpha-2 code) — kept as two separate fields anyway since
/// that's what the API returns and they could diverge for other
/// enumerations that share this same shape.
class CountryModel {
  final String code;
  final String value;
  final String description;
  final int ordinal;

  CountryModel({
    required this.code,
    required this.value,
    required this.description,
    required this.ordinal,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: (json['code'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      ordinal: int.tryParse(json['ordinal']?.toString() ?? '') ?? 0,
    );
  }

  /// Parses the full `enumRepresentations` response into a flat,
  /// ordinal-sorted list. The response wraps the actual list one level
  /// deeper than you'd expect (`enumRepresentations[0].data`), and in
  /// principle could have more than one `data` group, so this flattens
  /// across all of them rather than assuming there's exactly one.
  static List<CountryModel> listFromResponse(Map<String, dynamic> response) {
    final groups = response['enumRepresentations'];
    if (groups is! List) return [];

    final countries = <CountryModel>[];
    for (final group in groups) {
      if (group is! Map<String, dynamic>) continue;
      final data = group['data'];
      if (data is! List) continue;
      countries.addAll(
        data.whereType<Map<String, dynamic>>().map(CountryModel.fromJson),
      );
    }
    countries.sort((a, b) => a.ordinal.compareTo(b.ordinal));
    return countries;
  }
}
