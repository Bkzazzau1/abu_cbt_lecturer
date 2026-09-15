import 'dart:typed_data';

import 'package:printing/printing.dart';

Future<void> saveExamScriptPdf(Uint8List bytes, String filename) async {
  await Printing.sharePdf(bytes: bytes, filename: filename);
}
