import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/lecturer_gradebook_state.dart';
import 'lecturer_exam_script_pdf_save.dart';

enum LecturerGradebookPdfKind {
  matricList,
  gradeSheet,
  blankScoreSheet,
}

class LecturerGradebookPdfService {
  const LecturerGradebookPdfService();

  Future<Uint8List> buildPdf({
    required LecturerGradebookCourse course,
    required List<LecturerGradebookStudent> students,
    required LecturerGradebookPdfKind kind,
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

    final sorted = [...students]
      ..sort((a, b) => a.matricNumber.compareTo(b.matricNumber));

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.fromLTRB(34, 30, 34, 38),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ),
        build: (_) => [
          _header(course, kind, logo),
          pw.SizedBox(height: 14),
          _courseMetadata(course),
          pw.SizedBox(height: 16),
          _table(course, sorted, kind),
          if (kind == LecturerGradebookPdfKind.gradeSheet) ...[
            pw.SizedBox(height: 18),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Students: ${sorted.length}'),
                pw.Text(
                  'Assessment: CA1/${course.ca1Max} + CA2/${course.ca2Max} + Exam/${course.examMax} = ${course.totalMax}',
                ),
              ],
            ),
          ],
        ],
      ),
    );

    return document.save();
  }

  Future<void> download({
    required LecturerGradebookCourse course,
    required List<LecturerGradebookStudent> students,
    required LecturerGradebookPdfKind kind,
  }) async {
    final bytes = await buildPdf(course: course, students: students, kind: kind);
    await saveExamScriptPdf(bytes, fileName(course, kind));
  }

  Future<void> printSheet({
    required LecturerGradebookCourse course,
    required List<LecturerGradebookStudent> students,
    required LecturerGradebookPdfKind kind,
  }) async {
    await Printing.layoutPdf(
      name: fileName(course, kind),
      onLayout: (format) => buildPdf(
        course: course,
        students: students,
        kind: kind,
        pageFormat: format,
      ),
    );
  }

  String fileName(LecturerGradebookCourse course, LecturerGradebookPdfKind kind) {
    final code = course.code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    final suffix = switch (kind) {
      LecturerGradebookPdfKind.matricList => 'matric_list',
      LecturerGradebookPdfKind.gradeSheet => 'grade_sheet',
      LecturerGradebookPdfKind.blankScoreSheet => 'blank_score_sheet',
    };
    return '${code}_${course.academicSession.replaceAll('/', '_')}_$suffix.pdf';
  }

  pw.Widget _header(
    LecturerGradebookCourse course,
    LecturerGradebookPdfKind kind,
    pw.MemoryImage? logo,
  ) {
    final title = switch (kind) {
      LecturerGradebookPdfKind.matricList => 'STUDENT MATRICULATION LIST',
      LecturerGradebookPdfKind.gradeSheet => 'COURSE GRADE SHEET',
      LecturerGradebookPdfKind.blankScoreSheet => 'BLANK COURSE SCORE SHEET',
    };

    return pw.Column(
      children: [
        if (logo != null) pw.Image(logo, width: 52, height: 52),
        pw.SizedBox(height: 7),
        pw.Text(
          'AHMADU BELLO UNIVERSITY, ZARIA',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'Faculty of Physical Sciences',
          style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Department of Computer Science', style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 9),
        pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _courseMetadata(LecturerGradebookCourse course) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500, width: 0.6),
      ),
      child: pw.Wrap(
        spacing: 18,
        runSpacing: 6,
        children: [
          _meta('Course Code', course.code),
          _meta('Course Title', course.title),
          _meta('Session', course.academicSession),
          _meta('Semester', course.semester),
          _meta('Level', course.level),
        ],
      ),
    );
  }

  pw.Widget _meta(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(text: '$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.TextSpan(text: value),
        ],
      ),
    );
  }

  pw.Widget _table(
    LecturerGradebookCourse course,
    List<LecturerGradebookStudent> students,
    LecturerGradebookPdfKind kind,
  ) {
    final headers = switch (kind) {
      LecturerGradebookPdfKind.matricList => ['S/N', 'Matric Number'],
      LecturerGradebookPdfKind.gradeSheet => [
          'S/N',
          'Matric Number',
          'CA1/${course.ca1Max}',
          'CA2/${course.ca2Max}',
          'Exam/${course.examMax}',
          'Total/${course.totalMax}',
          'Grade',
        ],
      LecturerGradebookPdfKind.blankScoreSheet => [
          'S/N',
          'Matric Number',
          'CA1/${course.ca1Max}',
          'CA2/${course.ca2Max}',
          'Exam/${course.examMax}',
          'Total/${course.totalMax}',
        ],
    };

    final rows = <List<String>>[];
    for (var index = 0; index < students.length; index++) {
      final student = students[index];
      switch (kind) {
        case LecturerGradebookPdfKind.matricList:
          rows.add(['${index + 1}', student.matricNumber]);
        case LecturerGradebookPdfKind.gradeSheet:
          rows.add([
            '${index + 1}',
            student.matricNumber,
            _score(student.ca1),
            _score(student.ca2),
            _score(student.exam),
            student.complete ? '${student.total}' : '—',
            student.gradeFor(course),
          ]);
        case LecturerGradebookPdfKind.blankScoreSheet:
          rows.add(['${index + 1}', student.matricNumber, '', '', '', '']);
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            for (final header in headers)
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  header,
                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                ),
              ),
          ],
        ),
        for (final row in rows)
          pw.TableRow(
            children: [
              for (final value in row)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(value, style: const pw.TextStyle(fontSize: 8.5)),
                ),
            ],
          ),
      ],
    );
  }

  String _score(int? value) => value?.toString() ?? '—';
}
