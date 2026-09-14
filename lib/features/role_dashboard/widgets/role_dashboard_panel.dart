import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../data/role_dashboard_api.dart';

class RoleDashboardPanel extends StatefulWidget {
  const RoleDashboardPanel({super.key});

  @override
  State<RoleDashboardPanel> createState() => _RoleDashboardPanelState();
}

class _RoleDashboardPanelState extends State<RoleDashboardPanel> {
  late final RoleDashboardApi _api;
  late Future<RoleDashboardData> _future;
  bool _busy = false;

  String get _role {
    final session = AuthSession.instance.session;
    if (session == null) return 'lecturer';
    if (session.primaryRole.isNotEmpty) return session.primaryRole;
    if (session.roles.isNotEmpty) return session.roles.first;
    return 'lecturer';
  }

  bool get _isLecturer => _role == 'lecturer';

  @override
  void initState() {
    super.initState();
    _api = RoleDashboardApi();
    _future = _api.fetchForRole(_role);
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  void _reload() => setState(() => _future = _api.fetchForRole(_role));

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action completed')));
      _reload();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconForRole(_role), color: scheme.primary),
                    const SizedBox(width: 10),
                    Text('My role dashboard', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    if (_isLecturer) ...[
                      FilledButton.icon(onPressed: _busy ? null : _openAssignmentForm, icon: const Icon(Icons.assignment_add), label: const Text('New assignment')),
                      FilledButton.icon(onPressed: _busy ? null : _openCAForm, icon: const Icon(Icons.fact_check_outlined), label: const Text('Submit CA')),
                      FilledButton.icon(onPressed: _busy ? null : _openMarkedScriptsForm, icon: const Icon(Icons.task_alt_outlined), label: const Text('Submit scripts')),
                    ],
                    OutlinedButton.icon(onPressed: _busy ? null : _reload, icon: const Icon(Icons.refresh_outlined), label: const Text('Refresh')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<RoleDashboardData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return _RoleError(message: snapshot.error.toString(), onRetry: _reload);
                }
                final data = snapshot.data;
                if (data == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 14),
                    for (final section in data.sections) ...[
                      _RoleSection(section: section, busy: _busy, onAction: _handleItemAction),
                      const SizedBox(height: 14),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleItemAction(RoleDashboardSection section, RoleDashboardItem item, String action) async {
    final needsFeedback = action.contains('return') || action == 'approve' || action == 'accepted';
    final feedback = needsFeedback ? await _askFeedback(action) : '';
    if (feedback == null) return;

    await _runAction(() async {
      switch (section.kind) {
        case 'exam_assessment':
          await _api.examOfficerAssessmentAction(item.id, action, feedback);
          break;
        case 'moderator_assessment':
          await _api.moderatorAssessmentAction(item.id, action, feedback);
          break;
        case 'ca_review':
          await _api.reviewCA(item.id, action, feedback);
          break;
        case 'script_review':
          await _api.reviewMarkedScript(item.id, action, feedback);
          break;
      }
    });
  }

  Future<String?> _askFeedback(String action) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action.contains('return') ? 'Return with feedback' : 'Confirm action'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Comment or feedback'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Continue')),
        ],
      ),
    );
  }

  Future<void> _openAssignmentForm() async {
    final payload = await showDialog<Map<String, dynamic>>(context: context, builder: (context) => const _AssignmentFormDialog());
    if (payload == null) return;
    await _runAction(() => _api.createAssignment(payload));
  }

  Future<void> _openCAForm() async {
    final payload = await showDialog<Map<String, dynamic>>(context: context, builder: (context) => const _CAFormDialog());
    if (payload == null) return;
    await _runAction(() => _api.submitCA(payload));
  }

  Future<void> _openMarkedScriptsForm() async {
    final payload = await showDialog<Map<String, dynamic>>(context: context, builder: (context) => const _MarkedScriptsFormDialog());
    if (payload == null) return;
    await _runAction(() => _api.submitMarkedScripts(payload));
  }

  IconData _iconForRole(String role) {
    switch (role) {
      case 'exam_officer':
        return Icons.assignment_turned_in_outlined;
      case 'moderator':
        return Icons.rule_folder_outlined;
      case 'hod':
        return Icons.account_tree_outlined;
      case 'dlc_director':
      case 'admin':
        return Icons.cast_for_education_outlined;
      default:
        return Icons.school_outlined;
    }
  }
}

