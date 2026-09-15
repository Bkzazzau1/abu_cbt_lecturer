import 'package:flutter/foundation.dart';

import '../../lecturer_workflow/data/lecturer_gradebook_state.dart';
import 'exam_officer_academic_registry.dart';

enum LevelResultStatus {
  readyForDecision,
  moderationInProgress,
  waitingHodApproval,
  returnedToExamOfficer,
  hodApproved,
  published,
}

extension LevelResultStatusLabel on LevelResultStatus {
  String get label {
    switch (this) {
      case LevelResultStatus.readyForDecision:
        return 'Ready for Decision';
      case LevelResultStatus.moderationInProgress:
        return 'Level Moderation';
      case LevelResultStatus.waitingHodApproval:
        return 'Waiting for HoD Approval';
      case LevelResultStatus.returnedToExamOfficer:
        return 'Returned to Exam Officer';
      case LevelResultStatus.hodApproved:
        return 'HoD Approved';
      case LevelResultStatus.published:
        return 'Published';
    }
  }
}

class LevelResultAudit {
  LevelResultAudit({
    required this.actor,
    required this.action,
    required this.note,
  });

  final String actor;
  final String action;
  final String note;
  final DateTime createdAt = DateTime.now();
}

class LevelResultStudentScore {
  const LevelResultStudentScore({
    required this.matricNumber,
    required this.studentName,
    required this.originalScore,
  });

  final String matricNumber;
  final String studentName;
  final int originalScore;

  int moderatedScore(int adjustment) =>
      (originalScore + adjustment).clamp(0, 100).toInt();

  String gradeFor(int adjustment) {
    final score = moderatedScore(adjustment);
    if (score >= 70) return 'A';
    if (score >= 60) return 'B';
    if (score >= 50) return 'C';
    if (score >= 45) return 'D';
    if (score >= 40) return 'E';
    return 'F';
  }
}

class LevelResultCoursePackage {
  LevelResultCoursePackage({
    required this.courseCode,
    required this.courseTitle,
    required this.lecturers,
    required this.students,
    this.verifiedByExamOfficer = true,
  });

  final String courseCode;
  final String courseTitle;
  final List<String> lecturers;
  final List<LevelResultStudentScore> students;
  bool verifiedByExamOfficer;

  double get originalAverage {
    if (students.isEmpty) return 0;
    return students.fold<int>(0, (sum, row) => sum + row.originalScore) /
        students.length;
  }

  double moderatedAverage(int adjustment) {
    if (students.isEmpty) return 0;
    return students.fold<int>(
          0,
          (sum, row) => sum + row.moderatedScore(adjustment),
        ) /
        students.length;
  }
}

class LevelResultBoard {
  LevelResultBoard({
    required this.level,
    required this.courses,
    required this.status,
    this.adjustment = 0,
    this.departmentalMeetingHeld = false,
    this.meetingReference = '',
    this.moderationNote = '',
    List<LevelResultAudit>? audit,
  }) : audit = audit ?? [];

  final String level;
  final List<LevelResultCoursePackage> courses;
  LevelResultStatus status;
  int adjustment;
  bool departmentalMeetingHeld;
  String meetingReference;
  String moderationNote;
  final List<LevelResultAudit> audit;

  int get studentScoreRows => courses.fold<int>(
        0,
        (sum, course) => sum + course.students.length,
      );

  int get verifiedCourses =>
      courses.where((course) => course.verifiedByExamOfficer).length;

  bool get allCoursesVerified =>
      courses.isNotEmpty && courses.every((course) => course.verifiedByExamOfficer);

  double get originalAverage {
    final rows = [for (final course in courses) ...course.students];
    if (rows.isEmpty) return 0;
    return rows.fold<int>(0, (sum, row) => sum + row.originalScore) /
        rows.length;
  }

  double get moderatedAverage {
    final rows = [for (final course in courses) ...course.students];
    if (rows.isEmpty) return 0;
    return rows.fold<int>(
          0,
          (sum, row) => sum + row.moderatedScore(adjustment),
        ) /
        rows.length;
  }
}

class LevelResultModerationState extends ChangeNotifier {
  LevelResultModerationState._() {
    _boards = _buildBoards();
    _seedWorkflowStages();
  }

  static final LevelResultModerationState instance =
      LevelResultModerationState._();

  final ExamOfficerAcademicRegistry _registry =
      ExamOfficerAcademicRegistry.instance;
  final LecturerGradebookState _gradebook = LecturerGradebookState.instance;

  late final List<LevelResultBoard> _boards;

  List<LevelResultBoard> get boards => List.unmodifiable(_boards);

  LevelResultBoard boardFor(String level) =>
      _boards.firstWhere((board) => board.level == level);

