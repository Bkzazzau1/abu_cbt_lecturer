import 'package:flutter/material.dart';

import '../../exam_workflow/data/exam_workflow_api.dart';

enum QuestionReviewMode { examOfficer, moderator }

class ModeratorQuestionReviewPanel extends StatefulWidget {
  const ModeratorQuestionReviewPanel({
    super.key,
    this.mode = QuestionReviewMode.examOfficer,
  });

  final QuestionReviewMode mode;

  @override
  State<ModeratorQuestionReviewPanel> createState() =>
      _ModeratorQuestionReviewPanelState();
}

class _ModeratorQuestionReviewPanelState
    extends State<ModeratorQuestionReviewPanel> {
  final ExamWorkflowApi _api = ExamWorkflowApi();

  bool _loading = true;
  String? _error;
  String _selectedStatus = 'all';
  String _selectedWindow = 'First semester';
  int? _busyExamId;
  List<ExamWorkflowItem> _items = const [];

  bool get _isModerator => widget.mode == QuestionReviewMode.moderator;

  @override
  void initState() {
    super.initState();
    if (_isModerator) _selectedStatus = 'moderator_review';
    _load();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await _api.fetchExams();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  List<ExamWorkflowItem> get _relevantItems {
    final statuses = _isModerator
        ? const ['moderator_review', 'moderated']
        : const [
            'officer_review',
            'moderator_review',
            'moderated',
            'lecturer_correction',
            'scheduled',
          ];

    return _items.where((item) => statuses.contains(item.status)).toList();
  }

  List<ExamWorkflowItem> get _visibleItems {
    if (_selectedStatus == 'all') return _relevantItems;
    return _relevantItems
        .where((item) => item.status == _selectedStatus)
        .toList();
  }

  int _count(String status) =>
      _relevantItems.where((item) => item.status == status).length;

  Future<String?> _noteDialog({required String title, required String hint}) {
    final controller = TextEditingController();
    return showDialog<String>(
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
    ).whenComplete(controller.dispose);
  }

  Future<void> _runAction(
    ExamWorkflowItem item,
    Future<ExamWorkflowItem> Function(String note) action, {
    required String title,
    required String hint,
  }) async {
    final note = await _noteDialog(title: title, hint: hint);
    if (note == null) return;

    setState(() => _busyExamId = item.id);
    try {
      await action(note);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question paper updated successfully.')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busyExamId = null);
    }
  }

  void _openPaper(ExamWorkflowItem item) {
    final questions = _collectQuestions(item.questionPayload);

    showDialog<void>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Read-only examination paper'),
          content: SizedBox(
            width: 820,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ExamPaperHeader(
                    item: item,
                    window: _selectedWindow,
                    totalMarks: _totalMarks(questions),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Questions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (questions.isEmpty)
                    Text(
                      'No questions found in this paper.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    )
                  else
                    for (var i = 0; i < questions.length; i++)
                      _QuestionPreviewCard(
                        number: i + 1,
                        question: questions[i],
                      ),
                  if (item.workflowNotes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Review history',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final note in item.workflowNotes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${note.actionLabel}: ${note.comment.isEmpty ? 'No note added' : note.comment}',
                          style: TextStyle(color: scheme.onSurfaceVariant),
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
        );
      },
    );
  }

  static List<Map<String, dynamic>> _collectQuestions(
    Map<String, dynamic> payload,
  ) {
    final out = <Map<String, dynamic>>[];

    final questions = payload['questions'];
    if (questions is List) {
      out.addAll(
        questions.whereType<Map>().map((raw) {
          return raw.map((key, value) => MapEntry(key.toString(), value));
        }),
      );
    }

    final sections = payload['sections'];
    if (sections is List) {
      for (final section in sections.whereType<Map>()) {
        final items = section['questions'];
        if (items is List) {
          out.addAll(
            items.whereType<Map>().map((raw) {
              return raw.map((key, value) => MapEntry(key.toString(), value));
            }),
          );
        }
      }
    }

    return out;
  }

  static int _totalMarks(List<Map<String, dynamic>> questions) {
    return questions.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item['marks']?.toString() ?? '') ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = _visibleItems;
    final title = _isModerator
        ? 'Moderator Question Review'
        : 'Question Submission & Moderation';
    final subtitle = _isModerator
        ? 'Read submitted question papers, add moderation notes, and return them to the Exam Officer.'
        : 'Track submitted question papers, moderation progress, correction notes, and scheduling readiness.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 14,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 210,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedWindow,
                        decoration: const InputDecoration(
                          labelText: 'Exam window',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'First semester',
                            child: Text('First semester'),
                          ),
                          DropdownMenuItem(
                            value: 'Second semester',
                            child: Text('Second semester'),
                          ),
                        ],
                        onChanged: (value) => setState(
                          () => _selectedWindow = value ?? 'First semester',
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusFilterChip(
                  label: 'All ${_relevantItems.length}',
                  selected: _selectedStatus == 'all',
                  onTap: () => setState(() => _selectedStatus = 'all'),
                ),
                if (!_isModerator)
                  _StatusFilterChip(
                    label: 'Exam Officer Review ${_count('officer_review')}',
                    selected: _selectedStatus == 'officer_review',
                    onTap: () =>
                        setState(() => _selectedStatus = 'officer_review'),
                  ),
                _StatusFilterChip(
                  label: 'With Moderator ${_count('moderator_review')}',
                  selected: _selectedStatus == 'moderator_review',
                  onTap: () =>
                      setState(() => _selectedStatus = 'moderator_review'),
                ),
                _StatusFilterChip(
                  label: _isModerator
                      ? 'Returned to Exam Officer ${_count('moderated')}'
                      : 'Returned ${_count('moderated')}',
                  selected: _selectedStatus == 'moderated',
                  onTap: () => setState(() => _selectedStatus = 'moderated'),
                ),
                if (!_isModerator)
                  _StatusFilterChip(
                    label: 'Correction ${_count('lecturer_correction')}',
                    selected: _selectedStatus == 'lecturer_correction',
                    onTap: () =>
                        setState(() => _selectedStatus = 'lecturer_correction'),
                  ),
                if (!_isModerator)
                  _StatusFilterChip(
                    label: 'Scheduled ${_count('scheduled')}',
                    selected: _selectedStatus == 'scheduled',
                    onTap: () => setState(() => _selectedStatus = 'scheduled'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              _ErrorBox(message: _error!, onRetry: _load)
            else if (visible.isEmpty)
              const _EmptyBox()
            else
              for (final item in visible)
                _LiveQuestionPaperTile(
                  item: item,
                  mode: widget.mode,
                  busy: _busyExamId == item.id,
                  onOpen: () => _openPaper(item),
                  onSendToModerator: () => _runAction(
                    item,
                    (note) => _api.sendToModerator(item.id, note),
                    title: 'Send to Moderator',
                    hint: 'Add instruction for the moderator.',
                  ),
                  onReturnToOfficer: () => _runAction(
                    item,
                    (note) => _api.moderatorReturn(item.id, note),
                    title: 'Return to Exam Officer',
                    hint: 'Add the moderator review note.',
                  ),
                  onSendBackToLecturer: () => _runAction(
                    item,
                    (note) => _api.sendBackToLecturer(item.id, note),
                    title: 'Send Back to Lecturer',
                    hint: 'Explain the correction needed.',
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _LiveQuestionPaperTile extends StatelessWidget {
  const _LiveQuestionPaperTile({
    required this.item,
    required this.mode,
    required this.busy,
    required this.onOpen,
    required this.onSendToModerator,
    required this.onReturnToOfficer,
    required this.onSendBackToLecturer,
  });

  final ExamWorkflowItem item;
  final QuestionReviewMode mode;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onSendToModerator;
  final VoidCallback onReturnToOfficer;
  final VoidCallback onSendBackToLecturer;

  bool get _isModerator => mode == QuestionReviewMode.moderator;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(scheme, item.status);
    final lastNote = item.workflowNotes.isEmpty
        ? null
        : item.workflowNotes.last;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.courseLabel} • ${item.title}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.deliveryLabel} • ${item.scheduleLabel}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: item.statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: '${item.questionCount} questions'),
              for (final type in item.questionTypes)
                _MiniPill(label: _label(type)),
            ],
          ),
          if (lastNote != null) ...[
            const SizedBox(height: 10),
            Text(
              '${lastNote.actionLabel}: ${lastNote.comment.isEmpty ? 'No note added' : lastNote.comment}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
          if (busy)
            const LinearProgressIndicator()
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Open paper'),
                ),
                if (!_isModerator && item.status == 'officer_review')
                  FilledButton.icon(
                    onPressed: onSendToModerator,
                    icon: const Icon(Icons.forward_to_inbox_outlined),
                    label: const Text('Send to Moderator'),
                  ),
                if (_isModerator && item.status == 'moderator_review')
                  FilledButton.icon(
                    onPressed: onReturnToOfficer,
                    icon: const Icon(Icons.assignment_return_outlined),
                    label: const Text('Return to Exam Officer'),
                  ),
                if (!_isModerator &&
                    (item.status == 'moderated' ||
                        item.status == 'officer_review'))
                  OutlinedButton.icon(
                    onPressed: onSendBackToLecturer,
                    icon: const Icon(Icons.reply_all_outlined),
                    label: const Text('Send Back to Lecturer'),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Color _statusColor(ColorScheme scheme, String status) {
    switch (status) {
      case 'moderator_review':
        return scheme.secondary;
      case 'moderated':
      case 'scheduled':
        return scheme.primary;
      case 'lecturer_correction':
        return scheme.error;
      default:
        return scheme.tertiary;
    }
  }
}

class _ExamPaperHeader extends StatelessWidget {
  const _ExamPaperHeader({
    required this.item,
    required this.window,
    required this.totalMarks,
  });

  final ExamWorkflowItem item;
  final String window;
  final int totalMarks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final level = _levelFromCourse(item.courseCode);
    final faculty = _facultyFromCourse(item.courseCode);
    final department = _departmentFromCourse(item.courseCode);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'KADUNA STATE UNIVERSITY',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'DISTANCE LEARNING CENTRE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _PaperInfoRow(label: 'Faculty', value: faculty),
          _PaperInfoRow(label: 'Department', value: department),
          _PaperInfoRow(label: 'Level', value: level),
          _PaperInfoRow(label: 'Exam window', value: window),
          _PaperInfoRow(label: 'Course', value: item.courseLabel),
          _PaperInfoRow(label: 'Paper title', value: item.title),
          _PaperInfoRow(
            label: 'Duration',
            value: '${item.durationMinutes} minutes',
          ),
          _PaperInfoRow(label: 'Total marks', value: '$totalMarks marks'),
          const SizedBox(height: 8),
          const Divider(),
          _PaperInfoRow(label: 'Instructions', value: 'Answer all questions.'),
        ],
      ),
    );
  }
}

