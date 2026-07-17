/// Builds from `GET /digx-common/feedback/v1/feedback/template`, confirmed
/// live shape:
/// ```json
/// {
///   "status": {...},
///   "feedbackEnabled": true,
///   "feedbackTemplateDTO": [],
///   "feedbackforTransaction": "ALWAYS"
/// }
/// ```
/// Fired after a successful service-request submission in the base app,
/// but doesn't block showing the success screen — treat it as best-effort.
/// `feedbackTemplateDTO` came back empty in the sample, so its item shape
/// is unconfirmed; kept raw for now.
class FeedbackTemplateModel {
  final bool feedbackEnabled;
  final List<dynamic> feedbackTemplateDTO;
  final String feedbackForTransaction;

  FeedbackTemplateModel({
    required this.feedbackEnabled,
    required this.feedbackTemplateDTO,
    required this.feedbackForTransaction,
  });

  factory FeedbackTemplateModel.fromJson(Map<String, dynamic> json) {
    return FeedbackTemplateModel(
      feedbackEnabled: json['feedbackEnabled'] == true,
      feedbackTemplateDTO: (json['feedbackTemplateDTO'] as List?) ?? [],
      feedbackForTransaction: (json['feedbackforTransaction'] ?? '').toString(),
    );
  }
}
