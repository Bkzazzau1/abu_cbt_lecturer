import 'package:flutter/foundation.dart';

import '../../lecturer_workflow/data/cbt_calendar_state.dart';
import '../../lecturer_workflow/data/lecturer_demo_state.dart';
import '../../lecturer_workflow/data/lecturer_gradebook_state.dart';
import 'exam_officer_academic_registry.dart';

enum ExamOfficerQuestionStatus {
  received,
  withModerator,
  correctionRequested,
  moderated,
  readyForTimetable,
  partiallyScheduled,
  scheduled,
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
      case ExamOfficerQuestionStatus.partiallyScheduled:
        return 'Partially Scheduled';
      case ExamOfficerQuestionStatus.scheduled:
        return 'Scheduled';
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

class ExamOfficerExamSchedule {
  ExamOfficerExamSchedule({
    required this.paperId,
    required this.courseCode,
    required this.slotId,
    required this.scheduleLabel,
    required this.venue,
    required this.capacity,
  });

  final int paperId;
  final String courseCode;
  final String slotId;
  final String scheduleLabel;
  final String venue;
  final int capacity;
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
    _ensureExamSlots();
    _seedQuestionPaper();
    _syncResults(notify: false);
  }

  static final ExamOfficerWorkflowState instance = ExamOfficerWorkflowState._();

  final ExamOfficerAcademicRegistry registry = ExamOfficerAcademicRegistry.instance;
  final List<ExamOfficerQuestionPaper> _questionPapers = [];
  final List<ExamOfficerResultBatch> _resultBatches = [];
  final List<ExamOfficerExamSchedule> _examSchedules = [];

  List<ExamOfficerQuestionPaper> get questionPapers =>
      List.unmodifiable(_questionPapers);
  List<ExamOfficerResultBatch> get resultBatches =>
      List.unmodifiable(_resultBatches);
  List<ExamOfficerExamSchedule> get examSchedules =>
      List.unmodifiable(_examSchedules);
  List<ExamOfficerCourseRegistration> get courseRegistrations => registry.courses;
  List<String> get levels => ExamOfficerAcademicRegistry.levels;

  int get questionsReceived => _questionPapers.length;
  int get questionsWithModerator => _questionPapers
      .where((item) => item.status == ExamOfficerQuestionStatus.withModerator)
      .length;
  int get questionsReady => _questionPapers
      .where(
        (item) =>
            item.status == ExamOfficerQuestionStatus.readyForTimetable ||
            item.status == ExamOfficerQuestionStatus.partiallyScheduled,
      )
      .length;
  int get questionsScheduled => _questionPapers
      .where((item) => item.status == ExamOfficerQuestionStatus.scheduled)
      .length;
  int get resultBatchesReceived => _resultBatches.length;
  int get resultBatchesVerified => _resultBatches
      .where((item) =>
          item.status == ExamOfficerResultStatus.verified ||
          item.status == ExamOfficerResultStatus.forwardedToHod)
      .length;
  int get totalLevelStudents => registry.totalLevelStudents;
  int get totalCourseRegistrations => registry.totalCourseRegistrations;
  int get totalCarryoverRegistrations => registry.totalCarryoverRegistrations;

  List<ExamOfficerCourseRegistration> coursesForLevel(String level) =>
      registry.coursesForLevel(level);
  List<ExamOfficerLevelStudent> studentsForLevel(String level) =>
      registry.studentsForLevel(level);
  int cohortCount(String level) => registry.cohortCount(level);

  ExamOfficerCourseRegistration? registrationForCourse(String courseCode) =>
      registry.registrationFor(courseCode);

  int candidateCountForCourse(String courseCode) {
    final registration = registrationForCourse(courseCode);
    if (registration != null) return registration.totalRegistered;
    final gradebook = LecturerGradebookState.instance;
    final match = gradebook.courses
        .where((course) => _normalise(course.code) == _normalise(courseCode));
    if (match.isEmpty) return 0;
    return gradebook.studentsFor(match.first.code).length;
  }

  List<ExamOfficerExamSchedule> schedulesForPaper(int paperId) =>
      _examSchedules.where((item) => item.paperId == paperId).toList();

