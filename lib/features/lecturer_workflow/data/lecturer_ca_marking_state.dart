import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_session.dart';
import 'cbt_calendar_state.dart';
import 'lecturer_gradebook_state.dart';

enum LecturerCaAttemptStatus { pending, marked }

extension LecturerCaAttemptStatusLabel on LecturerCaAttemptStatus {
  String get label => this == LecturerCaAttemptStatus.marked ? 'Marked' : 'Pending Marking';
}

class LecturerCaAttempt {
  LecturerCaAttempt({
    required this.id,
    required this.assessmentId,
    required this.courseCode,
    required this.caLabel,
    required this.matricNumber,
    required this.studentName,
    required this.responses,
    Map<int, int?>? marks,
    this.status = LecturerCaAttemptStatus.pending,
    this.markedBy = '',
  }) : marks = marks ?? <int, int?>{};

  final String id;
  final String assessmentId;
  final String courseCode;
  final String caLabel;
  final String matricNumber;
  final String studentName;
  final Map<int, String> responses;
  final Map<int, int?> marks;
  LecturerCaAttemptStatus status;
  String markedBy;

  int score(CaAssessmentRecord assessment) {
    var total = 0;
    for (var i = 0; i < assessment.questions.length; i++) {
      total += marks[i] ?? 0;
    }
    return total;
  }

  bool complete(CaAssessmentRecord assessment) =>
      List.generate(assessment.questions.length, (index) => index)
          .every((index) => marks[index] != null);

  String grade(CaAssessmentRecord assessment) {
    if (!complete(assessment) || assessment.totalMarks <= 0) return '—';
    final percent = score(assessment) * 100 / assessment.totalMarks;
    if (percent >= 70) return 'A';
    if (percent >= 60) return 'B';
    if (percent >= 50) return 'C';
    if (percent >= 45) return 'D';
    if (percent >= 40) return 'E';
    return 'F';
  }
}

class LecturerCaMarkingState extends ChangeNotifier {
  LecturerCaMarkingState._() {
    _syncAttempts();
    CbtCalendarState.instance.addListener(_handleCalendarChanged);
  }

  static final LecturerCaMarkingState instance = LecturerCaMarkingState._();

  final List<LecturerCaAttempt> _attempts = [];
  final LecturerGradebookState _gradebook = LecturerGradebookState.instance;

  List<CaAssessmentRecord> get assessments => CbtCalendarState.instance.assessments
      .where((item) => item.status == CaAssessmentStatus.scheduled)
      .toList(growable: false);

  List<LecturerCaAttempt> attemptsFor(String assessmentId) => List.unmodifiable(
        _attempts.where((item) => item.assessmentId == assessmentId),
      );

  LecturerCaAttempt attempt(String id) =>
      _attempts.firstWhere((item) => item.id == id);

  String get _actor => AuthSession.instance.session?.name ?? 'Course Lecturer';

  void _handleCalendarChanged() {
    final changed = _syncAttempts();
    if (changed) notifyListeners();
  }

  bool _syncAttempts() {
    var changed = false;
    for (final assessment in assessments) {
      final gradebookCourse = _courseFor(assessment.courseCode);
      if (gradebookCourse == null) continue;
      final students = _gradebook.studentsFor(gradebookCourse.code);
      for (var index = 0; index < students.length; index++) {
        final student = students[index];
        final id = '${assessment.id}-${student.matricNumber}';
        if (_attempts.any((item) => item.id == id)) continue;
        _attempts.add(
          LecturerCaAttempt(
            id: id,
            assessmentId: assessment.id,
            courseCode: assessment.courseCode,
            caLabel: assessment.caLabel,
            matricNumber: student.matricNumber,
            studentName: student.studentName,
            responses: _demoResponses(assessment, index),
          ),
        );
        changed = true;
      }
    }
    return changed;
  }

  Map<int, String> _demoResponses(CaAssessmentRecord assessment, int studentIndex) {
    final out = <int, String>{};
    for (var i = 0; i < assessment.questions.length; i++) {
      final question = assessment.questions[i];
      final mostlyCorrect = (studentIndex + i) % 4 != 0;
      switch (question.type) {
        case 'single_choice':
          final correct = question.correctOptions.isEmpty ? 'A' : question.correctOptions.first;
          out[i] = mostlyCorrect ? correct : (correct == 'A' ? 'B' : 'A');
          break;
        case 'multiple_choice':
          final correct = question.correctOptions;
          out[i] = mostlyCorrect
              ? correct.join(', ')
              : (correct.isEmpty ? 'A' : correct.first);
          break;
        case 'fill_blank':
          final accepted = _acceptedAnswers(question.answer);
          out[i] = mostlyCorrect && accepted.isNotEmpty ? accepted.first : 'incorrect answer';
          break;
        case 'drag_drop':
          final canonical = question.matchPairs
              .map((pair) => '${pair.left}→${pair.right}')
              .join('; ');
          out[i] = mostlyCorrect ? canonical : '${canonical}; incorrect match';
          break;
        case 'essay':
          out[i] = 'The student explains the concept and gives a relevant practical example.';
          break;
        case 'image_question':
          out[i] = 'The student interprets the diagram and explains the observed structure.';
          break;
        case 'file_upload':
          out[i] = 'student_submission_${studentIndex + 1}.zip';
          break;
        default:
          out[i] = 'Student response';
      }
    }
    return out;
  }