  void openModeration({
    required String level,
    required String meetingReference,
    required String note,
  }) {
    final board = boardFor(level);
    if (board.status != LevelResultStatus.readyForDecision &&
        board.status != LevelResultStatus.returnedToExamOfficer) {
      throw StateError('This level is not available for moderation.');
    }
    if (!board.allCoursesVerified) {
      throw StateError('All course results for this level must be verified first.');
    }
    if (meetingReference.trim().isEmpty) {
      throw StateError('Enter the departmental meeting reference or title.');
    }
    board.departmentalMeetingHeld = true;
    board.meetingReference = meetingReference.trim();
    board.moderationNote = note.trim();
    board.status = LevelResultStatus.moderationInProgress;
    board.audit.add(
      LevelResultAudit(
        actor: 'Exam Officer',
        action: 'Opened Level Result Moderation',
        note:
            '${board.meetingReference}${note.trim().isEmpty ? '' : ' — ${note.trim()}'}',
      ),
    );
    notifyListeners();
  }

  void applyLevelAdjustment({
    required String level,
    required int adjustment,
    required String note,
  }) {
    final board = boardFor(level);
    if (board.status != LevelResultStatus.moderationInProgress ||
        !board.departmentalMeetingHeld) {
      throw StateError(
        'Open level moderation and record the departmental meeting first.',
      );
    }
    if (note.trim().isEmpty) {
      throw StateError('Enter the departmental moderation reason.');
    }
    board.adjustment = adjustment;
    board.moderationNote = note.trim();
    board.audit.add(
      LevelResultAudit(
        actor: 'Departmental Meeting',
        action: 'Applied Uniform Level Adjustment',
        note:
            '${adjustment >= 0 ? '+' : ''}$adjustment mark(s) to every result score in ${board.level}. ${note.trim()}',
      ),
    );
    notifyListeners();
  }

  void sendToHod({
    required String level,
    required String note,
    required bool withoutModeration,
  }) {
    final board = boardFor(level);
    final directAllowed = board.status == LevelResultStatus.readyForDecision ||
        board.status == LevelResultStatus.returnedToExamOfficer;
    final moderatedAllowed =
        board.status == LevelResultStatus.moderationInProgress &&
            board.departmentalMeetingHeld;
    if (withoutModeration && !directAllowed) {
      throw StateError('This level cannot be sent directly to the HoD now.');
    }
    if (!withoutModeration && !moderatedAllowed) {
      throw StateError('Complete the level moderation decision first.');
    }
    if (!board.allCoursesVerified) {
      throw StateError('All course results for this level must be verified first.');
    }
    if (withoutModeration) {
      board.adjustment = 0;
      board.departmentalMeetingHeld = false;
      board.meetingReference = '';
      board.moderationNote = 'No level mark adjustment requested.';
    }
    board.status = LevelResultStatus.waitingHodApproval;
    board.audit.add(
      LevelResultAudit(
        actor: 'Exam Officer',
        action: 'Submitted Level Results to HoD',
        note: withoutModeration
            ? 'Submitted without result moderation. ${note.trim()}'
            : 'Submitted after departmental level moderation (${board.adjustment >= 0 ? '+' : ''}${board.adjustment}). ${note.trim()}',
      ),
    );
    notifyListeners();
  }

  void hodApprove({required String level, required String note}) {
    final board = boardFor(level);
    if (board.status != LevelResultStatus.waitingHodApproval) return;
    board.status = LevelResultStatus.hodApproved;
    board.audit.add(
      LevelResultAudit(
        actor: 'HoD',
        action: 'Approved Level Results',
        note: note.trim().isEmpty ? 'Approved for publication.' : note.trim(),
      ),
    );
    notifyListeners();
  }

  void hodReturn({required String level, required String note}) {
    final board = boardFor(level);
    if (board.status != LevelResultStatus.waitingHodApproval) return;
    board.status = LevelResultStatus.returnedToExamOfficer;
    board.audit.add(
      LevelResultAudit(
        actor: 'HoD',
        action: 'Returned Level Results',
        note: note.trim().isEmpty
            ? 'Returned to Exam Officer for review.'
            : note.trim(),
      ),
    );
    notifyListeners();
  }

  void publishLevel({required String level, required String note}) {
    final board = boardFor(level);
    if (board.status != LevelResultStatus.hodApproved) {
      throw StateError('HoD approval is required before publication.');
    }
    board.status = LevelResultStatus.published;
    board.audit.add(
      LevelResultAudit(
        actor: 'HoD',
        action: 'Published Level Results',
        note: note.trim().isEmpty
            ? '${board.level} results published.'
            : note.trim(),
      ),
    );
    notifyListeners();
  }

