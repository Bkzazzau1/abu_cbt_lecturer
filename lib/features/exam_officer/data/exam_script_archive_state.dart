import 'package:flutter/foundation.dart';

import '../../lecturer_workflow/data/lecturer_demo_state.dart';
import 'exam_officer_academic_registry.dart';
import 'exam_officer_marking_assignment_state.dart';

class ArchivedExamQuestion {
  const ArchivedExamQuestion({
    required this.question,
    required this.response,
    required this.mark,
    required this.maxMark,
  });

  final String question;
  final String response;
  final int mark;
  final int maxMark;
}

class ArchivedExamScript {
  const ArchivedExamScript({
    required this.id,
    required this.academicSession,
    required this.semester,
    required this.level,
    required this.courseCode,
    required this.courseTitle,
    required this.studentName,
    required this.matricNumber,
    required this.markerName,
    required this.objectiveScore,
    required this.objectiveMax,
    required this.questions,
    required this.archivedAt,
  });

  final String id;
  final String academicSession;
  final String semester;
  final String level;
  final String courseCode;
  final String courseTitle;
  final String studentName;
  final String matricNumber;
  final String markerName;
  final int objectiveScore;
  final int objectiveMax;
  final List<ArchivedExamQuestion> questions;
  final DateTime archivedAt;

  int get theoryScore =>
      questions.fold<int>(0, (sum, question) => sum + question.mark);
  int get theoryMax =>
      questions.fold<int>(0, (sum, question) => sum + question.maxMark);
  int get totalScore => objectiveScore + theoryScore;
  int get totalMax => objectiveMax + theoryMax;

  String get grade {
    if (totalMax == 0) return '—';
    final score = totalScore * 100 / totalMax;
    if (score >= 70) return 'A';
    if (score >= 60) return 'B';
    if (score >= 50) return 'C';
    if (score >= 45) return 'D';
    if (score >= 40) return 'E';
    return 'F';
  }

  String get archivePath {
    final session = academicSession.replaceAll('/', '-');
    final matric = matricNumber.replaceAll('/', '_');
    return 'School History / $session / $semester / $level / $courseCode / $matric.pdf';
  }
}

class ExamScriptArchiveState extends ChangeNotifier {
  ExamScriptArchiveState._() {
    _records.addAll(_historicalSamples());
    _syncSubmittedScripts(notify: false);
    LecturerDemoState.instance.addListener(_handleScriptChange);
  }

  static final ExamScriptArchiveState instance = ExamScriptArchiveState._();

  final ExamOfficerAcademicRegistry _registry =
      ExamOfficerAcademicRegistry.instance;
  final ExamOfficerMarkingAssignmentState _markers =
      ExamOfficerMarkingAssignmentState.instance;
  final List<ArchivedExamScript> _records = [];

  List<ArchivedExamScript> get records => List.unmodifiable(_records);

  List<String> get sessions =>
      ({for (final item in _records) item.academicSession}.toList()..sort()).reversed.toList();

  List<String> get semesters =>
      ({for (final item in _records) item.semester}.toList()..sort());

  List<String> get levels =>
      ({for (final item in _records) item.level}.toList()..sort());

  void _handleScriptChange() => _syncSubmittedScripts(notify: true);

  void _syncSubmittedScripts({required bool notify}) {
    var changed = false;
    for (final script in LecturerDemoState.instance.scripts) {
      if (script.status != LecturerDemoScriptStatus.submittedToExamOfficer ||
          !script.markingComplete) {
        continue;
      }
      final archiveId = 'live-${script.id}';
      if (_records.any((item) => item.id == archiveId)) continue;

      final registration = _registry.registrationFor(script.courseCode);
      final markerNames = _markers.markersFor(script.courseCode);
      _records.insert(
        0,
        ArchivedExamScript(
          id: archiveId,
          academicSession: '2025/2026',
          semester: registration?.semester ?? 'Semester 1',
          level: registration?.level ?? _levelFromCourse(script.courseCode),
          courseCode: script.courseCode,
          courseTitle: registration?.courseTitle ?? script.examTitle,
          studentName: script.student,
          matricNumber: _matricFromScript(script),
          markerName: markerNames.isEmpty
              ? 'Assigned Marker'
              : markerNames.map((item) => item.name).join(' / '),
          objectiveScore: script.objectiveScore,
          objectiveMax: 40,
          questions: [
            for (final question in script.questions)
              ArchivedExamQuestion(
                question: question.question,
                response: question.candidateAnswer,
                mark: script.marks[question.id] ?? 0,
                maxMark: question.maxMark,
              ),
          ],
          archivedAt: DateTime.now(),
        ),
      );
      changed = true;
    }
    if (changed && notify) notifyListeners();
  }

