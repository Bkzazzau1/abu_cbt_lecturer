import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_session.dart';
import 'lecturer_course_collaboration_state.dart';
import 'lecturer_demo_state.dart';

class LecturerCourseTeacher {
  const LecturerCourseTeacher({required this.name, required this.role});

  final String name;
  final String role;
}

class LecturerGradebookCourse {
  LecturerGradebookCourse({
    required this.code,
    required this.title,
    required this.level,
    required this.academicSession,
    required this.semester,
    required this.ca1Max,
    required this.ca2Max,
    required this.examMax,
    required this.lecturers,
    this.resultsSubmitted = false,
  });

  final String code;
  final String title;
  final String level;
  final String academicSession;
  final String semester;
  final int ca1Max;
  final int ca2Max;
  final int examMax;
  final List<LecturerCourseTeacher> lecturers;
  bool resultsSubmitted;

  int get totalMax => ca1Max + ca2Max + examMax;
}

class LecturerGradebookStudent {
  LecturerGradebookStudent({
    required this.courseCode,
    required this.matricNumber,
    required this.studentName,
    this.ca1,
    this.ca2,
    this.exam,
    this.lastUpdatedBy = '',
  });

  final String courseCode;
  final String matricNumber;
  final String studentName;
  int? ca1;
  int? ca2;
  int? exam;
  String lastUpdatedBy;

  bool get complete => ca1 != null && ca2 != null && exam != null;

  int get total => (ca1 ?? 0) + (ca2 ?? 0) + (exam ?? 0);

  String gradeFor(LecturerGradebookCourse course) {
    if (!complete || course.totalMax == 0) return '—';
    final percent = total * 100 / course.totalMax;
    if (percent >= 70) return 'A';
    if (percent >= 60) return 'B';
    if (percent >= 50) return 'C';
    if (percent >= 45) return 'D';
    if (percent >= 40) return 'E';
    return 'F';
  }
}

class LecturerGradebookState extends ChangeNotifier {
  LecturerGradebookState._() {
    _syncFromExamScripts(notify: false);
    LecturerDemoState.instance.addListener(_handleExamStateChanged);
  }

  static final LecturerGradebookState instance = LecturerGradebookState._();

  final List<LecturerGradebookCourse> _courses = [
    LecturerGradebookCourse(
      code: 'CSC 201',
      title: 'Data Structures',
      level: '200 Level',
      academicSession: '2025/2026',
      semester: 'Semester 1',
      ca1Max: 10,
      ca2Max: 10,
      examMax: 80,
      lecturers: const [
        LecturerCourseTeacher(name: 'Dr. Amina Bello', role: 'Course Lecturer'),
        LecturerCourseTeacher(name: 'Dr. Yusuf Abdullahi', role: 'Course Lecturer'),
      ],
    ),
    LecturerGradebookCourse(
      code: 'CSC 305',
      title: 'Database Systems',
      level: '300 Level',
      academicSession: '2025/2026',
      semester: 'Semester 1',
      ca1Max: 10,
      ca2Max: 10,
      examMax: 80,
      lecturers: const [
        LecturerCourseTeacher(name: 'Dr. Amina Bello', role: 'Course Lecturer'),
        LecturerCourseTeacher(name: 'Dr. Grace Adamu', role: 'Course Lecturer'),
      ],
    ),
    LecturerGradebookCourse(
      code: 'CSC 411',
      title: 'Artificial Intelligence',
      level: '400 Level',
      academicSession: '2025/2026',
      semester: 'Semester 2',
      ca1Max: 10,
      ca2Max: 10,
      examMax: 80,
      lecturers: const [
        LecturerCourseTeacher(name: 'Dr. Amina Bello', role: 'Course Lecturer'),
        LecturerCourseTeacher(name: 'Dr. Sani Bello', role: 'Course Lecturer'),
      ],
    ),
  ];

