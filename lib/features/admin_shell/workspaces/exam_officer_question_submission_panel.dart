import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_workflow_state.dart';

class ExamOfficerQuestionSubmissionPanel extends StatefulWidget {
  const ExamOfficerQuestionSubmissionPanel({super.key});

  @override
  State<ExamOfficerQuestionSubmissionPanel> createState() =>
      _ExamOfficerQuestionSubmissionPanelState();
}

class _ExamOfficerQuestionSubmissionPanelState
    extends State<ExamOfficerQuestionSubmissionPanel> {
  final ExamOfficerWorkflowState _state = ExamOfficerWorkflowState.instance;
  ExamOfficerQuestionStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final papers = _state.questionPapers
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
                      Icons.inbox_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Question Submission',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    Chip(label: Text('${_state.questionsReceived} received')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Receive lecturer question papers, see the registered candidate load for each course, read the full paper, send it to moderation, or return it to the lecturer with a correction note.',
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
                      label: Text('All ${_state.questionPapers.length}'),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                    for (final status in ExamOfficerQuestionStatus.values)
                      FilterChip(
                        label: Text(
                          '${status.label} ${_state.questionPapers.where((item) => item.status == status).length}',
                        ),
                        selected: _filter == status,
                        onSelected: (_) => setState(() => _filter = status),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (papers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 26),
                    child: Center(
                      child: Text('No question paper is in this stage.'),
                    ),
                  )
                else
                  for (final paper in papers) _paperCard(context, paper),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _paperCard(BuildContext context, ExamOfficerQuestionPaper paper) {
    final scheme = Theme.of(context).colorScheme;
    final lastNote = paper.notes.isEmpty ? null : paper.notes.last;
    final registration = _state.registrationForCourse(paper.courseCode);
    final candidateCount = _state.candidateCountForCourse(paper.courseCode);
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
                      '${paper.courseCode} • ${paper.title}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${paper.courseTitle} • ${paper.lecturerName}',
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
              _pill('${paper.questionCount} questions'),
              _pill('${paper.totalMarks} marks'),
              _pill('${paper.durationMinutes} minutes'),
              _pill('$candidateCount candidates'),
              if (registration != null && registration.carryoverCount > 0)
                _pill('${registration.carryoverCount} carryover'),
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
                onPressed: () => _openPaper(paper),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Read Paper'),
              ),
              if (paper.status == ExamOfficerQuestionStatus.received ||
                  paper.status == ExamOfficerQuestionStatus.moderated)
                FilledButton.tonalIcon(
                  onPressed: () => _withNote(
                    title: 'Send to Moderator',
                    hint: 'Add instructions for the moderator.',
                    action: (note) =>
                        _state.sendQuestionToModerator(paper.id, note),
                  ),
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Send to Moderator'),
                ),
              if (paper.status == ExamOfficerQuestionStatus.received ||
                  paper.status == ExamOfficerQuestionStatus.moderated)
                OutlinedButton.icon(
                  onPressed: () => _withNote(
                    title: 'Return to Lecturer',
                    hint: 'Explain the correction required.',
                    action: (note) =>
                        _state.returnQuestionToLecturer(paper.id, note),
                  ),
                  icon: const Icon(Icons.assignment_return_outlined),
                  label: const Text('Return to Lecturer'),
                ),
              if (paper.status == ExamOfficerQuestionStatus.moderated)
                FilledButton.icon(
                  onPressed: () => _withNote(
                    title: 'Mark Ready for Timetable',
                    hint: 'Add a short readiness note.',
                    action: (note) => _state.markQuestionReady(paper.id, note),
                  ),
                  icon: const Icon(Icons.event_available_outlined),
                  label: const Text('Ready for Timetable'),
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
            labelText: 'Review note',
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

  void _openPaper(ExamOfficerQuestionPaper paper) {
    final raw = paper.questionPayload['questions'];
    final questions = raw is List
        ? raw.whereType<Map>().map((item) {
            return item.map((key, value) => MapEntry(key.toString(), value));
          }).toList()
        : <Map<String, dynamic>>[];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${paper.courseCode} • ${paper.title}'),
        content: SizedBox(
          width: 820,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill(paper.lecturerName),
                    _pill('${paper.totalMarks} marks'),
                    _pill('${paper.durationMinutes} minutes'),
                    _pill('${_state.candidateCountForCourse(paper.courseCode)} candidates'),
                  ],
                ),
                const SizedBox(height: 16),
                if (questions.isEmpty)
                  const Text('No question detail is available for this paper.')
                else
                  for (var i = 0; i < questions.length; i++)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${i + 1} • ${_label(questions[i]['type']?.toString() ?? 'question')} • ${questions[i]['marks'] ?? 0} marks',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            questions[i]['prompt']?.toString() ??
                                'Question text not available.',
                          ),
                        ],
                      ),
                    ),
                if (paper.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Review History',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  for (final note in paper.notes)
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

  String _label(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
