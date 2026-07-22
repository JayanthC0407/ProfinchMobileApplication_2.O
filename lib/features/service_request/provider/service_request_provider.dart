import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/models/content_model.dart';
import 'package:profinch_mobile_application/data/models/service_request_definition_model.dart';
import 'package:profinch_mobile_application/data/models/service_request_submission_model.dart';
import 'package:profinch_mobile_application/data/repositories/service_request_list_item_model.dart';
import 'package:profinch_mobile_application/data/repositories/service_request_lookup_models.dart';
import 'package:profinch_mobile_application/data/repositories/service_request_repository.dart';

class ServiceRequestProvider extends ChangeNotifier {
  final ServiceRequestRepository _repository = ServiceRequestRepository();

  // ── Definitions list (the searchable list on "Raise a new request") ──
  List<ServiceRequestDefinitionModel> definitions = [];
  bool isLoadingDefinitions = false;
  String? definitionsLoadError;

  // ── Categories (fetched alongside definitions, filter isn't wired up
  // in the UI yet since every real response so far came back empty) ──
  List<dynamic> categories = [];

  /// Mirrors what the base app fires when "Raise a new request" opens:
  /// definitions + categories together, not sequentially.
  Future<void> loadDefinitions() async {
    isLoadingDefinitions = true;
    definitionsLoadError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getDefinitions(),
        // "Product" is sent as a literal path segment in the captured
        // request — see the note on ServiceRequestRepository.getCategories.
        _repository.getCategories('Product'),
      ]);
      definitions = results[0] as List<ServiceRequestDefinitionModel>;
      // ignore: unnecessary_cast
      categories = results[1] as List<dynamic>;
    } catch (e) {
      definitionsLoadError = e.toString();
    } finally {
      isLoadingDefinitions = false;
      notifyListeners();
    }
  }

  // ── Selected definition detail + its icon ──────────────────────
  ServiceRequestDefinitionModel? selectedDefinition;
  ContentModel? selectedIcon;
  bool isLoadingDefinitionDetail = false;
  String? definitionDetailLoadError;

  /// Mirrors what fires when a result is tapped: the full definition
  /// (with `form`/`infoNote`) and the icon content it references, in
  /// parallel.
  Future<void> loadDefinitionDetail(String id) async {
    isLoadingDefinitionDetail = true;
    definitionDetailLoadError = null;
    selectedDefinition = null;
    selectedIcon = null;
    notifyListeners();

    try {
      final detail = await _repository.getDefinitionDetail(id);
      selectedDefinition = detail;

      final iconId = detail?.form?.infoNote.icon.value;
      if (iconId != null && iconId.isNotEmpty) {
        selectedIcon = await _repository.getContent(iconId);
      }
    } catch (e) {
      definitionDetailLoadError = e.toString();
    } finally {
      isLoadingDefinitionDetail = false;
      notifyListeners();
    }
  }

  // ── Submission ──────────────────────────────────────────────────
  bool isSubmitting = false;
  String? submitError;
  ServiceRequestSubmissionResult? submissionResult;

  /// Submits the request, then best-effort fetches the feedback template
  /// — a failure there is logged but never surfaces to the user or blocks
  /// the success screen, matching how it behaves in the base app (it's
  /// clearly a secondary, non-critical call fired after the real work is
  /// already done).
  /// Uses [selectedDefinition] (already loaded by [loadDefinitionDetail]
  /// before the user ever reaches a Submit button) rather than taking a
  /// separate id, since the repository now needs `priorityType` off the
  /// definition too — see `ServiceRequestRepository.submitServiceRequest`.
  Future<bool> submit({required String description}) async {
    final definition = selectedDefinition;
    if (definition == null) {
      submitError = 'No service selected — try going back and reopening it.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    submitError = null;
    notifyListeners();

    try {
      submissionResult = await _repository.submitServiceRequest(
        definition: definition,
        description: description,
      );

      try {
        await _repository.getFeedbackTemplate();
      } catch (e) {
        // ignore: avoid_print
        print('[ServiceRequestProvider] feedback template fetch failed '
            '(non-blocking): $e');
      }

      return true;
    } catch (e) {
      submitError = e.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void reset() {
    selectedDefinition = null;
    selectedIcon = null;
    submissionResult = null;
    submitError = null;
    notifyListeners();
  }
  // ── Track Request ────────────────────────────────────────────

  List<ServiceRequestProductModel> trackProducts = [];
  List<ServiceRequestStatusOption> trackStatuses = [];
  bool isLoadingTrackFilters = false;
  String? trackFiltersLoadError;

  /// Mirrors what fires when Track Request opens: products + status enum
  /// together, not sequentially.
  Future<void> loadTrackFilters() async {
    isLoadingTrackFilters = true;
    trackFiltersLoadError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getProducts(),
        _repository.getStatuses(),
      ]);
      trackProducts = results[0] as List<ServiceRequestProductModel>;
      trackStatuses = results[1] as List<ServiceRequestStatusOption>;
    } catch (e) {
      trackFiltersLoadError = e.toString();
    } finally {
      isLoadingTrackFilters = false;
      notifyListeners();
    }
  }

  List<ServiceRequestCategoryModel> trackCategories = [];
  bool isLoadingTrackCategories = false;
  String? trackCategoriesLoadError;

  /// Fired when the user picks a product on the filter form — repopulates
  /// the Category Name dropdown for that product.
  Future<void> loadCategoriesForProduct(String product) async {
    trackCategories = [];
    isLoadingTrackCategories = true;
    trackCategoriesLoadError = null;
    notifyListeners();

    try {
      trackCategories = await _repository.getCategoriesForProduct(product);
    } catch (e) {
      trackCategoriesLoadError = e.toString();
    } finally {
      isLoadingTrackCategories = false;
      notifyListeners();
    }
  }

  List<ServiceRequestListItemModel> trackResults = [];
  bool isSearchingTrackResults = false;
  String? trackSearchError;

  /// True only after Apply has actually been pressed at least once —
  /// distinguishes "haven't searched yet" from "searched, found nothing"
  /// so the UI can show the right empty state for each.
  bool hasSearchedTrackRequests = false;

  Future<void> searchTrackRequests({
    required String categoryType,
    required String product,
    required String status,
  }) async {
    isSearchingTrackResults = true;
    trackSearchError = null;
    notifyListeners();

    try {
      trackResults = await _repository.searchServiceRequests(
        categoryType: categoryType,
        product: product,
        status: status,
      );
      hasSearchedTrackRequests = true;
    } catch (e) {
      trackSearchError = e.toString();
    } finally {
      isSearchingTrackResults = false;
      notifyListeners();
    }
  }

  void resetTrackFilters() {
    trackCategories = [];
    trackResults = [];
    hasSearchedTrackRequests = false;
    trackSearchError = null;
    notifyListeners();
  }

}