  List<LevelResultBoard> _buildBoards() {
    return [
      for (final level in ExamOfficerAcademicRegistry.levels)
        LevelResultBoard(
          level: level,
          status: LevelResultStatus.readyForDecision,
          courses: [
            for (final course in _registry.coursesForLevel(level))
              _coursePackage(course, level),
          ],
        ),
    ];
  }

  LevelResultCoursePackage _coursePackage(
    ExamOfficerCourseRegistration course,
    String level,
  ) {
    final gradebookCourse = _findGradebookCourse(course.courseCode);
    if (gradebookCourse != null) {
      final rows = _gradebook
          .studentsFor(gradebookCourse.code)
          .where((student) => student.complete)
          .map(
            (student) => LevelResultStudentScore(
              matricNumber: student.matricNumber,
              studentName: student.studentName,
              originalScore: student.total.clamp(0, 100).toInt(),
            ),
          )
          .toList();
      if (rows.isNotEmpty) {
        return LevelResultCoursePackage(
          courseCode: course.courseCode,
          courseTitle: course.courseTitle,
          lecturers: course.lecturers,
          students: rows,
        );
      }
    }

    return LevelResultCoursePackage(
      courseCode: course.courseCode,
      courseTitle: course.courseTitle,
      lecturers: course.lecturers,
      students: _generatedRows(course.courseCode, level),
    );
  }

  LecturerGradebookCourse? _findGradebookCourse(String code) {
    final key = _normalise(code);
    for (final course in _gradebook.courses) {
      if (_normalise(course.code) == key) return course;
    }
    return null;
  }

  List<LevelResultStudentScore> _generatedRows(String courseCode, String level) {
    const names = [
      'Aisha Muhammad',
      'Abdullahi Musa',
      'Maryam Usman',
      'Samuel John',
      'Zainab Bello',
      'Ibrahim Lawal',
    ];
    final levelNumber = int.tryParse(level.substring(0, 3)) ?? 100;
    final year = switch (levelNumber) {
      100 => 2026,
      200 => 2025,
      300 => 2024,
      _ => 2023,
    };
    final seed = courseCode.codeUnits.fold<int>(0, (sum, value) => sum + value);
    return [
      for (var i = 0; i < names.length; i++)
        LevelResultStudentScore(
          matricNumber:
              '$year/C/CSC/${((levelNumber * 10) + i + 1).toString().padLeft(4, '0')}',
          studentName: names[(i + seed) % names.length],
          originalScore: 38 + ((seed + (i * 9)) % 51),
        ),
    ];
  }

  void _seedWorkflowStages() {
    final level100 = boardFor('100 Level');
    level100.audit.add(
      LevelResultAudit(
        actor: 'Exam Officer',
        action: 'Course Results Verified',
        note: 'All 100 Level course submissions are ready for a level decision.',
      ),
    );

    final level200 = boardFor('200 Level');
    level200.status = LevelResultStatus.moderationInProgress;
    level200.departmentalMeetingHeld = true;
    level200.meetingReference = 'Departmental Results Meeting — 200 Level';
    level200.adjustment = 2;
    level200.moderationNote =
        'Department approved a uniform two-mark upward moderation.';
    level200.audit.addAll([
      LevelResultAudit(
        actor: 'Exam Officer',
        action: 'Opened Level Result Moderation',
        note: level200.meetingReference,
      ),
      LevelResultAudit(
        actor: 'Departmental Meeting',
        action: 'Applied Uniform Level Adjustment',
        note: '+2 marks to all 200 Level result scores.',
      ),
    ]);

    final level300 = boardFor('300 Level');
    level300.status = LevelResultStatus.waitingHodApproval;
    level300.departmentalMeetingHeld = true;
    level300.meetingReference = 'Departmental Results Meeting — 300 Level';
    level300.adjustment = -1;
    level300.moderationNote =
        'Department approved a uniform one-mark downward moderation.';
    level300.audit.addAll([
      LevelResultAudit(
        actor: 'Departmental Meeting',
        action: 'Applied Uniform Level Adjustment',
        note: '-1 mark to all 300 Level result scores.',
      ),
      LevelResultAudit(
        actor: 'Exam Officer',
        action: 'Submitted Level Results to HoD',
        note: 'Waiting for HoD approval after departmental moderation.',
      ),
    ]);

    final level400 = boardFor('400 Level');
    level400.status = LevelResultStatus.hodApproved;
    level400.adjustment = 0;
    level400.audit.addAll([
      LevelResultAudit(
        actor: 'Exam Officer',
        action: 'Submitted Level Results to HoD',
        note: 'No level adjustment requested.',
      ),
      LevelResultAudit(
        actor: 'HoD',
        action: 'Approved Level Results',
        note: '400 Level results approved and ready for publication.',
      ),
    ]);
  }
}

String _normalise(String value) => value.replaceAll(' ', '').toUpperCase();
