import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../data/review_evidence_api.dart';

class ReviewEvidencePanel extends StatefulWidget {
  const ReviewEvidencePanel({super.key});

  @override
  State<ReviewEvidencePanel> createState() => _ReviewEvidencePanelState();
}

class _ReviewEvidencePanelState extends State<ReviewEvidencePanel> {
  late final ReviewEvidenceApi _api;
  final TextEditingController _courseFilterController = TextEditingController();
  final TextEditingController _attemptFilterController =
      TextEditingController();

  List<ReviewEvidenceCase> _cases = const <ReviewEvidenceCase>[];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'all';
  String _attentionFilter = 'all';
  String? _busyCaseId;
  String? _busyAction;

  @override
  void initState() {
    super.initState();
    _api = ReviewEvidenceApi();
    _loadCases();
  }

  @override
  void dispose() {
    _courseFilterController.dispose();
    _attemptFilterController.dispose();
    _api.close();
    super.dispose();
  }

  Future<void> _loadCases() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cases = await _api.listCases(
        status: _statusFilter,
        attentionLevel: _attentionFilter,
        assignedRole: _roleFilter,
        courseCode: _courseFilterController.text,
        attemptId: _attemptFilterController.text,
      );
      if (!mounted) return;
      setState(() {
        _cases = cases;
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

  String? get _roleFilter {
    final role =
        AuthSession.instance.session?.primaryRole.trim().toLowerCase() ?? '';
    if (role.isEmpty ||
        role == 'admin' ||
        role == 'super_admin' ||
        role == 'superadmin' ||
        role == 'system_admin' ||
        role == 'dlc_director') {
      return null;
    }
    return role;
  }

  Future<void> _takeAction(ReviewEvidenceCase item, String action) async {
    final comment = await _commentDialog(action: action, item: item);
    if (comment == null) return;

    setState(() {
      _busyCaseId = item.id;
      _busyAction = action;
      _error = null;
    });

    try {
      final session = AuthSession.instance.session;
      final updated = await _api.takeAction(
        caseId: item.id,
        action: action,
        actorId: session?.staffId,
        actorRole: session?.primaryRole,
        comment: comment,
      );
      if (!mounted) return;
      setState(() {
        final index = _cases.indexWhere((candidate) => candidate.id == item.id);
        if (index >= 0) {
          final copy = List<ReviewEvidenceCase>.from(_cases);
          copy[index] = updated;
          _cases = copy;
        }
        _busyCaseId = null;
        _busyAction = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _busyCaseId = null;
        _busyAction = null;
      });
    }
  }

  Future<String?> _commentDialog({
    required String action,
    required ReviewEvidenceCase item,
  }) async {
    final controller = TextEditingController();
    final label = reviewLabel(action);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(label),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.studentLabel),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Reviewer comment',
                  hintText: 'Add the reason for this review action.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save action'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final waiting = _cases
        .where((item) => item.status == 'awaiting_review')
        .length;
    final evidenceCount = _cases.fold<int>(
      0,
      (sum, item) => sum + item.evidenceFiles.length,
    );
    final cleared = _cases
        .where(
          (item) =>
              item.status == 'cleared' ||
              item.status == 'marked_incorrect_alert',
        )
        .length;
    final sentToHod = _cases
        .where((item) => item.status == 'sent_to_hod')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Evidence',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Evidence files, activity timelines, and human review actions for sessions that need attention.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _loadCases,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              title: 'Cases waiting',
              value: '$waiting',
              icon: Icons.fact_check_outlined,
            ),
            _SummaryCard(
              title: 'Evidence files',
              value: '$evidenceCount',
              icon: Icons.folder_copy_outlined,
            ),
            _SummaryCard(
              title: 'Cleared cases',
              value: '$cleared',
              icon: Icons.verified_outlined,
            ),
            _SummaryCard(
              title: 'Sent to HoD',
              value: '$sentToHod',
              icon: Icons.account_tree_outlined,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _FilterBar(
          status: _statusFilter,
          attentionLevel: _attentionFilter,
          courseController: _courseFilterController,
          attemptController: _attemptFilterController,
          onStatusChanged: (value) {
            setState(() => _statusFilter = value ?? 'all');
            _loadCases();
          },
          onAttentionChanged: (value) {
            setState(() => _attentionFilter = value ?? 'all');
            _loadCases();
          },
          onApply: _loadCases,
          onClear: () {
            setState(() {
              _statusFilter = 'all';
              _attentionFilter = 'all';
              _courseFilterController.clear();
              _attemptFilterController.clear();
            });
            _loadCases();
          },
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          _ErrorBanner(message: _error!, onRetry: _loadCases),
        ],
        const SizedBox(height: 18),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_cases.isEmpty)
          const _EmptyState()
        else
          for (final item in _cases) ...[
            _ReviewCaseCard(
              item: item,
              busyAction: _busyCaseId == item.id ? _busyAction : null,
              onAction: (action) => _takeAction(item, action),
            ),
            const SizedBox(height: 14),
          ],
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.status,
    required this.attentionLevel,
    required this.courseController,
    required this.attemptController,
    required this.onStatusChanged,
    required this.onAttentionChanged,
    required this.onApply,
    required this.onClear,
  });

  final String status;
  final String attentionLevel;
  final TextEditingController courseController;
  final TextEditingController attemptController;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onAttentionChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 230,
              child: DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Case status'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All statuses')),
                  DropdownMenuItem(
                    value: 'awaiting_review',
                    child: Text('Awaiting review'),
                  ),
                  DropdownMenuItem(
                    value: 'sent_to_hod',
                    child: Text('Sent to HoD'),
                  ),
                  DropdownMenuItem(
                    value: 'requires_student_explanation',
                    child: Text('Requires explanation'),
                  ),
                  DropdownMenuItem(value: 'cleared', child: Text('Cleared')),
                  DropdownMenuItem(
                    value: 'marked_incorrect_alert',
                    child: Text('Incorrect alert'),
                  ),
                  DropdownMenuItem(
                    value: 'finalized',
                    child: Text('Finalized'),
                  ),
                ],
                onChanged: onStatusChanged,
              ),
            ),
            SizedBox(
              width: 250,
              child: DropdownButtonFormField<String>(
                initialValue: attentionLevel,
                decoration: const InputDecoration(labelText: 'Attention level'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All levels')),
                  DropdownMenuItem(
                    value: 'medium_attention_required',
                    child: Text('Medium attention required'),
                  ),
                  DropdownMenuItem(
                    value: 'high_attention_required',
                    child: Text('High attention required'),
                  ),
                  DropdownMenuItem(
                    value: 'urgent_review_required',
                    child: Text('Urgent review required'),
                  ),
                ],
                onChanged: onAttentionChanged,
              ),
            ),
            SizedBox(
              width: 170,
              child: TextField(
                controller: courseController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Course code',
                  hintText: 'CSC204',
                ),
                onSubmitted: (_) => onApply(),
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: attemptController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Attempt ID',
                  hintText: 'attempt-demo-001',
                ),
                onSubmitted: (_) => onApply(),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.search_outlined),
              label: const Text('Apply'),
            ),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_outlined),
              label: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(title),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCaseCard extends StatelessWidget {
  const _ReviewCaseCard({
    required this.item,
    required this.busyAction,
    required this.onAction,
  });

  final ReviewEvidenceCase item;
  final String? busyAction;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final busy = busyAction != null;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  item.studentName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                Chip(label: Text(reviewLabel(item.attentionLevel))),
                Chip(
                  avatar: const Icon(Icons.hourglass_bottom_outlined, size: 18),
                  label: Text(reviewLabel(item.status)),
                ),
                if (item.riskPoints > 0)
                  Chip(label: Text('${item.riskPoints} alert points')),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${item.matricNumber.isEmpty ? 'No matric number' : item.matricNumber} • ${item.courseLabel}',
            ),
            const SizedBox(height: 4),
            Text(
              item.assessmentLabel,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(item.reviewSummary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final evidence = _EvidenceList(files: item.evidenceFiles);
                final timeline = _TimelineList(items: item.timeline);
                if (compact) {
                  return Column(
                    children: [evidence, const SizedBox(height: 14), timeline],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: evidence),
                    const SizedBox(width: 14),
                    Expanded(child: timeline),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ActionButton(
                  label: 'Incorrect alert',
                  icon: Icons.report_off_outlined,
                  action: 'mark-incorrect-alert',
                  busyAction: busyAction,
                  enabled: !busy,
                  onAction: onAction,
                ),
                _ActionButton(
                  label: 'Clear case',
                  icon: Icons.verified_outlined,
                  action: 'clear',
                  busyAction: busyAction,
                  enabled: !busy,
                  onAction: onAction,
                ),
                _ActionButton(
                  label: 'Send to HoD',
                  icon: Icons.account_tree_outlined,
                  action: 'send-to-hod',
                  busyAction: busyAction,
                  enabled: !busy,
                  onAction: onAction,
                ),
                _ActionButton(
                  label: 'Request explanation',
                  icon: Icons.chat_outlined,
                  action: 'request-student-explanation',
                  busyAction: busyAction,
                  enabled: !busy,
                  onAction: onAction,
                ),
                _ActionButton(
                  label: 'Finalize',
                  icon: Icons.task_alt_outlined,
                  action: 'finalize',
                  busyAction: busyAction,
                  enabled: !busy,
                  onAction: onAction,
                ),
              ],
            ),
            if (item.actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _ActionHistory(actions: item.actions),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.action,
    required this.busyAction,
    required this.enabled,
    required this.onAction,
  });

  final String label;
  final IconData icon;
  final String action;
  final String? busyAction;
  final bool enabled;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final busy = busyAction == action;
    return OutlinedButton.icon(
      onPressed: enabled ? () => onAction(action) : null,
      icon: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(busy ? 'Saving...' : label),
    );
  }
}

