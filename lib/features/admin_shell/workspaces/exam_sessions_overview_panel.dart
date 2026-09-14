import 'package:flutter/material.dart';

class ExamSessionsOverviewPanel extends StatefulWidget {
  const ExamSessionsOverviewPanel({super.key});

  @override
  State<ExamSessionsOverviewPanel> createState() =>
      _ExamSessionsOverviewPanelState();
}

class _ExamSessionsOverviewPanelState extends State<ExamSessionsOverviewPanel> {
  String _selectedRisk = 'All';
  String _selectedMode = 'All';

  static const _sessions = [
    _SessionSummary(
      session: 'Morning CBT Block',
      mode: 'CBT Centre',
      rooms: 8,
      candidates: 1240,
      checkedIn: 1198,
      submissionsSynced: 1144,
      openReports: 3,
      escalatedReports: 1,
      risk: 'Medium',
      status: 'Live',
      note: 'Monitor CBT Centre 1 app ID exceptions before final sign-off.',
    ),
    _SessionSummary(
      session: 'DLC Online Proctoring Group A',
      mode: 'Distance Learning',
      rooms: 4,
      candidates: 780,
      checkedIn: 734,
      submissionsSynced: 690,
      openReports: 8,
      escalatedReports: 3,
      risk: 'High',
      status: 'Live',
      note:
          'Review repeated face-away and device-change reports before closure.',
    ),
    _SessionSummary(
      session: 'Hybrid Practical Session',
      mode: 'Hybrid',
      rooms: 3,
      candidates: 214,
      checkedIn: 208,
      submissionsSynced: 201,
      openReports: 1,
      escalatedReports: 0,
      risk: 'Low',
      status: 'Closing',
      note: 'Await final workstation sync confirmation from Lab B.',
    ),
  ];

  static const _reviews = [
    _SessionReview(
      title: 'Escalated CSC 309 proctoring reports',
      owner: 'Chief Invigilator',
      scope: 'DLC Online Proctoring Group A',
      reason:
          'Multiple high-confidence events were reported within the same candidate session.',
      status: 'Escalated',
      severity: 'High',
      time: 'Today, 10:38',
    ),
    _SessionReview(
      title: 'CBT Centre 1 sign-off pending',
      owner: 'Chief Invigilator',
      scope: 'Morning CBT Block',
      reason:
          'Two app ID exceptions require exam officer review before room sign-off.',
      status: 'Pending',
      severity: 'Medium',
      time: 'Today, 10:44',
    ),
    _SessionReview(
      title: 'Lab B room sign-off approved',
      owner: 'Chief Invigilator',
      scope: 'Hybrid Practical Session',
      reason: 'Candidate count, submissions and incident review reconciled.',
      status: 'Approved',
      severity: 'Low',
      time: 'Today, 11:03',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _sessions
        .where(
          (session) => _selectedRisk == 'All' || session.risk == _selectedRisk,
        )
        .where(
          (session) => _selectedMode == 'All' || session.mode == _selectedMode,
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
                Icon(Icons.sensors_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Chief Invigilator / Exam Sessions Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Session sign-off'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _OverviewChip(
                  label: 'Live sessions: 15',
                  icon: Icons.play_circle_outline,
                ),
                _OverviewChip(
                  label: 'Rooms/groups: 42',
                  icon: Icons.meeting_room_outlined,
                ),
                _OverviewChip(
                  label: 'Open reports: 24',
                  icon: Icons.report_problem_outlined,
                ),
                _OverviewChip(
                  label: 'Escalated: 7',
                  icon: Icons.priority_high_outlined,
                ),
                _OverviewChip(
                  label: 'Pending sign-off: 4',
                  icon: Icons.pending_actions_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedRisk,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All risk levels'),
                      ),
                      DropdownMenuItem(value: 'High', child: Text('High')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedRisk = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Risk'),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedMode,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All modes')),
                      DropdownMenuItem(
                        value: 'CBT Centre',
                        child: Text('CBT Centre'),
                      ),
                      DropdownMenuItem(
                        value: 'Distance Learning',
                        child: Text('Distance Learning'),
                      ),
                      DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedMode = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Mode'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Session overview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final session in filtered)
              _SessionSummaryTile(session: session),
            const SizedBox(height: 18),
            Text(
              'Escalation and sign-off reviews',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final review in _reviews) _SessionReviewTile(review: review),
          ],
        ),
      ),
    );
  }
}

class _SessionSummaryTile extends StatelessWidget {
  const _SessionSummaryTile({required this.session});

  final _SessionSummary session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final riskColor = session.risk == 'High'
        ? scheme.error
        : session.risk == 'Medium'
        ? scheme.secondary
        : scheme.primary;
    final checkInProgress = session.candidates == 0
        ? 0.0
        : session.checkedIn / session.candidates;
    final syncProgress = session.candidates == 0
        ? 0.0
        : session.submissionsSynced / session.candidates;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: session.risk == 'High'
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
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${session.session} • ${session.mode}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.rooms} rooms/groups • ${session.status}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: session.risk, color: riskColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(
                label: '${session.checkedIn}/${session.candidates} checked in',
              ),
              _MiniPill(
                label: '${session.submissionsSynced} submissions synced',
              ),
              _MiniPill(label: '${session.openReports} open reports'),
              _MiniPill(label: '${session.escalatedReports} escalated'),
            ],
          ),
          const SizedBox(height: 10),
          Text(session.note, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Text(
            'Check-in progress',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: checkInProgress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          Text(
            'Submission sync progress',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: syncProgress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.dashboard_customize_outlined),
                label: const Text('Open rooms'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Review reports'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Hold sign-off'),
              ),
              FilledButton.icon(
                onPressed: session.risk == 'High' ? null : () {},
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Approve sign-off'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionReviewTile extends StatelessWidget {
  const _SessionReviewTile({required this.review});

  final _SessionReview review;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final severityColor = review.severity == 'High'
        ? scheme.error
        : review.severity == 'Medium'
        ? scheme.secondary
        : scheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: severityColor.withValues(alpha: 0.12),
        foregroundColor: severityColor,
        child: const Icon(Icons.verified_user_outlined),
      ),
      title: Text(
        '${review.title} • ${review.scope}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text('${review.owner} • ${review.reason} • ${review.time}'),
      trailing: _StatusBadge(text: review.status, color: severityColor),
    );
  }
}

class _OverviewChip extends StatelessWidget {
  const _OverviewChip({required this.label, required this.icon});

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

class _SessionSummary {
  const _SessionSummary({
    required this.session,
    required this.mode,
    required this.rooms,
    required this.candidates,
    required this.checkedIn,
    required this.submissionsSynced,
    required this.openReports,
    required this.escalatedReports,
    required this.risk,
    required this.status,
    required this.note,
  });

  final String session;
  final String mode;
  final int rooms;
  final int candidates;
  final int checkedIn;
  final int submissionsSynced;
  final int openReports;
  final int escalatedReports;
  final String risk;
  final String status;
  final String note;
}

class _SessionReview {
  const _SessionReview({
    required this.title,
    required this.owner,
    required this.scope,
    required this.reason,
    required this.status,
    required this.severity,
    required this.time,
  });

  final String title;
  final String owner;
  final String scope;
  final String reason;
  final String status;
  final String severity;
  final String time;
}
