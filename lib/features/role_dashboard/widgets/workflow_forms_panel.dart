import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../data/role_dashboard_api.dart';

class WorkflowFormsPanel extends StatefulWidget {
  const WorkflowFormsPanel({super.key});

  @override
  State<WorkflowFormsPanel> createState() => _WorkflowFormsPanelState();
}

class _WorkflowFormsPanelState extends State<WorkflowFormsPanel> {
  late final RoleDashboardApi _api;
  late final Future<_FormReferences> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _api = RoleDashboardApi();
    _future = _loadReferences();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<_FormReferences> _loadReferences() async {
    final results = await Future.wait<dynamic>([
      _api.fetchCourses(),
      _api.fetchAssessments(),
    ]);
    return _FormReferences(
      courses: results[0] as List<ReferenceOption>,
      assessments: results[1] as List<ReferenceOption>,
    );
  }

  Future<String> _pickAndUpload(String category) async {
    final picked = await FilePicker.platform.pickFiles(withData: true);
    if (picked == null || picked.files.isEmpty) return '';
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) throw const ApiException('Could not read selected file');
    return _api.uploadFile(
      bytes: bytes,
      fileName: file.name,
      category: category,
    );
  }

  Future<void> _submit(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Submitted successfully')));
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
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
        child: FutureBuilder<_FormReferences>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final refs =
                snapshot.data ??
                const _FormReferences(courses: [], assessments: []);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.dynamic_form_outlined, color: scheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Smart lecturer forms',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Use live course and assessment references from the backend. Uploads are saved through /api/uploads.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FormActionCard(
                      icon: Icons.assignment_add,
                      title: 'Create assignment',
                      subtitle: 'Pick course, add marks and instructions.',
                      onTap: _busy
                          ? null
                          : () async {
                              final payload =
                                  await showDialog<Map<String, dynamic>>(
                                    context: context,
                                    builder: (_) => _AssignmentDialog(
                                      courses: refs.courses,
                                    ),
                                  );
                              if (payload != null) {
                                await _submit(
                                  () => _api.createAssignment(payload),
                                );
                              }
                            },
                    ),
                    _FormActionCard(
                      icon: Icons.fact_check_outlined,
                      title: 'Submit CA',
                      subtitle: 'Pick course and upload CA sheet.',
                      onTap: _busy
                          ? null
                          : () async {
                              final payload =
                                  await showDialog<Map<String, dynamic>>(
                                    context: context,
                                    builder: (_) => _CADialog(
                                      courses: refs.courses,
                                      onUpload: () => _pickAndUpload('ca'),
                                    ),
                                  );
                              if (payload != null) {
                                await _submit(() => _api.submitCA(payload));
                              }
                            },
                    ),
                    _FormActionCard(
                      icon: Icons.task_alt_outlined,
                      title: 'Submit marked scripts',
                      subtitle: 'Pick assessment, course, and upload scripts.',
                      onTap: _busy
                          ? null
                          : () async {
                              final payload =
                                  await showDialog<Map<String, dynamic>>(
                                    context: context,
                                    builder: (_) => _ScriptsDialog(
                                      courses: refs.courses,
                                      assessments: refs.assessments,
                                      onUpload: () =>
                                          _pickAndUpload('marked-scripts'),
                                    ),
                                  );
                              if (payload != null) {
                                await _submit(
                                  () => _api.submitMarkedScripts(payload),
                                );
                              }
                            },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FormReferences {
  const _FormReferences({required this.courses, required this.assessments});
  final List<ReferenceOption> courses;
  final List<ReferenceOption> assessments;
}

class _FormActionCard extends StatelessWidget {
  const _FormActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentDialog extends StatefulWidget {
  const _AssignmentDialog({required this.courses});
  final List<ReferenceOption> courses;

  @override
  State<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<_AssignmentDialog> {
  String? _courseId;
  final _fallbackCourse = TextEditingController();
  final _title = TextEditingController();
  final _instructions = TextEditingController();
  final _marks = TextEditingController(text: '10');
  bool _feedback = true;

  @override
  void dispose() {
    _fallbackCourse.dispose();
    _title.dispose();
    _instructions.dispose();
    _marks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DialogScaffold(
      title: 'Create assignment',
      children: [
        _ReferencePicker(
          label: 'Course',
          options: widget.courses,
          value: _courseId,
          fallbackController: _fallbackCourse,
          onChanged: (value) => setState(() => _courseId = value),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Assignment title'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _instructions,
          minLines: 3,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Instructions'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _marks,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Total marks'),
        ),
        SwitchListTile(
          value: _feedback,
          onChanged: (value) => setState(() => _feedback = value),
          title: const Text('Allow feedback to students'),
        ),
      ],
      onSubmit: () => {
        'course_id': _courseId ?? _fallbackCourse.text.trim(),
        'title': _title.text.trim(),
        'instructions': _instructions.text.trim(),
        'total_marks': double.tryParse(_marks.text) ?? 0,
        'feedback_enabled': _feedback,
      },
    );
  }
}

class _CADialog extends StatefulWidget {
  const _CADialog({required this.courses, required this.onUpload});
  final List<ReferenceOption> courses;
  final Future<String> Function() onUpload;

  @override
  State<_CADialog> createState() => _CADialogState();
}

class _CADialogState extends State<_CADialog> {
  String? _courseId;
  final _fallbackCourse = TextEditingController();
  final _session = TextEditingController(text: '2025/2026');
  final _semester = TextEditingController(text: 'first');
  final _students = TextEditingController();
  final _marks = TextEditingController(text: '40');
  final _fileUrl = TextEditingController();
  final _summary = TextEditingController();
  bool _uploading = false;

  @override
  void dispose() {
    _fallbackCourse.dispose();
    _session.dispose();
    _semester.dispose();
    _students.dispose();
    _marks.dispose();
    _fileUrl.dispose();
    _summary.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    setState(() => _uploading = true);
    try {
      final url = await widget.onUpload();
      if (url.isNotEmpty) _fileUrl.text = url;
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DialogScaffold(
      title: 'Submit CA',
      children: [
        _ReferencePicker(
          label: 'Course',
          options: widget.courses,
          value: _courseId,
          fallbackController: _fallbackCourse,
          onChanged: (value) => setState(() => _courseId = value),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _session,
          decoration: const InputDecoration(labelText: 'Academic session'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _semester,
          decoration: const InputDecoration(labelText: 'Semester'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _students,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Total students'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _marks,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Total marks'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fileUrl,
                decoration: const InputDecoration(labelText: 'File URL'),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _uploading ? null : _upload,
              icon: const Icon(Icons.upload_file),
              label: Text(_uploading ? 'Uploading...' : 'Upload'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _summary,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Summary'),
        ),
      ],
      onSubmit: () => {
        'course_id': _courseId ?? _fallbackCourse.text.trim(),
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

class _ScriptsDialog extends StatefulWidget {
  const _ScriptsDialog({
    required this.courses,
    required this.assessments,
    required this.onUpload,
  });
  final List<ReferenceOption> courses;
  final List<ReferenceOption> assessments;
  final Future<String> Function() onUpload;

  @override
  State<_ScriptsDialog> createState() => _ScriptsDialogState();
}

class _ScriptsDialogState extends State<_ScriptsDialog> {
  String? _courseId;
  String? _assessmentId;
  final _fallbackCourse = TextEditingController();
  final _fallbackAssessment = TextEditingController();
  final _session = TextEditingController(text: '2025/2026');
  final _semester = TextEditingController(text: 'first');
  final _count = TextEditingController();
  final _fileUrl = TextEditingController();
  final _summary = TextEditingController();
  bool _uploading = false;

  @override
  void dispose() {
    _fallbackCourse.dispose();
    _fallbackAssessment.dispose();
    _session.dispose();
    _semester.dispose();
    _count.dispose();
    _fileUrl.dispose();
    _summary.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    setState(() => _uploading = true);
    try {
      final url = await widget.onUpload();
      if (url.isNotEmpty) _fileUrl.text = url;
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DialogScaffold(
      title: 'Submit marked scripts',
      children: [
        _ReferencePicker(
          label: 'Assessment',
          options: widget.assessments,
          value: _assessmentId,
          fallbackController: _fallbackAssessment,
          onChanged: (value) => setState(() => _assessmentId = value),
        ),
        const SizedBox(height: 10),
        _ReferencePicker(
          label: 'Course',
          options: widget.courses,
          value: _courseId,
          fallbackController: _fallbackCourse,
          onChanged: (value) => setState(() => _courseId = value),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _session,
          decoration: const InputDecoration(labelText: 'Academic session'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _semester,
          decoration: const InputDecoration(labelText: 'Semester'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _count,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Marked count'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fileUrl,
                decoration: const InputDecoration(labelText: 'File URL'),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _uploading ? null : _upload,
              icon: const Icon(Icons.upload_file),
              label: Text(_uploading ? 'Uploading...' : 'Upload'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _summary,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Summary'),
        ),
      ],
      onSubmit: () => {
        'assessment_id': _assessmentId ?? _fallbackAssessment.text.trim(),
        'course_id': _courseId ?? _fallbackCourse.text.trim(),
        'academic_session': _session.text.trim(),
        'semester': _semester.text.trim(),
        'marked_count': int.tryParse(_count.text) ?? 0,
        'file_url': _fileUrl.text.trim(),
        'summary': _summary.text.trim(),
      },
    );
  }
}

class _ReferencePicker extends StatelessWidget {
  const _ReferencePicker({
    required this.label,
    required this.options,
    required this.value,
    required this.fallbackController,
    required this.onChanged,
  });
  final String label;
  final List<ReferenceOption> options;
  final String? value;
  final TextEditingController fallbackController;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return TextField(
        controller: fallbackController,
        decoration: InputDecoration(labelText: '$label ID'),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(
            value: option.id,
            child: Text(option.label, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DialogScaffold extends StatelessWidget {
  const _DialogScaffold({
    required this.title,
    required this.children,
    required this.onSubmit,
  });
  final String title;
  final List<Widget> children;
  final Map<String, dynamic> Function() onSubmit;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: SizedBox(
      width: 620,
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(onSubmit()),
        child: const Text('Submit'),
      ),
    ],
  );
}
