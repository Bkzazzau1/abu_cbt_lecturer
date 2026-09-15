import 'package:flutter/material.dart';

import '../../lecturer_workflow/data/lecturer_demo_state.dart';
import 'folded_question_builder_panel.dart' as legacy;
import 'lecturer_ca_question_panel.dart';

class LecturerQuestionLivePanel extends StatefulWidget {
  const LecturerQuestionLivePanel({super.key});

  @override
  State<LecturerQuestionLivePanel> createState() =>
      _LecturerQuestionLivePanelState();
}

class _LecturerQuestionLivePanelState extends State<LecturerQuestionLivePanel> {
  final LecturerDemoState _state = LecturerDemoState.instance;
  Key _builderKey = UniqueKey();
  String _section = 'Exam Questions';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'Exam Questions',
                label: Text('Exam Questions'),
                icon: Icon(Icons.description_outlined),
              ),
              ButtonSegment(
                value: 'CA Questions',
                label: Text('CA Questions'),
                icon: Icon(Icons.quiz_outlined),
              ),
            ],
            selected: {_section},
            onSelectionChanged: (selection) =>
                setState(() => _section = selection.first),
          ),
        ),
        if (_section == 'CA Questions')
          const LecturerCaQuestionPanel()
        else
          _buildExamQuestions(),
      ],
    );
  }

  Widget _buildExamQuestions() {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final submission = _state.latestQuestionSubmission;
        if (_state.questionEditorLocked && submission != null) {
          final scheme = Theme.of(context).colorScheme;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_outlined, color: scheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Exam Question Paper',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      Chip(label: Text(submission.status)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _Detail(label: 'Course', value: submission.courseCode),
                      _Detail(label: 'Title', value: submission.title),
                      _Detail(
                        label: 'Questions',
                        value: '${submission.questionCount}',
                      ),
                      _Detail(
                        label: 'Total marks',
                        value: '${submission.totalMarks}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () {
                      _state.startNewQuestionPaper();
                      setState(() => _builderKey = UniqueKey());
                    },
                    icon: const Icon(Icons.add_outlined),
                    label: const Text('New Question Paper'),
                  ),
                ],
              ),
            ),
          );
        }

        return KeyedSubtree(
          key: _builderKey,
          child: const legacy.LecturerQuestionLivePanel(),
        );
      },
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
