import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_workflow_state.dart';
import '../../lecturer_workflow/data/lecturer_gradebook_state.dart';

class ExamOfficerResultsPanel extends StatefulWidget {
  const ExamOfficerResultsPanel({super.key});

  @override
  State<ExamOfficerResultsPanel> createState() => _ExamOfficerResultsPanelState();
}

class _ExamOfficerResultsPanelState extends State<ExamOfficerResultsPanel> {
  final ExamOfficerWorkflowState _state = ExamOfficerWorkflowState.instance;
  final LecturerGradebookState _gradebook = LecturerGradebookState.instance;
  ExamOfficerResultStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final batches = _state.resultBatches
            .where((item) => _filter == null || item.status == _filter)
            .toList();
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
                        'Result Collection & Verification',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        '${_state.resultBatchesVerified}/${_state.resultBatchesReceived} verified',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Receive lecturer result batches, inspect the submitted class record, return a batch for correction, verify complete results, and forward verified work to the HoD.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text('All ${_state.resultBatches.length}'),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                    for (final status in ExamOfficerResultStatus.values)
                      FilterChip(
                        label: Text(
                          '${status.label} ${_state.resultBatches.where((item) => item.status == status).length}',
                        ),
                        selected: _filter == status,
                        onSelected: (_) => setState(() => _filter = status),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (batches.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text('No result batch is in this stage.'),
                    ),
                  )
                else
                  for (final batch in batches) _batchCard(context, batch),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _batchCard(BuildContext context, ExamOfficerResultBatch batch) {
    final scheme = Theme.of(context).colorScheme;
    final lastNote = batch.notes.isEmpty ? null : batch.notes.last;
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
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${batch.courseCode} • ${batch.courseTitle}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      batch.fullBatchSubmitted
                          ? 'Full class gradebook submitted by lecturer'
                          : '${batch.receivedScripts} marked script${batch.receivedScripts == 1 ? '' : 's'} received so far',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Chip(label: Text(batch.status.label)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('${batch.studentCount} students'),
              _pill('${batch.completeCount} complete'),
              _pill('${batch.receivedScripts} submitted scripts'),
              _pill('${batch.classAverage.toStringAsFixed(1)}% class average'),
              _pill(batch.complete ? 'Complete batch' : 'Incomplete batch'),
            ],
          ),
          if (lastNote != null) ...[
            const SizedBox(height: 10),
            Text(
              '${lastNote.action}: ${lastNote.note.isEmpty ? 'No note added' : lastNote.note}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openBatch(batch),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Inspect Results'),
              ),
              if (batch.status == ExamOfficerResultStatus.received ||
                  batch.status == ExamOfficerResultStatus.returnedToLecturer)
                FilledButton.tonalIcon(
                  onPressed: () => _state.startResultReview(batch.id),
                  icon: const Icon(Icons.manage_search_outlined),
                  label: const Text('Start Verification'),
                ),
              if (batch.status == ExamOfficerResultStatus.received ||
                  batch.status == ExamOfficerResultStatus.underReview)
                OutlinedButton.icon(
                  onPressed: () => _withNote(
                    title: 'Return Results to Lecturer',
                    hint: 'Explain what must be corrected before verification.',
                    action: (note) =>
                        _state.returnResultToLecturer(batch.id, note),
                  ),
                  icon: const Icon(Icons.assignment_return_outlined),
                  label: const Text('Return to Lecturer'),
                ),
              if (batch.status == ExamOfficerResultStatus.underReview)
                FilledButton.icon(
                  onPressed: batch.complete
                      ? () => _withNote(
                            title: 'Verify Result Batch',
                            hint: 'Add a verification note for the audit trail.',
                            action: (note) =>
                                _state.verifyResultBatch(batch.id, note),
                          )
                      : null,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Verify Batch'),
                ),
              if (batch.status == ExamOfficerResultStatus.verified)
                FilledButton.icon(
                  onPressed: () => _withNote(
                    title: 'Forward to HoD',
                    hint: 'Add the note that should accompany this batch.',
                    action: (note) =>
                        _state.forwardResultToHod(batch.id, note),
                  ),
                  icon: const Icon(Icons.forward_to_inbox_outlined),
                  label: const Text('Forward to HoD'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) => Chip(
        visualDensity: VisualDensity.compact,
        label: Text(text),
      );

  void _openBatch(ExamOfficerResultBatch batch) {
    final course = _findCourse(batch.courseCode);
    final students = course == null
        ? const <LecturerGradebookStudent>[]
        : _gradebook.studentsFor(course.code);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${batch.courseCode} • Result Verification'),
        content: SizedBox(
          width: 900,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill('${batch.studentCount} students'),
                    _pill('${batch.completeCount} complete'),
                    _pill('${batch.classAverage.toStringAsFixed(1)}% average'),
                    _pill(batch.status.label),
                  ],
                ),
                const SizedBox(height: 16),
                if (students.isEmpty)
                  Text(
                    'Individual gradebook rows are not available for this submitted script group. ${batch.receivedScripts} script${batch.receivedScripts == 1 ? '' : 's'} were received.',
                  )
                else ...[
                  const Text(
                    'Submitted class record',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Matric Number')),
                        DataColumn(label: Text('CA1')),
                        DataColumn(label: Text('CA2')),
                        DataColumn(label: Text('Exam')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Grade')),
                        DataColumn(label: Text('Updated By')),
                      ],
                      rows: [
                        for (final student in students)
                          DataRow(
                            cells: [
                              DataCell(Text(student.matricNumber)),
                              DataCell(Text(student.ca1?.toString() ?? '—')),
                              DataCell(Text(student.ca2?.toString() ?? '—')),
                              DataCell(Text(student.exam?.toString() ?? '—')),
                              DataCell(
                                Text(student.complete ? '${student.total}' : '—'),
                              ),
                              DataCell(
                                Text(
                                  course == null
                                      ? '—'
                                      : student.gradeFor(course),
                                ),
                              ),
                              DataCell(Text(student.lastUpdatedBy)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
                if (batch.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Verification History',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  for (final note in batch.notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${note.actor} • ${note.action}: ${note.note.isEmpty ? 'No note added' : note.note}',
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  LecturerGradebookCourse? _findCourse(String code) {
    final key = _normalise(code);
    for (final course in _gradebook.courses) {
      if (_normalise(course.code) == key) return course;
    }
    return null;
  }

  Future<void> _withNote({
    required String title,
    required String hint,
    required ValueChanged<String> action,
  }) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: 'Verification note',
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null) return;
    action(note);
  }
}

String _normalise(String value) => value.replaceAll(' ', '').toUpperCase();
