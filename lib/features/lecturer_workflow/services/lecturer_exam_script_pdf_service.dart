import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/lecturer_demo_state.dart';

class LecturerExamScriptPdfMetadata {
  const LecturerExamScriptPdfMetadata({
    required this.schoolName,
    required this.faculty,
    required this.department,
    required this.courseCode,
    required this.courseTitle,
    required this.academicSession,
    required this.level,
    required this.matricNumber,
  });

  final String schoolName;
  final String faculty;
  final String department;
  final String courseCode;
  final String courseTitle;
  final String academicSession;
  final String level;
  final String matricNumber;
}

class LecturerExamScriptPdfService {
  const LecturerExamScriptPdfService();

  LecturerExamScriptPdfMetadata metadataFor(LecturerDemoExamScript script) {
    return LecturerExamScriptPdfMetadata(
      schoolName: 'Ahmadu Bello University, Zaria',
      faculty: 'Faculty of Physical Sciences',
      department: 'Department of Computer Science',
      courseCode: script.courseCode,
      courseTitle: _courseTitle(script.examTitle),
      academicSession: '2025/2026',
      level: _level(script.courseCode),
      matricNumber: _matricNumber(script),
    );
  }

  Future<Uint8List> buildPdf(
    LecturerDemoExamScript script, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final metadata = metadataFor(script);
    final document = pw.Document();

    pw.MemoryImage? logo;
    try {
      final data = await rootBundle.load('assets/abulogo.png');
      logo = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      logo = null;
    }

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.fromLTRB(42, 36, 42, 42),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ),
        build: (context) => [
          if (logo != null)
            pw.Center(child: pw.Image(logo, width: 58, height: 58)),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              metadata.schoolName.toUpperCase(),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Center(
            child: pw.Text(
              metadata.faculty,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Center(
            child: pw.Text(
              metadata.department,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'EXAMINATION SCRIPT',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 14),
          _metadataTable(metadata),
          pw.SizedBox(height: 18),
          pw.Divider(thickness: 0.8),
          pw.SizedBox(height: 8),
          for (var index = 0; index < script.questions.length; index++) ...[
            _questionBlock(script, index),
            pw.SizedBox(height: 14),
          ],
          pw.Divider(thickness: 0.8),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Objective Score: ${script.objectiveScore}/40',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              if (script.markingComplete)
                pw.Text(
                  'Total Score: ${script.examScore}/${script.examMax}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
            ],
          ),
        ],
      ),
    );

    return document.save();
  }

  Future<void> printScript(LecturerDemoExamScript script) async {
    final metadata = metadataFor(script);
    await Printing.layoutPdf(
      name: fileName(metadata),
      onLayout: (format) => buildPdf(script, pageFormat: format),
    );
  }

  Future<void> downloadScript(LecturerDemoExamScript script) async {
    final metadata = metadataFor(script);
    final bytes = await buildPdf(script);
    await Printing.sharePdf(bytes: bytes, filename: fileName(metadata));
  }

  String fileName(LecturerExamScriptPdfMetadata metadata) {
    final course = metadata.courseCode.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    final matric = metadata.matricNumber.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    return '${course}_${matric}_exam_script.pdf';
  }

  pw.Widget _metadataTable(LecturerExamScriptPdfMetadata metadata) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Course Code', metadata.courseCode),
      MapEntry('Course Title', metadata.courseTitle),
      MapEntry('Academic Session', metadata.academicSession),
      MapEntry('Level', metadata.level),
      MapEntry('Matric Number', metadata.matricNumber),
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.6),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.15),
        1: pw.FlexColumnWidth(2.85),
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

  pw.Widget _questionBlock(LecturerDemoExamScript script, int index) {
    final question = script.questions[index];
    final mark = script.marks[question.id];

    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Question ${index + 1}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(question.question),
          pw.SizedBox(height: 9),
          pw.Text(
            'Response',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(question.candidateAnswer),
          if (mark != null) ...[
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Mark: $mark/${question.maxMark}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _courseTitle(String examTitle) {
    return examTitle
        .replaceAll('CBT + Theory', '')
        .replaceAll('Practical', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _level(String courseCode) {
    final match = RegExp(r'\d+').firstMatch(courseCode);
    final digits = match?.group(0) ?? '';
    if (digits.isEmpty) return '';
    return '${digits[0]}00 Level';
  }

  String _matricNumber(LecturerDemoExamScript script) {
    final serial = script.candidateNo.split('/').last.trim();
    final padded = serial.padLeft(4, '0');
    return '2023/C/CSC/$padded';
  }
}
