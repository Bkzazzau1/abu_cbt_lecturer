import 'package:flutter/material.dart';

class LevelAdviserOverviewPanel extends StatelessWidget {
  const LevelAdviserOverviewPanel({super.key});

  static const _signals = [
    _LevelSignal(
      'Course registration completion',
      '402/420',
      0.96,
      Icons.app_registration_outlined,
    ),
    _LevelSignal(
      'Assignment participation',
      '348/420',
      0.83,
      Icons.assignment_turned_in_outlined,
    ),
    _LevelSignal('Quiz participation', '336/420', 0.80, Icons.quiz_outlined),
    _LevelSignal('Exam readiness', '398/420', 0.95, Icons.fact_check_outlined),
  ];

  static const _watchList = [
    _StudentWatch('Aisha Musa', 'No login for 14 days', 'CSC 201, MTH 203'),
    _StudentWatch(
      'Daniel Okoro',
      'Wrong course registration',
      'GST 201 missing',
    ),
    _StudentWatch(
      'Zainab Umar',
      'Exam eligibility issue',
      'Two quizzes pending',
    ),
    _StudentWatch('Kelvin James', 'Missing CA score complaint', 'CSC 205'),
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
                  Icons.person_search_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '200L Computer Science DLC',
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
              'Level Adviser dashboard for 420 assigned students: 390 active, 30 inactive, 18 registration issues, 22 exam eligibility risks, and 11 open academic complaints.',
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
                      child: const _SignalPanel(signals: _signals),
                    ),
                    SizedBox(
                      width: panelWidth,
                      child: const _WatchListPanel(students: _watchList),
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

class _SignalPanel extends StatelessWidget {
  const _SignalPanel({required this.signals});

  final List<_LevelSignal> signals;

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
              'Level readiness',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final signal in signals) _SignalRow(signal: signal),
          ],
        ),
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({required this.signal});

  final _LevelSignal signal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(signal.icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        signal.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(signal.value),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: signal.progress,
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

class _WatchListPanel extends StatelessWidget {
  const _WatchListPanel({required this.students});

  final List<_StudentWatch> students;

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
              'Students needing attention',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final student in students) _WatchRow(student: student),
          ],
        ),
      ),
    );
  }
}

class _WatchRow extends StatelessWidget {
  const _WatchRow({required this.student});

  final _StudentWatch student;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flag_outlined, color: scheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '${student.issue} • ${student.coursesAffected}',
                  maxLines: 2,
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

class _LevelSignal {
  const _LevelSignal(this.label, this.value, this.progress, this.icon);

  final String label;
  final String value;
  final double progress;
  final IconData icon;
}

class _StudentWatch {
  const _StudentWatch(this.name, this.issue, this.coursesAffected);

  final String name;
  final String issue;
  final String coursesAffected;
}
