/// Downloads/saves PDF bytes to the user's device, with the actual
/// implementation swapped per-platform at COMPILE time (not runtime).
///
/// This matters because `dart:html` doesn't exist outside web builds —
/// even guarding its use behind `if (kIsWeb)` at runtime still fails to
/// compile on Android/iOS, since the import itself gets resolved for every
/// platform. Conditional exports avoid that: only the matching file for
/// the current platform ever gets compiled in.
export 'pdf_downloader_stub.dart'
if (dart.library.html) 'pdf_downloader_web.dart'
if (dart.library.io) 'pdf_downloader_io.dart';