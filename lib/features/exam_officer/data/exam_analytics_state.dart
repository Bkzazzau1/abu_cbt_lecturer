import 'package:flutter/foundation.dart';

import 'exam_officer_academic_registry.dart';
import 'exam_officer_invigilation_state.dart';
import 'exam_officer_workflow_state.dart';
import 'level_result_moderation_state.dart';

class ExamAnalyticsHistoryPoint {
  const ExamAnalyticsHistoryPoint({
    required this.session,
    required this.averageScore,
    required this.passRate,
    required this.candidateCount,
  });

  final String session;
  final double averageScore;
  final double passRate;
  final int candidateCount;

  double get failRate => 100 - passRate;
}

class ExamAnalyticsCourseSnapshot {
  const ExamAnalyticsCourseSnapshot({
    required this.courseCode,
    required this.courseTitle,
    required this.level,
    required this.semester,
    required this.registeredCandidates,
    required this.carryoverCandidates,
    required this.averageScore,
    required this.passRate,
    required this.scoreBands,
    required this.moderationAdjustment,
    required this.questionStatus,
    required this.resultStatus,
    required this.sittingCount,
    required this.scheduledCapacity,
    required this.invigilatorCount,
    required this.history,
  });

  final String courseCode;
  final String courseTitle;
  final String level;
  final String semester;
  final int registeredCandidates;
  final int carryoverCandidates;
  final double averageScore;
  final double passRate;
  final Map<String, int> scoreBands;
  final int moderationAdjustment;
  final String questionStatus;
  final String resultStatus;
  final int sittingCount;
  final int scheduledCapacity;
  final int invigilatorCount;
  final List<ExamAnalyticsHistoryPoint> history;

  double get failRate => 100 - passRate;

  double get carryoverRate => registeredCandidates == 0
      ? 0
      : carryoverCandidates * 100 / registeredCandidates;

  double get capacityCoverage => registeredCandidates == 0
      ? 0
      : (scheduledCapacity * 100 / registeredCandidates).clamp(0, 100).toDouble();

  double get previousPassRate =>
      history.length < 2 ? passRate : history[history.length - 2].passRate;

  double get passRateChange => passRate - previousPassRate;

  int get riskScore {
    var score = 0;
    if (passRate < 50) {
      score += 35;
    } else if (passRate < 65) {
      score += 24;
    } else if (passRate < 75) {
      score += 10;
    }
    if (averageScore < 45) {
      score += 25;
    } else if (averageScore < 55) {
      score += 14;
    }
    if (passRateChange <= -8) {
      score += 15;
    } else if (passRateChange <= -3) {
      score += 8;
    }
    if (carryoverRate >= 12) score += 10;
    if (questionStatus == 'Correction Requested' ||
        questionStatus == 'With Moderator') {
      score += 8;
    }
    if (sittingCount > 0 && invigilatorCount == 0) score += 5;
    if (sittingCount > 0 && capacityCoverage < 100) score += 5;
    return score.clamp(0, 100);
  }

  String get riskLabel {
    if (riskScore >= 55) return 'High attention';
    if (riskScore >= 32) return 'Watch';
    return 'Stable';
  }

  List<String> get riskReasons {
    final reasons = <String>[];
    if (passRate < 65) reasons.add('Low pass rate');
    if (averageScore < 55) reasons.add('Low class average');
    if (passRateChange <= -3) reasons.add('Declining historical trend');
    if (carryoverRate >= 12) reasons.add('High carryover load');
    if (questionStatus == 'Correction Requested') {
      reasons.add('Question correction outstanding');
    }
    if (questionStatus == 'With Moderator') {
      reasons.add('Moderation still pending');
    }
    if (sittingCount > 0 && capacityCoverage < 100) {
      reasons.add('Scheduled capacity gap');
    }
    if (sittingCount > 0 && invigilatorCount == 0) {
      reasons.add('No invigilator posted');
    }
    if (reasons.isEmpty) reasons.add('No major risk signal');
    return reasons;
  }
}

class ExamAnalyticsLevelSummary {
  const ExamAnalyticsLevelSummary({
    required this.level,
    required this.courseCount,
    required this.registeredCandidates,
    required this.averageScore,
    required this.passRate,
    required this.weakCourses,
  });

  final String level;
  final int courseCount;
  final int registeredCandidates;
  final double averageScore;
  final double passRate;
  final int weakCourses;
}

