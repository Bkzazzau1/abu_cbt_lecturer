import 'package:flutter/foundation.dart';

import '../../lecturer_workflow/data/cbt_calendar_state.dart';
import 'exam_officer_academic_registry.dart';
import 'exam_officer_workflow_state.dart';

class ExamInvigilatorStaff {
  const ExamInvigilatorStaff({
    required this.id,
    required this.name,
    required this.label,
  });

  final String id;
  final String name;
  final String label;
}

class ExamInvigilationAssignment {
  ExamInvigilationAssignment({
    required this.id,
    required this.staffId,
    required this.courseCode,
    required this.dutyRole,
  });

  final String id;
  final String staffId;
  final String courseCode;
  final String dutyRole;
  final DateTime createdAt = DateTime.now();
}

class ExamOfficerInvigilationState extends ChangeNotifier {
  ExamOfficerInvigilationState._() {
    final names = <String>{};
    for (final course in _workflow.courseRegistrations) {
      names.addAll(course.lecturers);
    }
    final ordered = names.toList()..sort();
    _staff = [
      for (var i = 0; i < ordered.length; i++)
        ExamInvigilatorStaff(
          id: 'inv-${i + 1}',
          name: ordered[i],
          label: 'Academic Staff',
        ),
    ];
  }

  static final ExamOfficerInvigilationState instance =
      ExamOfficerInvigilationState._();

  static const dutyRoles = ['Chief Invigilator', 'Invigilator'];

  final ExamOfficerWorkflowState _workflow = ExamOfficerWorkflowState.instance;
  late final List<ExamInvigilatorStaff> _staff;
  final List<ExamInvigilationAssignment> _assignments = [];

  List<ExamInvigilatorStaff> get staff => List.unmodifiable(_staff);
  List<ExamInvigilationAssignment> get assignments =>
      List.unmodifiable(_assignments);

  List<ExamInvigilationAssignment> assignmentsForCourse(String courseCode) {
    final key = _normalise(courseCode);
    return _assignments
        .where((item) => _normalise(item.courseCode) == key)
        .toList(growable: false);
  }

  List<ExamInvigilationAssignment> assignmentsForStaff(String staffId) =>
      _assignments.where((item) => item.staffId == staffId).toList(growable: false);

  ExamInvigilatorStaff staffById(String staffId) =>
      _staff.firstWhere((item) => item.id == staffId);

  int workloadFor(String staffId) => assignmentsForStaff(staffId).length;

  bool isCourseScheduled(String courseCode) => _workflow.examSchedules.any(
        (item) => _normalise(item.courseCode) == _normalise(courseCode),
      );

  List<ExamOfficerExamSchedule> schedulesForCourse(String courseCode) =>
      _workflow.examSchedules
          .where((item) => _normalise(item.courseCode) == _normalise(courseCode))
          .toList(growable: false);

  void assignMany({
    required Set<String> staffIds,
    required Set<String> courseCodes,
    required String dutyRole,
  }) {
    if (staffIds.isEmpty) {
      throw StateError('Select at least one invigilator.');
    }
    if (courseCodes.isEmpty) {
      throw StateError('Select at least one course.');
    }
    if (!dutyRoles.contains(dutyRole)) {
      throw StateError('Select a valid invigilation duty role.');
    }

    final planned = <({String staffId, String courseCode})>[];
    final errors = <String>[];

    for (final staffId in staffIds) {
      final staff = staffById(staffId);
      for (final courseCode in courseCodes) {
        final duplicate = _assignments.any(
          (item) =>
              item.staffId == staffId &&
              _normalise(item.courseCode) == _normalise(courseCode),
        );
        if (duplicate) continue;

        final clash = _clashingCourse(staffId, courseCode);
        if (clash != null) {
          errors.add(
            '${staff.name} already has an overlapping invigilation duty on $clash.',
          );
          continue;
        }
        planned.add((staffId: staffId, courseCode: courseCode));
      }
    }

    if (errors.isNotEmpty) {
      throw StateError(errors.join('\n'));
    }
    if (planned.isEmpty) {
      throw StateError('The selected staff are already posted to these courses.');
    }

    for (final item in planned) {
      _assignments.add(
        ExamInvigilationAssignment(
          id: 'duty-${DateTime.now().microsecondsSinceEpoch}-${_assignments.length + 1}',
          staffId: item.staffId,
          courseCode: item.courseCode,
          dutyRole: dutyRole,
        ),
      );
    }
    notifyListeners();
  }

  void removeAssignment(String assignmentId) {
    final before = _assignments.length;
    _assignments.removeWhere((item) => item.id == assignmentId);
    if (_assignments.length != before) notifyListeners();
  }

  String? _clashingCourse(String staffId, String targetCourseCode) {
    if (!isCourseScheduled(targetCourseCode)) return null;
    for (final assignment in assignmentsForStaff(staffId)) {
      if (_normalise(assignment.courseCode) == _normalise(targetCourseCode)) {
        continue;
      }
      if (_coursesOverlap(assignment.courseCode, targetCourseCode)) {
        return assignment.courseCode;
      }
    }
    return null;
  }

  bool _coursesOverlap(String leftCourse, String rightCourse) {
    final leftSchedules = schedulesForCourse(leftCourse);
    final rightSchedules = schedulesForCourse(rightCourse);
    if (leftSchedules.isEmpty || rightSchedules.isEmpty) return false;

    final calendar = CbtCalendarState.instance;
    for (final left in leftSchedules) {
      final leftSlot = calendar.slots.where((item) => item.id == left.slotId);
      if (leftSlot.isEmpty) continue;
      for (final right in rightSchedules) {
        final rightSlot = calendar.slots.where((item) => item.id == right.slotId);
        if (rightSlot.isEmpty) continue;
        if (_slotsOverlap(leftSlot.first, rightSlot.first)) return true;
      }
    }
    return false;
  }

  bool _slotsOverlap(CbtCalendarSlot left, CbtCalendarSlot right) {
    if (left.date.year != right.date.year ||
        left.date.month != right.date.month ||
        left.date.day != right.date.day) {
      return false;
    }
    final leftStart = _minutes(left.startTime);
    final leftEnd = _minutes(left.endTime);
    final rightStart = _minutes(right.startTime);
    final rightEnd = _minutes(right.endTime);
    return leftStart < rightEnd && rightStart < leftEnd;
  }

  int _minutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }
}

String _normalise(String value) => value.replaceAll(' ', '').toUpperCase();
