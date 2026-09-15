import 'package:flutter/material.dart';

import '../../lecturer_marking/data/lecturer_marking_api.dart';
import '../../lecturer_workflow/data/lecturer_demo_state.dart';

class LecturerConnectedMarkingPanel extends StatefulWidget {
  const LecturerConnectedMarkingPanel({
    super.key,
    this.section = 'Marking & Grading',
  });

  final String section;

  @override
  State<LecturerConnectedMarkingPanel> createState() =>
      _LecturerConnectedMarkingPanelState();
}

class _LecturerConnectedMarkingPanelState
    extends State<LecturerConnectedMarkingPanel> {
  final LecturerDemoState _state = LecturerDemoState.instance;
  late String _section = widget.section;
  String _course = 'All';
  String? _openScriptId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final scripts = _state.scripts
            .where((script) => _course == 'All' || script.courseCode == _course)
            .toList();
        LecturerDemoExamScript? openScript;
        if (_openScriptId != null) {
          for (final script in _state.scripts) {
            if (script.id == _openScriptId) {
              openScript = script;
              break;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'Marking & Grading',
                    label: Text('Marking & Grading'),
                    icon: Icon(Icons.edit_note_outlined),
                  ),
                  ButtonSegment(
                    value: 'Results Submission',
                    label: Text('Results Submission'),
                    icon: Icon(Icons.publish_outlined),
                  ),
                ],
                selected: {_section},
                onSelectionChanged: (selection) => setState(() {
                  _section = selection.first;
                  _openScriptId = null;
                }),
              ),
            ),
            if (_section == 'Results Submission')
              _ResultsPanel(
                state: _state,
                scripts: scripts,
                course: _course,
                onCourseChanged: (value) =>
                    setState(() => _course = value ?? 'All'),
              )
            else
              _MarkingPanel(
                state: _state,
                scripts: scripts,
                course: _course,
                openScript: openScript,
                onCourseChanged: (value) =>
                    setState(() => _course = value ?? 'All'),
                onOpen: (script) => setState(() => _openScriptId = script.id),
                onClose: () => setState(() => _openScriptId = null),
              ),
          ],
        );
      },
    );
  }
}

class _MarkingPanel extends StatelessWidget {
  const _MarkingPanel({
    required this.state,
    required this.scripts,
    required this.course,
    required this.openScript,
    required this.onCourseChanged,
    required this.onOpen,
    required this.onClose,
  });

  final LecturerDemoState state;
  final List<LecturerDemoExamScript> scripts;
  final String course;
  final LecturerDemoExamScript? openScript;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<LecturerDemoExamScript> onOpen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final pending = scripts
        .where((script) => script.status == LecturerDemoScriptStatus.pendingMarking)
        .length;
    final marked = scripts
        .where((script) => script.status == LecturerDemoScriptStatus.marked)
        .length;

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
                    'Examination Marking',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Metric(label: 'Scripts', value: '${scripts.length}'),
                _Metric(label: 'Pending', value: '$pending'),
                _Metric(label: 'Marked', value: '$marked'),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: course,
                    decoration: const InputDecoration(labelText: 'Course'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All courses')),
                      DropdownMenuItem(value: 'CSC 305', child: Text('CSC 305')),
                      DropdownMenuItem(value: 'CSC 309', child: Text('CSC 309')),
                    ],
                    onChanged: onCourseChanged,
                  ),
                ),
              ],
            ),
            if (openScript != null) ...[
              const SizedBox(height: 18),
              _ScriptWorkspace(
                state: state,
                script: openScript!,
                onClose: onClose,
              ),
            ],
            const SizedBox(height: 18),
            for (final script in scripts)
              _ScriptTile(script: script, onOpen: () => onOpen(script)),
          ],
        ),
      ),
    );
  }
}

class _ScriptTile extends StatelessWidget {
  const _ScriptTile({required this.script, required this.onOpen});

