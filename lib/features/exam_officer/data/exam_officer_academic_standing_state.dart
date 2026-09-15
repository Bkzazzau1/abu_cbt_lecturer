import 'package:flutter/foundation.dart';

import 'exam_officer_academic_registry.dart';
import 'level_result_moderation_state.dart';

/// ABU undergraduate classified-degree grading policy used by the academic
/// standing calculator. Keep this policy in one place so GPA/CGPA calculations
/// never depend on presentation-layer grade labels.
class AbuUndergraduateGradingPolicy {
  const AbuUndergraduateGradingPolicy._();

  static String letterGrade(int score) {
    if (score >= 80) return 'A';
    if (score >= 60) return 'B';
    if (score >= 50) return 'C';
    if (score >= 45) return 'D';
    if (score >= 40) return 'E';
    return 'F';
  }

  static int gradePoint(int score) {
    if (score >= 80) return 5;
    if (score >= 60) return 4;
    if (score >= 50) return 3;
    if (score >= 45) return 2;
    if (score >= 40) return 1;
    return 0;
  }

  static const double classifiedGoodStandingCgpa = 1.00;
}

enum AcademicStandingStatus { goodStanding, probation, withdrawalReview }

extension AcademicStandingStatusLabel on AcademicStandingStatus {
  String get label {
    switch (this) {
      case AcademicStandingStatus.goodStanding:
        return 'Good Standing';
      case AcademicStandingStatus.probation:
        return 'Probation';
      case AcademicStandingStatus.withdrawalReview:
        return 'Withdrawal Review';
    }
  }
}

class AcademicCourseResult {
  const AcademicCourseResult({
    required this.courseCode,
    required this.courseTitle,
    required this.creditUnits,
    required this.originalScore,
    required this.levelAdjustment,
    this.isCarryover = false,
  });

  final String courseCode;
  final String courseTitle;
  final int creditUnits;
  final int originalScore;
  final int levelAdjustment;
  final bool isCarryover;

  int get finalScore => (originalScore + levelAdjustment).clamp(0, 100).toInt();
  String get grade => AbuUndergraduateGradingPolicy.letterGrade(finalScore);
  int get gradePoint => AbuUndergraduateGradingPolicy.gradePoint(finalScore);
  int get creditPoints => gradePoint * creditUnits;
  bool get failed => gradePoint == 0;
}

class StudentAcademicStanding {
  const StudentAcademicStanding({
    required this.matricNumber,
    required this.studentName,
    required this.level,
    required this.academicSession,
    required this.semester,
    required this.previousRegisteredUnits,
    required this.previousCreditPoints,
    required this.previousProbationSemesters,
    required this.currentResults,
  });

  final String matricNumber;
  final String studentName;
  final String level;
  final String academicSession;
  final String semester;
  final int previousRegisteredUnits;
  final int previousCreditPoints;
  final int previousProbationSemesters;
  final List<AcademicCourseResult> currentResults;

  int get currentRegisteredUnits => currentResults.fold<int>(
        0,
        (sum, item) => sum + item.creditUnits,
      );

  int get currentCreditPoints => currentResults.fold<int>(
        0,
        (sum, item) => sum + item.creditPoints,
      );

  double get gpa => currentRegisteredUnits == 0
      ? 0
      : currentCreditPoints / currentRegisteredUnits;

  int get cumulativeRegisteredUnits =>
      previousRegisteredUnits + currentRegisteredUnits;

  int get cumulativeCreditPoints =>
      previousCreditPoints + currentCreditPoints;

  double get cgpa => cumulativeRegisteredUnits == 0
      ? 0
      : cumulativeCreditPoints / cumulativeRegisteredUnits;

  int get failedCourses => currentResults.where((item) => item.failed).length;

  int get carryoverAttempts =>
      currentResults.where((item) => item.isCarryover).length;

  bool get belowGoodStanding =>
      cgpa < AbuUndergraduateGradingPolicy.classifiedGoodStandingCgpa;

  AcademicStandingStatus get standing {
    if (!belowGoodStanding) return AcademicStandingStatus.goodStanding;
    if (previousProbationSemesters >= 1) {
      return AcademicStandingStatus.withdrawalReview;
    }
    return AcademicStandingStatus.probation;
  }

  int get probationSemesterCount =>
      previousProbationSemesters + (belowGoodStanding ? 1 : 0);
}

/// Exam Officer academic-standing ledger.
///
/// This mock state deliberately keeps GPA/CGPA arithmetic separate from
/// question marking. It consumes the department registry for students/courses
/// and the level-result moderation state for any approved level-wide mark
/// adjustment. Historical cumulative totals are seeded so the interface can
/// demonstrate good standing, probation and withdrawal-review cases.
class ExamOfficerAcademicStandingState extends ChangeNotifier {
  ExamOfficerAcademicStandingState._() {
    LevelResultModerationState.instance.addListener(_handleResultChange);
  }

  static final ExamOfficerAcademicStandingState instance =
      ExamOfficerAcademicStandingState._();

  final ExamOfficerAcademicRegistry _registry =
      ExamOfficerAcademicRegistry.instance;
  final LevelResultModerationState _levelResults =
      LevelResultModerationState.instance;

  static const academicSession = '2025/2026';

  static const Map<String, int> _creditUnits = {
    'CSC101': 2,
    'CSC103': 3,
    'MTH101': 3,
    'CSC201': 3,
    'CSC203': 3,
    'MTH201': 3,
    'CSC305': 3,
    'CSC307': 3,
    'CSC411': 3,
    'CSC413': 3,
  };

