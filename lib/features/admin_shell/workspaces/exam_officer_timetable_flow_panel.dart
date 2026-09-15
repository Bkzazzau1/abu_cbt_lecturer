import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_hall_availability_state.dart';
import '../../exam_officer/data/exam_officer_workflow_state.dart';

class ExamOfficerTimetableFlowPanel extends StatefulWidget {
  const ExamOfficerTimetableFlowPanel({super.key});

  @override
  State<ExamOfficerTimetableFlowPanel> createState() =>
      _ExamOfficerTimetableFlowPanelState();
}

class _ExamOfficerTimetableFlowPanelState
    extends State<ExamOfficerTimetableFlowPanel> {
  final ExamOfficerWorkflowState _state = ExamOfficerWorkflowState.instance;
  final ExamHallAvailabilityState _hallState =
      ExamHallAvailabilityState.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) => AnimatedBuilder(
        animation: _hallState,
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
          final pending = _hallState.requests
              .where(
                (item) => item.status == ExamHallAvailabilityStatus.pending,
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
                            Icons.event_available_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Moderation → Hall/Time Request → Timetable',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          Chip(label: Text('$pending awaiting ICT')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'After moderation, the Exam Officer proposes the examination hall, date and time. ICT only confirms whether that hall and time are available. The sitting enters the published timetable automatically after ICT approval.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (schedulable.isEmpty)
                        const Text(
                          'No moderated examination paper is waiting for hall/time approval.',
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
    final requests = _hallState.requestsForPaper(paper.id);
    final pending = requests
        .where((item) => item.status == ExamHallAvailabilityStatus.pending)
        .toList();
    final hasRejected = requests
        .any((item) => item.status == ExamHallAvailabilityStatus.rejected);

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
                Chip(label: Text('${sittings.length} sitting(s) approved')),
              if (pending.isNotEmpty)
                Chip(label: Text('${pending.length} ICT request(s) pending')),
            ],
          ),
          if (requests.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final request in requests.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${request.scheduleLabel} • ${request.status.label}${request.responseNote.isEmpty ? '' : ' • ${request.responseNote}'}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: remaining == 0 || pending.isNotEmpty
                ? null
                : () => _requestHallTime(paper),
            icon: const Icon(Icons.meeting_room_outlined),
            label: Text(
              hasRejected
                  ? 'Reassign Hall & Time'
                  : sittings.isEmpty
                  ? 'Request Hall & Time'
                  : 'Request Another Sitting',
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
              'A sitting appears here only after ICT confirms that the requested hall and time are available.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (schedules.isEmpty)
              const Text('No approved exam sitting is on the timetable yet.')
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

  Future<void> _requestHallTime(ExamOfficerQuestionPaper paper) async {
    var selectedHall = ExamHallAvailabilityState.halls.first.id;
    var date = DateTime(2026, 9, 24);
    var start = const TimeOfDay(hour: 9, minute: 0);
    var end = TimeOfDay(
      hour: 9 + (paper.durationMinutes ~/ 60),
      minute: paper.durationMinutes % 60,
    );

    String time(TimeOfDay value) =>
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final hall = ExamHallAvailabilityState.halls
              .firstWhere((item) => item.id == selectedHall);
          final requestedMinutes = _durationMinutes(time(start), time(end));
          final validDuration = requestedMinutes >= paper.durationMinutes;
          final dateLabel =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

          return AlertDialog(
            title: Text('Request hall/time for ${paper.courseCode}'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose the proposed hall and time. ICT will only receive the operational hall/time request and will not see the examination paper or other academic details.',
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedHall,
                      decoration: const InputDecoration(labelText: 'Exam hall'),
                      items: [
                        for (final item in ExamHallAvailabilityState.halls)
                          DropdownMenuItem(
                            value: item.id,
                            child: Text('${item.name} • ${item.capacity} seats'),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedHall = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Date'),
                      subtitle: Text(dateLabel),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2026, 9, 15),
                          lastDate: DateTime(2027, 12, 31),
                        );
                        if (picked != null) {
                          setDialogState(() => date = picked);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule_outlined),
                      title: const Text('Start time'),
                      subtitle: Text(time(start)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: start,
                        );
                        if (picked != null) {
                          setDialogState(() => start = picked);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule_outlined),
                      title: const Text('End time'),
                      subtitle: Text(time(end)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: end,
                        );
                        if (picked != null) {
                          setDialogState(() => end = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('${hall.capacity} seats')),
                        Chip(label: Text('${paper.durationMinutes} min required')),
                        Chip(label: Text('$requestedMinutes min requested')),
                      ],
                    ),
                    if (!validDuration) ...[
                      const SizedBox(height: 8),
                      Text(
                        'The requested time window is shorter than the examination duration.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: validDuration
                    ? () => Navigator.pop(context, true)
                    : null,
                child: const Text('Send to ICT'),
              ),
            ],
          );
        },
      ),
    );

    if (submitted != true) return;

    try {
      if (paper.status == ExamOfficerQuestionStatus.moderated) {
        _state.markQuestionReady(
          paper.id,
          'Moderation completed; hall/time availability requested from ICT.',
        );
      }
      _hallState.requestAvailability(
        paperId: paper.id,
        hallId: selectedHall,
        date: date,
        startTime: time(start),
        endTime: time(end),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${paper.courseCode} hall/time request sent to ICT for availability confirmation.',
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