  List<ArchivedExamScript> _historicalSamples() {
    return [
      _sample(
        id: 'hist-100-1',
        session: '2025/2026',
        semester: 'Semester 1',
        level: '100 Level',
        courseCode: 'CSC 101',
        courseTitle: 'Introduction to Computer Science',
        studentName: 'Aisha Muhammad',
        matric: '2026/C/CSC/0001',
        marker: 'Dr. Amina Bello',
        seed: 1,
      ),
      _sample(
        id: 'hist-100-2',
        session: '2025/2026',
        semester: 'Semester 1',
        level: '100 Level',
        courseCode: 'CSC 103',
        courseTitle: 'Programming Fundamentals',
        studentName: 'Abdullahi Musa',
        matric: '2026/C/CSC/0002',
        marker: 'Dr. Kabiru Umar',
        seed: 2,
      ),
      _sample(
        id: 'hist-200-1',
        session: '2025/2026',
        semester: 'Semester 1',
        level: '200 Level',
        courseCode: 'CSC 201',
        courseTitle: 'Data Structures',
        studentName: 'Rukayya Sani',
        matric: '2025/C/CSC/0022',
        marker: 'Dr. Yusuf Abdullahi',
        seed: 3,
      ),
      _sample(
        id: 'hist-300-1',
        session: '2025/2026',
        semester: 'Semester 1',
        level: '300 Level',
        courseCode: 'CSC 305',
        courseTitle: 'Database Systems',
        studentName: 'Hauwa Ibrahim',
        matric: '2024/C/CSC/0041',
        marker: 'Dr. Amina Bello',
        seed: 4,
      ),
      _sample(
        id: 'hist-300-2',
        session: '2024/2025',
        semester: 'Semester 1',
        level: '300 Level',
        courseCode: 'CSC 307',
        courseTitle: 'Operating Systems',
        studentName: 'Musa Abdullahi',
        matric: '2023/C/CSC/0038',
        marker: 'Dr. Grace Adamu',
        seed: 5,
      ),
      _sample(
        id: 'hist-400-1',
        session: '2025/2026',
        semester: 'Semester 2',
        level: '400 Level',
        courseCode: 'CSC 411',
        courseTitle: 'Artificial Intelligence',
        studentName: 'Halima Yusuf',
        matric: '2023/C/CSC/0061',
        marker: 'Dr. Kabiru Umar',
        seed: 6,
      ),
      _sample(
        id: 'hist-400-2',
        session: '2025/2026',
        semester: 'Semester 2',
        level: '400 Level',
        courseCode: 'CSC 413',
        courseTitle: 'Software Engineering',
        studentName: 'Michael Joseph',
        matric: '2023/C/CSC/0062',
        marker: 'Dr. Sani Bello',
        seed: 7,
      ),
    ];
  }

  ArchivedExamScript _sample({
    required String id,
    required String session,
    required String semester,
    required String level,
    required String courseCode,
    required String courseTitle,
    required String studentName,
    required String matric,
    required String marker,
    required int seed,
  }) {
    return ArchivedExamScript(
      id: id,
      academicSession: session,
      semester: semester,
      level: level,
      courseCode: courseCode,
      courseTitle: courseTitle,
      studentName: studentName,
      matricNumber: matric,
      markerName: marker,
      objectiveScore: 24 + seed,
      objectiveMax: 40,
      archivedAt: DateTime(2026, 8, 20 + seed),
      questions: [
        ArchivedExamQuestion(
          question: 'Question 1: Explain the major concept assessed in this course.',
          response: 'The candidate gave a structured explanation with a relevant example.',
          mark: 14 + (seed % 4),
          maxMark: 20,
        ),
        ArchivedExamQuestion(
          question: 'Question 2: Apply the concept to a practical problem.',
          response: 'The candidate applied the method and explained the main steps.',
          mark: 12 + (seed % 5),
          maxMark: 20,
        ),
        ArchivedExamQuestion(
          question: 'Question 3: Discuss limitations or trade-offs.',
          response: 'The candidate identified limitations and proposed an improvement.',
          mark: 10 + (seed % 6),
          maxMark: 20,
        ),
      ],
    );
  }
}

String _matricFromScript(LecturerDemoExamScript script) {
  final serial = script.candidateNo.split('/').last.trim().padLeft(4, '0');
  return '2023/C/CSC/$serial';
}

String _levelFromCourse(String courseCode) {
  final match = RegExp(r'\d+').firstMatch(courseCode);
  final digits = match?.group(0) ?? '';
  return digits.isEmpty ? 'Unknown Level' : '${digits[0]}00 Level';
}