class _EvidenceList extends StatelessWidget {
  const _EvidenceList({required this.files});

  final List<ReviewEvidenceFile> files;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Evidence Files',
      icon: Icons.folder_copy_outlined,
      children: [
        if (files.isEmpty)
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline),
            title: Text('No evidence files attached yet'),
            subtitle: Text(
              'Activity records may still be available in the timeline.',
            ),
          )
        else
          for (final file in files)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(file.title),
              subtitle: Text(
                '${reviewLabel(file.evidenceType)} • ${file.detail.isEmpty ? 'Record saved for review.' : file.detail}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    reviewLabel(file.status),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    file.sourceKey.isEmpty ? 'review_record' : file.sourceKey,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.items});

  final List<ReviewTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Activity Timeline',
      icon: Icons.timeline_outlined,
      children: [
        if (items.isEmpty)
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline),
            title: Text('No timeline records attached yet'),
            subtitle: Text('New activity records will appear here after sync.'),
          )
        else
          for (var index = 0; index < items.length; index++)
            _TimelineEntry(index: index, item: items[index]),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.index, required this.item});

  final int index;
  final ReviewTimelineItem item;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (item.eventType.isNotEmpty) reviewLabel(item.eventType),
      if (item.alertLevel.isNotEmpty) reviewLabel(item.alertLevel),
      if (item.eventTime != null) _formatDate(item.eventTime!),
      if (item.modelLabel.isNotEmpty) item.modelLabel,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(child: Text('${index + 1}')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.message),
                const SizedBox(height: 3),
                Text(
                  details.join(' • '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (item.signalGroups.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.signalGroups
                        .map(
                          (group) => Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(reviewLabel(group)),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
                if (item.reasons.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  for (final reason in item.reasons)
                    Text(
                      '• $reason',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
                if (item.observableBehaviourOnly)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Observable behaviour only — human review required.',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionHistory extends StatelessWidget {
  const _ActionHistory({required this.actions});

  final List<ReviewAction> actions;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Review Actions',
      icon: Icons.history_outlined,
      children: [
        for (final action in actions)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(reviewLabel(action.action)),
            subtitle: Text(
              [
                if (action.actorRole.isNotEmpty) reviewLabel(action.actorRole),
                if (action.comment.isNotEmpty) action.comment,
                if (action.createdAt != null) _formatDate(action.createdAt!),
              ].join(' • '),
            ),
          ),
      ],
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

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
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.verified_outlined, size: 42, color: scheme.primary),
              const SizedBox(height: 10),
              Text(
                'No review cases found',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Cases will appear here when student exam activity records are saved for human review.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