class ExamAnalyticsState extends ChangeNotifier {
  ExamAnalyticsState._() {
    _workflow.addListener(_handleSourceChanged);
    _levelResults.addListener(_handleSourceChanged);
    _invigilation.addListener(_handleSourceChanged);
  }

  static final ExamAnalyticsState instance = ExamAnalyticsState._();

  final ExamOfficerAcademicRegistry _registry = ExamOfficerAcademicRegistry.instance;
  final ExamOfficerWorkflowState _workflow = ExamOfficerWorkflowState.instance;
  final LevelResultModerationState _levelResults =
      LevelResultModerationState.instance;
  final ExamOfficerInvigilationState _invigilation =
      ExamOfficerInvigilationState.instance;

  static const historySessions = [
    '2021/2022',
    '2022/2023',
    '2023/2024',
    '2024/2025',
    '2025/2026',
  ];

  List<ExamAnalyticsCourseSnapshot> get courses => [
        for (final registration in _registry.courses)
          _courseSnapshot(registration),
      ];

  List<ExamAnalyticsCourseSnapshot> coursesForLevel(String? level) {
    final all = courses;
    if (level == null || level == 'All Levels') return all;
    return all.where((item) => item.level == level).toList(growable: false);
  }

  List<ExamAnalyticsCourseSnapshot> get weakCourses {
    final items = courses.where((item) => item.riskScore >= 32).toList();
    items.sort((a, b) => b.riskScore.compareTo(a.riskScore));
    return items;
  }

  List<ExamAnalyticsLevelSummary> get levelSummaries => [
        for (final level in ExamOfficerAcademicRegistry.levels)
          _levelSummary(level),
      ];

  double get departmentPassRate {
    final all = courses;
    final totalCandidates = all.fold<int>(
      0,
      (sum, item) => sum + item.registeredCandidates,
    );
    if (totalCandidates == 0) return 0;
    final weighted = all.fold<double>(
      0,
      (sum, item) => sum + item.passRate * item.registeredCandidates,
    );
    return weighted / totalCandidates;
  }

  double get departmentAverage {
    final all = courses;
    final totalCandidates = all.fold<int>(
      0,
      (sum, item) => sum + item.registeredCandidates,
    );
    if (totalCandidates == 0) return 0;
    final weighted = all.fold<double>(
      0,
      (sum, item) => sum + item.averageScore * item.registeredCandidates,
    );
    return weighted / totalCandidates;
  }

  int get scheduledCourseCount =>
      courses.where((item) => item.sittingCount > 0).length;

  int get fullyInvigilatedCourseCount => courses
      .where((item) => item.sittingCount > 0 && item.invigilatorCount > 0)
      .length;

  int get resultReadyCourseCount => courses
      .where((item) =>
          item.resultStatus == 'Verified' ||
          item.resultStatus == 'Forwarded to HoD')
      .length;

  ExamAnalyticsCourseSnapshot courseByCode(String code) {
    final key = _normalise(code);
    for (final item in courses) {
      if (_normalise(item.courseCode) == key) return item;
    }
    return courses.first;
  }