  final List<LecturerGradebookStudent> _students = [
    LecturerGradebookStudent(courseCode: 'CSC 201', matricNumber: '2024/C/CSC/0001', studentName: 'Aisha Muhammad', ca1: 8, ca2: 9, exam: 61),
    LecturerGradebookStudent(courseCode: 'CSC 201', matricNumber: '2024/C/CSC/0002', studentName: 'Abdullahi Musa', ca1: 7, ca2: 8, exam: 56),
    LecturerGradebookStudent(courseCode: 'CSC 201', matricNumber: '2024/C/CSC/0003', studentName: 'Maryam Usman', ca1: 9, ca2: 9, exam: 65),
    LecturerGradebookStudent(courseCode: 'CSC 201', matricNumber: '2024/C/CSC/0004', studentName: 'Samuel John', ca1: 6, ca2: 7, exam: 49),
    LecturerGradebookStudent(courseCode: 'CSC 201', matricNumber: '2024/C/CSC/0005', studentName: 'Zainab Bello', ca1: 10, ca2: 8, exam: 68),
    LecturerGradebookStudent(courseCode: 'CSC 201', matricNumber: '2024/C/CSC/0006', studentName: 'Ibrahim Lawal', ca1: 5, ca2: 6, exam: 45),
    LecturerGradebookStudent(courseCode: 'CSC 201', matricNumber: '2024/C/CSC/0007', studentName: 'Rukayya Sani', ca1: 8, ca2: null, exam: 59),
    LecturerGradebookStudent(courseCode: 'CSC 201', matricNumber: '2024/C/CSC/0008', studentName: 'Daniel Peter', ca1: 7, ca2: 7, exam: null),
    LecturerGradebookStudent(courseCode: 'CSC 201', matricNumber: '2024/C/CSC/0009', studentName: 'Fatima Garba', ca1: 9, ca2: 8, exam: 63),
    LecturerGradebookStudent(courseCode: 'CSC 201', matricNumber: '2024/C/CSC/0010', studentName: 'Yusuf Ahmed', ca1: 6, ca2: 6, exam: 51),

    LecturerGradebookStudent(courseCode: 'CSC 305', matricNumber: '2023/C/CSC/0044', studentName: 'Maryam Bello', ca1: 8, ca2: 9),
    LecturerGradebookStudent(courseCode: 'CSC 305', matricNumber: '2023/C/CSC/0071', studentName: 'Tunde Okafor', ca1: 7, ca2: null),
    LecturerGradebookStudent(courseCode: 'CSC 305', matricNumber: '2023/C/CSC/0072', studentName: 'Hauwa Ibrahim', ca1: 9, ca2: 8, exam: 62),
    LecturerGradebookStudent(courseCode: 'CSC 305', matricNumber: '2023/C/CSC/0073', studentName: 'Musa Abdullahi', ca1: 6, ca2: 7, exam: 54),
    LecturerGradebookStudent(courseCode: 'CSC 305', matricNumber: '2023/C/CSC/0074', studentName: 'Grace James', ca1: 10, ca2: 9, exam: 69),
    LecturerGradebookStudent(courseCode: 'CSC 305', matricNumber: '2023/C/CSC/0075', studentName: 'Sadiq Umar', ca1: 5, ca2: 6, exam: 47),
    LecturerGradebookStudent(courseCode: 'CSC 305', matricNumber: '2023/C/CSC/0076', studentName: 'Amina Kabir', ca1: 8, ca2: 8, exam: 60),
    LecturerGradebookStudent(courseCode: 'CSC 305', matricNumber: '2023/C/CSC/0077', studentName: 'Emmanuel David', ca1: 7, ca2: 7, exam: 58),
    LecturerGradebookStudent(courseCode: 'CSC 305', matricNumber: '2023/C/CSC/0078', studentName: 'Khadija Aliyu', ca1: 9, ca2: 10, exam: 66),
    LecturerGradebookStudent(courseCode: 'CSC 305', matricNumber: '2023/C/CSC/0079', studentName: 'Bashir Sule', ca1: 6, ca2: 5, exam: 50),

    LecturerGradebookStudent(courseCode: 'CSC 411', matricNumber: '2022/C/CSC/0101', studentName: 'Halima Yusuf', ca1: 9, ca2: 9, exam: 67),
    LecturerGradebookStudent(courseCode: 'CSC 411', matricNumber: '2022/C/CSC/0102', studentName: 'Michael Joseph', ca1: 8, ca2: 7, exam: 61),
    LecturerGradebookStudent(courseCode: 'CSC 411', matricNumber: '2022/C/CSC/0103', studentName: 'Suleiman Garba', ca1: 7, ca2: 7, exam: 57),
    LecturerGradebookStudent(courseCode: 'CSC 411', matricNumber: '2022/C/CSC/0104', studentName: 'Esther Paul', ca1: 10, ca2: 9, exam: 70),
    LecturerGradebookStudent(courseCode: 'CSC 411', matricNumber: '2022/C/CSC/0105', studentName: 'Muhammad Sani', ca1: 6, ca2: 6, exam: 52),
    LecturerGradebookStudent(courseCode: 'CSC 411', matricNumber: '2022/C/CSC/0106', studentName: 'Rita Andrew', ca1: 8, ca2: 8, exam: 64),
    LecturerGradebookStudent(courseCode: 'CSC 411', matricNumber: '2022/C/CSC/0107', studentName: 'Nasir Bello', ca1: 5, ca2: null, exam: 48),
    LecturerGradebookStudent(courseCode: 'CSC 411', matricNumber: '2022/C/CSC/0108', studentName: 'Blessing Sunday', ca1: 9, ca2: 8, exam: 65),
    LecturerGradebookStudent(courseCode: 'CSC 411', matricNumber: '2022/C/CSC/0109', studentName: 'Mustapha Ali', ca1: 7, ca2: 6, exam: 55),
    LecturerGradebookStudent(courseCode: 'CSC 411', matricNumber: '2022/C/CSC/0110', studentName: 'Rahila Adamu', ca1: 8, ca2: 9, exam: 63),
  ];

