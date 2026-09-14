import 'package:flutter/material.dart';

class ChiefInvigilatorControlRoomPanel extends StatefulWidget {
  const ChiefInvigilatorControlRoomPanel({super.key});

  @override
  State<ChiefInvigilatorControlRoomPanel> createState() =>
      _ChiefInvigilatorControlRoomPanelState();
}

class _ChiefInvigilatorControlRoomPanelState
    extends State<ChiefInvigilatorControlRoomPanel> {
  String _selectedRisk = 'All';
  String _selectedMode = 'All';

  static const _sessions = [
    _CommandSession(
      session: 'Morning CBT Block',
      mode: 'CBT Centre',
      rooms: 8,
      candidates: 1240,
      checkedIn: 1198,
      submissionsSynced: 1144,
      openIncidents: 3,
      escalated: 1,
      risk: 'Medium',
      status: 'Live',
      decision: 'Monitor CBT Centre 1 app ID exceptions.',
    ),
    _CommandSession(
      session: 'DLC Online Proctoring Group A',
      mode: 'Distance Learning',
      rooms: 4,
      candidates: 780,
      checkedIn: 734,
      submissionsSynced: 690,
      openIncidents: 8,
      escalated: 3,
      risk: 'High',
      status: 'Live',
      decision:
          'Review repeated face-away and device-change alerts before closure.',
    ),
    _CommandSession(
      session: 'Hybrid Practical Session',
      mode: 'Hybrid',
      rooms: 3,
      candidates: 214,
      checkedIn: 208,
      submissionsSynced: 201,
      openIncidents: 1,
      escalated: 0,
      risk: 'Low',
      status: 'Closing',
      decision: 'Await final workstation sync confirmation from Lab B.',
    ),
  ];

  static const _decisions = [
    _CommandDecision(
      title: 'Escalate CSC 309 repeated proctor alerts',
      owner: 'Chief Invigilator',
      scope: 'DLC Online Proctoring Group A',
      reason:
          'Multiple high-confidence events across the same candidate session.',
      status: 'Escalated',
      severity: 'High',
      time: 'Today, 10:38',
    ),
    _CommandDecision(
      title: 'Hold CBT Centre 1 closure',
      owner: 'Chief Invigilator',
      scope: 'Morning CBT Block',
      reason:
          'Two app ID exceptions require exam officer review before closure.',
      status: 'Pending',
      severity: 'Medium',
      time: 'Today, 10:44',
    ),
    _CommandDecision(
      title: 'Approve Lab B room closure',
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
                    'Chief Invigilator / Exam Control Room',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock_clock_outlined),
                  label: const Text('Command closure'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _ControlChip(
                  label: 'Live sessions: 15',
                  icon: Icons.play_circle_outline,
                ),
                _ControlChip(
                  label: 'Rooms/groups: 42',
                  icon: Icons.meeting_room_outlined,
                ),
                _ControlChip(
                  label: 'Open incidents: 24',
                  icon: Icons.report_problem_outlined,
                ),
                _ControlChip(
                  label: 'Escalated: 7',
                  icon: Icons.priority_high_outlined,
                ),
                _ControlChip(
                  label: 'Closure holds: 4',
                  icon: Icons.lock_clock_outlined,
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
              'Command overview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final session in filtered)
              _CommandSessionTile(session: session),
            const SizedBox(height: 18),
            Text(
              'Command decisions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final decision in _decisions)
              _CommandDecisionTile(decision: decision),
          ],
        ),
      ),
    );
  }
}

class _CommandSessionTile extends StatelessWidget {
  const _CommandSessionTile({required this.session});

  final _CommandSession session;

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
              _MiniPill(label: '${session.openIncidents} open incidents'),
              _MiniPill(label: '${session.escalated} escalated'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            session.decision,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
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
                label: const Text('Review incidents'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Hold closure'),
              ),
              FilledButton.icon(
                onPressed: session.risk == 'High' ? null : () {},
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Approve closure'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommandDecisionTile extends StatelessWidget {
  const _CommandDecisionTile({required this.decision});

  final _CommandDecision decision;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final severityColor = decision.severity == 'High'
        ? scheme.error
        : decision.severity == 'Medium'
        ? scheme.secondary
        : scheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: severityColor.withValues(alpha: 0.12),
        foregroundColor: severityColor,
        child: const Icon(Icons.gavel_outlined),
      ),
      title: Text(
        '${decision.title} • ${decision.scope}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${decision.owner} • ${decision.reason} • ${decision.time}',
      ),
      trailing: _StatusBadge(text: decision.status, color: severityColor),
    );
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({required this.label, required this.icon});

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

class _CommandSession {
  const _CommandSession({
    required this.session,
    required this.mode,
    required this.rooms,
    required this.candidates,
    required this.checkedIn,
    required this.submissionsSynced,
    required this.openIncidents,
    required this.escalated,
    required this.risk,
    required this.status,
    required this.decision,
  });

  final String session;
  final String mode;
  final int rooms;
  final int candidates;
  final int checkedIn;
  final int submissionsSynced;
  final int openIncidents;
  final int escalated;
  final String risk;
  final String status;
  final String decision;
}

class _CommandDecision {
  const _CommandDecision({
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