class _PaperInfoRow extends StatelessWidget {
  const _PaperInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}

class _QuestionPreviewCard extends StatelessWidget {
  const _QuestionPreviewCard({required this.number, required this.question});

  final int number;
  final Map<String, dynamic> question;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = (question['type'] ?? question['question_type'] ?? '')
        .toString();
    final prompt = (question['prompt'] ?? question['question_text'] ?? '')
        .toString();
    final marks = question['marks']?.toString() ?? '0';
    final guide =
        (question['marking_guide'] ??
                question['correct_answer'] ??
                question['correct_answers'] ??
                '')
            .toString();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: 'Question $number'),
              _MiniPill(label: _label(type)),
              _MiniPill(label: '$marks marks'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prompt.isEmpty ? 'No question text provided.' : prompt,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (guide.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Guide: $guide',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});

  final String text;
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
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Could not load question papers',
            style: TextStyle(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(message, style: TextStyle(color: scheme.onErrorContainer)),
          const SizedBox(height: 10),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: Text('No question papers found for this view.')),
    );
  }
}

String _label(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

String _levelFromCourse(String code) {
  final digits = RegExp(r'\d+').firstMatch(code)?.group(0) ?? '';
  if (digits.startsWith('1')) return '100 Level';
  if (digits.startsWith('2')) return '200 Level';
  if (digits.startsWith('3')) return '300 Level';
  if (digits.startsWith('4')) return '400 Level';
  if (digits.startsWith('5')) return '500 Level';
  return 'Undergraduate';
}

String _facultyFromCourse(String code) {
  final upper = code.toUpperCase();
  if (upper.startsWith('CSC') || upper.startsWith('SEN')) {
    return 'Faculty of Computing';
  }
  if (upper.startsWith('GST')) return 'General Studies Unit';
  return 'Faculty';
}

String _departmentFromCourse(String code) {
  final upper = code.toUpperCase();
  if (upper.startsWith('CSC')) return 'Department of Computer Science';
  if (upper.startsWith('SEN')) return 'Department of Software Engineering';
  if (upper.startsWith('GST')) return 'General Studies';
  return 'Department';
}
