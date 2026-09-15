import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_academic_registry.dart';
import '../../staff_management/data/department_staff_appointments_state.dart';

class HodAcademicResourcesPanel extends StatefulWidget {
  const HodAcademicResourcesPanel({super.key});

  @override
  State<HodAcademicResourcesPanel> createState() =>
      _HodAcademicResourcesPanelState();
}

class _HodAcademicResourcesPanelState extends State<HodAcademicResourcesPanel> {
  final ExamOfficerAcademicRegistry _registry = ExamOfficerAcademicRegistry.instance;
  final DepartmentStaffAppointmentsState _appointments =
      DepartmentStaffAppointmentsState.instance;

  String _section = 'Courses';
  String _level = 'All Levels';

  @override
  Widget build(BuildContext context) {
    final courses = _level == 'All Levels'
        ? _registry.courses
        : _registry.coursesForLevel(_level);
    final students = _level == 'All Levels'
        ? _registry.students
        : _registry.studentsForLevel(_level);

    return AnimatedBuilder(
      animation: _appointments,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Courses',
                        icon: Icon(Icons.menu_book_outlined),
                        label: Text('Courses'),
                      ),
                      ButtonSegment(
                        value: 'Teaching Load',
                        icon: Icon(Icons.school_outlined),
                        label: Text('Teaching Load'),
                      ),
                      ButtonSegment(
                        value: 'Students',
                        icon: Icon(Icons.groups_2_outlined),
                        label: Text('Students'),
                      ),
                    ],
                    selected: {_section},
                    onSelectionChanged: (value) =>
                        setState(() => _section = value.first),
                  ),
                  SizedBox(
                    width: 210,
                    child: DropdownButtonFormField<String>(
                      initialValue: _level,
                      decoration: const InputDecoration(
                        labelText: 'Level filter',
                        prefixIcon: Icon(Icons.layers_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'All Levels',
                          child: Text('All Levels'),
                        ),
                        for (final level in ExamOfficerAcademicRegistry.levels)
                          DropdownMenuItem(value: level, child: Text(level)),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _level = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_section == 'Courses') _coursesPanel(context, courses),
          if (_section == 'Teaching Load') _teachingLoadPanel(context, courses),
          if (_section == 'Students') _studentsPanel(context, students),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lecturers = <String>{};
    final moderators = <String>{};
    for (final course in _registry.courses) {
      lecturers.addAll(_appointments.lecturersFor(course.courseCode));
      moderators.addAll(_appointments.moderatorsFor(course.courseCode));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 18,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Department Academic Register',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Live register of courses, HoD lecturer/moderator appointments, cohort population and carryover pressure. Teaching appointment is independent of marking and invigilation duty.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('${_registry.courses.length} courses')),
                Chip(label: Text('${lecturers.length} lecturers allocated')),
                Chip(label: Text('${moderators.length} moderators allocated')),
                Chip(label: Text('${_registry.totalLevelStudents} students')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _coursesPanel(
    BuildContext context,
    List<ExamOfficerCourseRegistration> courses,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Register & Academic Appointments',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            const SizedBox(height: 12),
            for (final course in courses) _courseRow(context, course),
          ],
        ),
      ),
    );
  }

  Widget _courseRow(BuildContext context, ExamOfficerCourseRegistration course) {
    final scheme = Theme.of(context).colorScheme;
    final lecturers = _appointments.lecturersFor(course.courseCode);
    final moderators = _appointments.moderatorsFor(course.courseCode);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${course.courseCode} — ${course.courseTitle}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text('${course.level} • ${course.semester}'),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('${course.regularCount} regular')),
                  Chip(label: Text('${course.carryoverCount} carryover')),
                  Chip(label: Text('${course.totalRegistered} total')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Lecturer(s): ${lecturers.isEmpty ? 'Not assigned' : lecturers.join(', ')}',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            'Moderator(s): ${moderators.isEmpty ? 'Not assigned' : moderators.join(', ')}',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _teachingLoadPanel(
    BuildContext context,
    List<ExamOfficerCourseRegistration> courses,
  ) {
    final mapping = <String, List<ExamOfficerCourseRegistration>>{};
    for (final course in courses) {
      for (final lecturer in _appointments.lecturersFor(course.courseCode)) {
        mapping.putIfAbsent(lecturer, () => []).add(course);
      }
    }
    final names = mapping.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lecturer Teaching Load',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            const SizedBox(height: 5),
            const Text(
              'This is course teaching responsibility only. It does not automatically make the lecturer an exam marker or invigilator.',
            ),
            const SizedBox(height: 12),
            if (names.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No lecturer allocation in this filter.')),
              )
            else
              for (final name in names)
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    mapping[name]!
                        .map((course) => '${course.courseCode} (${course.level})')
                        .join(' • '),
                  ),
                  trailing: Chip(label: Text('${mapping[name]!.length} course(s)')),
                ),
          ],
        ),
      ),
    );
  }

  Widget _studentsPanel(BuildContext context, List<ExamOfficerLevelStudent> students) {
    final scheme = Theme.of(context).colorScheme;
    final carryover = students.where((item) => item.hasCarryover).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 800
                ? (constraints.maxWidth - 24) / 3
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: _MetricCard(
                    label: 'Cohort population',
                    value: _level == 'All Levels'
                        ? '${_registry.totalLevelStudents}'
                        : '${_registry.cohortCount(_level)}',
                    detail: _level,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _MetricCard(
                    label: 'Visible records',
                    value: '${students.length}',
                    detail: 'Prototype student rows',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _MetricCard(
                    label: 'Carryover examples',
                    value: '$carryover',
                    detail: 'Students with repeat courses',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                for (final student in students)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outlineVariant),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name,
                                style: const TextStyle(fontWeight: FontWeight.w900)),
                            Text('${student.matricNumber} • ${student.level}'),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(label: Text('${student.registeredCourseCount} courses')),
                            if (student.hasCarryover)
                              Chip(label: Text(student.carryoverCourseCodes.join(', '))),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(detail, style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