  int scheduledCapacityForPaper(int paperId) => schedulesForPaper(paperId)
      .fold<int>(0, (sum, item) => sum + item.capacity);

  int remainingCandidates(ExamOfficerQuestionPaper paper) {
    final total = candidateCountForCourse(paper.courseCode);
    final remaining = total - scheduledCapacityForPaper(paper.paperId);
    return remaining < 0 ? 0 : remaining;
  }

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

  void scheduleExamSitting({
    required String paperId,
    required String slotId,
  }) {
    final paper = _paper(paperId);
    if (paper.status != ExamOfficerQuestionStatus.readyForTimetable &&
        paper.status != ExamOfficerQuestionStatus.partiallyScheduled) {
      throw StateError('This paper is not ready for timetable scheduling.');
    }

    final calendar = CbtCalendarState.instance;
    final slot = calendar.slots.firstWhere((item) => item.id == slotId);
    if (!slot.isAvailable) {
      throw StateError('The selected CBT slot is no longer available.');
    }
    if (_slotDurationMinutes(slot.startTime, slot.endTime) <
        paper.durationMinutes) {
      throw StateError('The selected slot is shorter than the exam duration.');
    }

    final remaining = remainingCandidates(paper);
    if (remaining <= 0) {
      throw StateError('All candidates already have scheduled capacity.');
    }

    calendar.setSlotAvailability(slot.id, false);
    slot.bookedAssessmentId = 'exam-${paper.paperId}-${_examSchedules.length + 1}';
    slot.bookedCourseCode = paper.courseCode;
    slot.bookedCaLabel = 'Exam';

    _examSchedules.add(
      ExamOfficerExamSchedule(
        paperId: paper.paperId,
        courseCode: paper.courseCode,
        slotId: slot.id,
        scheduleLabel: slot.scheduleLabel,
        venue: slot.venue,
        capacity: slot.capacity,
      ),
    );

    final afterRemaining = remainingCandidates(paper);
    paper.status = afterRemaining == 0
        ? ExamOfficerQuestionStatus.scheduled
        : ExamOfficerQuestionStatus.partiallyScheduled;
    paper.notes.add(
      ExamOfficerReviewNote(
        actor: 'Exam Officer',
        action: afterRemaining == 0
            ? 'Exam Fully Scheduled'
            : 'Exam Sitting Scheduled',
        note: afterRemaining == 0
            ? '${slot.scheduleLabel}. All registered candidates now have timetable capacity.'
            : '${slot.scheduleLabel}. $afterRemaining candidates still require another sitting.',
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
      } else if (batch.courseTitle != course.title ||
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

  void _ensureExamSlots() {
    final calendar = CbtCalendarState.instance;
    final desired = [
      (DateTime(2026, 9, 24), '09:00', '11:00', 'CBT Centre A', 250),
      (DateTime(2026, 9, 24), '13:00', '15:00', 'CBT Centre B', 180),
      (DateTime(2026, 9, 25), '09:00', '12:00', 'CBT Centre Main', 300),
    ];
    for (final item in desired) {
      final exists = calendar.slots.any(
        (slot) =>
            slot.date.year == item.$1.year &&
            slot.date.month == item.$1.month &&
            slot.date.day == item.$1.day &&
            slot.startTime == item.$2 &&
            slot.endTime == item.$3 &&
            slot.venue == item.$4,
      );
      if (!exists) {
        calendar.addSlot(
          date: item.$1,
          startTime: item.$2,
          endTime: item.$3,
          venue: item.$4,
          capacity: item.$5,
        );
      }
    }
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

int _slotDurationMinutes(String start, String end) {
  int parse(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 +
        (int.tryParse(parts[1]) ?? 0);
  }

  final minutes = parse(end) - parse(start);
  return minutes < 0 ? 0 : minutes;
}

String _normalise(String value) => value.replaceAll(' ', '').toUpperCase();

String _displayCode(String value) {
  final clean = _normalise(value);
  if (clean.length >= 6 && clean.startsWith('CSC')) {
    return '${clean.substring(0, 3)} ${clean.substring(3)}';
  }
  return value;
}