  final LecturerDemoExamScript script;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final submitted =
        script.status == LecturerDemoScriptStatus.submittedToExamOfficer;
    final color = script.status == LecturerDemoScriptStatus.integrityReview
        ? scheme.error
        : submitted || script.status == LecturerDemoScriptStatus.marked
        ? scheme.primary
        : scheme.secondary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${script.courseCode} • ${script.examTitle}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text('${script.student} • ${script.candidateNo}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(label: 'Objective ${script.objectiveScore}/40'),
                    _Pill(label: 'Theory ${script.theoryScore}/${script.theoryMax}'),
                    _Pill(label: 'Total ${script.examScore}/${script.examMax}'),
                    _Pill(label: 'Grade ${script.grade}'),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Status(label: script.status.label, color: color),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.description_outlined),
                label: Text(submitted ? 'View script' : 'Mark script'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScriptWorkspace extends StatelessWidget {
  const _ScriptWorkspace({
    required this.state,
    required this.script,
    required this.onClose,
  });

  final LecturerDemoState state;
  final LecturerDemoExamScript script;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locked =
        script.status == LecturerDemoScriptStatus.submittedToExamOfficer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${script.student} • ${script.candidateNo}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(label: script.courseCode),
              _Pill(label: 'Objective ${script.objectiveScore}/40'),
              _Pill(label: 'Total ${script.examScore}/${script.examMax}'),
              _Pill(label: 'Grade ${script.grade}'),
              _Pill(label: script.status.label),
            ],
          ),
          const SizedBox(height: 16),
          for (final question in script.questions) ...[
            _QuestionMarkCard(
              key: ValueKey('${script.id}-${question.id}'),
              state: state,
              script: script,
              question: question,
              locked: locked,
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            initialValue: script.summary,
            readOnly: locked,
            minLines: 2,
            maxLines: 4,
            onChanged: (value) => state.updateSummary(script.id, value),
            decoration: const InputDecoration(
              labelText: 'Lecturer marking summary',
              prefixIcon: Icon(Icons.comment_outlined),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: locked || !script.markingComplete
                    ? null
                    : () => state.completeMarking(script.id),
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Complete Marking'),
              ),
              if (script.status == LecturerDemoScriptStatus.marked)
                FilledButton.icon(
                  onPressed: () => state.submitScriptToExamOfficer(script.id),
                  icon: const Icon(Icons.publish_outlined),
                  label: const Text('Submit to Exam Officer'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionMarkCard extends StatefulWidget {
  const _QuestionMarkCard({
    super.key,
    required this.state,
    required this.script,
    required this.question,
    required this.locked,
  });

  final LecturerDemoState state;
  final LecturerDemoExamScript script;
  final LecturerDemoMarkingQuestion question;
  final bool locked;

  @override
  State<_QuestionMarkCard> createState() => _QuestionMarkCardState();
}

class _QuestionMarkCardState extends State<_QuestionMarkCard> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.script.marks[widget.question.id]?.toString() ?? '',
    );
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _QuestionMarkCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stored = widget.script.marks[widget.question.id]?.toString() ?? '';
    if (!_focusNode.hasFocus && _controller.text != stored) {
      _controller.text = stored;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.question,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(widget.question.candidateAnswer),
          const SizedBox(height: 10),
          Text(
            'Marking guide: ${widget.question.markingGuide}',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 190,
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: widget.locked,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    widget.state.updateQuestionMark(
                      widget.script.id,
                      widget.question.id,
                      int.tryParse(value.trim()),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'Mark / ${widget.question.maxMark}',
                    prefixIcon: const Icon(Icons.edit_note_outlined),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.locked
                    ? null
                    : () async {
                        final score = await showDialog<int>(
                          context: context,
                          builder: (_) => _AiMarkDialog(
                            question: widget.question,
                          ),
                        );
                        if (score == null || !mounted) return;
                        _controller.text = '$score';
                        widget.state.updateQuestionMark(
                          widget.script.id,
                          widget.question.id,
                          score,
                        );
                      },
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('AI Suggest Mark'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiMarkDialog extends StatefulWidget {
  const _AiMarkDialog({required this.question});

  final LecturerDemoMarkingQuestion question;

  @override
  State<_AiMarkDialog> createState() => _AiMarkDialogState();
}

class _AiMarkDialogState extends State<_AiMarkDialog> {
  final LecturerMarkingApi _api = LecturerMarkingApi();
  AiMarkingSuggestion? _suggestion;
  bool _loading = false;

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<void> _suggest() async {
    setState(() => _loading = true);
    final result = await _api.suggestMarking(
      question: widget.question.question,
      markingGuide: widget.question.markingGuide,
      candidateAnswer: widget.question.candidateAnswer,
      maxMark: widget.question.maxMark,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _suggestion = result.suggestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Marking Suggestion'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.question.question,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(widget.question.candidateAnswer),
              const SizedBox(height: 10),
              Text('Marking guide: ${widget.question.markingGuide}'),
              if (_suggestion != null) ...[
                const SizedBox(height: 16),
                Text(
                  '${_suggestion!.suggestedMark} / ${widget.question.maxMark}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                if (_suggestion!.rationale.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_suggestion!.rationale),
                ],
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
        if (_suggestion == null)
          FilledButton.icon(
            onPressed: _loading ? null : _suggest,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_outlined),
            label: const Text('Generate Suggestion'),
          )
        else
          FilledButton(
            onPressed: () => Navigator.pop(context, _suggestion!.suggestedMark),
            child: const Text('Use Score'),
          ),
      ],
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.state,
    required this.scripts,
    required this.course,
    required this.onCourseChanged,
  });

  final LecturerDemoState state;
  final List<LecturerDemoExamScript> scripts;
  final String course;
  final ValueChanged<String?> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    final ready = scripts
        .where((script) => script.status == LecturerDemoScriptStatus.marked)
        .toList();
    final submitted = scripts
        .where(
          (script) =>
              script.status == LecturerDemoScriptStatus.submittedToExamOfficer,
        )
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
                  Icons.publish_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Results Submission',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: ready.isEmpty
                      ? null
                      : () => state.submitReadyBatch(courseCode: course),
                  icon: const Icon(Icons.publish_outlined),
                  label: const Text('Submit Ready Batch'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Metric(label: 'Ready', value: '${ready.length}'),
                _Metric(label: 'Submitted', value: '${submitted.length}'),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: course,
                    decoration: const InputDecoration(labelText: 'Course'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All courses')),
                      DropdownMenuItem(value: 'CSC 305', child: Text('CSC 305')),
                      DropdownMenuItem(value: 'CSC 309', child: Text('CSC 309')),
                    ],
                    onChanged: onCourseChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final script in scripts)
              if (script.status == LecturerDemoScriptStatus.marked ||
                  script.status ==
                      LecturerDemoScriptStatus.submittedToExamOfficer)
                _ResultTile(state: state, script: script),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.state, required this.script});

  final LecturerDemoState state;
  final LecturerDemoExamScript script;

  @override
  Widget build(BuildContext context) {
    final submitted =
        script.status == LecturerDemoScriptStatus.submittedToExamOfficer;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${script.courseCode} • ${script.student}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(label: script.candidateNo),
                  _Pill(label: 'Score ${script.examScore}/${script.examMax}'),
                  _Pill(label: 'Grade ${script.grade}'),
                  _Pill(label: script.status.label),
                ],
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: submitted
                ? null
                : () => state.submitScriptToExamOfficer(script.id),
            icon: const Icon(Icons.publish_outlined),
            label: Text(submitted ? 'Submitted' : 'Submit to Exam Officer'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
