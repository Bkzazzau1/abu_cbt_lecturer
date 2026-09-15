import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_academic_registry.dart';

class HodAcademicResourcesPanel extends StatefulWidget {
  const HodAcademicResourcesPanel({super.key});

  @override
  State<HodAcademicResourcesPanel> createState() =>
      _HodAcademicResourcesPanelState();
}

class _HodAcademicResourcesPanelState extends State<HodAcademicResourcesPanel> {
  final ExamOfficerAcademicRegistry _registry =
      ExamOfficerAcademicRegistry.instance;
  String _section = 'Staff';
  String _level = 'All Levels';

  @override
  Widget build(BuildContext context) {
    final courses = _level == 'All Levels'
        ? _registry.courses
        : _registry.coursesForLevel(_level);
    final students = _level == 'All Levels'
        ? _registry.students
        : _registry.studentsForLevel(_level);

    return Column(
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
                      value: 'Staff',
                      icon: Icon(Icons.school_outlined),
                      label: Text('Academic Staff'),
                    ),
                    ButtonSegment(
                      value: 'Courses',
                      icon: Icon(Icons.menu_book_outlined),
                      label: Text('Courses'),
                    ),
                    ButtonSegment(
                      value: 'Students',
                      icon: Icon(Icons.groups_2_outlined),
                      label: Text('Students'),
                    ),
                  ],
                  selected: {_section},
                  onSelectionChanged: (value) {
                    setState(() => _section = value.first);
                  },
                ),
                SizedBox(
                  width: 210,
                  child: DropdownButtonFormField<String>(
                    value: _level,
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
        if (_section == 'Staff') _staffSection(context, courses),
        if (_section == 'Courses') _courseSection(context, courses),
        if (_section == 'Students') _studentSection(context, students),
      ],
    );
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final uniqueStaff = _registry.courses
        .expand((course) => course.lecturers)
        .toSet()
        .length;
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
                    'Academic Resources & Department Register',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'HoD supervisory view of staff teaching allocations, registered courses, student cohorts and carryover pressure. Exam marking and invigilation assignments remain under the Exam Officer workflow.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('$uniqueStaff academic staff')),
                Chip(label: Text('${_registry.courses.length} courses')),
                Chip(label: Text('${_registry.totalLevelStudents} students')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _staffSection(
    BuildContext context,
    List<ExamOfficerCourseRegistration> courses,
  ) {
    final staffCourses = <String, List<ExamOfficerCourseRegistration>>{};
    for (final course in courses) {
      for (final lecturer in course.lecturers) {
        staffCourses.putIfAbsent(lecturer, () => []).add(course);
      }
    }
    final names = staffCourses.keys.toList()..sort();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              icon: Icons.school_outlined,
              title: 'Teaching allocation overview',
              subtitle:
                  'Course ownership and teaching load only. This is separate from examination marking and invigilation duty.',
            ),
            const SizedBox(height: 14),
            if (names.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No staff allocation in this filter.')),
              )
            else
              for (final name in names)
                _staffCard(context, name, staffCourses[name]!),
          ],
        ),
      ),
    );
  }

  Widget _staffCard(
    BuildContext context,
    String name,
    List<ExamOfficerCourseRegistration> courses,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final candidateLoad = courses.fold<int>(
      0,
      (sum, course) => sum + course.totalRegistered,
    );
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(
                  courses
                      .map((course) => '${course.courseCode} (${course.level})')
                      .join(' • '),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('${courses.length} course${courses.length == 1 ? '' : 's'}')),
              Chip(label: Text('$candidateLoad registrations')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _courseSection(
    BuildContext context,
    List<ExamOfficerCourseRegistration> courses,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              icon: Icons.menu_book_outlined,
              title: 'Department course register',
              subtitle:
                  'Live prototype register used by examination readiness, analytics and student-load calculations.',
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Course')),
                  DataColumn(label: Text('Level')),
                  DataColumn(label: Text('Semester')),
                  DataColumn(label: Text('Lecturer(s)')),
                  DataColumn(label: Text('Regular')),
                  DataColumn(label: Text('Carryover')),
                  DataColumn(label: Text('Total')),
                ],
                rows: [
                  for (final course in courses)
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            '${course.courseCode} — ${course.courseTitle}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        DataCell(Text(course.level)),
                        DataCell(Text(course.semester)),
                        DataCell(Text(course.lecturers.join(', '))),
                        DataCell(Text('${course.regularCount}')),
                        DataCell(Text('${course.carryoverCount}')),
                        DataCell(Text('${course.totalRegistered}')),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentSection(
    BuildContext context,
    List<ExamOfficerLevelStudent> students,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final carryoverStudents = students.where((item) => item.hasCarryover).length;
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
                  child: _InfoCard(
                    label: 'Cohort population',
                    value: _level == 'All Levels'
                        ? '${_registry.totalLevelStudents}'
                        : '${_registry.cohortCount(_level)}',
                    detail: _level,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _InfoCard(
                    label: 'Visible student records',
                    value: '${students.length}',
                    detail: 'Prototype register rows',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _InfoCard(
                    label: 'Carryover examples',
                    value: '$carryoverStudents',
                    detail: 'Students with listed repeat courses',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  icon: Icons.groups_2_outlined,
                  title: 'Student academic register',
                  subtitle:
                      'Department supervision view. Detailed results and academic standing remain in the results workflow.',
                ),
                const SizedBox(height: 14),
                for (final student in students)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 9),
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
                            Text(
                              student.name,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            Text('${student.matricNumber} • ${student.level}'),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(label: Text('${student.registeredCourseCount} courses')),
                            if (student.hasCarryover)
                              Chip(
                                avatar: const Icon(Icons.replay_outlined, size: 17),
                                label: Text(student.carryoverCourseCodes.join(', ')),
                              ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(detail, style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
