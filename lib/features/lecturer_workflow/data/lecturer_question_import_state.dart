import 'package:flutter/foundation.dart';

class LecturerQuestionImportBatch {
  const LecturerQuestionImportBatch({
    required this.id,
    required this.courseCode,
    required this.target,
    required this.questionType,
    required this.questionCount,
    required this.fileName,
    required this.sourceUrl,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  final String id;
  final String courseCode;
  final String target;
  final String questionType;
  final int questionCount;
  final String fileName;
  final String sourceUrl;
  final String uploadedBy;
  final DateTime uploadedAt;
}

class LecturerQuestionImportState extends ChangeNotifier {
  LecturerQuestionImportState._();

  static final LecturerQuestionImportState instance =
      LecturerQuestionImportState._();

  final List<LecturerQuestionImportBatch> _batches = [];

  List<LecturerQuestionImportBatch> get batches => List.unmodifiable(_batches);

  void addBatch({
    required String courseCode,
    required String target,
    required String questionType,
    required int questionCount,
    required String fileName,
    required String sourceUrl,
    required String uploadedBy,
  }) {
    _batches.insert(
      0,
      LecturerQuestionImportBatch(
        id: 'question-import-${DateTime.now().microsecondsSinceEpoch}',
        courseCode: courseCode,
        target: target,
        questionType: questionType,
        questionCount: questionCount,
        fileName: fileName,
        sourceUrl: sourceUrl,
        uploadedBy: uploadedBy,
        uploadedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void removeBatch(String id) {
    _batches.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
