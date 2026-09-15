import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_workflow_state.dart';
import '../../lecturer_workflow/data/cbt_calendar_state.dart';

class ExamOfficerTimetableFlowPanel extends StatefulWidget {
  const ExamOfficerTimetableFlowPanel({super.key});

  @override
  State<ExamOfficerTimetableFlowPanel> createState() =>
      _ExamOfficerTimetableFlowPanelState();
}

class _ExamOfficerTimetableFlowPanelState
    extends State<ExamOfficerTimetableFlowPanel> {
  final ExamOfficerWorkflowState _state = ExamOfficerWorkflowState.instance;
  final CbtCalendarState _calendar = CbtCalendarState.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) => AnimatedBuilder(
        animation: _calendar,
        builder: (context, _) {
          final schedulable = _state.questionPapers
              .where(
                (paper) =>
                    paper.status == ExamOfficerQuestionStatus.moderated ||
                    paper.status ==
                        ExamOfficerQuestionStatus.readyForTimetable ||
                    paper.status ==
                        ExamOfficerQuestionStatus.partiallyScheduled,
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
                      Row(
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Moderation → Slot → Timetable',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          Chip(
                            label: Text(
                              '${_calendar.availableSlots.length} slots available',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Only moderated examination papers can be scheduled. The Exam Officer selects an available slot and the booked sitting is published automatically in the exam timetable.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (schedulable.isEmpty)
                        const Text(
                          'No moderated examination paper is waiting for a slot.',
                        )
                      else
                        for (final paper in schedulable)
                          _schedulablePaper(context, paper),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _publishedTimetable(context),
            ],
          );
        },
      ),
    );
  }

  Widget _schedulablePaper(
    BuildContext context,
    ExamOfficerQuestionPaper paper,
  ) {
    final candidates = _state.candidateCountForCourse(paper.courseCode);
    final remaining = _state.remainingCandidates(paper);
    final sittings = _state.schedulesForPaper(paper.paperId);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
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
                '${paper.courseCode} • ${paper.courseTitle}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Chip(label: Text(paper.status.label)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('$candidates candidates')),
              Chip(label: Text('${paper.durationMinutes} minutes')),
              Chip(label: Text('$remaining awaiting capacity')),
              if (sittings.isNotEmpty)
                Chip(label: Text('${sittings.length} sitting(s) booked')),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: remaining == 0 || _calendar.availableSlots.isEmpty
                ? null
                : () => _chooseSlot(paper),
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(
              sittings.isEmpty ? 'Select Available Slot' : 'Add Another Sitting',
            ),
          ),
        ],
      ),
    );
  }

  Widget _publishedTimetable(BuildContext context) {
    final schedules = _state.examSchedules;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Published Exam Timetable',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                Chip(label: Text('${schedules.length} sitting(s)')),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'A sitting appears here immediately after the Exam Officer books an available slot.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (schedules.isEmpty)
              const Text('No exam sitting has been placed on the timetable yet.')
            else
              for (final schedule in schedules) _timetableRow(context, schedule),
          ],
        ),
      ),
    );
  }

  Widget _timetableRow(
    BuildContext context,
    ExamOfficerExamSchedule schedule,
  ) {
    final matching = _state.questionPapers.where(
      (paper) => paper.paperId == schedule.paperId,
    );
    final paper = matching.isEmpty ? null : matching.first;
    final candidates = _state.candidateCountForCourse(schedule.courseCode);
    final allSittings = _state.schedulesForPaper(schedule.paperId);
    final sittingIndex = allSittings.indexWhere(
      (item) => item.slotId == schedule.slotId,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        child: Icon(Icons.event_note_outlined),
      ),
      title: Text(
        '${schedule.courseCode} • ${paper?.courseTitle ?? 'Examination'}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${schedule.scheduleLabel} • ${schedule.capacity} seats • $candidates registered candidates',
      ),
      trailing: Chip(
        label: Text(
          allSittings.length > 1
              ? 'Sitting ${sittingIndex < 0 ? 1 : sittingIndex + 1}'
              : 'Timetabled',
        ),
      ),
    );
  }

  Future<void> _chooseSlot(ExamOfficerQuestionPaper paper) async {
    final available = _calendar.availableSlots
        .where(
          (slot) =>
              _durationMinutes(slot.startTime, slot.endTime) >=
              paper.durationMinutes,
        )
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available slot can hold this exam duration.'),
        ),
      );
      return;
    }

    String? selected;
    final slotId = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Select slot for ${paper.courseCode}'),
          content: SizedBox(
            width: 700,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_state.remainingCandidates(paper)} candidates still need capacity. Only available slots long enough for the ${paper.durationMinutes}-minute exam are shown.',
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<String>(
                    groupValue: selected,
                    onChanged: (value) =>
                        setDialogState(() => selected = value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final slot in available)
                          RadioListTile<String>(
                            value: slot.id,
                            title: Text(slot.scheduleLabel),
                            subtitle: Text(
                              '${slot.capacity} seats • ${_durationMinutes(slot.startTime, slot.endTime)} minutes${slot.capacity >= _state.remainingCandidates(paper) ? ' • enough for remaining candidates' : ' • another sitting will still be needed'}',
                            ),
                          ),
                      ],
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
              child: const Text('Book & Publish'),
            ),
          ],
        ),
      ),
    );

    if (slotId == null) return;

    try {
      if (paper.status == ExamOfficerQuestionStatus.moderated) {
        _state.markQuestionReady(
          paper.id,
          'Moderation completed; paper opened for exam slot scheduling.',
        );
      }
      _state.scheduleExamSitting(paperId: paper.id, slotId: slotId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${paper.courseCode} booked successfully and added to the exam timetable.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

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
