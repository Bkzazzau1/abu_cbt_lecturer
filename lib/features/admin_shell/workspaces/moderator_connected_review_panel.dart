import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_demo_seed.dart';
import '../../exam_officer/data/exam_officer_workflow_state.dart';

class ModeratorConnectedReviewPanel extends StatelessWidget {
  const ModeratorConnectedReviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    ExamOfficerDemoSeed.ensureSeeded();
    final state = ExamOfficerWorkflowState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final queue = state.questionPapers
            .where((paper) => paper.status == ExamOfficerQuestionStatus.withModerator)
            .toList();
        final completed = state.questionPapers
            .where(
              (paper) =>
                  paper.status == ExamOfficerQuestionStatus.moderated ||
                  paper.status == ExamOfficerQuestionStatus.readyForTimetable ||
                  paper.status == ExamOfficerQuestionStatus.partiallyScheduled ||
                  paper.status == ExamOfficerQuestionStatus.scheduled,
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
                          Icons.rule_folder_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Moderator Question Review',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Chip(label: Text('${queue.length} awaiting review')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These are the exact papers sent by the Exam Officer. Complete moderation here and the same paper returns to the Exam Officer as Moderated, ready for slot selection.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (queue.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text('No paper is waiting for moderation.'),
                        ),
                      )
                    else
                      for (final paper in queue)
                        _paperCard(context, state, paper),
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
                      'Recently Moderated Papers',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completed moderation remains visible while the Exam Officer schedules and publishes the examination.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (completed.isEmpty)
                      const Text('No completed moderation is available yet.')
                    else
                      for (final paper in completed.take(8))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.verified_outlined),
                          ),
                          title: Text('${paper.courseCode} • ${paper.courseTitle}'),
                          subtitle: Text(paper.lecturerName),
                          trailing: Chip(label: Text(paper.status.label)),
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

  Widget _paperCard(
    BuildContext context,
    ExamOfficerWorkflowState state,
    ExamOfficerQuestionPaper paper,
  ) {
    final scheme = Theme.of(context).colorScheme;
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
                      '${paper.courseTitle} • submitted by ${paper.lecturerName}',
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
              Chip(label: Text('${paper.questionCount} questions')),
              Chip(label: Text('${paper.totalMarks} marks')),
              Chip(label: Text('${paper.durationMinutes} minutes')),
              Chip(
                label: Text(
                  '${state.candidateCountForCourse(paper.courseCode)} registered candidates',
                ),
              ),
            ],
          ),
          if (paper.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Exam Officer instruction: ${paper.notes.last.note.isEmpty ? 'Review the paper.' : paper.notes.last.note}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openPaper(context, paper),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Read Full Paper'),
              ),
              FilledButton.icon(
                onPressed: () => _completeModeration(context, state, paper),
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Complete Moderation'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completeModeration(
    BuildContext context,
    ExamOfficerWorkflowState state,
    ExamOfficerQuestionPaper paper,
  ) async {
    final controller = TextEditingController(
      text: 'Paper reviewed. Coverage, clarity, difficulty balance and mark allocation are acceptable.',
    );
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete moderation • ${paper.courseCode}'),
        content: SizedBox(
          width: 620,
          child: TextField(
            controller: controller,
            minLines: 4,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Moderator comment',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Complete & Return'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null) return;

    state.recordModeratorReturn(
      paper.id,
      note.isEmpty ? 'Moderation completed.' : note,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${paper.courseCode} moderation completed and returned to the Exam Officer.',
        ),
      ),
    );
  }

  void _openPaper(BuildContext context, ExamOfficerQuestionPaper paper) {
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
                    Chip(label: Text(paper.lecturerName)),
                    Chip(label: Text('${paper.totalMarks} marks')),
                    Chip(label: Text('${paper.durationMinutes} minutes')),
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
