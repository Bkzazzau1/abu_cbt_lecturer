import 'package:flutter/material.dart';

class AcademicRecordsOverviewPanel extends StatelessWidget {
  const AcademicRecordsOverviewPanel({super.key});

  static const _signals = [
    _RecordSignal(
      'Complete registration',
      '17,642/18,420',
      0.96,
      Icons.app_registration_outlined,
    ),
    _RecordSignal(
      'Approved results stored',
      '2,184/2,460',
      0.89,
      Icons.workspace_premium_outlined,
    ),
    _RecordSignal(
      'Carryover cases reconciled',
      '614/780',
      0.79,
      Icons.repeat_outlined,
    ),
    _RecordSignal(
      'Transcript requests processed',
      '128/164',
      0.78,
      Icons.description_outlined,
    ),
  ];

  static const _watchList = [
    _RecordWatch('CSC 201 grade correction', 'C to B • HoD approval attached'),
    _RecordWatch(
      'GST 303 missing exam score',
      'Awaiting approved departmental result sheet',
    ),
    _RecordWatch(
      '2024/DLC/SENG/0211 registration',
      'Elective registration correction requested',
    ),
    _RecordWatch(
      'Graduation clearance batch',
      '42 students require outstanding-course check',
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
                  Icons.badge_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Academic Records Custody',
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
              'Official DLC academic information: student profiles, matriculation, registration, approved results, carryovers, academic standing, transcripts, graduation clearance, and audit trails.',
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
                      child: const _WatchPanel(items: _watchList),
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

  final List<_RecordSignal> signals;

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
              'Official record signals',
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

  final _RecordSignal signal;

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

class _WatchPanel extends StatelessWidget {
  const _WatchPanel({required this.items});

  final List<_RecordWatch> items;

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
              'Corrections and audit watch',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final item in items) _WatchRow(item: item),
          ],
        ),
      ),
    );
  }
}

class _WatchRow extends StatelessWidget {
  const _WatchRow({required this.item});

  final _RecordWatch item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.manage_history_outlined, color: scheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(item.detail, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordSignal {
  const _RecordSignal(this.label, this.value, this.progress, this.icon);

  final String label;
  final String value;
  final double progress;
  final IconData icon;
}

class _RecordWatch {
  const _RecordWatch(this.title, this.detail);

  final String title;
  final String detail;
}
