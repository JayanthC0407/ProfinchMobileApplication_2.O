import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/data/models/content_model.dart';
import 'package:profinch_mobile_application/data/models/feedback_template_model.dart';
import 'package:profinch_mobile_application/data/models/service_request_definition_model.dart';
import 'package:profinch_mobile_application/data/models/service_request_submission_model.dart';
import 'package:profinch_mobile_application/data/repositories/service_request_list_item_model.dart';
import 'package:profinch_mobile_application/data/repositories/service_request_lookup_models.dart';

/// Backs the "Service Request" module's "Raise a new request" flow.
/// Confirmed against real captured requests/responses for every call
/// below, GETs and the POST alike — see [submitServiceRequest] for the
/// one open question left (where the typed description goes, if
/// anywhere).
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

  /// Confirmed against a real captured request body:
  /// ```json
  /// {
  ///   "requestType": "OTHERS",
  ///   "entityTypeIdentifier": "SR0000000103",
  ///   "status": "IN",
  ///   "definition": {"id": "SR0000000103"},
  ///   "entity": "AC",
  ///   "entityTypeIdentifierKey": "DE",
  ///   "priorityType": "M",
  ///   "requestData": "{\"elements\":[]}"
  /// }
  /// ```
  /// ⚠️ **The typed description isn't in this payload at all** — no
  /// `description` key, and `requestData.elements` (where you'd expect
  /// per-field form input to live) is empty even though this definition
  /// has a description screen before Confirm. Two possibilities: (a) this
  /// specific definition really doesn't forward the description anywhere
  /// server-side (its `form.fields` is also `[]`, so there may be nothing
  /// for the base app to attach it to), or (b) this capture happened to
  /// be from a submission where nothing was typed. Until you can capture
  /// one with a non-empty description actually typed in, this method
  /// sends the confirmed shape as-is and **silently does not include the
  /// description** — it's accepted as a parameter for the caller's own
  /// use (e.g. local display) but deliberately not put anywhere in the
  /// payload, rather than guessing a key and risking the real field being
  /// silently ignored by OBDX while looking like it worked.
  ///
  /// `requestType: "OTHERS"`, `status: "IN"`, `entity: "AC"`,
  /// `entityTypeIdentifierKey: "DE"` are all hardcoded to the exact
  /// values seen — only one real submission was captured, so whether
  /// these ever vary (e.g. `entity` by product, `requestType` by
  /// category) is unconfirmed. `priorityType` **is** confirmed to come
  /// from the definition (`"M"` matched `definition.priorityType` in the
  /// same capture), so that one's wired dynamically rather than hardcoded.
  Future<ServiceRequestSubmissionResult> submitServiceRequest({
    required ServiceRequestDefinitionModel definition,
    required String description,
  }) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.serviceRequestSubmit,
      data: _buildSubmitPayload(definition),
    );
    return ServiceRequestSubmissionResult.fromJson(response);
  }

  Map<String, dynamic> _buildSubmitPayload(
    ServiceRequestDefinitionModel definition,
  ) {
    return {
      'requestType': 'OTHERS',
      'entityTypeIdentifier': definition.id,
      'status': 'IN',
      'definition': {'id': definition.id},
      'entity': 'AC',
      'entityTypeIdentifierKey': 'DE',
      'priorityType': definition.priorityType,
      'requestData': '{"elements":[]}',
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
  // ── Track Request ────────────────────────────────────────────
  // Everything below backs the Track Request filter form: products +
  // status fire together on open; picking a product fires
  // getCategoriesForProduct; Apply fires searchServiceRequests. All
  // confirmed against real captured requests/responses.

  Future<List<ServiceRequestProductModel>> getProducts() async {
    final response =
        await ApiClient.instance.get(ApiEndpoints.serviceRequestProducts);
    return ServiceRequestProductModel.listFromResponse(response);
  }

  Future<List<ServiceRequestStatusOption>> getStatuses() async {
    final response =
        await ApiClient.instance.get(ApiEndpoints.serviceRequestStatusEnum);
    return ServiceRequestStatusOption.listFromResponse(response);
  }

  /// Same underlying endpoint as [getCategories] (kept separate, typed
  /// version) — Track Request drives this off the user-selected product
  /// rather than the "Raise" flow's literal `"Product"` placeholder, and
  /// this response's `categoryResponse[]` items are now confirmed
  /// (`{categoryName: "Loan Topup"}`), unlike when [getCategories] was
  /// first written against an empty list.
  Future<List<ServiceRequestCategoryModel>> getCategoriesForProduct(
      String product) async {
    final response = await ApiClient.instance
        .get(ApiEndpoints.serviceRequestCategories(product));
    return ServiceRequestCategoryModel.listFromResponse(response);
  }

  /// Confirmed against a real captured request:
  /// `GET .../servicerequest?categoryType=Loan%20Topup&product=Loan&status=RQ`
  /// — query params passed as-is via Dio's `queryParameters` (which
  /// handles the URL-encoding of the space in "Loan Topup" automatically,
  /// no manual encoding needed). Response wrapper (`{"list": [...]}`) is
  /// confirmed; item shape inside it is not — see
  /// `ServiceRequestListItemModel`'s doc comment.
  ///
  /// ⚠️ The filter form also shows From Date / To Date pickers (see your
  /// screenshots), but the one captured query string had no date params
  /// at all — so whatever key names OBDX expects for a date range
  /// (`fromDate`/`toDate`? `startDate`/`endDate`?) are unconfirmed. This
  /// method deliberately does **not** accept from/to date params yet
  /// rather than guessing keys the server would likely just ignore —
  /// capture a query string with the date fields actually filled in and
  /// I'll wire it up.
  Future<List<ServiceRequestListItemModel>> searchServiceRequests({
    required String categoryType,
    required String product,
    required String status,
  }) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.serviceRequestSubmit,
      queryParameters: {
        'categoryType': categoryType,
        'product': product,
        'status': status,
      },
    );
    return ServiceRequestListItemModel.listFromResponse(response);
  }

}