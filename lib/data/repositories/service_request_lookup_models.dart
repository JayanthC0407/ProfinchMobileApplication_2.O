/// One entry from `GET /digx-common/sr/v1/servicerequest/products`,
/// confirmed live shape:
/// ```json
/// {"version": 1, "generatedPackageId": false, "auditSequence": 1, "productName": "Credit Card"}
/// ```
/// Powers the "Product Name" dropdown on the Track Request filter form.
class ServiceRequestProductModel {
  final String productName;

  ServiceRequestProductModel({required this.productName});

  factory ServiceRequestProductModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestProductModel(
      productName: (json['productName'] ?? '').toString(),
    );
  }

  static List<ServiceRequestProductModel> listFromResponse(
      Map<String, dynamic> response) {
    final list = response['productResponse'];
    if (list is! List) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ServiceRequestProductModel.fromJson)
        .toList();
  }
}

/// One entry from `GET .../servicerequest/products/{product}/categories`,
/// confirmed live shape:
/// ```json
/// {"version": 1, "generatedPackageId": false, "auditSequence": 1, "categoryName": "Loan Topup"}
/// ```
/// Powers the "Category Name" dropdown, which repopulates whenever the
/// selected product changes.
class ServiceRequestCategoryModel {
  final String categoryName;

  ServiceRequestCategoryModel({required this.categoryName});

  factory ServiceRequestCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestCategoryModel(
      categoryName: (json['categoryName'] ?? '').toString(),
    );
  }

  static List<ServiceRequestCategoryModel> listFromResponse(
      Map<String, dynamic> response) {
    final list = response['categoryResponse'];
    if (list is! List) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ServiceRequestCategoryModel.fromJson)
        .toList();
  }
}

/// One entry from `GET /digx-common/sr/v1/enumerations/srStatus`. Same
/// wrapped-enum shape as the country enumeration
/// (`enumRepresentations[0].data[]`), confirmed live:
/// ```json
/// {"code": "PE", "value": "PE", "description": "Pending", "ordinal": 1}
/// ```
/// `code`/`value` is what you send back as the `status` query param on
/// Apply (e.g. `"RQ"` for "Requested"); `description` is what's shown in
/// the dropdown.
class ServiceRequestStatusOption {
  final String code;
  final String description;
  final int ordinal;

  ServiceRequestStatusOption({
    required this.code,
    required this.description,
    required this.ordinal,
  });

  factory ServiceRequestStatusOption.fromJson(Map<String, dynamic> json) {
    return ServiceRequestStatusOption(
      code: (json['code'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      ordinal: int.tryParse(json['ordinal']?.toString() ?? '') ?? 0,
    );
  }

  /// Same wrapping/flattening logic as `CountryModel.listFromResponse` —
  /// duplicated here rather than shared, since this is a separate,
  /// smaller model and the two aren't meant to be interchangeable.
  static List<ServiceRequestStatusOption> listFromResponse(
      Map<String, dynamic> response) {
    final groups = response['enumRepresentations'];
    if (groups is! List) return [];

    final options = <ServiceRequestStatusOption>[];
    for (final group in groups) {
      if (group is! Map<String, dynamic>) continue;
      final data = group['data'];
      if (data is! List) continue;
      options.addAll(data
          .whereType<Map<String, dynamic>>()
          .map(ServiceRequestStatusOption.fromJson));
    }
    options.sort((a, b) => a.ordinal.compareTo(b.ordinal));
    return options;
  }
}