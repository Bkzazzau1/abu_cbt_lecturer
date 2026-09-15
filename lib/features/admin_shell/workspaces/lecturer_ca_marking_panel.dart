import 'package:flutter/material.dart';

import '../../lecturer_workflow/data/cbt_calendar_state.dart';
import '../../lecturer_workflow/data/lecturer_ca_marking_state.dart';

class LecturerCaMarkingPanel extends StatefulWidget {
  const LecturerCaMarkingPanel({super.key});

  @override
  State<LecturerCaMarkingPanel> createState() => _LecturerCaMarkingPanelState();
}

class _LecturerCaMarkingPanelState extends State<LecturerCaMarkingPanel> {
  final LecturerCaMarkingState _state = LecturerCaMarkingState.instance;
  String? _assessmentId;
  String? _attemptId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final assessments = _state.assessments;
        if (assessments.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No scheduled CA is available for marking yet.'),
            ),
          );
        }

        final assessment = _resolveAssessment(assessments);
        final attempts = _state.attemptsFor(assessment.id);
        final selectedAttempt = _resolveAttempt(attempts);
        final marked = _state.markedCount(assessment.id);

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
                        Icon(Icons.fact_check_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'CA Marking & Grading',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        Chip(label: Text('${assessment.totalMarks} marks')),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 360,
                          child: DropdownButtonFormField<String>(
                            initialValue: assessment.id,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Scheduled CA',
                              prefixIcon: Icon(Icons.quiz_outlined),
                            ),
                            items: [
                              for (final item in assessments)
                                DropdownMenuItem(
                                  value: item.id,
                                  child: Text('${item.courseCode} • ${item.caLabel} • ${item.title}'),
                                ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _assessmentId = value;
                                _attemptId = null;
                              });
                            },
                          ),
                        ),
                        _Metric(label: 'Students', value: '${attempts.length}'),
                        _Metric(label: 'Marked', value: '$marked'),
                        _Metric(label: 'Pending', value: '${attempts.length - marked}'),
                        _Metric(
                          label: 'Average',
                          value: '${_state.averagePercent(assessment.id).toStringAsFixed(1)}%',
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
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Student')),
                      DataColumn(label: Text('Matric Number')),
                      DataColumn(label: Text('Score')),
                      DataColumn(label: Text('Grade')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Marked By')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: [
                      for (final attempt in attempts)
                        DataRow(
                          selected: selectedAttempt?.id == attempt.id,
                          cells: [
                            DataCell(Text(attempt.studentName)),
                            DataCell(Text(attempt.matricNumber)),
                            DataCell(
                              Text(
                                attempt.complete(assessment)
                                    ? '${attempt.score(assessment)}/${assessment.totalMarks}'
                                    : '—',
                              ),
                            ),
                            DataCell(Text(attempt.grade(assessment))),
                            DataCell(Text(attempt.status.label)),
                            DataCell(Text(attempt.markedBy.isEmpty ? '—' : attempt.markedBy)),
                            DataCell(
                              TextButton.icon(
                                onPressed: () => setState(() => _attemptId = attempt.id),
                                icon: const Icon(Icons.edit_note_outlined),
                                label: const Text('Open'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (selectedAttempt != null) ...[
              const SizedBox(height: 14),
              _AttemptWorkspace(
                assessment: assessment,
                attempt: selectedAttempt,
                state: _state,
              ),
            ],
          ],
        );
      },
    );
  }

  CaAssessmentRecord _resolveAssessment(List<CaAssessmentRecord> assessments) {
    if (_assessmentId != null) {
      for (final item in assessments) {
        if (item.id == _assessmentId) return item;
      }
    }
    _assessmentId = assessments.first.id;
    return assessments.first;
  }

  LecturerCaAttempt? _resolveAttempt(List<LecturerCaAttempt> attempts) {
    if (attempts.isEmpty) return null;
    if (_attemptId != null) {
      for (final item in attempts) {
        if (item.id == _attemptId) return item;
      }
    }
    _attemptId = attempts.first.id;
    return attempts.first;
  }
}

class _AttemptWorkspace extends StatelessWidget {
  const _AttemptWorkspace({
    required this.assessment,
    required this.attempt,
    required this.state,
  });

  final CaAssessmentRecord assessment;
  final LecturerCaAttempt attempt;
  final LecturerCaMarkingState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${attempt.studentName} • ${attempt.matricNumber}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text('${assessment.courseCode} • ${assessment.caLabel} • ${assessment.title}'),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => state.applyAutoMarks(attempt.id),
                      icon: const Icon(Icons.auto_awesome_outlined),
                      label: const Text('Auto-mark Eligible'),
                    ),
                    FilledButton.icon(
                      onPressed: state.canComplete(attempt.id)
                          ? () => state.completeMarking(attempt.id)
                          : null,
                      icon: const Icon(Icons.task_alt_outlined),
                      label: const Text('Complete CA Marking'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < assessment.questions.length; i++) ...[
              _QuestionMarkCard(
                key: ValueKey('${attempt.id}-$i-${attempt.marks[i]}'),
                number: i + 1,
                question: assessment.questions[i],
                response: attempt.responses[i] ?? '',
                mark: attempt.marks[i],
                onMarkChanged: (value) => state.updateMark(attempt.id, i, value),
              ),
              const SizedBox(height: 10),
            ],
            const Divider(height: 28),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(
                  label: Text(
                    attempt.complete(assessment)
                        ? 'Score ${attempt.score(assessment)}/${assessment.totalMarks}'
                        : 'Marking incomplete',
                  ),
                ),
                Chip(label: Text('CA Grade ${attempt.grade(assessment)}')),
                Chip(label: Text(attempt.status.label)),
                if (attempt.markedBy.isNotEmpty)
                  Chip(label: Text('Marked by ${attempt.markedBy}')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionMarkCard extends StatelessWidget {
  const _QuestionMarkCard({
    super.key,
    required this.number,
    required this.question,
    required this.response,
    required this.mark,
    required this.onMarkChanged,
  });

  final int number;
  final CaQuestionSnapshot question;
  final String response;
  final int? mark;
  final ValueChanged<int?> onMarkChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Question $number', style: const TextStyle(fontWeight: FontWeight.w900)),
              Chip(label: Text(_typeLabel(question.type))),
              Chip(label: Text('${question.marks} marks')),
              if (question.autoMarkable)
                const Chip(label: Text('Auto-mark eligible')),
            ],
          ),
          const SizedBox(height: 8),
          Text(question.prompt, style: const TextStyle(fontWeight: FontWeight.w800)),
          if (question.imageFileName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Question image: ${question.imageFileName}'),
          ],
          const SizedBox(height: 10),
          Text('Student response', style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          SelectableText(response.isEmpty ? 'No response' : response),
          const SizedBox(height: 10),
          Text('Marking guide', style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(question.answer.isEmpty ? '—' : question.answer),
          if (question.rubric.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Rubric: ${question.rubric}'),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: 160,
            child: TextFormField(
              initialValue: mark?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Mark /${question.marks}'),
              onChanged: (value) => onMarkChanged(int.tryParse(value.trim())),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'single_choice':
        return 'Single Choice';
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'fill_blank':
        return 'Fill in the Blank';
      case 'essay':
        return 'Essay';
      case 'drag_drop':
        return 'Drag & Drop';
      case 'image_question':
        return 'Image Question';
      case 'file_upload':
        return 'File Upload';
      default:
        return type;
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
