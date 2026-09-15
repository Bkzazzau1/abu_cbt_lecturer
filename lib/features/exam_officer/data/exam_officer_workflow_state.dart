import 'package:flutter/foundation.dart';

import '../../lecturer_workflow/data/lecturer_demo_state.dart';
import '../../lecturer_workflow/data/lecturer_gradebook_state.dart';

enum ExamOfficerQuestionStatus {
  received,
  withModerator,
  correctionRequested,
  moderated,
  readyForTimetable,
}

extension ExamOfficerQuestionStatusLabel on ExamOfficerQuestionStatus {
  String get label {
    switch (this) {
      case ExamOfficerQuestionStatus.received:
        return 'Received';
      case ExamOfficerQuestionStatus.withModerator:
        return 'With Moderator';
      case ExamOfficerQuestionStatus.correctionRequested:
        return 'Correction Requested';
      case ExamOfficerQuestionStatus.moderated:
        return 'Moderated';
      case ExamOfficerQuestionStatus.readyForTimetable:
        return 'Ready for Timetable';
    }
  }
}

enum ExamOfficerResultStatus {
  received,
  underReview,
  returnedToLecturer,
  verified,
  forwardedToHod,
}

extension ExamOfficerResultStatusLabel on ExamOfficerResultStatus {
  String get label {
    switch (this) {
      case ExamOfficerResultStatus.received:
        return 'Received';
      case ExamOfficerResultStatus.underReview:
        return 'Under Review';
      case ExamOfficerResultStatus.returnedToLecturer:
        return 'Returned to Lecturer';
      case ExamOfficerResultStatus.verified:
        return 'Verified';
      case ExamOfficerResultStatus.forwardedToHod:
        return 'Forwarded to HoD';
    }
  }
}

class ExamOfficerReviewNote {
  ExamOfficerReviewNote({
    required this.actor,
    required this.action,
    required this.note,
  });

  final String actor;
  final String action;
  final String note;
  final DateTime createdAt = DateTime.now();
}

class ExamOfficerQuestionPaper {
  ExamOfficerQuestionPaper({
    required this.paperId,
    required this.courseCode,
    required this.courseTitle,
    required this.title,
    required this.lecturerName,
    required this.questionCount,
    required this.totalMarks,
    required this.durationMinutes,
    required this.questionPayload,
    this.status = ExamOfficerQuestionStatus.received,
    List<ExamOfficerReviewNote>? notes,
  }) : notes = notes ?? [];

  final int paperId;
  final String courseCode;
  final String courseTitle;
  final String title;
  final String lecturerName;
  final int questionCount;
  final int totalMarks;
  final int durationMinutes;
  final Map<String, dynamic> questionPayload;
  ExamOfficerQuestionStatus status;
  final List<ExamOfficerReviewNote> notes;

  String get id => 'paper-$paperId';
}

class ExamOfficerResultBatch {
  ExamOfficerResultBatch({
    required this.courseCode,
    required this.courseTitle,
    required this.studentCount,
    required this.completeCount,
    required this.receivedScripts,
    required this.classAverage,
    required this.fullBatchSubmitted,
    this.status = ExamOfficerResultStatus.received,
    List<ExamOfficerReviewNote>? notes,
  }) : notes = notes ?? [];

  final String courseCode;
  String courseTitle;
  int studentCount;
  int completeCount;
  int receivedScripts;
  double classAverage;
  bool fullBatchSubmitted;
  ExamOfficerResultStatus status;
  final List<ExamOfficerReviewNote> notes;

  String get id => _normalise(courseCode);
  bool get complete =>
      fullBatchSubmitted && studentCount > 0 && completeCount == studentCount;
}

class ExamOfficerWorkflowState extends ChangeNotifier {
  ExamOfficerWorkflowState._() {
    LecturerDemoState.instance.addListener(_syncFromLecturer);
    LecturerGradebookState.instance.addListener(_syncFromLecturer);
    _seedQuestionPaper();
    _syncResults(notify: false);
  }

  static final ExamOfficerWorkflowState instance = ExamOfficerWorkflowState._();

  final List<ExamOfficerQuestionPaper> _questionPapers = [];
  final List<ExamOfficerResultBatch> _resultBatches = [];

  List<ExamOfficerQuestionPaper> get questionPapers =>
      List.unmodifiable(_questionPapers);
  List<ExamOfficerResultBatch> get resultBatches =>
      List.unmodifiable(_resultBatches);

