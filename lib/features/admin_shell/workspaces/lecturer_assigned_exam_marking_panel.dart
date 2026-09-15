import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../exam_officer/data/exam_officer_marking_assignment_state.dart';
import '../../lecturer_marking/data/lecturer_marking_api.dart';
import '../../lecturer_workflow/data/lecturer_demo_state.dart';

class LecturerAssignedExamMarkingPanel extends StatefulWidget {
  const LecturerAssignedExamMarkingPanel({super.key});

  @override
  State<LecturerAssignedExamMarkingPanel> createState() =>
      _LecturerAssignedExamMarkingPanelState();
}

class _LecturerAssignedExamMarkingPanelState
    extends State<LecturerAssignedExamMarkingPanel> {
  final LecturerDemoState _state = LecturerDemoState.instance;
  final ExamOfficerMarkingAssignmentState _assignments =
      ExamOfficerMarkingAssignmentState.instance;

  String _course = 'All';
  String? _openScriptId;
  String _section = 'Marking';

  String get _markerName =>
      AuthSession.instance.session?.name ?? 'Dr. Amina Bello';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _assignments,
      builder: (context, _) => AnimatedBuilder(
        animation: _state,
        builder: (context, _) {
          final assignedScripts = _state.scripts
              .where(
                (script) =>
                    _assignments.canMark(_markerName, script.courseCode),
              )
              .toList();
          final courseCodes = <String>{
            for (final script in assignedScripts) script.courseCode,
          }.toList()
            ..sort();
          if (_course != 'All' && !courseCodes.contains(_course)) {
            _course = 'All';
          }
          final scripts = assignedScripts
              .where(
                (script) => _course == 'All' || script.courseCode == _course,
              )
              .toList();
          LecturerDemoExamScript? openScript;
          for (final script in scripts) {
            if (script.id == _openScriptId) openScript = script;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.assignment_ind_outlined),
                      Text(
                        'Marker: $_markerName',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Chip(
                        label: Text(
                          '${courseCodes.length} assigned course${courseCodes.length == 1 ? '' : 's'}',
                        ),
                      ),
                      if (courseCodes.isNotEmpty)
                        Chip(label: Text(courseCodes.join(' • '))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'Marking',
                    label: Text('Assigned Marking'),
                    icon: Icon(Icons.edit_note_outlined),
                  ),
                  ButtonSegment(
                    value: 'Submission',
                    label: Text('Results Submission'),
                    icon: Icon(Icons.publish_outlined),
                  ),
                ],
                selected: {_section},
                onSelectionChanged: (value) => setState(() {
                  _section = value.first;
                  _openScriptId = null;
                }),
              ),
              const SizedBox(height: 12),
              if (assignedScripts.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No examination marking has been assigned to this lecturer by the Exam Officer.',
                    ),
                  ),
                )
              else if (_section == 'Submission')
                _submissionPanel(scripts, courseCodes)
              else
                _markingPanel(scripts, courseCodes, openScript),
            ],
          );
        },
      ),
    );
  }

  Widget _courseFilter(List<String> courseCodes) {
    return SizedBox(
      width: 230,
      child: DropdownButtonFormField<String>(
        initialValue: _course,
        decoration: const InputDecoration(labelText: 'Assigned course'),
        items: [
          const DropdownMenuItem(value: 'All', child: Text('All assigned courses')),
          for (final code in courseCodes)
            DropdownMenuItem(value: code, child: Text(code)),
        ],
        onChanged: (value) => setState(() {
          _course = value ?? 'All';
          _openScriptId = null;
        }),
      ),
    );
  }

  Widget _markingPanel(
    List<LecturerDemoExamScript> scripts,
    List<String> courseCodes,
    LecturerDemoExamScript? openScript,
  ) {
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(label: Text('Scripts ${scripts.length}')),
                Chip(label: Text('Pending $pending')),
                Chip(label: Text('Marked $marked')),
                _courseFilter(courseCodes),
              ],
            ),
            if (openScript != null) ...[
              const SizedBox(height: 16),
              _scriptWorkspace(openScript),
            ],
            const SizedBox(height: 16),
            for (final script in scripts) _scriptTile(script),
          ],
        ),
      ),
    );
  }

  Widget _scriptTile(LecturerDemoExamScript script) {
    final locked =
        script.status == LecturerDemoScriptStatus.submittedToExamOfficer;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        '${script.courseCode} • ${script.student}',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        '${script.candidateNo} • ${script.status.label} • ${script.examScore}/${script.examMax} • Grade ${script.grade}',
      ),
      trailing: OutlinedButton.icon(
        onPressed: () => setState(() => _openScriptId = script.id),
        icon: const Icon(Icons.description_outlined),
        label: Text(locked ? 'View Script' : 'Mark Script'),
      ),
    );
  }

  Widget _scriptWorkspace(LecturerDemoExamScript script) {
    final locked =
        script.status == LecturerDemoScriptStatus.submittedToExamOfficer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${script.student} • ${script.candidateNo}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _openScriptId = null),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final question in script.questions)
            _AssignedQuestionMarkCard(
              key: ValueKey('${script.id}-${question.id}'),
              state: _state,
              script: script,
              question: question,
              locked: locked,
            ),
          TextFormField(
            initialValue: script.summary,
            readOnly: locked,
            minLines: 2,
            maxLines: 4,
            onChanged: (value) => _state.updateSummary(script.id, value),
            decoration: const InputDecoration(labelText: 'Marker summary'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              FilledButton.icon(
                onPressed: locked || !script.markingComplete
                    ? null
                    : () => _state.completeMarking(script.id),
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Complete Marking'),
              ),
              if (script.status == LecturerDemoScriptStatus.marked)
                FilledButton.icon(
                  onPressed: () => _state.submitScriptToExamOfficer(script.id),
                  icon: const Icon(Icons.publish_outlined),
                  label: const Text('Submit to Exam Officer'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _submissionPanel(
    List<LecturerDemoExamScript> scripts,
    List<String> courseCodes,
  ) {
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(label: Text('Ready ${ready.length}')),
                Chip(label: Text('Submitted ${submitted.length}')),
                _courseFilter(courseCodes),
                FilledButton.icon(
                  onPressed: ready.isEmpty
                      ? null
                      : () => _state.submitReadyBatch(courseCode: _course),
                  icon: const Icon(Icons.publish_outlined),
                  label: const Text('Submit Ready Batch'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final script in scripts)
              if (script.status == LecturerDemoScriptStatus.marked ||
                  script.status ==
                      LecturerDemoScriptStatus.submittedToExamOfficer)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${script.courseCode} • ${script.student}'),
                  subtitle: Text(
                    '${script.candidateNo} • Score ${script.examScore}/${script.examMax} • Grade ${script.grade}',
                  ),
                  trailing: FilledButton(
                    onPressed: script.status ==
                            LecturerDemoScriptStatus.submittedToExamOfficer
                        ? null
                        : () => _state.submitScriptToExamOfficer(script.id),
                    child: Text(
                      script.status ==
                              LecturerDemoScriptStatus.submittedToExamOfficer
                          ? 'Submitted'
                          : 'Submit',
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _AssignedQuestionMarkCard extends StatefulWidget {
  const _AssignedQuestionMarkCard({
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
  State<_AssignedQuestionMarkCard> createState() =>
      _AssignedQuestionMarkCardState();
}

class _AssignedQuestionMarkCardState
    extends State<_AssignedQuestionMarkCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.script.marks[widget.question.id]?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.question.question,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(widget.question.candidateAnswer),
          const SizedBox(height: 8),
          Text('Marking guide: ${widget.question.markingGuide}'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _controller,
                  readOnly: widget.locked,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => widget.state.updateQuestionMark(
                    widget.script.id,
                    widget.question.id,
                    int.tryParse(value.trim()),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Mark / ${widget.question.maxMark}',
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.locked
                    ? null
                    : () async {
                        final score = await showDialog<int>(
                          context: context,
                          builder: (_) => _AssignedAiMarkDialog(
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

class _AssignedAiMarkDialog extends StatefulWidget {
  const _AssignedAiMarkDialog({required this.question});

  final LecturerDemoMarkingQuestion question;

  @override
  State<_AssignedAiMarkDialog> createState() => _AssignedAiMarkDialogState();
}

class _AssignedAiMarkDialogState extends State<_AssignedAiMarkDialog> {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.question),
            const SizedBox(height: 8),
            Text(widget.question.candidateAnswer),
            if (_suggestion != null) ...[
              const SizedBox(height: 14),
              Text(
                '${_suggestion!.suggestedMark} / ${widget.question.maxMark}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              if (_suggestion!.rationale.isNotEmpty) Text(_suggestion!.rationale),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (_suggestion == null)
          FilledButton(
            onPressed: _loading ? null : _suggest,
            child: Text(_loading ? 'Checking…' : 'Generate Suggestion'),
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
