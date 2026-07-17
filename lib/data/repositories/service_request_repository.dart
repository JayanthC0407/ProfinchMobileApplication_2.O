import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/data/models/content_model.dart';
import 'package:profinch_mobile_application/data/models/feedback_template_model.dart';
import 'package:profinch_mobile_application/data/models/service_request_definition_model.dart';
import 'package:profinch_mobile_application/data/models/service_request_submission_model.dart';

/// Backs the "Service Request" module's "Raise a new request" flow.
/// Confirmed against real GET responses for every read call below; the
/// POST payload shape is a best-effort guess — see [submitServiceRequest].
class ServiceRequestRepository {
  Future<List<ServiceRequestDefinitionModel>> getDefinitions() async {
    final response =
        await ApiClient.instance.get(ApiEndpoints.serviceRequestDefinitions);
    return ServiceRequestDefinitionModel.listFromResponse(response);
  }

  /// ⚠️ The one real response seen (`products/Product/categories`, with
  /// the literal string `"Product"` as the path segment) came back with
  /// `categoryResponse: []`, so the item shape inside that list is
  /// unconfirmed. Kept raw rather than typed until a populated response
  /// is available. `productId` is passed through as-is — worth checking
  /// whether the base app always sends the literal `"Product"` or
  /// substitutes an actual product code once more than one definition
  /// exists to compare against.
  Future<List<dynamic>> getCategories(String productId) async {
    final response = await ApiClient.instance
        .get(ApiEndpoints.serviceRequestCategories(productId));
    final list = response['categoryResponse'];
    return list is List ? list : [];
  }

  Future<ServiceRequestDefinitionModel?> getDefinitionDetail(String id) async {
    final response = await ApiClient.instance
        .get(ApiEndpoints.serviceRequestDefinitionById(id));
    final items = ServiceRequestDefinitionModel.listFromResponse(response);
    return items.isNotEmpty ? items.first : null;
  }

  Future<ContentModel?> getContent(String contentId) async {
    final response =
        await ApiClient.instance.get(ApiEndpoints.contentById(contentId));
    return ContentModel.fromResponse(response);
  }

  /// ⚠️ PAYLOAD NOT CONFIRMED. The real POST was captured with
  /// `Content-Length: 209` but the request body itself wasn't shared —
  /// only the response. This sends the smallest defensible payload (the
  /// two pieces of data the form screen actually collects: which
  /// definition, and the free-text description), matching common OBDX SR
  /// submission conventions, but it has **not** been verified against a
  /// real captured request body. Before relying on this in anything but
  /// a test environment, capture the actual "Request Payload" from the
  /// base app's Network tab for this POST and compare against
  /// [_buildSubmitPayload] below — if OBDX expects e.g. `fields: [...]`
  /// populated even when the form has none, or different key names
  /// (`requestId` vs `id`, `remarks` vs `description`, etc.), this will
  /// need adjusting.
  Future<ServiceRequestSubmissionResult> submitServiceRequest({
    required String definitionId,
    required String description,
  }) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.serviceRequestSubmit,
      data: _buildSubmitPayload(
        definitionId: definitionId,
        description: description,
      ),
    );
    return ServiceRequestSubmissionResult.fromJson(response);
  }

  Map<String, dynamic> _buildSubmitPayload({
    required String definitionId,
    required String description,
  }) {
    return {
      'id': definitionId,
      'description': description,
    };
  }

  /// Fired after a successful submission in the base app, but doesn't
  /// gate showing the success screen — call this best-effort and ignore
  /// failures (see `ServiceRequestProvider.submit`).
  Future<FeedbackTemplateModel> getFeedbackTemplate({
    String roleIdentifier = 'Y',
    String transactionId = 'SR_N_CRT',
  }) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.feedbackTemplate,
      queryParameters: {
        'roleIdentifier': roleIdentifier,
        'transactionId': transactionId,
      },
    );
    return FeedbackTemplateModel.fromJson(response);
  }
}