  List<LecturerGradebookCourse> get courses => List.unmodifiable(_courses);

  LecturerGradebookCourse course(String courseCode) =>
      _courses.firstWhere((item) => item.code == courseCode);

  List<LecturerGradebookStudent> studentsFor(String courseCode) =>
      List.unmodifiable(_students.where((item) => item.courseCode == courseCode));

  String get _actor => AuthSession.instance.session?.name ?? 'Course Lecturer';

  void updateCa1(String courseCode, String matricNumber, int? score) {
    final course = this.course(courseCode);
    if (course.resultsSubmitted) return;
    final student = _student(courseCode, matricNumber);
    student.ca1 = score?.clamp(0, course.ca1Max).toInt();
    student.lastUpdatedBy = _actor;
    LecturerCourseCollaborationState.instance.recordGradebookChange(
      courseCode: courseCode,
      actor: _actor,
      action: 'Updated CA 1 for $matricNumber',
    );
    notifyListeners();
  }

  void updateCa2(String courseCode, String matricNumber, int? score) {
    final course = this.course(courseCode);
    if (course.resultsSubmitted) return;
    final student = _student(courseCode, matricNumber);
    student.ca2 = score?.clamp(0, course.ca2Max).toInt();
    student.lastUpdatedBy = _actor;
    LecturerCourseCollaborationState.instance.recordGradebookChange(
      courseCode: courseCode,
      actor: _actor,
      action: 'Updated CA 2 for $matricNumber',
    );
    notifyListeners();
  }

  bool canSubmitResults(String courseCode) {
    final course = this.course(courseCode);
    if (course.resultsSubmitted) return false;
    final students = studentsFor(courseCode);
    return students.isNotEmpty && students.every((student) => student.complete);
  }

  void submitResults(String courseCode) {
    if (!canSubmitResults(courseCode)) return;
    course(courseCode).resultsSubmitted = true;
    LecturerCourseCollaborationState.instance.lockGradebook(
      courseCode: courseCode,
      actor: _actor,
    );
    notifyListeners();
  }

  int completeCount(String courseCode) =>
      studentsFor(courseCode).where((student) => student.complete).length;

  double classAverage(String courseCode) {
    final course = this.course(courseCode);
    final complete = studentsFor(courseCode).where((student) => student.complete).toList();
    if (complete.isEmpty || course.totalMax == 0) return 0;
    final totalPercent = complete.fold<double>(
      0,
      (sum, student) => sum + (student.total * 100 / course.totalMax),
    );
    return totalPercent / complete.length;
  }

  double passRate(String courseCode) {
    final course = this.course(courseCode);
    final complete = studentsFor(courseCode).where((student) => student.complete).toList();
    if (complete.isEmpty || course.totalMax == 0) return 0;
    final passed = complete.where((student) =>
        (student.total * 100 / course.totalMax) >= 40).length;
    return passed * 100 / complete.length;
  }

  Map<String, int> gradeDistribution(String courseCode) {
    final course = this.course(courseCode);
    final distribution = <String, int>{'A': 0, 'B': 0, 'C': 0, 'D': 0, 'E': 0, 'F': 0};
    for (final student in studentsFor(courseCode)) {
      if (!student.complete) continue;
      final grade = student.gradeFor(course);
      distribution[grade] = (distribution[grade] ?? 0) + 1;
    }
    return distribution;
  }

  void _handleExamStateChanged() => _syncFromExamScripts(notify: true);

  void _syncFromExamScripts({required bool notify}) {
    var changed = false;
    for (final script in LecturerDemoState.instance.scripts) {
      if (!script.markingComplete || script.examMax <= 0) continue;

      LecturerGradebookCourse? matchedCourse;
      for (final course in _courses) {
        if (course.code == script.courseCode) {
          matchedCourse = course;
          break;
        }
      }
      if (matchedCourse == null || matchedCourse.resultsSubmitted) continue;

      final serial = script.candidateNo.split('/').last.trim().padLeft(4, '0');
      final matric = '2023/C/CSC/$serial';
      LecturerGradebookStudent? matchedStudent;
      for (final student in _students) {
        if (student.courseCode == script.courseCode && student.matricNumber == matric) {
          matchedStudent = student;
          break;
        }
      }
      if (matchedStudent == null) continue;

      final scaled = (script.examScore * matchedCourse.examMax / script.examMax).round();
      if (matchedStudent.exam != scaled) {
        matchedStudent.exam = scaled;
        matchedStudent.lastUpdatedBy = 'Exam Marking';
        LecturerCourseCollaborationState.instance.recordGradebookChange(
          courseCode: matchedCourse.code,
          actor: 'Exam Marking',
          action: 'Synced exam score for ${matchedStudent.matricNumber}',
        );
        changed = true;
      }
    }
    if (changed && notify) notifyListeners();
  }

  LecturerGradebookStudent _student(String courseCode, String matricNumber) =>
      _students.firstWhere(
        (item) => item.courseCode == courseCode && item.matricNumber == matricNumber,
      );
}