  ExamAnalyticsCourseSnapshot _courseSnapshot(
    ExamOfficerCourseRegistration registration,
  ) {
    final board = _levelResults.boardFor(registration.level);
    LevelResultCoursePackage? package;
    for (final item in board.courses) {
      if (_normalise(item.courseCode) == _normalise(registration.courseCode)) {
        package = item;
        break;
      }
    }

    final scores = <int>[];
    if (package != null) {
      for (final row in package.students) {
        scores.add(row.moderatedScore(board.adjustment));
      }
    }
    if (scores.isEmpty) {
      scores.addAll(_fallbackScores(registration.courseCode));
    }

    final average = scores.fold<int>(0, (sum, value) => sum + value) /
        scores.length;
    final passed = scores.where((value) => value >= 40).length;
    final passRate = passed * 100 / scores.length;

    final schedules = _workflow.examSchedules
        .where(
          (item) =>
              _normalise(item.courseCode) ==
              _normalise(registration.courseCode),
        )
        .toList(growable: false);
    final capacity = schedules.fold<int>(0, (sum, item) => sum + item.capacity);
    final invigilators =
        _invigilation.assignmentsForCourse(registration.courseCode).length;

    String questionStatus = 'Not Submitted';
    for (final paper in _workflow.questionPapers) {
      if (_normalise(paper.courseCode) == _normalise(registration.courseCode)) {
        questionStatus = paper.status.label;
        break;
      }
    }

    String resultStatus = 'Awaiting Result Batch';
    for (final result in _workflow.resultBatches) {
      if (_normalise(result.courseCode) == _normalise(registration.courseCode)) {
        resultStatus = result.status.label;
        break;
      }
    }

    final bands = <String, int>{
      '80–100': 0,
      '60–79': 0,
      '50–59': 0,
      '45–49': 0,
      '40–44': 0,
      '<40': 0,
    };
    for (final score in scores) {
      final band = score >= 80
          ? '80–100'
          : score >= 60
              ? '60–79'
              : score >= 50
                  ? '50–59'
                  : score >= 45
                      ? '45–49'
                      : score >= 40
                          ? '40–44'
                          : '<40';
      bands[band] = (bands[band] ?? 0) + 1;
    }

    final history = _historyFor(
      registration: registration,
      currentAverage: average,
      currentPassRate: passRate,
    );

    return ExamAnalyticsCourseSnapshot(
      courseCode: registration.courseCode,
      courseTitle: registration.courseTitle,
      level: registration.level,
      semester: registration.semester,
      registeredCandidates: registration.totalRegistered,
      carryoverCandidates: registration.carryoverCount,
      averageScore: average,
      passRate: passRate,
      scoreBands: bands,
      moderationAdjustment: board.adjustment,
      questionStatus: questionStatus,
      resultStatus: resultStatus,
      sittingCount: schedules.length,
      scheduledCapacity: capacity,
      invigilatorCount: invigilators,
      history: history,
    );
  }

  ExamAnalyticsLevelSummary _levelSummary(String level) {
    final items = courses.where((item) => item.level == level).toList();
    final registrations = items.fold<int>(
      0,
      (sum, item) => sum + item.registeredCandidates,
    );
    if (items.isEmpty || registrations == 0) {
      return ExamAnalyticsLevelSummary(
        level: level,
        courseCount: items.length,
        registeredCandidates: registrations,
        averageScore: 0,
        passRate: 0,
        weakCourses: 0,
      );
    }
    final average = items.fold<double>(
          0,
          (sum, item) => sum + item.averageScore * item.registeredCandidates,
        ) /
        registrations;
    final passRate = items.fold<double>(
          0,
          (sum, item) => sum + item.passRate * item.registeredCandidates,
        ) /
        registrations;
    return ExamAnalyticsLevelSummary(
      level: level,
      courseCount: items.length,
      registeredCandidates: registrations,
      averageScore: average,
      passRate: passRate,
      weakCourses: items.where((item) => item.riskScore >= 32).length,
    );
  }

  List<ExamAnalyticsHistoryPoint> _historyFor({
    required ExamOfficerCourseRegistration registration,
    required double currentAverage,
    required double currentPassRate,
  }) {
    final seed = registration.courseCode.codeUnits.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final courseBias = ((seed % 9) - 4).toDouble();
    final trendBias = ((seed % 5) - 2).toDouble();
    final candidateBase = registration.totalRegistered;
    final history = <ExamAnalyticsHistoryPoint>[];

    for (var i = 0; i < historySessions.length - 1; i++) {
      final yearsBack = (historySessions.length - 1) - i;
      final avg = (currentAverage - trendBias * yearsBack +
              courseBias * (i.isEven ? 0.8 : -0.45))
          .clamp(34, 78)
          .toDouble();
      final pass = (currentPassRate - trendBias * yearsBack * 1.8 +
              courseBias * (i.isEven ? 1.0 : -0.7))
          .clamp(35, 96)
          .toDouble();
      final count = (candidateBase - yearsBack * 8 + (seed + i * 7) % 17)
          .clamp(60, 400)
          .toInt();
      history.add(
        ExamAnalyticsHistoryPoint(
          session: historySessions[i],
          averageScore: avg,
          passRate: pass,
          candidateCount: count,
        ),
      );
    }

    history.add(
      ExamAnalyticsHistoryPoint(
        session: historySessions.last,
        averageScore: currentAverage,
        passRate: currentPassRate,
        candidateCount: registration.totalRegistered,
      ),
    );
    return history;
  }

  List<int> _fallbackScores(String courseCode) {
    final seed = courseCode.codeUnits.fold<int>(0, (sum, value) => sum + value);
    return [
      for (var i = 0; i < 12; i++) 36 + ((seed + i * 11) % 51),
    ];
  }

  void _handleSourceChanged() => notifyListeners();
}

String _normalise(String value) => value.replaceAll(' ', '').toUpperCase();
