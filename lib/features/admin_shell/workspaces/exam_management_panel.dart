import 'package:flutter/material.dart';

import '../../exam_workflow/data/exam_workflow_api.dart';

class ExamManagementPanel extends StatefulWidget {
  const ExamManagementPanel({super.key});

  @override
  State<ExamManagementPanel> createState() => _ExamManagementPanelState();
}

class _ExamManagementPanelState extends State<ExamManagementPanel> {
  final ExamWorkflowApi _api = ExamWorkflowApi();

  bool _loading = true;
  String? _error;
  String _filter = 'all';
  int? _busyExamId;
  List<ExamWorkflowItem> _items = const [];

  @override
  void initState() {
    super.initState();
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

  List<ExamWorkflowItem> get _visibleItems {
    if (_filter == 'all') return _items;
    return _items.where((item) => item.status == _filter).toList();
  }

  Future<void> _runAction(int examId, Future<void> Function() action) async {
    setState(() => _busyExamId = examId);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam workflow updated successfully.')),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _busyExamId = null);
    }
  }

  Future<String?> _commentDialog({
    required String title,
    required String hint,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
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
        );
      },
    ).whenComplete(controller.dispose);
  }

  Future<void> _scheduleDialog(ExamWorkflowItem item) async {
    final start = DateTime.now().toUtc().add(const Duration(days: 3));
    final end = start.add(const Duration(hours: 2));
    final startController = TextEditingController(text: start.toIso8601String());
    final endController = TextEditingController(text: end.toIso8601String());
    final durationController = TextEditingController(
      text: item.durationMinutes > 0 ? item.durationMinutes.toString() : '120',
    );
    final venueController = TextEditingController(
      text: item.venue.isNotEmpty ? item.venue : 'Remote Proctored Exam',
    );
    final commentController = TextEditingController(text: 'Exam scheduled for student access.');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Schedule exam'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorText != null) ...[
                      Text(errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: startController,
                      decoration: const InputDecoration(
                        labelText: 'Start time',
                        helperText: 'Use ISO time, for example 2026-06-26T09:00:00Z',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: endController,
                      decoration: const InputDecoration(
                        labelText: 'End time',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration in minutes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: venueController,
                      decoration: const InputDecoration(
                        labelText: 'Exam location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: commentController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Schedule note',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final startAt = DateTime.tryParse(startController.text.trim());
                    final endAt = DateTime.tryParse(endController.text.trim());
                    final duration = int.tryParse(durationController.text.trim());

                    if (startAt == null || endAt == null || duration == null || !endAt.isAfter(startAt)) {
                      setDialogState(() => errorText = 'Please enter valid exam time and duration.');
                      return;
                    }

                    Navigator.pop(context, {
                      'start_time': startAt,
                      'end_time': endAt,
                      'duration_minutes': duration,
                      'venue': venueController.text.trim(),
                      'comment': commentController.text.trim(),
                    });
                  },
                  child: const Text('Schedule'),
                ),
              ],
            );
          },
        );
      },
    );

    startController.dispose();
    endController.dispose();
    durationController.dispose();
    venueController.dispose();
    commentController.dispose();

    if (result == null) return;

    await _runAction(
      item.id,
      () => _api.scheduleExam(
        examId: item.id,
        startTime: result['start_time'] as DateTime,
        endTime: result['end_time'] as DateTime,
        durationMinutes: result['duration_minutes'] as int,
        venue: result['venue']?.toString() ?? '',
        comment: result['comment']?.toString() ?? '',
      ),
    );
  }

  Future<void> _withComment(
    ExamWorkflowItem item, {
    required String title,
    required String hint,
    required Future<void> Function(String comment) action,
  }) async {
    final comment = await _commentDialog(title: title, hint: hint);
    if (comment == null) return;
    await _runAction(item.id, () => action(comment));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = _visibleItems;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rule_folder_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Examination Workflow',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
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
            const SizedBox(height: 8),
            Text(
              'Lecturer question papers, exam officer review, moderator notes, corrections and scheduling.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'All ${_items.length}',
                  selected: _filter == 'all',
                  onSelected: () => setState(() => _filter = 'all'),
                ),
                for (final status in [
                  'draft',
                  'officer_review',
                  'moderator_review',
                  'moderated',
                  'lecturer_correction',
                  'scheduled',
                  'released',
                ])
                  _FilterChip(
                    label: '${_statusLabel(status)} ${_items.where((e) => e.status == status).length}',
                    selected: _filter == status,
                    onSelected: () => setState(() => _filter = status),
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
                _ExamWorkflowTile(
                  item: item,
                  busy: _busyExamId == item.id,
                  onSubmitToOfficer: () => _withComment(
                    item,
                    title: 'Submit to Exam Officer',
                    hint: 'Add a short note for the exam officer.',
                    action: (comment) => _api.submitToOfficer(item.id, comment),
                  ),
                  onSendToModerator: () => _withComment(
                    item,
                    title: 'Send to Moderator',
                    hint: 'Add the review instruction for the moderator.',
                    action: (comment) => _api.sendToModerator(item.id, comment),
                  ),
                  onModeratorReturn: () => _withComment(
                    item,
                    title: 'Return with Notes',
                    hint: 'Enter moderator note for the exam officer.',
                    action: (comment) => _api.moderatorReturn(item.id, comment),
                  ),
                  onSendBackToLecturer: () => _withComment(
                    item,
                    title: 'Send Back to Lecturer',
                    hint: 'Explain the correction needed.',
                    action: (comment) => _api.sendBackToLecturer(item.id, comment),
                  ),
                  onSchedule: () => _scheduleDialog(item),
                  onRelease: () => _withComment(
                    item,
                    title: 'Release Exam',
                    hint: 'Add release note.',
                    action: (comment) => _api.releaseExam(item.id, comment),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}


String _humanLabel(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

class _ExamWorkflowTile extends StatelessWidget {
  const _ExamWorkflowTile({
    required this.item,
    required this.busy,
    required this.onSubmitToOfficer,
    required this.onSendToModerator,
    required this.onModeratorReturn,
    required this.onSendBackToLecturer,
    required this.onSchedule,
    required this.onRelease,
  });

  final ExamWorkflowItem item;
  final bool busy;
  final VoidCallback onSubmitToOfficer;
  final VoidCallback onSendToModerator;
  final VoidCallback onModeratorReturn;
  final VoidCallback onSendBackToLecturer;
  final VoidCallback onSchedule;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(scheme, item.status);

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
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.courseLabel.isEmpty ? 'Course not shown' : item.courseLabel,
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
              _MiniPill(label: item.deliveryLabel),
              _MiniPill(label: item.scheduleLabel),
              _MiniPill(label: '${item.durationMinutes} minutes'),
              _MiniPill(label: '${item.questionCount} questions'),
              if (item.venue.isNotEmpty) _MiniPill(label: item.venue),
            ],
          ),
          if (item.questionTypes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.questionTypes
                  .map((type) => _MiniPill(label: _humanLabel(type)))
                  .toList(),
            ),
          ],
          if (item.workflowNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Review notes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            for (final note in item.workflowNotes.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${note.actionLabel}: ${note.comment.isEmpty ? 'No note added' : note.comment}',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
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
                if (item.status == 'draft' || item.status == 'lecturer_correction')
                  OutlinedButton.icon(
                    onPressed: onSubmitToOfficer,
                    icon: const Icon(Icons.outbox_outlined),
                    label: const Text('Submit to Exam Officer'),
                  ),
                if (item.status == 'officer_review')
                  FilledButton.icon(
                    onPressed: onSendToModerator,
                    icon: const Icon(Icons.forward_to_inbox_outlined),
                    label: const Text('Send to Moderator'),
                  ),
                if (item.status == 'moderator_review')
                  FilledButton.icon(
                    onPressed: onModeratorReturn,
                    icon: const Icon(Icons.assignment_return_outlined),
                    label: const Text('Return with Notes'),
                  ),
                if (item.status == 'moderated' || item.status == 'officer_review')
                  OutlinedButton.icon(
                    onPressed: onSendBackToLecturer,
                    icon: const Icon(Icons.reply_all_outlined),
                    label: const Text('Send Back to Lecturer'),
                  ),
                if (item.status == 'moderated' || item.status == 'officer_review' || item.status == 'lecturer_correction')
                  FilledButton.icon(
                    onPressed: onSchedule,
                    icon: const Icon(Icons.event_available_outlined),
                    label: const Text('Schedule Exam'),
                  ),
                if (item.status == 'scheduled')
                  FilledButton.icon(
                    onPressed: onRelease,
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Release to Students'),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Color _statusColor(ColorScheme scheme, String status) {
    switch (status) {
      case 'released':
      case 'scheduled':
        return scheme.primary;
      case 'moderator_review':
      case 'lecturer_correction':
        return scheme.secondary;
      case 'cancelled':
        return scheme.error;
      default:
        return scheme.tertiary;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Could not load exams', style: TextStyle(color: scheme.onErrorContainer, fontWeight: FontWeight.w900)),
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
      child: Center(
        child: Text('No exams found for this view.'),
      ),
    );
  }
}
