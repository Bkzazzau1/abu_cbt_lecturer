import 'package:flutter/material.dart';

class HodDepartmentOverviewPanel extends StatelessWidget {
  const HodDepartmentOverviewPanel({super.key});

  static const _readiness = [
    _DepartmentSignal(
      'Courses with materials',
      '35/42',
      0.83,
      Icons.menu_book_outlined,
    ),
    _DepartmentSignal(
      'Video lectures uploaded',
      '288/360',
      0.80,
      Icons.video_library_outlined,
    ),
    _DepartmentSignal(
      'Assessment readiness',
      '31/42',
      0.74,
      Icons.assignment_turned_in_outlined,
    ),
    _DepartmentSignal(
      'Results submitted',
      '27/42',
      0.64,
      Icons.workspace_premium_outlined,
    ),
  ];

  static const _warnings = [
    _DepartmentWarning(
      'CSC 301 has no video lecture uploaded',
      'Lecturer follow-up required',
    ),
    _DepartmentWarning(
      'CSC 205 course outline is missing',
      'Course coordinator review',
    ),
    _DepartmentWarning(
      'CSC 411 assignment not created',
      'Assessment readiness risk',
    ),
    _DepartmentWarning(
      'CSC 102 notes awaiting review',
      'Moderator confirmation pending',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Computer Science Department',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'B.Sc. Computer Science DLC academic supervision: 1,250 students, 18 lecturers, 42 courses, 35 active courses, and 7 pending readiness actions.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 920;
                final panelWidth = wide
                    ? (constraints.maxWidth - 14) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    SizedBox(
                      width: panelWidth,
                      child: _ReadinessPanel(items: _readiness),
                    ),
                    SizedBox(
                      width: panelWidth,
                      child: const _WarningPanel(warnings: _warnings),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessPanel extends StatelessWidget {
  const _ReadinessPanel({required this.items});

  final List<_DepartmentSignal> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department readiness',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final item in items) _ReadinessRow(item: item),
          ],
        ),
      ),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow({required this.item});

  final _DepartmentSignal item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(item.value),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningPanel extends StatelessWidget {
  const _WarningPanel({required this.warnings});

  final List<_DepartmentWarning> warnings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic warnings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final warning in warnings) _WarningRow(warning: warning),
          ],
        ),
      ),
    );
  }
}

class _WarningRow extends StatelessWidget {
  const _WarningRow({required this.warning});

  final _DepartmentWarning warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_outlined, color: scheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  warning.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentSignal {
  const _DepartmentSignal(this.label, this.value, this.progress, this.icon);

  final String label;
  final String value;
  final double progress;
  final IconData icon;
}

class _DepartmentWarning {
  const _DepartmentWarning(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
