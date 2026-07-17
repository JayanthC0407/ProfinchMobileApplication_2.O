import 'dart:convert';
import 'dart:typed_data';

/// Builds from `GET /digx-common/content/v1/contents/{id}`, confirmed
/// live shape:
/// ```json
/// {
///   "status": {...},
///   "contentDTOList": [
///     {
///       "contentId": {"displayValue": "20651", "value": "6969993A..."},
///       "title": "PL1.jpg",
///       "mimeType": "image/jpeg",
///       "content": "<base64>",
///       "contentSize": 6266,
///       "updatedBy": "superadmin",
///       "createdDate": "2025-09-15T09:28:03",
///       "shared": true,
///       "moduleIdentifier": "SERVICE_REQUEST_DEFINITION",
///       "toBeDeleted": false
///     }
///   ]
/// }
/// ```
/// Used for the icon referenced by a service request's
/// `form.infoNote.icon` — general-purpose otherwise, keyed by whatever
/// content id you fetch.
class ContentModel {
  final String contentId;
  final String title;
  final String mimeType;

  /// Raw base64 payload — decode via [bytes] rather than using this
  /// directly for display.
  final String base64Content;
  final int contentSize;

  ContentModel({
    required this.contentId,
    required this.title,
    required this.mimeType,
    required this.base64Content,
    required this.contentSize,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    final idObj = (json['contentId'] as Map<String, dynamic>?) ?? {};
    return ContentModel(
      contentId: (idObj['value'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      mimeType: (json['mimeType'] ?? '').toString(),
      base64Content: (json['content'] ?? '').toString(),
      contentSize: int.tryParse(json['contentSize']?.toString() ?? '') ?? 0,
    );
  }

  /// Parses `GET /content/v1/contents/{id}`, which wraps a single item in
  /// `contentDTOList`. Returns null if the list is empty (e.g. a stale/
  /// deleted content id).
  static ContentModel? fromResponse(Map<String, dynamic> response) {
    final list = response['contentDTOList'];
    if (list is! List || list.isEmpty) return null;
    final first = list.first;
    if (first is! Map<String, dynamic>) return null;
    return ContentModel.fromJson(first);
  }

  bool get isImage => mimeType.startsWith('image/');

  Uint8List get bytes => base64Decode(base64Content);
}
