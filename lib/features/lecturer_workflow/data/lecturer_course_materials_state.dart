import 'dart:convert';

import 'package:flutter/foundation.dart';

class LecturerCourseMaterial {
  LecturerCourseMaterial({
    required this.id,
    required this.courseCode,
    required this.fileName,
    required this.category,
    required this.sizeBytes,
    required this.sourceUrl,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.extractedText,
    this.useForAi = true,
  });

  final String id;
  final String courseCode;
  final String fileName;
  final String category;
  final int sizeBytes;
  final String sourceUrl;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String extractedText;
  bool useForAi;

  bool get contentIndexed => extractedText.trim().isNotEmpty;

  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (sizeBytes >= 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$sizeBytes B';
  }
}

class LecturerCourseMaterialsState extends ChangeNotifier {
  LecturerCourseMaterialsState._();

  static final LecturerCourseMaterialsState instance =
      LecturerCourseMaterialsState._();

  final List<LecturerCourseMaterial> _materials = [];

  List<LecturerCourseMaterial> materialsFor(String courseCode) =>
      List.unmodifiable(
        _materials.where(
          (item) => _normalize(item.courseCode) == _normalize(courseCode),
        ),
      );

  List<LecturerCourseMaterial> aiMaterialsFor(String courseCode) =>
      List.unmodifiable(
        _materials.where(
          (item) =>
              _normalize(item.courseCode) == _normalize(courseCode) &&
              item.useForAi,
        ),
      );

  void addMaterial({
    required String courseCode,
    required String fileName,
    required String category,
    required int sizeBytes,
    required String sourceUrl,
    required String uploadedBy,
    required List<int> bytes,
  }) {
    _materials.insert(
      0,
      LecturerCourseMaterial(
        id: 'material-${DateTime.now().microsecondsSinceEpoch}',
        courseCode: courseCode,
        fileName: fileName,
        category: category,
        sizeBytes: sizeBytes,
        sourceUrl: sourceUrl,
        uploadedBy: uploadedBy,
        uploadedAt: DateTime.now(),
        extractedText: _extractReadableText(fileName, bytes),
      ),
    );
    notifyListeners();
  }

  void setUseForAi(String materialId, bool value) {
    final material = _materials.firstWhere((item) => item.id == materialId);
    material.useForAi = value;
    notifyListeners();
  }

  void removeMaterial(String materialId) {
    _materials.removeWhere((item) => item.id == materialId);
    notifyListeners();
  }

  int aiSourceCount(String courseCode) => aiMaterialsFor(courseCode).length;

  String aiContextForCourseLabel(String? courseLabel) {
    if (courseLabel == null || courseLabel.trim().isEmpty) return '';
    final normalizedLabel = _normalize(courseLabel);
    final candidates = _materials
        .where((item) => normalizedLabel.contains(_normalize(item.courseCode)))
        .map((item) => item.courseCode)
        .toSet();
    if (candidates.isEmpty) return '';
    return aiContextForCode(candidates.first);
  }

  String aiContextForCode(String courseCode) {
    final active = aiMaterialsFor(courseCode);
    if (active.isEmpty) return '';

    final parts = <String>[];
    for (final material in active.take(6)) {
      final source = '${material.category}: ${material.fileName}';
      if (material.extractedText.isEmpty) {
        parts.add(source);
      } else {
        final excerpt = material.extractedText.length > 700
            ? material.extractedText.substring(0, 700)
            : material.extractedText;
        parts.add('$source — $excerpt');
      }
    }
    return parts.join('\n');
  }

  List<String> keyTopicsFor(String courseCode) {
    final active = aiMaterialsFor(courseCode);
    if (active.isEmpty) return const [];
    final topics = <String>{};
    for (final material in active) {
      final base = material.fileName
          .replaceAll(RegExp(r'\.[^.]+$'), '')
          .replaceAll(RegExp(r'[_-]+'), ' ')
          .trim();
      if (base.isNotEmpty) topics.add(base);
      if (topics.length >= 8) break;
    }
    return topics.toList(growable: false);
  }

  String teachingSummaryFor(String courseCode) {
    final active = aiMaterialsFor(courseCode);
    if (active.isEmpty) {
      return 'No active AI course materials yet.';
    }
    final withText = active.where((item) => item.extractedText.isNotEmpty).toList();
    if (withText.isNotEmpty) {
      final text = withText.first.extractedText.replaceAll(RegExp(r'\s+'), ' ');
      return text.length > 700 ? '${text.substring(0, 700)}…' : text;
    }
    return 'Active sources: ${active.map((item) => item.fileName).join(', ')}.';
  }

  String _extractReadableText(String fileName, List<int> bytes) {
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    final plainTextExtensions = {'txt', 'md', 'csv', 'json'};
    String raw;
    if (plainTextExtensions.contains(extension)) {
      raw = utf8.decode(bytes, allowMalformed: true);
    } else {
      final chunks = <String>[];
      final current = StringBuffer();
      void flush() {
        final value = current.toString().trim();
        if (value.length >= 18 && RegExp(r'[A-Za-z]').hasMatch(value)) {
          chunks.add(value);
        }
        current.clear();
      }

      for (final byte in bytes.take(500000)) {
        if ((byte >= 32 && byte <= 126) || byte == 10 || byte == 13 || byte == 9) {
          current.writeCharCode(byte);
        } else {
          flush();
        }
        if (chunks.join(' ').length >= 6000) break;
      }
      flush();
      raw = chunks.join(' ');
    }

    final cleaned = raw
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), ' ')
        .trim();
    return cleaned.length > 5000 ? cleaned.substring(0, 5000) : cleaned;
  }

  String _normalize(String value) =>
      value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}
