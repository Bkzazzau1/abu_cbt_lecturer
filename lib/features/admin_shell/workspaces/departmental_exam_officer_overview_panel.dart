import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_workflow_state.dart';
import '../../lecturer_workflow/data/cbt_calendar_state.dart';

class DepartmentalExamOfficerOverviewPanel extends StatelessWidget {
  const DepartmentalExamOfficerOverviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final workflow = ExamOfficerWorkflowState.instance;
    final calendar = CbtCalendarState.instance;

    return AnimatedBuilder(
      animation: workflow,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: calendar,
          builder: (context, _) {
            final pendingQuestions = workflow.questionPapers
                .where(
                  (paper) =>
                      paper.status != ExamOfficerQuestionStatus.readyForTimetable &&
                      paper.status != ExamOfficerQuestionStatus.partiallyScheduled &&
                      paper.status != ExamOfficerQuestionStatus.scheduled,
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
                          'Course registrations include carryover students. Level students are unique students currently in that level, so the two totals are intentionally different.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth >= 1100
                                ? (constraints.maxWidth - 60) / 6
                                : constraints.maxWidth >= 600
                                    ? (constraints.maxWidth - 12) / 2
                                    : constraints.maxWidth;
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _MetricCard(
                                  width: width,
                                  label: 'Level Students',
                                  value: '${workflow.totalLevelStudents}',
                                  detail: 'Unique 100–400L students',
                                  icon: Icons.groups_2_outlined,
                                ),
                                _MetricCard(
                                  width: width,
                                  label: 'Course Registrations',
                                  value: '${workflow.totalCourseRegistrations}',
                                  detail: 'Exam candidate entries',
                                  icon: Icons.app_registration_outlined,
                                ),
                                _MetricCard(
                                  width: width,
                                  label: 'Carryover Entries',
                                  value: '${workflow.totalCarryoverRegistrations}',
                                  detail: 'Included in course totals',
                                  icon: Icons.replay_outlined,
                                ),
                                _MetricCard(
                                  width: width,
                                  label: 'Question Papers',
                                  value: '${workflow.questionsReceived}',
                                  detail: '$pendingQuestions still in review',
                                  icon: Icons.quiz_outlined,
                                ),
                                _MetricCard(
                                  width: width,
                                  label: 'Exam Slots',
                                  value: '${calendar.availableSlots.length}',
                                  detail: '${workflow.questionsScheduled} fully scheduled',
                                  icon: Icons.event_available_outlined,
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
                    final wide = constraints.maxWidth >= 920;
                    final panelWidth = wide
                        ? (constraints.maxWidth - 14) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        SizedBox(
                          width: panelWidth,
                          child: _LevelLoadCard(workflow: workflow),
                        ),
                        SizedBox(
                          width: panelWidth,
                          child: _QuestionQueueCard(workflow: workflow),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LevelLoadCard extends StatelessWidget {
  const _LevelLoadCard({required this.workflow});

  final ExamOfficerWorkflowState workflow;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Courses by Level',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (final level in workflow.levels)
              Builder(
                builder: (context) {
                  final courses = workflow.coursesForLevel(level);
                  final registrations = courses.fold<int>(
                    0,
                    (sum, item) => sum + item.totalRegistered,
                  );
                  final carryover = courses.fold<int>(
                    0,
                    (sum, item) => sum + item.carryoverCount,
                  );
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(level.substring(0, 1)),
                    ),
                    title: Text(
                      '$level • ${workflow.cohortCount(level)} students',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${courses.length} courses • $registrations registrations • $carryover carryover',
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _QuestionQueueCard extends StatelessWidget {
  const _QuestionQueueCard({required this.workflow});

  final ExamOfficerWorkflowState workflow;

  @override
  Widget build(BuildContext context) {
    final papers = workflow.questionPapers.take(6).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question & Timetable Queue',
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
                  subtitle: Text(
                    '${workflow.candidateCountForCourse(paper.courseCode)} candidates • ${paper.lecturerName}',
                  ),
                  trailing: Chip(label: Text(paper.status.label)),
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
          Text(detail, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