  void applyAutoMarks(String attemptId) {
    final attempt = attempt(attemptId);
    final assessment = _assessment(attempt.assessmentId);
    if (_gradebookLocked(assessment.courseCode)) return;
    for (var i = 0; i < assessment.questions.length; i++) {
      final question = assessment.questions[i];
      if (!question.autoMarkable) continue;
      attempt.marks[i] = _autoMark(question, attempt.responses[i] ?? '');
    }
    if (attempt.status == LecturerCaAttemptStatus.marked) {
      attempt.status = LecturerCaAttemptStatus.pending;
    }
    notifyListeners();
  }

  int _autoMark(CaQuestionSnapshot question, String response) {
    final max = question.marks;
    switch (question.type) {
      case 'single_choice':
        final key = response.trim().toUpperCase();
        return question.correctOptions.map((item) => item.toUpperCase()).contains(key)
            ? max
            : 0;
      case 'multiple_choice':
        final expected = question.correctOptions.map((item) => item.toUpperCase()).toSet();
        final selected = response
            .split(RegExp(r'[,;\s]+'))
            .map((item) => item.trim().toUpperCase())
            .where((item) => item.isNotEmpty)
            .toSet();
        if (setEquals(expected, selected)) return max;
        if (!question.partialMarking || expected.isEmpty) return 0;
        final correctSelected = selected.intersection(expected).length;
        final wrongSelected = selected.difference(expected).length;
        final earnedRatio = ((correctSelected - wrongSelected) / expected.length).clamp(0.0, 1.0);
        return (max * earnedRatio).round();
      case 'fill_blank':
        final value = _normalise(response);
        return _acceptedAnswers(question.answer).map(_normalise).contains(value) ? max : 0;
      case 'drag_drop':
        final expected = question.matchPairs
            .map((pair) => '${_normalise(pair.left)}→${_normalise(pair.right)}')
            .toSet();
        final actual = response
            .split(';')
            .map((part) {
              final pieces = part.split('→');
              if (pieces.length != 2) return '';
              return '${_normalise(pieces[0])}→${_normalise(pieces[1])}';
            })
            .where((item) => item.isNotEmpty)
            .toSet();
        return setEquals(expected, actual) ? max : 0;
      default:
        return 0;
    }
  }

  void updateMark(String attemptId, int questionIndex, int? mark) {
    final attempt = this.attempt(attemptId);
    final assessment = _assessment(attempt.assessmentId);
    if (_gradebookLocked(assessment.courseCode)) return;
    final max = assessment.questions[questionIndex].marks;
    attempt.marks[questionIndex] =
        mark == null ? null : mark.clamp(0, max).toInt();
    if (attempt.status == LecturerCaAttemptStatus.marked) {
      attempt.status = LecturerCaAttemptStatus.pending;
    }
    notifyListeners();
  }

  bool canComplete(String attemptId) {
    final attempt = this.attempt(attemptId);
    final assessment = _assessment(attempt.assessmentId);
    return !_gradebookLocked(assessment.courseCode) && attempt.complete(assessment);
  }

  void completeMarking(String attemptId) {
    final attempt = this.attempt(attemptId);
    final assessment = _assessment(attempt.assessmentId);
    if (!attempt.complete(assessment) || _gradebookLocked(assessment.courseCode)) return;
    final course = _courseFor(assessment.courseCode);
    if (course == null || assessment.totalMarks <= 0) return;

    final rawScore = attempt.score(assessment);
    if (assessment.caLabel == 'CA 2') {
      final scaled = (rawScore * course.ca2Max / assessment.totalMarks).round();
      _gradebook.updateCa2(course.code, attempt.matricNumber, scaled);
    } else {
      final scaled = (rawScore * course.ca1Max / assessment.totalMarks).round();
      _gradebook.updateCa1(course.code, attempt.matricNumber, scaled);
    }
    attempt.status = LecturerCaAttemptStatus.marked;
    attempt.markedBy = _actor;
    notifyListeners();
  }

  int markedCount(String assessmentId) => attemptsFor(assessmentId)
      .where((item) => item.status == LecturerCaAttemptStatus.marked)
      .length;

  double averagePercent(String assessmentId) {
    final assessment = _assessment(assessmentId);
    final marked = attemptsFor(assessmentId)
        .where((item) => item.status == LecturerCaAttemptStatus.marked)
        .toList();
    if (marked.isEmpty || assessment.totalMarks <= 0) return 0;
    final total = marked.fold<double>(
      0,
      (sum, item) => sum + (item.score(assessment) * 100 / assessment.totalMarks),
    );
    return total / marked.length;
  }

  CaAssessmentRecord _assessment(String id) =>
      CbtCalendarState.instance.assessments.firstWhere((item) => item.id == id);

  LecturerGradebookCourse? _courseFor(String externalCode) {
    final wanted = _normaliseCode(externalCode);
    for (final course in _gradebook.courses) {
      if (_normaliseCode(course.code) == wanted) return course;
    }
    return null;
  }

  bool _gradebookLocked(String externalCode) => _courseFor(externalCode)?.resultsSubmitted == true;

  String _normaliseCode(String value) =>
      value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  String _normalise(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

  List<String> _acceptedAnswers(String value) => value
      .split(RegExp(r'[;\n]+'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
