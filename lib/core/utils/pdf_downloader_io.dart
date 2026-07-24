import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

/// Mobile/desktop implementation — saves via FileSaver. Only ever compiled
/// in when building for a platform with `dart:io` (Android, iOS, desktop),
/// so this file never gets anywhere near a web build either.
Future<void> downloadPdfBytes(List<int> bytes, String filename) async {
  await FileSaver.instance.saveFile(
    name: filename.replaceAll('.pdf', ''),
    bytes: Uint8List.fromList(bytes),
    ext: 'pdf',
  );
}