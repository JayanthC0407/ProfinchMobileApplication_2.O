// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation — triggers a browser download via a Blob + anchor
/// click. Only ever compiled in when building for web (see
/// pdf_downloader.dart's conditional export).
Future<void> downloadPdfBytes(List<int> bytes, String filename) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();

  html.Url.revokeObjectUrl(url);
}