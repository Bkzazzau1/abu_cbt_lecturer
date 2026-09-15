import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_academic_registry.dart';
import '../../exam_officer/data/exam_officer_marking_assignment_state.dart';

class ExamOfficerMarkingAssignmentPanel extends StatefulWidget {
  const ExamOfficerMarkingAssignmentPanel({super.key});

  @override
  State<ExamOfficerMarkingAssignmentPanel> createState() =>
      _ExamOfficerMarkingAssignmentPanelState();
}

class _ExamOfficerMarkingAssignmentPanelState
    extends State<ExamOfficerMarkingAssignmentPanel> {
  final ExamOfficerMarkingAssignmentState _state =
      ExamOfficerMarkingAssignmentState.instance;
  final ExamOfficerAcademicRegistry _registry =
      ExamOfficerAcademicRegistry.instance;

  final Set<String> _selectedCourses = {};
  final Set<String> _selectedMarkers = {};

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _assignmentForm(context),
          const SizedBox(height: 14),
          _assignmentTable(context),
          const SizedBox(height: 14),
          _markerWorkload(context),
        ],
      ),
    );
  }

  Widget _assignmentForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign Examination Markers',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'The Exam Officer decides who marks each examination. The assigned marker may be the course lecturer or another qualified academic staff member.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select course(s)',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final course in _registry.courses)
                  FilterChip(
                    label: Text('${course.courseCode} • ${course.level}'),
                    selected: _selectedCourses.contains(course.courseCode),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _selectedCourses.add(course.courseCode);
                      } else {
                        _selectedCourses.remove(course.courseCode);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Select marker(s)',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final staff in _state.staff)
                  FilterChip(
                    label: Text(
                      '${staff.name} • ${_state.workloadFor(staff.id)} course(s)',
                    ),
                    selected: _selectedMarkers.contains(staff.id),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _selectedMarkers.add(staff.id);
                      } else {
                        _selectedMarkers.remove(staff.id);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _selectedCourses.isEmpty || _selectedMarkers.isEmpty
                  ? null
                  : _applyAssignment,
              icon: const Icon(Icons.assignment_ind_outlined),
              label: const Text('Assign / Replace Markers'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assignmentTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Marking Postings',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (final assignment in _state.assignments)
              _assignmentCard(context, assignment),
          ],
        ),
      ),
    );
  }

  Widget _assignmentCard(
    BuildContext context,
    ExamMarkingAssignment assignment,
  ) {
    final registration = _registry.registrationFor(assignment.courseCode);
    final courseLecturers = registration?.lecturers ?? const <String>[];
    final markers = _state.markersFor(assignment.courseCode);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${assignment.courseCode} • ${assignment.courseTitle}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            '${assignment.academicSession} • ${assignment.semester} • ${assignment.level}',
          ),
          const SizedBox(height: 10),
          Text(
            'Course lecturer(s): ${courseLecturers.isEmpty ? '—' : courseLecturers.join(' / ')}',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final marker in markers)
                InputChip(
                  label: Text(
                    '${marker.name}${_state.isCourseLecturer(assignment.courseCode, marker.name) ? ' • Course Lecturer' : ' • Independent Marker'}',
                  ),
                  onDeleted: () =>
                      _state.removeMarker(assignment.courseCode, marker.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _markerWorkload(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Marker Workload',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final staff in _state.staff)
                  Chip(
                    avatar: const Icon(Icons.person_outline, size: 18),
                    label: Text(
                      '${staff.name} • ${_state.workloadFor(staff.id)} assigned course(s)',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyAssignment() {
    try {
      _state.assignMarkers(
        courseCodes: Set<String>.from(_selectedCourses),
        markerIds: Set<String>.from(_selectedMarkers),
      );
      setState(() {
        _selectedCourses.clear();
        _selectedMarkers.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marking assignment updated.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}
