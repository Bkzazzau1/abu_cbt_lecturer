import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_academic_registry.dart';
import '../../exam_officer/data/exam_officer_workflow_state.dart';
import '../../lecturer_workflow/data/cbt_calendar_state.dart';

class ExamOfficerReadinessPanel extends StatefulWidget {
  const ExamOfficerReadinessPanel({super.key});

  @override
  State<ExamOfficerReadinessPanel> createState() =>
      _ExamOfficerReadinessPanelState();
}

class _ExamOfficerReadinessPanelState extends State<ExamOfficerReadinessPanel> {
  final ExamOfficerWorkflowState _state = ExamOfficerWorkflowState.instance;
  final CbtCalendarState _calendar = CbtCalendarState.instance;

  String _section = 'Courses by Level';
  String _level = '100 Level';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: _calendar,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _summaryCard(context),
                const SizedBox(height: 14),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'Courses by Level',
                      icon: Icon(Icons.menu_book_outlined),
                      label: Text('Courses by Level'),
                    ),
                    ButtonSegment(
                      value: 'Level Students',
                      icon: Icon(Icons.groups_2_outlined),
                      label: Text('Level Students'),
                    ),
                    ButtonSegment(
                      value: 'Exam Slots',
                      icon: Icon(Icons.event_available_outlined),
                      label: Text('Exam Slots & Timetable'),
                    ),
                  ],
                  selected: {_section},
                  onSelectionChanged: (value) {
                    setState(() => _section = value.first);
                  },
                ),
                const SizedBox(height: 14),
                if (_section == 'Courses by Level')
                  _coursesByLevel(context)
                else if (_section == 'Level Students')
                  _levelStudents(context)
                else
                  _examSlots(context),
              ],
            );
          },
        );
      },
    );
  }

  Widget _summaryCard(BuildContext context) {
    final availableSlots = _calendar.availableSlots.length;
    final scheduled = _state.questionsScheduled;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Department Exam Readiness',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Level population and course registration are tracked separately. Course registration totals include carryover students, so a course can have more candidates than the normal cohort for that level.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth >= 1000
                    ? (constraints.maxWidth - 48) / 5
                    : constraints.maxWidth >= 600
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _metric(
                      context,
                      width,
                      'Courses',
                      '${_state.courseRegistrations.length}',
                      'Across 100–400 levels',
                      Icons.menu_book_outlined,
                    ),
                    _metric(
                      context,
                      width,
                      'Level Students',
                      '${_state.totalLevelStudents}',
                      'Unique cohort students',
                      Icons.groups_2_outlined,
                    ),
                    _metric(
                      context,
                      width,
                      'Course Registrations',
                      '${_state.totalCourseRegistrations}',
                      'All exam registrations',
                      Icons.app_registration_outlined,
                    ),
                    _metric(
                      context,
                      width,
                      'Carryover Entries',
                      '${_state.totalCarryoverRegistrations}',
                      'Included in course totals',
                      Icons.replay_outlined,
                    ),
                    _metric(
                      context,
                      width,
                      'Exam Slots',
                      '$availableSlots',
                      '$scheduled paper${scheduled == 1 ? '' : 's'} fully scheduled',
                      Icons.event_available_outlined,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _coursesByLevel(BuildContext context) {
    final courses = _state.coursesForLevel(_level);
    final cohort = _state.cohortCount(_level);
    final registrations = courses.fold<int>(
      0,
      (sum, item) => sum + item.totalRegistered,
    );
    final carryovers = courses.fold<int>(
      0,
      (sum, item) => sum + item.carryoverCount,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _levelSelector(context, 'Courses and registrations'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(label: Text('$cohort students in $_level')),
                Chip(label: Text('${courses.length} courses')),
                Chip(label: Text('$registrations course registrations')),
                Chip(label: Text('$carryovers carryover registrations')),
              ],
            ),
            const SizedBox(height: 16),
            for (final course in courses) _courseCard(context, course),
          ],
        ),
      ),
    );
  }

  Widget _courseCard(
    BuildContext context,
    ExamOfficerCourseRegistration course,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final matching = _state.questionPapers.where(
      (paper) => _sameCode(paper.courseCode, course.courseCode),
    );
    final paper = matching.isEmpty ? null : matching.first;
    final status = paper?.status.label ?? 'Question Not Received';

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
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${course.courseCode} • ${course.courseTitle}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.level} • ${course.semester} • ${course.lecturers.join(' / ')}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Chip(label: Text(status)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('Regular ${course.regularCount}'),
              _pill('Carryover ${course.carryoverCount}'),
              _pill('Total ${course.totalRegistered}'),
              if (paper != null) _pill('${paper.durationMinutes} min exam'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _levelStudents(BuildContext context) {
    final students = _state.studentsForLevel(_level);
    final cohort = _state.cohortCount(_level);
    final visibleCarryover = students.where((student) => student.hasCarryover).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _levelSelector(context, 'Level student list'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(label: Text('$cohort students in cohort')),
                Chip(label: Text('${students.length} directory rows loaded')),
                Chip(label: Text('$visibleCarryover with carryover courses shown')),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Matric Number')),
                  DataColumn(label: Text('Student')),
                  DataColumn(label: Text('Level')),
                  DataColumn(label: Text('Courses')),
                  DataColumn(label: Text('Carryover Courses')),
                ],
                rows: [
                  for (final student in students)
                    DataRow(
                      cells: [
                        DataCell(Text(student.matricNumber)),
                        DataCell(Text(student.name)),
                        DataCell(Text(student.level)),
                        DataCell(Text('${student.registeredCourseCount}')),
                        DataCell(
                          Text(
                            student.carryoverCourseCodes.isEmpty
                                ? '—'
                                : student.carryoverCourseCodes.join(', '),
                          ),
                        ),
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

  Widget _examSlots(BuildContext context) {
    final slots = _calendar.slots;
    final papers = _state.questionPapers
        .where(
          (paper) =>
              paper.status == ExamOfficerQuestionStatus.readyForTimetable ||
              paper.status == ExamOfficerQuestionStatus.partiallyScheduled,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timetable-ready papers',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Schedule one or more sittings. Candidate capacity uses the full course registration count, including carryover students.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                if (papers.isEmpty)
                  const Text('No moderated paper is waiting for timetable placement.')
                else
                  for (final paper in papers) _paperScheduleCard(context, paper),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'CBT / Exam Slot Availability',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Chip(label: Text('${_calendar.availableSlots.length} available')),
                  ],
                ),
                const SizedBox(height: 12),
                for (final slot in slots) _slotRow(context, slot),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _paperScheduleCard(
    BuildContext context,
    ExamOfficerQuestionPaper paper,
  ) {
    final candidates = _state.candidateCountForCourse(paper.courseCode);
    final remaining = _state.remainingCandidates(paper);
    final scheduledCapacity = _state.scheduledCapacityForPaper(paper.paperId);
    final sittings = _state.schedulesForPaper(paper.paperId);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
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
              Text(
                '${paper.courseCode} • ${paper.title}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Chip(label: Text(paper.status.label)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('$candidates registered candidates'),
              _pill('${paper.durationMinutes} minutes'),
              _pill('$scheduledCapacity seats scheduled'),
              _pill('$remaining candidates remaining'),
            ],
          ),
          if (sittings.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (var i = 0; i < sittings.length; i++)
              Text(
                'Sitting ${i + 1}: ${sittings[i].scheduleLabel} • capacity ${sittings[i].capacity}',
              ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: remaining == 0 || _calendar.availableSlots.isEmpty
                ? null
                : () => _chooseSlot(paper),
            icon: const Icon(Icons.add_task_outlined),
            label: Text(sittings.isEmpty ? 'Schedule Exam' : 'Add Sitting'),
          ),
        ],
      ),
    );
  }

  Widget _slotRow(BuildContext context, CbtCalendarSlot slot) {
    final duration = _durationMinutes(slot.startTime, slot.endTime);
    final booking = slot.isBooked
        ? '${slot.bookedCourseCode ?? ''} ${slot.bookedCaLabel ?? ''}'.trim()
        : '';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Icon(slot.isAvailable ? Icons.event_available : Icons.event_busy),
      ),
      title: Text(slot.scheduleLabel),
      subtitle: Text(
        '${slot.capacity} seats • $duration minutes${booking.isEmpty ? '' : ' • $booking'}',
      ),
      trailing: Chip(label: Text(slot.statusLabel)),
    );
  }

  Widget _levelSelector(BuildContext context, String title) {
    return Wrap(
      spacing: 14,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        SizedBox(
          width: 190,
          child: DropdownButtonFormField<String>(
            initialValue: _level,
            decoration: const InputDecoration(labelText: 'Level'),
            items: [
              for (final level in _state.levels)
                DropdownMenuItem(value: level, child: Text(level)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _level = value);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _chooseSlot(ExamOfficerQuestionPaper paper) async {
    final available = _calendar.availableSlots;
    String? selected;
    final slotId = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Schedule ${paper.courseCode}'),
            content: SizedBox(
              width: 680,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_state.remainingCandidates(paper)} candidates still need timetable capacity. Exam duration: ${paper.durationMinutes} minutes.',
                    ),
                    const SizedBox(height: 12),
                    for (final slot in available)
                      RadioListTile<String>(
                        value: slot.id,
                        groupValue: selected,
                        onChanged: _durationMinutes(slot.startTime, slot.endTime) >=
                                paper.durationMinutes
                            ? (value) => setDialogState(() => selected = value)
                            : null,
                        title: Text(slot.scheduleLabel),
                        subtitle: Text(
                          '${slot.capacity} seats • ${_durationMinutes(slot.startTime, slot.endTime)} minutes${slot.capacity >= _state.remainingCandidates(paper) ? ' • can finish remaining candidates' : ' • additional sitting will be needed'}',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: selected == null
                    ? null
                    : () => Navigator.pop(context, selected),
                child: const Text('Book Sitting'),
              ),
            ],
          );
        },
      ),
    );

    if (slotId == null) return;
    try {
      _state.scheduleExamSitting(paperId: paper.id, slotId: slotId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${paper.courseCode} exam sitting scheduled.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Widget _metric(
    BuildContext context,
    double width,
    String label,
    String value,
    String detail,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(detail, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _pill(String text) => Chip(
        visualDensity: VisualDensity.compact,
        label: Text(text),
      );

  bool _sameCode(String a, String b) =>
      a.replaceAll(' ', '').toUpperCase() == b.replaceAll(' ', '').toUpperCase();

  int _durationMinutes(String start, String end) {
    int parse(String value) {
      final parts = value.split(':');
      if (parts.length != 2) return 0;
      return (int.tryParse(parts[0]) ?? 0) * 60 +
          (int.tryParse(parts[1]) ?? 0);
    }

    final minutes = parse(end) - parse(start);
    return minutes < 0 ? 0 : minutes;
  }
}
