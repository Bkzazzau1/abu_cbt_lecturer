import 'package:flutter/material.dart';

class ResultsApprovalReleasePanel extends StatefulWidget {
  const ResultsApprovalReleasePanel({super.key});

  @override
  State<ResultsApprovalReleasePanel> createState() =>
      _ResultsApprovalReleasePanelState();
}

class _ResultsApprovalReleasePanelState
    extends State<ResultsApprovalReleasePanel> {
  String _selectedStage = 'All';
  String _selectedDepartment = 'All';

  static const _batches = [
    _ResultBatch(
      courseCode: 'CSC 305',
      courseTitle: 'Data Structures',
      department: 'Computing',
      lecturer: 'Dr. A. Musa',
      students: 248,
      passRate: '84%',
      missingScores: 0,
      stage: 'HoD Review',
      issue:
          'Lecturer submitted marks. HoD review pending before exam office release.',
    ),
    _ResultBatch(
      courseCode: 'CSC 309',
      courseTitle: 'Artificial Intelligence',
      department: 'Computing',
      lecturer: 'Dr. L. Ibrahim',
      students: 197,
      passRate: '71%',
      missingScores: 3,
      stage: 'Moderator Query',
      issue: 'Three CA scores missing. Moderator queried grading consistency.',
    ),
    _ResultBatch(
      courseCode: 'GST 303',
      courseTitle: 'Communication in English',
      department: 'General Studies',
      lecturer: 'Mrs. H. John',
      students: 620,
      passRate: '91%',
      missingScores: 0,
      stage: 'Ready for Release',
      issue:
          'Records reconciliation completed. Ready for exam officer release.',
    ),
    _ResultBatch(
      courseCode: 'MTH 301',
      courseTitle: 'Numerical Methods',
      department: 'Mathematics',
      lecturer: 'Prof. S. Bala',
      students: 212,
      passRate: '68%',
      missingScores: 7,
      stage: 'Records Reconcile',
      issue:
          'Seven students have carryover/repeat status requiring records confirmation.',
    ),
  ];

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
      actor: 'Records Desk',
      role: 'Records Department',
      action: 'Reconciled repeated-course records for MTH 301',
      time: 'Today, 11:04',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _batches
        .where(
          (batch) => _selectedStage == 'All' || batch.stage == _selectedStage,
        )
        .where(
          (batch) =>
              _selectedDepartment == 'All' ||
              batch.department == _selectedDepartment,
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
                Icon(Icons.workspace_premium_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Results Approval & Release',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.publish_outlined),
                  label: const Text('Release approved'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _ResultChip(
                  label: 'Lecturer submitted: 18',
                  icon: Icons.upload_file_outlined,
                ),
                _ResultChip(
                  label: 'HoD review: 7',
                  icon: Icons.groups_2_outlined,
                ),
                _ResultChip(
                  label: 'Records reconcile: 5',
                  icon: Icons.badge_outlined,
                ),
                _ResultChip(
                  label: 'Ready release: 12',
                  icon: Icons.verified_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedStage,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All stages')),
                      DropdownMenuItem(
                        value: 'HoD Review',
                        child: Text('HoD Review'),
                      ),
                      DropdownMenuItem(
                        value: 'Moderator Query',
                        child: Text('Moderator Query'),
                      ),
                      DropdownMenuItem(
                        value: 'Records Reconcile',
                        child: Text('Records Reconcile'),
                      ),
                      DropdownMenuItem(
                        value: 'Ready for Release',
                        child: Text('Ready for Release'),
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
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedDepartment,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All departments'),
                      ),
                      DropdownMenuItem(
                        value: 'Computing',
                        child: Text('Computing'),
                      ),
                      DropdownMenuItem(
                        value: 'General Studies',
                        child: Text('General Studies'),
                      ),
                      DropdownMenuItem(
                        value: 'Mathematics',
                        child: Text('Mathematics'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedDepartment = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Department'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Result batches',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final batch in filtered) _ResultBatchTile(batch: batch),
            const SizedBox(height: 18),
            Text(
              'Approval audit trail',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final audit in _auditTrail) _AuditTile(audit: audit),
          ],
        ),
      ),
    );
  }
}

class _ResultBatchTile extends StatelessWidget {
  const _ResultBatchTile({required this.batch});

  final _ResultBatch batch;

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
                      '${batch.department} • ${batch.lecturer}',
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
              _MiniPill(label: '${batch.students} students'),
              _MiniPill(label: 'Pass rate ${batch.passRate}'),
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
                onPressed: () {},
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Review batch'),
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

class _ResultChip extends StatelessWidget {
  const _ResultChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
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

class _ResultBatch {
  const _ResultBatch({
    required this.courseCode,
    required this.courseTitle,
    required this.department,
    required this.lecturer,
    required this.students,
    required this.passRate,
    required this.missingScores,
    required this.stage,
    required this.issue,
  });

  final String courseCode;
  final String courseTitle;
  final String department;
  final String lecturer;
  final int students;
  final String passRate;
  final int missingScores;
  final String stage;
  final String issue;
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
