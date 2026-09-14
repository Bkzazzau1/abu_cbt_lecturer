import 'package:flutter/material.dart';

class DepartmentalExamOfficerOverviewPanel extends StatelessWidget {
  const DepartmentalExamOfficerOverviewPanel({super.key});

  static const _signals = [
    _ExamSignal('Questions submitted', '28/32', 0.88, Icons.quiz_outlined),
    _ExamSignal('Questions approved', '22/32', 0.69, Icons.verified_outlined),
    _ExamSignal(
      'Eligible students',
      '1,180/1,250',
      0.94,
      Icons.fact_check_outlined,
    ),
    _ExamSignal(
      'Results submitted',
      '18/32',
      0.56,
      Icons.workspace_premium_outlined,
    ),
  ];

  static const _alerts = [
    _ExamAlert(
      'CSC 405 question not submitted',
      'Dr. Musa Adamu • Deadline 15 June 2026',
    ),
    _ExamAlert(
      'CSC 301 moderation still pending',
      'Moderator comments due before HoD confirmation',
    ),
    _ExamAlert(
      '70 students not exam eligible',
      'Registration, CA, participation, and complaints checks',
    ),
    _ExamAlert(
      '4 malpractice reports under review',
      'AI proctoring and invigilator evidence attached',
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
                  Icons.assignment_turned_in_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Computer Science Department Exams',
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
              'Operational exam coordination under the HoD as Chief Departmental Exam Officer: 32 exam courses, 28 questions submitted, 22 approved, 1,180 eligible students, and 18 result batches submitted.',
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
                      child: const _AlertPanel(alerts: _alerts),
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

  final List<_ExamSignal> signals;

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
              'Exam readiness signals',
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

  final _ExamSignal signal;

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

class _AlertPanel extends StatelessWidget {
  const _AlertPanel({required this.alerts});

  final List<_ExamAlert> alerts;

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
              'Operational alerts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final alert in alerts) _AlertRow(alert: alert),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});

  final _ExamAlert alert;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.report_problem_outlined, color: scheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.subtitle,
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

class _ExamSignal {
  const _ExamSignal(this.label, this.value, this.progress, this.icon);

  final String label;
  final String value;
  final double progress;
  final IconData icon;
}

class _ExamAlert {
  const _ExamAlert(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