  int get questionsReceived => _questionPapers.length;
  int get questionsWithModerator => _questionPapers
      .where((item) => item.status == ExamOfficerQuestionStatus.withModerator)
      .length;
  int get questionsReady => _questionPapers
      .where((item) => item.status == ExamOfficerQuestionStatus.readyForTimetable)
      .length;
  int get resultBatchesReceived => _resultBatches.length;
  int get resultBatchesVerified => _resultBatches
      .where((item) =>
          item.status == ExamOfficerResultStatus.verified ||
          item.status == ExamOfficerResultStatus.forwardedToHod)
      .length;

  void registerQuestionSubmission({
    required int paperId,
    required String courseCode,
    required String courseTitle,
    required String title,
    required String lecturerName,
    required int questionCount,
    required int totalMarks,
    required int durationMinutes,
    required Map<String, dynamic> questionPayload,
  }) {
    final existing = _questionPapers.where((item) => item.paperId == paperId);
    if (existing.isNotEmpty) return;
    _questionPapers.insert(
      0,
      ExamOfficerQuestionPaper(
        paperId: paperId,
        courseCode: _displayCode(courseCode),
        courseTitle: courseTitle,
        title: title,
        lecturerName: lecturerName,
        questionCount: questionCount,
        totalMarks: totalMarks,
        durationMinutes: durationMinutes,
        questionPayload: Map<String, dynamic>.unmodifiable(questionPayload),
      ),
    );
    notifyListeners();
  }

  void sendQuestionToModerator(String id, String note) {
    final paper = _paper(id);
    if (paper.status != ExamOfficerQuestionStatus.received &&
        paper.status != ExamOfficerQuestionStatus.moderated) {
      return;
    }
    paper.status = ExamOfficerQuestionStatus.withModerator;
    paper.notes.add(
      ExamOfficerReviewNote(
        actor: 'Exam Officer',
        action: 'Sent to Moderator',
        note: note,
      ),
    );
    notifyListeners();
  }

  void returnQuestionToLecturer(String id, String note) {
    final paper = _paper(id);
    paper.status = ExamOfficerQuestionStatus.correctionRequested;
    paper.notes.add(
      ExamOfficerReviewNote(
        actor: 'Exam Officer',
        action: 'Returned to Lecturer',
        note: note,
      ),
    );
    notifyListeners();
  }

  void recordModeratorReturn(String id, String note) {
    final paper = _paper(id);
    paper.status = ExamOfficerQuestionStatus.moderated;
    paper.notes.add(
      ExamOfficerReviewNote(
        actor: 'Moderator',
        action: 'Moderation Completed',
        note: note,
      ),
    );
    notifyListeners();
  }

  void markQuestionReady(String id, String note) {
    final paper = _paper(id);
    if (paper.status != ExamOfficerQuestionStatus.moderated) return;
    paper.status = ExamOfficerQuestionStatus.readyForTimetable;
    paper.notes.add(
      ExamOfficerReviewNote(
        actor: 'Exam Officer',
        action: 'Ready for Timetable',
        note: note,
      ),
    );
    notifyListeners();
  }

  void startResultReview(String id) {
    final batch = _batch(id);
    if (batch.status == ExamOfficerResultStatus.received ||
        batch.status == ExamOfficerResultStatus.returnedToLecturer) {
      batch.status = ExamOfficerResultStatus.underReview;
      batch.notes.add(
        ExamOfficerReviewNote(
          actor: 'Exam Officer',
          action: 'Review Started',
          note: 'Result batch opened for verification.',
        ),
      );
      notifyListeners();
    }
  }

  void returnResultToLecturer(String id, String note) {
    final batch = _batch(id);
    batch.status = ExamOfficerResultStatus.returnedToLecturer;
    batch.notes.add(
      ExamOfficerReviewNote(
        actor: 'Exam Officer',
        action: 'Returned to Lecturer',
        note: note,
      ),
    );
    notifyListeners();
  }

  void verifyResultBatch(String id, String note) {
    final batch = _batch(id);
    if (!batch.complete) return;
    batch.status = ExamOfficerResultStatus.verified;
    batch.notes.add(
      ExamOfficerReviewNote(
        actor: 'Exam Officer',
        action: 'Verified',
        note: note,
      ),
    );
    notifyListeners();
  }

  void forwardResultToHod(String id, String note) {
    final batch = _batch(id);
    if (batch.status != ExamOfficerResultStatus.verified) return;
    batch.status = ExamOfficerResultStatus.forwardedToHod;
    batch.notes.add(
      ExamOfficerReviewNote(
        actor: 'Exam Officer',
        action: 'Forwarded to HoD',
        note: note,
      ),
    );
    notifyListeners();
  }

  void _syncFromLecturer() => _syncResults(notify: true);

