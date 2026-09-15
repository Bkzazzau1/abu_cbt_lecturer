import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_invigilation_state.dart';
import '../../exam_officer/data/exam_officer_workflow_state.dart';

class ExamOfficerInvigilationPanel extends StatefulWidget {
  const ExamOfficerInvigilationPanel({super.key});

  @override
  State<ExamOfficerInvigilationPanel> createState() =>
      _ExamOfficerInvigilationPanelState();
}

class _ExamOfficerInvigilationPanelState
    extends State<ExamOfficerInvigilationPanel> {
  final ExamOfficerInvigilationState _state =
      ExamOfficerInvigilationState.instance;
  final ExamOfficerWorkflowState _workflow = ExamOfficerWorkflowState.instance;

  final Set<String> _selectedStaff = {};
  final Set<String> _selectedCourses = {};
  String _dutyRole = ExamOfficerInvigilationState.dutyRoles.last;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_state, _workflow]),
      builder: (context, _) {
        final courses = _workflow.courseRegistrations;
        final scheduledCourseCount = courses
            .where((course) => _state.isCourseScheduled(course.courseCode))
            .length;
        final coveredCourses = courses
            .where(
              (course) =>
                  _state.assignmentsForCourse(course.courseCode).isNotEmpty,
            )
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.supervisor_account_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Invigilation Posting',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Post academic staff to one course or several courses. Timetabled courses are checked for overlapping duties automatically.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth >= 840
                            ? (constraints.maxWidth - 24) / 3
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _Metric(
                              width: width,
                              label: 'Available Staff',
                              value: '${_state.staff.length}',
                              detail: 'Academic staff available for posting',
                            ),
                            _Metric(
                              width: width,
                              label: 'Courses Covered',
                              value: '$coveredCourses/${courses.length}',
                              detail: '$scheduledCourseCount courses currently timetabled',
                            ),
                            _Metric(
                              width: width,
                              label: 'Invigilation Duties',
                              value: '${_state.assignments.length}',
                              detail: 'Current course postings',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '1. Select course(s)',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final course in courses)
                          FilterChip(
                            selected: _selectedCourses.contains(course.courseCode),
                            label: Text(
                              '${course.courseCode} • ${course.totalRegistered}',
                            ),
                            avatar: _state.isCourseScheduled(course.courseCode)
                                ? const Icon(Icons.event_available_outlined, size: 18)
                                : const Icon(Icons.schedule_outlined, size: 18),
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
                    Text(
                      '2. Select invigilator(s)',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final staff in _state.staff)
                          FilterChip(
                            selected: _selectedStaff.contains(staff.id),
                            label: Text(
                              '${staff.name} • ${_state.workloadFor(staff.id)} duties',
                            ),
                            onSelected: (selected) => setState(() {
                              if (selected) {
                                _selectedStaff.add(staff.id);
                              } else {
                                _selectedStaff.remove(staff.id);
                              }
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 240,
                          child: DropdownButtonFormField<String>(
                            initialValue: _dutyRole,
                            decoration: const InputDecoration(
                              labelText: 'Duty role',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            items: [
                              for (final role
                                  in ExamOfficerInvigilationState.dutyRoles)
                                DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _dutyRole = value);
                              }
                            },
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _postInvigilators,
                          icon: const Icon(Icons.assignment_ind_outlined),
                          label: const Text('Post Invigilator(s)'),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _selectedStaff.clear();
                            _selectedCourses.clear();
                          }),
                          child: const Text('Clear selection'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Invigilation Coverage',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Candidate totals include carryover registrations. A posting applies to the selected course; scheduled sitting details are shown where available.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final course in courses) _courseCard(context, course),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invigilator Workload',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    for (final staff in _state.staff)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(staff.name),
                        subtitle: Text(
                          _state.assignmentsForStaff(staff.id).isEmpty
                              ? 'No invigilation duty posted'
                              : _state
                                  .assignmentsForStaff(staff.id)
                                  .map((item) => item.courseCode)
                                  .join(' • '),
                        ),
                        trailing: Chip(
                          label: Text('${_state.workloadFor(staff.id)} duties'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _courseCard(BuildContext context, dynamic course) {
    final scheme = Theme.of(context).colorScheme;
    final assignments = _state.assignmentsForCourse(course.courseCode);
    final schedules = _state.schedulesForCourse(course.courseCode);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${course.courseCode} • ${course.courseTitle}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.level} • ${course.totalRegistered} candidates (${course.carryoverCount} carryover)',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Chip(
                avatar: Icon(
                  schedules.isEmpty
                      ? Icons.schedule_outlined
                      : Icons.event_available_outlined,
                  size: 18,
                ),
                label: Text(
                  schedules.isEmpty
                      ? 'Awaiting timetable'
                      : '${schedules.length} sitting${schedules.length == 1 ? '' : 's'}',
                ),
              ),
            ],
          ),
          if (schedules.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final schedule in schedules)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${schedule.scheduleLabel} • capacity ${schedule.capacity}',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
          ],
          const SizedBox(height: 10),
          if (assignments.isEmpty)
            Text(
              'No invigilator posted yet.',
              style: TextStyle(color: scheme.error),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final assignment in assignments)
                  InputChip(
                    avatar: const Icon(Icons.person_outline, size: 18),
                    label: Text(
                      '${_state.staffById(assignment.staffId).name} • ${assignment.dutyRole}',
                    ),
                    onDeleted: () => _state.removeAssignment(assignment.id),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _postInvigilators() {
    try {
      _state.assignMany(
        staffIds: _selectedStaff,
        courseCodes: _selectedCourses,
        dutyRole: _dutyRole,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invigilation posting saved.')),
      );
      setState(() {
        _selectedStaff.clear();
        _selectedCourses.clear();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.width,
    required this.label,
    required this.value,
    required this.detail,
  });

  final double width;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(detail, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
