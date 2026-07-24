/// Fallback used only if the platform has neither `dart:html` nor
/// `dart:io` available — shouldn't happen for any real Flutter target, but
/// keeps the conditional export in pdf_downloader.dart exhaustive rather
/// than silently failing to resolve.
Future<void> downloadPdfBytes(List<int> bytes, String filename) async {
  throw UnsupportedError(
    'PDF download/save is not supported on this platform.',
  );
}