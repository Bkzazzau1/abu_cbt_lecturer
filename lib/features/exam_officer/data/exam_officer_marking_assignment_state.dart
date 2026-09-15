import 'package:flutter/foundation.dart';

import 'exam_officer_academic_registry.dart';

class ExamMarkerStaff {
  const ExamMarkerStaff({
    required this.id,
    required this.name,
    required this.designation,
  });

  final String id;
  final String name;
  final String designation;
}

class ExamMarkingAssignment {
  ExamMarkingAssignment({
    required this.courseCode,
    required this.courseTitle,
    required this.level,
    required this.semester,
    required this.academicSession,
    required this.markerIds,
  });

  final String courseCode;
  final String courseTitle;
  final String level;
  final String semester;
  final String academicSession;
  List<String> markerIds;
}

class ExamOfficerMarkingAssignmentState extends ChangeNotifier {
  ExamOfficerMarkingAssignmentState._() {
    final names = <String>{};
    for (final course in _registry.courses) {
      names.addAll(course.lecturers);
    }
    names.addAll(const [
      'Dr. Kabiru Umar',
      'Dr. Hadiza Sule',
      'Dr. Bashir Mohammed',
    ]);

    final ordered = names.toList()..sort();
    _staff = [
      for (var index = 0; index < ordered.length; index++)
        ExamMarkerStaff(
          id: 'marker-${index + 1}',
          name: ordered[index],
          designation: 'Academic Staff',
        ),
    ];

    _seedAssignments();
  }

  static final ExamOfficerMarkingAssignmentState instance =
      ExamOfficerMarkingAssignmentState._();

  final ExamOfficerAcademicRegistry _registry =
      ExamOfficerAcademicRegistry.instance;
  late final List<ExamMarkerStaff> _staff;
  final List<ExamMarkingAssignment> _assignments = [];

  List<ExamMarkerStaff> get staff => List.unmodifiable(_staff);
  List<ExamMarkingAssignment> get assignments => List.unmodifiable(_assignments);

  ExamMarkerStaff staffById(String id) =>
      _staff.firstWhere((item) => item.id == id);

  ExamMarkingAssignment? assignmentFor(String courseCode) {
    final key = _normalise(courseCode);
    for (final assignment in _assignments) {
      if (_normalise(assignment.courseCode) == key) return assignment;
    }
    return null;
  }

  List<ExamMarkerStaff> markersFor(String courseCode) {
    final assignment = assignmentFor(courseCode);
    if (assignment == null) return const [];
    return [for (final id in assignment.markerIds) staffById(id)];
  }

  bool canMark(String markerName, String courseCode) {
    final name = markerName.trim().toLowerCase();
    if (name.isEmpty) return false;
    return markersFor(courseCode)
        .any((staff) => staff.name.trim().toLowerCase() == name);
  }

  int workloadFor(String staffId) => _assignments
      .where((assignment) => assignment.markerIds.contains(staffId))
      .length;

  bool isCourseLecturer(String courseCode, String staffName) {
    final registration = _registry.registrationFor(courseCode);
    if (registration == null) return false;
    final name = staffName.trim().toLowerCase();
    return registration.lecturers
        .any((lecturer) => lecturer.trim().toLowerCase() == name);
  }

  void assignMarkers({
    required Set<String> courseCodes,
    required Set<String> markerIds,
    String academicSession = '2025/2026',
  }) {
    if (courseCodes.isEmpty) {
      throw StateError('Select at least one course.');
    }
    if (markerIds.isEmpty) {
      throw StateError('Select at least one marker.');
    }

    for (final courseCode in courseCodes) {
      final registration = _registry.registrationFor(courseCode);
      final existing = assignmentFor(courseCode);
      final title = registration?.courseTitle ?? 'Examination Course';
      final level = registration?.level ?? _levelFromCourse(courseCode);
      final semester = registration?.semester ?? 'Semester 1';
      if (existing == null) {
        _assignments.add(
          ExamMarkingAssignment(
            courseCode: courseCode,
            courseTitle: title,
            level: level,
            semester: semester,
            academicSession: academicSession,
            markerIds: markerIds.toList(),
          ),
        );
      } else {
        existing.markerIds = markerIds.toList();
      }
    }
    notifyListeners();
  }

  void removeMarker(String courseCode, String staffId) {
    final assignment = assignmentFor(courseCode);
    if (assignment == null) return;
    assignment.markerIds.remove(staffId);
    if (assignment.markerIds.isEmpty) {
      _assignments.remove(assignment);
    }
    notifyListeners();
  }

  void _seedAssignments() {
    void assign(String courseCode, List<String> names) {
      final registration = _registry.registrationFor(courseCode);
      final ids = <String>[
        for (final name in names)
          _staff.firstWhere((staff) => staff.name == name).id,
      ];
      _assignments.add(
        ExamMarkingAssignment(
          courseCode: courseCode,
          courseTitle: registration?.courseTitle ?? 'Examination Course',
          level: registration?.level ?? _levelFromCourse(courseCode),
          semester: registration?.semester ?? 'Semester 1',
          academicSession: '2025/2026',
          markerIds: ids,
        ),
      );
    }

    assign('CSC 101', ['Dr. Amina Bello']);
    assign('CSC 103', ['Dr. Kabiru Umar']);
    assign('MTH 101', ['Dr. Hadiza Sule']);
    assign('CSC 201', ['Dr. Yusuf Abdullahi']);
    assign('CSC 203', ['Dr. Amina Bello']);
    assign('MTH 201', ['Dr. Bashir Mohammed']);
    assign('CSC 305', ['Dr. Amina Bello', 'Dr. Yusuf Abdullahi']);
    assign('CSC 307', ['Dr. Grace Adamu']);
    assign('CSC 309', ['Dr. Amina Bello']);
    assign('CSC 411', ['Dr. Kabiru Umar']);
    assign('CSC 413', ['Dr. Sani Bello']);
  }
}

String _normalise(String value) => value.replaceAll(' ', '').toUpperCase();

String _levelFromCourse(String courseCode) {
  final match = RegExp(r'\d+').firstMatch(courseCode);
  final digits = match?.group(0) ?? '';
  return digits.isEmpty ? 'Unknown Level' : '${digits[0]}00 Level';
}
