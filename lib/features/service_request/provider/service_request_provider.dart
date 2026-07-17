import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/models/content_model.dart';
import 'package:profinch_mobile_application/data/models/service_request_definition_model.dart';
import 'package:profinch_mobile_application/data/models/service_request_submission_model.dart';
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
  Future<bool> submit({
    required String definitionId,
    required String description,
  }) async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();

    try {
      submissionResult = await _repository.submitServiceRequest(
        definitionId: definitionId,
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
}