class _RoleSection extends StatelessWidget {
  const _RoleSection({required this.section, required this.busy, required this.onAction});

  final RoleDashboardSection section;
  final bool busy;
  final Future<void> Function(RoleDashboardSection section, RoleDashboardItem item, String action) onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: scheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${section.title} (${section.items.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (section.items.isEmpty)
            Text('No live records returned yet.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))
          else
            for (final item in section.items.take(6)) _RoleItemTile(section: section, item: item, busy: busy, onAction: onAction),
        ],
      ),
    );
  }
}

class _RoleItemTile extends StatelessWidget {
  const _RoleItemTile({required this.section, required this.item, required this.busy, required this.onAction});

  final RoleDashboardSection section;
  final RoleDashboardItem item;
  final bool busy;
  final Future<void> Function(RoleDashboardSection section, RoleDashboardItem item, String action) onAction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: item.subtitle.isEmpty ? null : Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Chip(label: Text(item.status), visualDensity: VisualDensity.compact),
          ..._actionsFor(section.kind).map((action) => TextButton(onPressed: busy || item.id.isEmpty ? null : () => onAction(section, item, action.value), child: Text(action.label))),
        ],
      ),
    );
  }

  List<_ActionSpec> _actionsFor(String kind) {
    switch (kind) {
      case 'exam_assessment':
        return const [
          _ActionSpec('send-to-moderator', 'Send'),
          _ActionSpec('approve', 'Approve'),
          _ActionSpec('return-to-lecturer', 'Return'),
        ];
      case 'moderator_assessment':
        return const [_ActionSpec('approve', 'Approve'), _ActionSpec('return', 'Return')];
      case 'ca_review':
      case 'script_review':
        return const [_ActionSpec('accepted', 'Accept'), _ActionSpec('returned', 'Return')];
      default:
        return const [];
    }
  }
}

class _ActionSpec {
  const _ActionSpec(this.value, this.label);
  final String value;
  final String label;
}

class _AssignmentFormDialog extends StatefulWidget {
  const _AssignmentFormDialog();

  @override
  State<_AssignmentFormDialog> createState() => _AssignmentFormDialogState();
}

class _AssignmentFormDialogState extends State<_AssignmentFormDialog> {
  final _courseId = TextEditingController();
  final _title = TextEditingController();
  final _instructions = TextEditingController();
  final _marks = TextEditingController(text: '10');
  bool _feedback = true;

  @override
  void dispose() {
    _courseId.dispose();
    _title.dispose();
    _instructions.dispose();
    _marks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormDialogScaffold(
      title: 'Create assignment',
      children: [
        TextField(controller: _courseId, decoration: const InputDecoration(labelText: 'Course ID')),
        const SizedBox(height: 10),
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Assignment title')),
        const SizedBox(height: 10),
        TextField(controller: _instructions, minLines: 3, maxLines: 4, decoration: const InputDecoration(labelText: 'Instructions')),
        const SizedBox(height: 10),
        TextField(controller: _marks, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total marks')),
        SwitchListTile(value: _feedback, onChanged: (value) => setState(() => _feedback = value), title: const Text('Allow feedback to students')),
      ],
      onSubmit: () => {
        'course_id': _courseId.text.trim(),
        'title': _title.text.trim(),
        'instructions': _instructions.text.trim(),
        'total_marks': double.tryParse(_marks.text) ?? 0,
        'feedback_enabled': _feedback,
      },
    );
  }
}

class _CAFormDialog extends StatefulWidget {
  const _CAFormDialog();

  @override
  State<_CAFormDialog> createState() => _CAFormDialogState();
}

class _CAFormDialogState extends State<_CAFormDialog> {
  final _courseId = TextEditingController();
  final _session = TextEditingController(text: '2025/2026');
  final _semester = TextEditingController(text: 'first');
  final _students = TextEditingController();
  final _marks = TextEditingController(text: '40');
  final _fileUrl = TextEditingController();
  final _summary = TextEditingController();

