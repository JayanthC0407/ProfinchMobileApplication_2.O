/// Builds from `GET /digx-common/sr/v1/servicerequest?categoryType=...
/// &product=...&status=...`, confirmed wrapper shape:
/// ```json
/// {"status": {...}, "list": []}
/// ```
/// ⚠️ The one real query captured came back with `list: []` (no matching
/// requests), so the shape of an actual item inside that list is
/// **unconfirmed**. The fields below are a best guess based on the same
/// field names used throughout the rest of this API family — id/
/// description/product/categoryType/status/creationDate all appear
/// identically named on `ServiceRequestDefinitionModel`
/// (`.../definitions`), so mirroring them here is the most defensible
/// guess available, but nothing here has been checked against a real
/// non-empty item. If you can trigger a search that actually returns
/// results (e.g. after raising a request, track it before it's
/// resolved), share that response and this becomes fully confirmed.
class ServiceRequestListItemModel {
  final String id;
  final String description;
  final String product;
  final String categoryType;
  final String status;
  final DateTime? creationDate;

  ServiceRequestListItemModel({
    required this.id,
    required this.description,
    required this.product,
    required this.categoryType,
    required this.status,
    required this.creationDate,
  });

  factory ServiceRequestListItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestListItemModel(
      id: (json['id'] ?? '').toString(),
      description: (json['description'] ?? json['name'] ?? '').toString(),
      product: (json['product'] ?? '').toString(),
      categoryType: (json['categoryType'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      creationDate: DateTime.tryParse(json['creationDate']?.toString() ?? ''),
    );
  }

  static List<ServiceRequestListItemModel> listFromResponse(
      Map<String, dynamic> response) {
    final list = response['list'];
    if (list is! List) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ServiceRequestListItemModel.fromJson)
        .toList();
  }
}