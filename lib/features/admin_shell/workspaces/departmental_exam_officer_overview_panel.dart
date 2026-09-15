import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_workflow_state.dart';
import '../../lecturer_workflow/data/lecturer_gradebook_state.dart';

class DepartmentalExamOfficerOverviewPanel extends StatelessWidget {
  const DepartmentalExamOfficerOverviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final workflow = ExamOfficerWorkflowState.instance;
    final gradebook = LecturerGradebookState.instance;

    return AnimatedBuilder(
      animation: workflow,
      builder: (context, _) {
        final courses = gradebook.courses;
        final submittedCourses = workflow.resultBatches
            .where((batch) => batch.fullBatchSubmitted)
            .length;
        final pendingQuestions = workflow.questionPapers
            .where(
              (paper) =>
                  paper.status != ExamOfficerQuestionStatus.readyForTimetable,
            )
            .length;
        final pendingResults = workflow.resultBatches
            .where(
              (batch) =>
                  batch.status != ExamOfficerResultStatus.verified &&
                  batch.status != ExamOfficerResultStatus.forwardedToHod,
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
                          Icons.assignment_turned_in_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Department Examination Control',
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
                      'Question submission, moderation readiness and lecturer result handoff for the department.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth >= 900
                            ? (constraints.maxWidth - 36) / 4
                            : constraints.maxWidth >= 520
                                ? (constraints.maxWidth - 12) / 2
                                : constraints.maxWidth;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _MetricCard(
                              width: width,
                              label: 'Question Papers',
                              value: '${workflow.questionsReceived}',
                              detail: '$pendingQuestions still in workflow',
                              icon: Icons.quiz_outlined,
                            ),
                            _MetricCard(
                              width: width,
                              label: 'With Moderator',
                              value: '${workflow.questionsWithModerator}',
                              detail: '${workflow.questionsReady} timetable-ready',
                              icon: Icons.rule_folder_outlined,
                            ),
                            _MetricCard(
                              width: width,
                              label: 'Result Batches',
                              value: '${workflow.resultBatchesReceived}',
                              detail: '$submittedCourses full batches submitted',
                              icon: Icons.inbox_outlined,
                            ),
                            _MetricCard(
                              width: width,
                              label: 'Verified Results',
                              value: '${workflow.resultBatchesVerified}',
                              detail: '$pendingResults awaiting verification',
                              icon: Icons.verified_outlined,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final panelWidth = wide
                    ? (constraints.maxWidth - 14) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    SizedBox(
                      width: panelWidth,
                      child: _QuestionQueueCard(workflow: workflow),
                    ),
                    SizedBox(
                      width: panelWidth,
                      child: _CourseReadinessCard(
                        workflow: workflow,
                        courseCount: courses.length,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _QuestionQueueCard extends StatelessWidget {
  const _QuestionQueueCard({required this.workflow});

  final ExamOfficerWorkflowState workflow;

  @override
  Widget build(BuildContext context) {
    final papers = workflow.questionPapers.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question Paper Queue',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (papers.isEmpty)
              const Text('No lecturer question paper has been received yet.')
            else
              for (final paper in papers)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.description_outlined),
                  ),
                  title: Text('${paper.courseCode} • ${paper.title}'),
                  subtitle: Text(paper.lecturerName),
                  trailing: Chip(label: Text(paper.status.label)),
                ),
          ],
        ),
      ),
    );
  }
}

class _CourseReadinessCard extends StatelessWidget {
  const _CourseReadinessCard({
    required this.workflow,
    required this.courseCount,
  });

  final ExamOfficerWorkflowState workflow;
  final int courseCount;

  @override
  Widget build(BuildContext context) {
    final batches = workflow.resultBatches.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department Result Handoff',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              '$courseCount assigned course${courseCount == 1 ? '' : 's'} are being monitored.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            if (batches.isEmpty)
              const Text('No lecturer result batch has reached the Exam Officer yet.')
            else
              for (final batch in batches)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.table_view_outlined),
                  ),
                  title: Text('${batch.courseCode} • ${batch.courseTitle}'),
                  subtitle: Text(
                    '${batch.completeCount}/${batch.studentCount} complete • ${batch.classAverage.toStringAsFixed(1)}% average',
                  ),
                  trailing: Chip(label: Text(batch.status.label)),
                ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });

  final double width;
  final String label;
  final String value;
  final String detail;
  final IconData icon;

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
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 10),
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
          Text(
            detail,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
