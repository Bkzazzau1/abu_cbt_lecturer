import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../lecturer_workflow/services/lecturer_exam_script_pdf_save.dart';
import '../data/exam_script_archive_state.dart';

class ExamOfficerScriptArchivePdfService {
  const ExamOfficerScriptArchivePdfService();

  Future<Uint8List> buildPdf(
    List<ArchivedExamScript> scripts, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final document = pw.Document();
    pw.MemoryImage? logo;
    try {
      final data = await rootBundle.load('assets/abulogo.png');
      logo = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      logo = null;
    }

    for (final script in scripts) {
      document.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.fromLTRB(40, 34, 40, 42),
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Archived Examination Script • Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ),
          build: (_) => [
            if (logo != null)
              pw.Center(child: pw.Image(logo, width: 54, height: 54)),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text(
                'AHMADU BELLO UNIVERSITY, ZARIA',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Department of Computer Science • Examination Script Archive',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.SizedBox(height: 14),
            _metadataTable(script),
            pw.SizedBox(height: 16),
            for (var index = 0; index < script.questions.length; index++) ...[
              _questionBlock(script.questions[index], index),
              pw.SizedBox(height: 12),
            ],
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Marker: ${script.markerName}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Total: ${script.totalScore}/${script.totalMax} • Grade ${script.grade}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Archive: ${script.archivePath}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
      );
    }

    return document.save();
  }

  Future<void> printScripts(
    List<ArchivedExamScript> scripts, {
    required String label,
  }) async {
    if (scripts.isEmpty) return;
    await Printing.layoutPdf(
      name: _fileName(label),
      onLayout: (format) => buildPdf(scripts, pageFormat: format),
    );
  }

  Future<void> downloadScripts(
    List<ArchivedExamScript> scripts, {
    required String label,
  }) async {
    if (scripts.isEmpty) return;
    final bytes = await buildPdf(scripts);
    await saveExamScriptPdf(bytes, _fileName(label));
  }

  String _fileName(String label) {
    final clean = label.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    return '${clean}_exam_scripts.pdf';
  }

  pw.Widget _metadataTable(ArchivedExamScript script) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Session', script.academicSession),
      MapEntry('Semester', script.semester),
      MapEntry('Level', script.level),
      MapEntry('Course', '${script.courseCode} • ${script.courseTitle}'),
      MapEntry('Student', script.studentName),
      MapEntry('Matric Number', script.matricNumber),
      MapEntry('Marker', script.markerName),
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.6),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.1),
        1: pw.FlexColumnWidth(2.9),
      },
      children: [
        for (final row in rows)
          pw.TableRow(
            children: [
              pw.Container(
                color: PdfColors.grey200,
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(
                  row.key,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(row.value),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _questionBlock(ArchivedExamQuestion question, int index) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Question ${index + 1}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(question.question),
          pw.SizedBox(height: 8),
          pw.Text(
            'Candidate Response',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(question.response),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Mark: ${question.mark}/${question.maxMark}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