  @override
  void dispose() {
    _courseId.dispose();
    _session.dispose();
    _semester.dispose();
    _students.dispose();
    _marks.dispose();
    _fileUrl.dispose();
    _summary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormDialogScaffold(
      title: 'Submit CA',
      children: [
        TextField(controller: _courseId, decoration: const InputDecoration(labelText: 'Course ID')),
        const SizedBox(height: 10),
        TextField(controller: _session, decoration: const InputDecoration(labelText: 'Academic session')),
        const SizedBox(height: 10),
        TextField(controller: _semester, decoration: const InputDecoration(labelText: 'Semester')),
        const SizedBox(height: 10),
        TextField(controller: _students, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total students')),
        const SizedBox(height: 10),
        TextField(controller: _marks, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total marks')),
        const SizedBox(height: 10),
        TextField(controller: _fileUrl, decoration: const InputDecoration(labelText: 'File URL')),
        const SizedBox(height: 10),
        TextField(controller: _summary, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Summary')),
      ],
      onSubmit: () => {
        'course_id': _courseId.text.trim(),
        'academic_session': _session.text.trim(),
        'semester': _semester.text.trim(),
        'total_students': int.tryParse(_students.text) ?? 0,
        'total_marks': double.tryParse(_marks.text) ?? 0,
        'file_url': _fileUrl.text.trim(),
        'summary': _summary.text.trim(),
      },
    );
  }
}

class _MarkedScriptsFormDialog extends StatefulWidget {
  const _MarkedScriptsFormDialog();

  @override
  State<_MarkedScriptsFormDialog> createState() => _MarkedScriptsFormDialogState();
}

class _MarkedScriptsFormDialogState extends State<_MarkedScriptsFormDialog> {
  final _assessmentId = TextEditingController();
  final _courseId = TextEditingController();
  final _session = TextEditingController(text: '2025/2026');
  final _semester = TextEditingController(text: 'first');
  final _count = TextEditingController();
  final _fileUrl = TextEditingController();
  final _summary = TextEditingController();

  @override
  void dispose() {
    _assessmentId.dispose();
    _courseId.dispose();
    _session.dispose();
    _semester.dispose();
    _count.dispose();
    _fileUrl.dispose();
    _summary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormDialogScaffold(
      title: 'Submit marked scripts',
      children: [
        TextField(controller: _assessmentId, decoration: const InputDecoration(labelText: 'Assessment ID')),
        const SizedBox(height: 10),
        TextField(controller: _courseId, decoration: const InputDecoration(labelText: 'Course ID')),
        const SizedBox(height: 10),
        TextField(controller: _session, decoration: const InputDecoration(labelText: 'Academic session')),
        const SizedBox(height: 10),
        TextField(controller: _semester, decoration: const InputDecoration(labelText: 'Semester')),
        const SizedBox(height: 10),
        TextField(controller: _count, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Marked count')),
        const SizedBox(height: 10),
        TextField(controller: _fileUrl, decoration: const InputDecoration(labelText: 'File URL')),
        const SizedBox(height: 10),
        TextField(controller: _summary, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Summary')),
      ],
      onSubmit: () => {
        'assessment_id': _assessmentId.text.trim(),
        'course_id': _courseId.text.trim(),
        'academic_session': _session.text.trim(),
        'semester': _semester.text.trim(),
        'marked_count': int.tryParse(_count.text) ?? 0,
        'file_url': _fileUrl.text.trim(),
        'summary': _summary.text.trim(),
      },
    );
  }
}

class _FormDialogScaffold extends StatelessWidget {
  const _FormDialogScaffold({required this.title, required this.children, required this.onSubmit});

  final String title;
  final List<Widget> children;
  final Map<String, dynamic> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(width: 560, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: children))),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(onSubmit()), child: const Text('Submit')),
      ],
    );
  }
}

class _RoleError extends StatelessWidget {
  const _RoleError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Theme.of(context).colorScheme.errorContainer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Role dashboard issue', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_outlined), label: const Text('Try again')),
        ],
      ),
    );
  }
}
