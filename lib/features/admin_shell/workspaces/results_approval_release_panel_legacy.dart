import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../exam_workflow/data/exam_results_api.dart';

class ResultsApprovalReleasePanel extends StatefulWidget {
  const ResultsApprovalReleasePanel({super.key, this.api});

  final ExamResultsApi? api;

  @override
  State<ResultsApprovalReleasePanel> createState() =>
      _ResultsApprovalReleasePanelState();
}

class _ResultsApprovalReleasePanelState
    extends State<ResultsApprovalReleasePanel> {
  late final ExamResultsApi _api;
  late Future<List<ExamResultBatch>> _future;

  String _selectedStage = 'All';
  String _selectedDepartment = 'All';
  String _selectedLevel = 'All';
  final Set<String> _expanded = {};

  static const _auditTrail = [
    _ResultAudit(
      actor: 'Dr. A. Musa',
      role: 'Lecturer',
      action: 'Submitted CSC 305 result batch',
      time: 'Today, 09:20',
    ),
    _ResultAudit(
      actor: 'Department HoD',
      role: 'HoD',
      action: 'Reviewed pass-rate summary for GST 303',
      time: 'Today, 10:12',
    ),
    _ResultAudit(
      actor: 'Exam Office',
      role: 'Exam Officer',
      action: 'Reconciled repeated-course records for MTH 301',
      time: 'Today, 11:04',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? ExamResultsApi();
    _future = _api.fetchBatches();
  }

  @override
  void dispose() {
    if (widget.api == null) _api.close();
    super.dispose();
  }

  Future<void> _saveBytes({
    required String fileName,
    required List<int> bytes,
    required List<String> allowedExtensions,
  }) async {
    try {
      final path = await FilePicker.platform.saveFile(
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        bytes: Uint8List.fromList(bytes),
      );
      if (!mounted || path == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved $fileName')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save file: $error')));
    }
  }

  Future<void> _downloadStudentList(ExamResultBatch batch) {
    return _saveBytes(
      fileName: '${batch.courseCode}_results.csv',
      bytes: _api.studentListCsvBytes(batch),
      allowedExtensions: const ['csv'],
    );
  }

  Future<void> _downloadScript(
    ExamResultBatch batch,
    ExamResultStudent student,
  ) {
    return _saveBytes(
      fileName:
          '${student.matricNo.replaceAll('/', '_')}_${batch.courseCode}_script.txt',
      bytes: _api.markingScriptBytes(batch, student),
      allowedExtensions: const ['txt'],
    );
  }

  Future<void> _downloadLevelResults(
    List<ExamResultBatch> batches,
    String department,
    String level,
  ) {
    return _saveBytes(
      fileName: '${department}_${level}L_results.csv',
      bytes: _api.levelResultsCsvBytes(
        department: department,
        level: level,
        batches: batches,
      ),
      allowedExtensions: const ['csv'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<ExamResultBatch>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final batches = snapshot.data ?? const [];

        final departments = <String>{
          'All',
          for (final batch in batches) batch.department,
        }.toList();
        final levels = <String>{
          'All',
          for (final batch in batches) batch.level,
        }.toList()..sort();
        final stages = <String>{
          'All',
          for (final batch in batches) batch.stage,
        }.toList();

        final filtered = batches
            .where(
              (batch) =>
                  _selectedStage == 'All' || batch.stage == _selectedStage,
            )
            .where(
              (batch) =>
                  _selectedDepartment == 'All' ||
                  batch.department == _selectedDepartment,
            )
            .where(
              (batch) =>
                  _selectedLevel == 'All' || batch.level == _selectedLevel,
            )
            .toList();

        final canDownloadLevel =
            _selectedDepartment != 'All' && _selectedLevel != 'All';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Results Approval & Release',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.publish_outlined),
                      label: const Text('Release approved'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Download the results a lecturer submitted — the full '
                  'student list per course, an individual marking script for '
                  'any student, or every course result for a whole '
                  'department and level in one file.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 210,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedStage,
                        items: [
                          for (final stage in stages)
                            DropdownMenuItem(
                              value: stage,
                              child: Text(
                                stage == 'All' ? 'All stages' : stage,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedStage = value ?? 'All'),
                        decoration: const InputDecoration(
                          labelText: 'Workflow stage',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 210,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedDepartment,
                        items: [
                          for (final department in departments)
                            DropdownMenuItem(
                              value: department,
                              child: Text(
                                department == 'All'
                                    ? 'All departments'
                                    : department,
                              ),
                            ),
                        ],
                        onChanged: (value) => setState(
                          () => _selectedDepartment = value ?? 'All',
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Department',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedLevel,
                        items: [
                          for (final level in levels)
                            DropdownMenuItem(
                              value: level,
                              child: Text(
                                level == 'All' ? 'All levels' : '${level}L',
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedLevel = value ?? 'All'),
                        decoration: const InputDecoration(labelText: 'Level'),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: canDownloadLevel
                          ? () => _downloadLevelResults(
                              batches,
                              _selectedDepartment,
                              _selectedLevel,
                            )
                          : null,
                      icon: const Icon(Icons.download_outlined),
                      label: Text(
                        canDownloadLevel
                            ? 'Download $_selectedDepartment ${_selectedLevel}L results'
                            : 'Pick a department and level to download',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Result batches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No result batches match this filter.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                else
                  for (final batch in filtered)
                    _ResultBatchTile(
                      batch: batch,
                      expanded: _expanded.contains(batch.courseCode),
                      onToggleExpanded: () => setState(() {
                        if (!_expanded.remove(batch.courseCode)) {
                          _expanded.add(batch.courseCode);
                        }
                      }),
                      onDownloadStudentList: () => _downloadStudentList(batch),
                      onDownloadScript: (student) =>
                          _downloadScript(batch, student),
                    ),
                const SizedBox(height: 18),
                Text(
                  'Approval audit trail',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (final audit in _auditTrail) _AuditTile(audit: audit),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultBatchTile extends StatelessWidget {
  const _ResultBatchTile({
    required this.batch,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onDownloadStudentList,
    required this.onDownloadScript,
  });

  final ExamResultBatch batch;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onDownloadStudentList;
  final ValueChanged<ExamResultStudent> onDownloadScript;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = batch.stage == 'Moderator Query'
        ? scheme.error
        : batch.stage == 'Ready for Release'
        ? scheme.primary
        : scheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: batch.missingScores > 0
              ? scheme.error.withValues(alpha: 0.4)
              : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${batch.courseCode} • ${batch.courseTitle}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${batch.department} • ${batch.level}L • ${batch.lecturer}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: batch.stage, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: '${batch.students.length} students'),
              _MiniPill(label: 'Pass rate ${batch.passRateLabel}'),
              _MiniPill(label: '${batch.missingScores} missing scores'),
              _MiniPill(label: 'Audit required'),
            ],
          ),
          const SizedBox(height: 10),
          Text(batch.issue, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onDownloadStudentList,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download student list'),
              ),
              OutlinedButton.icon(
                onPressed: onToggleExpanded,
                icon: Icon(
                  expanded
                      ? Icons.expand_less_outlined
                      : Icons.expand_more_outlined,
                ),
                label: Text(expanded ? 'Hide students' : 'View students'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.rule_outlined),
                label: const Text('Query'),
              ),
              FilledButton.icon(
                onPressed: batch.stage == 'Ready for Release' ? () {} : null,
                icon: const Icon(Icons.publish_outlined),
                label: const Text('Release'),
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            for (final student in batch.students)
              _StudentRow(
                student: student,
                onDownloadScript: () => onDownloadScript(student),
              ),
          ],
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student, required this.onDownloadScript});

  final ExamResultStudent student;
  final VoidCallback onDownloadScript;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  student.matricNo,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          _MiniPill(label: 'CA ${student.caScore}'),
          const SizedBox(width: 8),
          _MiniPill(label: 'Exam ${student.examScore}'),
          const SizedBox(width: 8),
          _MiniPill(label: 'Total ${student.total} (${student.grade})'),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Download marking script',
            onPressed: onDownloadScript,
            icon: const Icon(Icons.description_outlined),
          ),
        ],
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.audit});

  final _ResultAudit audit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: const Icon(Icons.history_outlined),
      ),
      title: Text(
        audit.action,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text('${audit.actor} • ${audit.role}'),
      trailing: Text(audit.time),
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

class _ResultAudit {
  const _ResultAudit({
    required this.actor,
    required this.role,
    required this.action,
    required this.time,
  });

  final String actor;
  final String role;
  final String action;
  final String time;
}
