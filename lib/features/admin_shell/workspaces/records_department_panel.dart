import 'package:flutter/material.dart';

class RecordsDepartmentPanel extends StatelessWidget {
  const RecordsDepartmentPanel({super.key});

  static const _records = [
    _StudentRecord(
      name: 'Ibrahim Yahaya',
      matricNo: '2023/C/SENG/0400',
      programme: 'B.Sc Software Engineering',
      cohort: '2023 Regular • 300 Level',
      cgpa: '4.18',
      status: 'Carryover check',
      issue:
          'CSC 209 repeat record must be linked before transcript preview is locked.',
    ),
    _StudentRecord(
      name: 'Aisha Musa',
      matricNo: '2023/C/SENG/0188',
      programme: 'B.Sc Software Engineering',
      cohort: '2023 Regular • 300 Level',
      cgpa: '4.52',
      status: 'Ready',
      issue: 'All completed courses reconciled. CGPA ready for approval.',
    ),
    _StudentRecord(
      name: 'Blessing John',
      matricNo: '2022/C/CSC/0112',
      programme: 'B.Sc Computer Science',
      cohort: '2022 Regular • 400 Level',
      cgpa: '3.76',
      status: 'Missing result',
      issue: 'GST 303 has released CA but missing exam score.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.badge_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Records Department',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.manage_search_outlined),
                  label: const Text('Audit'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _RecordChip(
                  label: 'Student profiles: 18,420',
                  icon: Icons.person_outline,
                ),
                _RecordChip(
                  label: 'Active cohorts: 62',
                  icon: Icons.groups_2_outlined,
                ),
                _RecordChip(
                  label: 'CGPA reviews: 74',
                  icon: Icons.workspace_premium_outlined,
                ),
                _RecordChip(
                  label: 'Missing results: 18',
                  icon: Icons.report_problem_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final record in _records) _StudentRecordTile(record: record),
          ],
        ),
      ),
    );
  }
}

class _StudentRecordTile extends StatelessWidget {
  const _StudentRecordTile({required this.record});

  final _StudentRecord record;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = record.status == 'Ready'
        ? scheme.primary
        : record.status == 'Missing result'
        ? scheme.error
        : scheme.secondary;

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
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.name} • ${record.matricNo}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text('${record.programme} • ${record.cohort}'),
                  ],
                ),
              ),
              _StatusBadge(text: record.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: 'CGPA ${record.cgpa}'),
              const _MiniPill(label: 'Completed courses checked'),
              const _MiniPill(label: 'Cohort mapped'),
              const _MiniPill(label: 'Transcript preview'),
            ],
          ),
          const SizedBox(height: 10),
          Text(record.issue, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.history_edu_outlined),
                label: const Text('Academic history'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.groups_outlined),
                label: const Text('Cohort'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.lock_outline),
                label: const Text('Lock record'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordChip extends StatelessWidget {
  const _RecordChip({required this.label, required this.icon});

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

class _StudentRecord {
  const _StudentRecord({
    required this.name,
    required this.matricNo,
    required this.programme,
    required this.cohort,
    required this.cgpa,
    required this.status,
    required this.issue,
  });

  final String name;
  final String matricNo;
  final String programme;
  final String cohort;
  final String cgpa;
  final String status;
  final String issue;
}
