import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_demo_seed.dart';
import '../../exam_officer/data/exam_officer_invigilation_state.dart';
import '../../exam_officer/data/exam_officer_workflow_state.dart';

enum HodExamOversightMode { exams, moderation }

class HodExamOversightPanel extends StatefulWidget {
  const HodExamOversightPanel({
    super.key,
    this.mode = HodExamOversightMode.exams,
  });

  final HodExamOversightMode mode;

  @override
  State<HodExamOversightPanel> createState() => _HodExamOversightPanelState();
}

class _HodExamOversightPanelState extends State<HodExamOversightPanel> {
  final ExamOfficerWorkflowState _workflow = ExamOfficerWorkflowState.instance;
  final ExamOfficerInvigilationState _invigilation =
      ExamOfficerInvigilationState.instance;
  String _level = 'All Levels';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExamOfficerDemoSeed.ensureSeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _workflow,
      builder: (context, _) => AnimatedBuilder(
        animation: _invigilation,
        builder: (context, __) {
          final papers = _filteredPapers();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              const SizedBox(height: 14),
              _filters(context),
              const SizedBox(height: 14),
              _kpis(context, papers),
              const SizedBox(height: 14),
              _paperList(context, papers),
            ],
          );
        },
      ),
    );
  }

  List<ExamOfficerQuestionPaper> _filteredPapers() {
    final papers = _workflow.questionPapers.where((paper) {
      final registration = _workflow.registrationForCourse(paper.courseCode);
      if (_level != 'All Levels' && registration?.level != _level) return false;
      if (widget.mode == HodExamOversightMode.moderation) {
        return paper.status == ExamOfficerQuestionStatus.withModerator ||
            paper.status == ExamOfficerQuestionStatus.correctionRequested ||
            paper.status == ExamOfficerQuestionStatus.moderated ||
            paper.status == ExamOfficerQuestionStatus.readyForTimetable;
      }
      return true;
    }).toList();
    papers.sort((a, b) => a.courseCode.compareTo(b.courseCode));
    return papers;
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final moderation = widget.mode == HodExamOversightMode.moderation;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Icon(
                    moderation
                        ? Icons.rule_folder_outlined
                        : Icons.fact_check_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moderation
                            ? 'Moderation Oversight'
                            : 'Examination Oversight',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        moderation
                            ? 'Supervisory view of question-paper movement, outstanding corrections and moderation completion. Operational hand-offs remain with the Exam Officer and Moderator.'
                            : 'Department-level view of exam readiness, timetable capacity and invigilation coverage. The HoD supervises and escalates; the Exam Officer retains day-to-day scheduling and posting actions.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 210,
              child: DropdownButtonFormField<String>(
                value: _level,
                decoration: const InputDecoration(
                  labelText: 'Level',
                  prefixIcon: Icon(Icons.layers_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'All Levels',
                    child: Text('All Levels'),
                  ),
                  for (final level in _workflow.levels)
                    DropdownMenuItem(value: level, child: Text(level)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _level = value);
                },
              ),
            ),
            const Chip(
              avatar: Icon(Icons.visibility_outlined, size: 18),
              label: Text('Supervisory access'),
            ),
            const Chip(
              avatar: Icon(Icons.lock_outline, size: 18),
              label: Text('No operational reassignment controls'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpis(
    BuildContext context,
    List<ExamOfficerQuestionPaper> papers,
  ) {
    final scheduled = papers.where((paper) =>
        paper.status == ExamOfficerQuestionStatus.scheduled).length;
    final moderationPending = papers.where((paper) =>
        paper.status == ExamOfficerQuestionStatus.withModerator ||
        paper.status == ExamOfficerQuestionStatus.correctionRequested).length;
    final capacityGaps = papers.where((paper) =>
        _workflow.remainingCandidates(paper) > 0 &&
        (paper.status == ExamOfficerQuestionStatus.partiallyScheduled ||
            paper.status == ExamOfficerQuestionStatus.readyForTimetable)).length;
    final noInvigilators = papers.where((paper) {
      final scheduledPaper = _workflow.schedulesForPaper(paper.paperId).isNotEmpty;
      return scheduledPaper &&
          _invigilation.assignmentsForCourse(paper.courseCode).isEmpty;
    }).length;

    final cards = [
      ('Papers in view', '${papers.length}', Icons.description_outlined),
      ('Fully scheduled', '$scheduled', Icons.event_available_outlined),
      ('Moderation attention', '$moderationPending', Icons.rule_folder_outlined),
      ('Capacity gaps', '$capacityGaps', Icons.event_busy_outlined),
      ('Missing invigilation', '$noInvigilators', Icons.person_off_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 1150
            ? (constraints.maxWidth - 48) / 5
            : constraints.maxWidth >= 700
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in cards)
              SizedBox(
                width: width,
                child: _KpiCard(
                  label: item.$1,
                  value: item.$2,
                  icon: item.$3,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _paperList(
    BuildContext context,
    List<ExamOfficerQuestionPaper> papers,
  ) {
    final moderation = widget.mode == HodExamOversightMode.moderation;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              moderation ? 'Moderation pipeline' : 'Department exam readiness',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              moderation
                  ? 'See where each paper currently sits and the latest review note.'
                  : 'See candidate load, timetable coverage, invigilation and current workflow stage per examination.',
            ),
            const SizedBox(height: 14),
            if (papers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: Text('No examination record matches this filter.')),
              )
            else
              for (final paper in papers) _paperCard(context, paper),
          ],
        ),
      ),
    );
  }

  Widget _paperCard(
    BuildContext context,
    ExamOfficerQuestionPaper paper,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final registration = _workflow.registrationForCourse(paper.courseCode);
    final schedules = _workflow.schedulesForPaper(paper.paperId);
    final invigilators = _invigilation.assignmentsForCourse(paper.courseCode);
    final lastNote = paper.notes.isEmpty ? null : paper.notes.last;
    final remaining = _workflow.remainingCandidates(paper);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(15),
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
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${paper.courseCode} • ${paper.courseTitle}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${registration?.level ?? 'Level not mapped'} • ${paper.lecturerName}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Chip(label: Text(paper.status.label)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('${_workflow.candidateCountForCourse(paper.courseCode)} candidates'),
              _pill('${paper.durationMinutes} min'),
              _pill('${schedules.length} sitting${schedules.length == 1 ? '' : 's'}'),
              _pill('${invigilators.length} invigilator${invigilators.length == 1 ? '' : 's'}'),
              if (remaining > 0) _pill('$remaining candidates not yet covered'),
              if (registration != null && registration.carryoverCount > 0)
                _pill('${registration.carryoverCount} carryover'),
            ],
          ),
          if (schedules.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              schedules.map((item) => '${item.scheduleLabel} • ${item.venue} • cap ${item.capacity}').join('\n'),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
          if (lastNote != null) ...[
            const SizedBox(height: 9),
            Text(
              'Latest: ${lastNote.actor} • ${lastNote.action}${lastNote.note.isEmpty ? '' : ' — ${lastNote.note}'}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(String text) => Chip(
        visualDensity: VisualDensity.compact,
        label: Text(text),
      );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