  void _syncResults({required bool notify}) {
    final gradebook = LecturerGradebookState.instance;
    final scripts = LecturerDemoState.instance.scripts;
    var changed = false;

    for (final course in gradebook.courses) {
      final codeKey = _normalise(course.code);
      final submittedScripts = scripts
          .where(
            (script) =>
                _normalise(script.courseCode) == codeKey &&
                script.status == LecturerDemoScriptStatus.submittedToExamOfficer,
          )
          .toList();
      if (!course.resultsSubmitted && submittedScripts.isEmpty) continue;

      final students = gradebook.studentsFor(course.code);
      final complete = students.where((student) => student.complete).toList();
      final average = complete.isEmpty || course.totalMax == 0
          ? 0.0
          : complete.fold<double>(
                  0,
                  (sum, student) =>
                      sum + (student.total * 100 / course.totalMax),
                ) /
                complete.length;

      ExamOfficerResultBatch? batch;
      for (final item in _resultBatches) {
        if (item.id == codeKey) {
          batch = item;
          break;
        }
      }

      if (batch == null) {
        _resultBatches.insert(
          0,
          ExamOfficerResultBatch(
            courseCode: course.code,
            courseTitle: course.title,
            studentCount: students.length,
            completeCount: complete.length,
            receivedScripts: submittedScripts.length,
            classAverage: average,
            fullBatchSubmitted: course.resultsSubmitted,
          ),
        );
        changed = true;
      } else {
        if (batch.courseTitle != course.title ||
            batch.studentCount != students.length ||
            batch.completeCount != complete.length ||
            batch.receivedScripts != submittedScripts.length ||
            batch.classAverage != average ||
            batch.fullBatchSubmitted != course.resultsSubmitted) {
          batch.courseTitle = course.title;
          batch.studentCount = students.length;
          batch.completeCount = complete.length;
          batch.receivedScripts = submittedScripts.length;
          batch.classAverage = average;
          batch.fullBatchSubmitted = course.resultsSubmitted;
          changed = true;
        }
      }
    }

    final knownCourseKeys = gradebook.courses
        .map((course) => _normalise(course.code))
        .toSet();
    final unmatchedSubmitted = scripts.where(
      (script) =>
          script.status == LecturerDemoScriptStatus.submittedToExamOfficer &&
          !knownCourseKeys.contains(_normalise(script.courseCode)),
    );
    final unmatchedKeys = unmatchedSubmitted
        .map((script) => _normalise(script.courseCode))
        .toSet();
    for (final key in unmatchedKeys) {
      final group = unmatchedSubmitted
          .where((script) => _normalise(script.courseCode) == key)
          .toList();
      ExamOfficerResultBatch? batch;
      for (final item in _resultBatches) {
        if (item.id == key) {
          batch = item;
          break;
        }
      }
      if (batch == null && group.isNotEmpty) {
        _resultBatches.insert(
          0,
          ExamOfficerResultBatch(
            courseCode: group.first.courseCode,
            courseTitle: group.first.examTitle,
            studentCount: group.length,
            completeCount: group.where((script) => script.markingComplete).length,
            receivedScripts: group.length,
            classAverage: group.isEmpty
                ? 0
                : group.fold<double>(
                        0,
                        (sum, script) =>
                            sum + (script.examScore * 100 / script.examMax),
                      ) /
                      group.length,
            fullBatchSubmitted: false,
          ),
        );
        changed = true;
      }
    }

    if (changed && notify) notifyListeners();
  }

  ExamOfficerQuestionPaper _paper(String id) =>
      _questionPapers.firstWhere((item) => item.id == id);
  ExamOfficerResultBatch _batch(String id) =>
      _resultBatches.firstWhere((item) => item.id == id);

  void _seedQuestionPaper() {
    if (_questionPapers.isNotEmpty) return;
    _questionPapers.add(
      ExamOfficerQuestionPaper(
        paperId: 7001,
        courseCode: 'CSC 305',
        courseTitle: 'Database Systems',
        title: 'CSC 305 First Semester Examination',
        lecturerName: 'Dr. Amina Bello',
        questionCount: 3,
        totalMarks: 100,
        durationMinutes: 120,
        questionPayload: const {
          'questions': [
            {
              'type': 'single_choice',
              'prompt': 'Which normal form removes partial dependency?',
              'marks': 10,
            },
            {
              'type': 'essay',
              'prompt': 'Explain transaction isolation and serializability.',
              'marks': 40,
            },
            {
              'type': 'essay',
              'prompt': 'Design a normalized schema for a university registration system.',
              'marks': 50,
            },
          ],
        },
      ),
    );
  }
}

String _normalise(String value) => value.replaceAll(' ', '').toUpperCase();

String _displayCode(String value) {
  final clean = _normalise(value);
  if (clean.length >= 6 && clean.startsWith('CSC')) {
    return '${clean.substring(0, 3)} ${clean.substring(3)}';
  }
  return value;
}
