import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_workflow_state.dart';
import 'exam_management_panel_legacy.dart' as legacy;

class ExamOfficerReadinessPanel extends StatelessWidget {
  const ExamOfficerReadinessPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ExamOfficerWorkflowState.instance;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final ready = state.questionPapers
            .where(
              (paper) =>
                  paper.status == ExamOfficerQuestionStatus.readyForTimetable,
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
                          Icons.fact_check_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Connected Exam Readiness',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Chip(label: Text('${ready.length} ready')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Question papers become timetable-ready only after the Exam Officer receives the moderated paper and marks it ready.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (ready.isEmpty)
                      const Text(
                        'No connected lecturer paper is ready for timetable placement yet.',
                      )
                    else
                      for (final paper in ready)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.event_available_outlined),
                          ),
                          title: Text('${paper.courseCode} • ${paper.title}'),
                          subtitle: Text(
                            '${paper.lecturerName} • ${paper.durationMinutes} minutes',
                          ),
                          trailing: const Chip(label: Text('Ready')),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const legacy.ExamManagementPanel(),
          ],
        );
      },
    );
  }
}
