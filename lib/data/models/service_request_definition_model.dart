/// One entry in `form.fields[]` for a service request definition.
///
/// ⚠️ Every real response seen so far has an empty `fields` array (the
/// only definition available, "Activate my Account", doesn't collect
/// structured field input — just the free-text description on the next
/// screen). So the actual per-field shape (label, type, required, etc.)
/// is unconfirmed. This is a minimal placeholder that survives whatever
/// comes back without crashing; if you get a response with populated
/// fields, share it and this becomes a proper typed field/form-builder
/// model instead.
class ServiceRequestField {
  final Map<String, dynamic> raw;
  ServiceRequestField(this.raw);
  factory ServiceRequestField.fromJson(Map<String, dynamic> json) =>
      ServiceRequestField(json);
}

/// The icon/audio reference inside `form.infoNote` — same `{displayValue,
/// value}` id pairing used everywhere else (accounts, party, etc.).
/// `value` is what you pass to `ApiEndpoints.contentById`.
class ContentRef {
  final String? displayValue;
  final String? value;

  ContentRef({this.displayValue, this.value});

  factory ContentRef.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ContentRef();
    return ContentRef(
      displayValue: json['displayValue']?.toString(),
      value: json['value']?.toString(),
    );
  }

  bool get hasValue => value != null && value!.isNotEmpty;
}

class ServiceRequestInfoNote {
  final String header;
  final String description;
  final ContentRef icon;
  final ContentRef audio;

  ServiceRequestInfoNote({
    required this.header,
    required this.description,
    required this.icon,
    required this.audio,
  });

  factory ServiceRequestInfoNote.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ServiceRequestInfoNote(
        header: '',
        description: '',
        icon: ContentRef(),
        audio: ContentRef(),
      );
    }
    return ServiceRequestInfoNote(
      header: (json['header'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      icon: ContentRef.fromJson(json['icon'] as Map<String, dynamic>?),
      audio: ContentRef.fromJson(json['audio'] as Map<String, dynamic>?),
    );
  }
}

/// The `form` block only present on the single-definition detail response
/// (`GET .../definitions/{id}`), not on the list response.
class ServiceRequestForm {
  final String id;
  final String header;
  final ServiceRequestInfoNote infoNote;
  final List<ServiceRequestField> fields;

  ServiceRequestForm({
    required this.id,
    required this.header,
    required this.infoNote,
    required this.fields,
  });

  factory ServiceRequestForm.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ServiceRequestForm(
        id: '',
        header: '',
        infoNote: ServiceRequestInfoNote.fromJson(null),
        fields: [],
      );
    }
    final fieldsList = json['fields'];
    return ServiceRequestForm(
      id: (json['id'] ?? '').toString(),
      header: (json['header'] ?? '').toString(),
      infoNote:
          ServiceRequestInfoNote.fromJson(json['infoNote'] as Map<String, dynamic>?),
      fields: fieldsList is List
          ? fieldsList
              .whereType<Map<String, dynamic>>()
              .map(ServiceRequestField.fromJson)
              .toList()
          : [],
    );
  }
}

/// Builds from either:
///  - `GET .../sr/v1/servicerequest/definitions` (list, no `form`), or
///  - `GET .../sr/v1/servicerequest/definitions/{id}` (single item, `form`
///    populated) — both wrap items in `serviceRequestResponse[]`.
///
/// Confirmed live shape (list item):
/// ```json
/// {
///   "creationDate": "2025-09-15T09:28:43",
///   "categoryType": "Loan Topup",
///   "count": 0,
///   "description": "Activate my Account",
///   "id": "SR0000000103",
///   "active": true,
///   "product": "Loan",
///   "name": "Activate my Account",
///   "priorityType": "M",
///   "requestType": "RT",
///   "roles": ["retailuser"],
///   "validity": 0
/// }
/// ```
/// The detail response additionally has `form` — see [ServiceRequestForm].
class ServiceRequestDefinitionModel {
  final String id;
  final String name;
  final String description;
  final String product;
  final String categoryType;
  final String priorityType;
  final String requestType;
  final bool active;
  final List<String> roles;
  final DateTime? creationDate;
  final ServiceRequestForm? form;

  ServiceRequestDefinitionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.product,
    required this.categoryType,
    required this.priorityType,
    required this.requestType,
    required this.active,
    required this.roles,
    required this.creationDate,
    this.form,
  });

  factory ServiceRequestDefinitionModel.fromJson(Map<String, dynamic> json) {
    final rolesList = json['roles'];
    return ServiceRequestDefinitionModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      product: (json['product'] ?? '').toString(),
      categoryType: (json['categoryType'] ?? '').toString(),
      priorityType: (json['priorityType'] ?? '').toString(),
      requestType: (json['requestType'] ?? '').toString(),
      active: json['active'] == true,
      roles: rolesList is List ? rolesList.map((r) => r.toString()).toList() : [],
      creationDate: DateTime.tryParse(json['creationDate']?.toString() ?? ''),
      form: json['form'] != null
          ? ServiceRequestForm.fromJson(json['form'] as Map<String, dynamic>?)
          : null,
    );
  }

  /// Parses the `serviceRequestResponse[]` wrapper shared by both the
  /// list and single-item detail endpoints.
  static List<ServiceRequestDefinitionModel> listFromResponse(
      Map<String, dynamic> response) {
    final list = response['serviceRequestResponse'];
    if (list is! List) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ServiceRequestDefinitionModel.fromJson)
        .toList();
  }
}