  List<StudentAcademicStanding> recordsForLevel(String level) {
    final students = _registry.studentsForLevel(level);
    final courses = _registry.coursesForLevel(level);
    final board = _levelResults.boardFor(level);
    final semester = courses.isEmpty ? 'Semester 1' : courses.first.semester;

    return [
      for (var i = 0; i < students.length; i++)
        _buildStanding(
          student: students[i],
          studentIndex: i,
          courses: courses,
          adjustment: board.adjustment,
          semester: semester,
        ),
    ];
  }

  List<StudentAcademicStanding> get allRecords => [
        for (final level in ExamOfficerAcademicRegistry.levels)
          ...recordsForLevel(level),
      ];

  List<StudentAcademicStanding> get probationList => allRecords
      .where((item) => item.standing == AcademicStandingStatus.probation)
      .toList(growable: false);

  List<StudentAcademicStanding> get withdrawalReviewList => allRecords
      .where(
        (item) => item.standing == AcademicStandingStatus.withdrawalReview,
      )
      .toList(growable: false);

  int creditUnitsFor(String courseCode) =>
      _creditUnits[_normalise(courseCode)] ?? 3;

  StudentAcademicStanding _buildStanding({
    required ExamOfficerLevelStudent student,
    required int studentIndex,
    required List<ExamOfficerCourseRegistration> courses,
    required int adjustment,
    required String semester,
  }) {
    final previous = _previousSummary(student, studentIndex);
    final results = <AcademicCourseResult>[
      for (var courseIndex = 0; courseIndex < courses.length; courseIndex++)
        AcademicCourseResult(
          courseCode: courses[courseIndex].courseCode,
          courseTitle: courses[courseIndex].courseTitle,
          creditUnits: creditUnitsFor(courses[courseIndex].courseCode),
          originalScore: _scoreFor(
            student: student,
            studentIndex: studentIndex,
            course: courses[courseIndex],
            courseIndex: courseIndex,
          ),
          levelAdjustment: adjustment,
        ),
    ];

    for (var i = 0; i < student.carryoverCourseCodes.length; i++) {
      final carryCode = student.carryoverCourseCodes[i];
      final course = _registry.registrationFor(carryCode);
      if (course == null) continue;
      final carryAdjustment = _levelResults.boardFor(course.level).adjustment;
      results.add(
        AcademicCourseResult(
          courseCode: course.courseCode,
          courseTitle: course.courseTitle,
          creditUnits: creditUnitsFor(course.courseCode),
          originalScore: _scoreFor(
            student: student,
            studentIndex: studentIndex,
            course: course,
            courseIndex: courses.length + i,
          ),
          levelAdjustment: carryAdjustment,
          isCarryover: true,
        ),
      );
    }

    return StudentAcademicStanding(
      matricNumber: student.matricNumber,
      studentName: student.name,
      level: student.level,
      academicSession: academicSession,
      semester: semester,
      previousRegisteredUnits: previous.registeredUnits,
      previousCreditPoints: previous.creditPoints,
      previousProbationSemesters: previous.probationSemesters,
      currentResults: results,
    );
  }

  int _scoreFor({
    required ExamOfficerLevelStudent student,
    required int studentIndex,
    required ExamOfficerCourseRegistration course,
    required int courseIndex,
  }) {
    final special = _specialStandingCase(student.matricNumber);
    if (special == _StandingSeed.withdrawalReview) {
      return 18 + ((studentIndex * 3 + courseIndex * 5) % 20);
    }
    if (special == _StandingSeed.probation) {
      return 24 + ((studentIndex * 5 + courseIndex * 4) % 16);
    }

    final seed = '${student.matricNumber}${course.courseCode}'
        .codeUnits
        .fold<int>(0, (sum, value) => sum + value);
    return 42 + ((seed + studentIndex * 7 + courseIndex * 11) % 47);
  }

  ({int registeredUnits, int creditPoints, int probationSemesters})
      _previousSummary(ExamOfficerLevelStudent student, int studentIndex) {
    final special = _specialStandingCase(student.matricNumber);
    final levelNumber = int.tryParse(student.level.substring(0, 3)) ?? 100;
    final completedYears =
        ((levelNumber - 100) ~/ 100).clamp(0, 3).toInt();
    if (completedYears == 0) {
      return (
        registeredUnits: 0,
        creditPoints: 0,
        probationSemesters: 0,
      );
    }

    final units = completedYears * 30;
    if (special == _StandingSeed.withdrawalReview) {
      return (
        registeredUnits: units,
        creditPoints: (units * 0.62).round(),
        probationSemesters: 1,
      );
    }
    if (special == _StandingSeed.probation) {
      return (
        registeredUnits: units,
        creditPoints: (units * 0.70).round(),
        probationSemesters: 0,
      );
    }

    final priorCgpa = 1.80 + ((studentIndex * 37) % 260) / 100;
    return (
      registeredUnits: units,
      creditPoints: (units * priorCgpa.clamp(1.80, 4.40)).round(),
      probationSemesters: 0,
    );
  }

  _StandingSeed _specialStandingCase(String matricNumber) {
    if (matricNumber.endsWith('0044') || matricNumber.endsWith('0064')) {
      return _StandingSeed.withdrawalReview;
    }
    if (matricNumber.endsWith('0004') || matricNumber.endsWith('0025')) {
      return _StandingSeed.probation;
    }
    return _StandingSeed.normal;
  }

  void _handleResultChange() => notifyListeners();
}

enum _StandingSeed { normal, probation, withdrawalReview }

String _normalise(String value) => value.replaceAll(' ', '').toUpperCase();
