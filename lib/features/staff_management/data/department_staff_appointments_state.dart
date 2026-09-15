import 'package:flutter/foundation.dart';

import '../../exam_officer/data/exam_officer_academic_registry.dart';

/// Department-level academic appointments controlled by the HoD.
///
/// This stays separate from exam marking and invigilation assignments. It
/// represents who teaches each course and which moderator pool is attached to
/// each course for departmental assessment governance.
class DepartmentStaffAppointmentsState extends ChangeNotifier {
  DepartmentStaffAppointmentsState._() {
    for (final course in _registry.courses) {
      _lecturersByCourse[course.courseCode] = List<String>.from(course.lecturers);
    }

    _moderatorsByCourse.addAll({
      'CSC 101': ['Ibrahim Sule'],
      'CSC 103': ['Ibrahim Sule'],
      'MTH 101': ['Ibrahim Sule'],
      'CSC 201': ['Ibrahim Sule'],
      'CSC 203': ['Ibrahim Sule'],
      'MTH 201': ['Ibrahim Sule'],
      'CSC 305': ['Ibrahim Sule'],
      'CSC 307': ['Ibrahim Sule'],
      'CSC 411': ['Ibrahim Sule'],
      'CSC 413': ['Ibrahim Sule'],
    });
  }

  static final DepartmentStaffAppointmentsState instance =
      DepartmentStaffAppointmentsState._();

  final ExamOfficerAcademicRegistry _registry = ExamOfficerAcademicRegistry.instance;
  final Map<String, List<String>> _lecturersByCourse = {};
  final Map<String, List<String>> _moderatorsByCourse = {};

  List<String> lecturersFor(String courseCode) =>
      List.unmodifiable(_lecturersByCourse[_displayCode(courseCode)] ?? const []);

  List<String> moderatorsFor(String courseCode) =>
      List.unmodifiable(_moderatorsByCourse[_displayCode(courseCode)] ?? const []);

  Map<String, List<String>> get lecturerAssignments => Map.unmodifiable({
        for (final entry in _lecturersByCourse.entries)
          entry.key: List.unmodifiable(entry.value),
      });

  Map<String, List<String>> get moderatorAssignments => Map.unmodifiable({
        for (final entry in _moderatorsByCourse.entries)
          entry.key: List.unmodifiable(entry.value),
      });

  void assignLecturer({required String courseCode, required String lecturer}) {
    final code = _displayCode(courseCode);
    final name = lecturer.trim();
    if (name.isEmpty) return;
    final list = _lecturersByCourse.putIfAbsent(code, () => <String>[]);
    if (list.any((item) => _same(item, name))) return;
    list.add(name);
    notifyListeners();
  }

  void removeLecturer({required String courseCode, required String lecturer}) {
    final code = _displayCode(courseCode);
    final list = _lecturersByCourse[code];
    if (list == null) return;
    final before = list.length;
    list.removeWhere((item) => _same(item, lecturer));
    if (list.length != before) notifyListeners();
  }

  void assignModerator({required String courseCode, required String moderator}) {
    final code = _displayCode(courseCode);
    final name = moderator.trim();
    if (name.isEmpty) return;
    final list = _moderatorsByCourse.putIfAbsent(code, () => <String>[]);
    if (list.any((item) => _same(item, name))) return;
    list.add(name);
    notifyListeners();
  }

  void removeModerator({required String courseCode, required String moderator}) {
    final code = _displayCode(courseCode);
    final list = _moderatorsByCourse[code];
    if (list == null) return;
    final before = list.length;
    list.removeWhere((item) => _same(item, moderator));
    if (list.length != before) notifyListeners();
  }

  int lecturerLoad(String lecturer) {
    var count = 0;
    for (final lecturers in _lecturersByCourse.values) {
      if (lecturers.any((item) => _same(item, lecturer))) count++;
    }
    return count;
  }

  int moderatorLoad(String moderator) {
    var count = 0;
    for (final moderators in _moderatorsByCourse.values) {
      if (moderators.any((item) => _same(item, moderator))) count++;
    }
    return count;
  }

  String _displayCode(String value) {
    final key = value.replaceAll(' ', '').toUpperCase();
    final match = _registry.courses.where(
      (course) => course.courseCode.replaceAll(' ', '').toUpperCase() == key,
    );
    return match.isEmpty ? value.trim().toUpperCase() : match.first.courseCode;
  }

  bool _same(String left, String right) =>
      left.trim().toLowerCase() == right.trim().toLowerCase();
}
