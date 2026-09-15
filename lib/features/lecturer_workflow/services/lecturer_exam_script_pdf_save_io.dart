import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<void> saveExamScriptPdf(Uint8List bytes, String filename) async {
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save exam script PDF',
    fileName: filename,
    type: FileType.custom,
    allowedExtensions: const ['pdf'],
  );

  if (path == null || path.trim().isEmpty) return;
  await File(path).writeAsBytes(bytes, flush: true);
}
