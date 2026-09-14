import 'package:flutter/material.dart';

class InvigilatorOperationsPanel extends StatefulWidget {
  const InvigilatorOperationsPanel({super.key});

  @override
  State<InvigilatorOperationsPanel> createState() =>
      _InvigilatorOperationsPanelState();
}

class _InvigilatorOperationsPanelState
    extends State<InvigilatorOperationsPanel> {
  String _selectedRoom = 'All';
  String _selectedStatus = 'All';

  static const _rooms = [
    _ExamRoom(
      room: 'ICT Lab A',
      exam: 'CSC 305 Data Structures CBT',
      mode: 'CBT Centre',
      candidates: 120,
      checkedIn: 113,
      workstations: 120,
      onlineDevices: 118,
      whitelistedApps: 116,
      incidents: 0,
      status: 'Ready',
    ),
    _ExamRoom(
      room: 'CBT Centre 1',
      exam: 'GST 303 Communication in English',
      mode: 'CBT Centre',
      candidates: 220,
      checkedIn: 204,
      workstations: 220,
      onlineDevices: 211,
      whitelistedApps: 207,
      incidents: 2,
      status: 'Attention',
    ),
    _ExamRoom(
      room: 'Online Proctored Group A',
      exam: 'CSC 309 Artificial Intelligence',
      mode: 'Distance Learning',
      candidates: 197,
      checkedIn: 181,
      workstations: 197,
      onlineDevices: 181,
      whitelistedApps: 181,
      incidents: 5,
      status: 'Monitoring',
    ),
    _ExamRoom(
      room: 'Lab B',
      exam: 'SEN 301 Practical',
      mode: 'Hybrid',
      candidates: 60,
      checkedIn: 58,
      workstations: 60,
      onlineDevices: 60,
      whitelistedApps: 58,
      incidents: 1,
      status: 'Ready',
    ),
  ];

  static const _incidents = [
    _InvigilationIncident(
      candidate: '2023/C/SENG/0400',
      room: 'Online Proctored Group A',
      type: 'Face-away alert',
      severity: 'Medium',
      status: 'Open',
      time: 'Today, 10:18',
    ),
    _InvigilationIncident(
      candidate: '2023/C/SENG/0188',
      room: 'CBT Centre 1',
      type: 'Unwhitelisted app ID',
      severity: 'High',
      status: 'Escalated',
      time: 'Today, 10:31',
    ),
    _InvigilationIncident(
      candidate: '2022/C/CSC/0112',
      room: 'Lab B',
      type: 'Network upload delay',
      severity: 'Low',
      status: 'Resolved',
      time: 'Yesterday, 15:12',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filteredRooms = _rooms
        .where((room) => _selectedRoom == 'All' || room.room == _selectedRoom)
        .where(
          (room) => _selectedStatus == 'All' || room.status == _selectedStatus,
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
                Icon(Icons.supervisor_account_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Invigilator Operations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Close session'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _OpsChip(
                  label: 'Active rooms: 18',
                  icon: Icons.meeting_room_outlined,
                ),
                _OpsChip(
                  label: 'Checked in: 2,418',
                  icon: Icons.how_to_reg_outlined,
                ),
                _OpsChip(
                  label: 'App ID issues: 11',
                  icon: Icons.app_blocking_outlined,
                ),
                _OpsChip(
                  label: 'Open incidents: 8',
                  icon: Icons.report_problem_outlined,
                ),
                _OpsChip(
                  label: 'Sessions closing: 4',
                  icon: Icons.task_alt_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedRoom,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All rooms')),
                      DropdownMenuItem(
                        value: 'ICT Lab A',
                        child: Text('ICT Lab A'),
                      ),
                      DropdownMenuItem(
                        value: 'CBT Centre 1',
                        child: Text('CBT Centre 1'),
                      ),
                      DropdownMenuItem(
                        value: 'Online Proctored Group A',
                        child: Text('Online Proctored Group A'),
                      ),
                      DropdownMenuItem(value: 'Lab B', child: Text('Lab B')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedRoom = value ?? 'All'),
                    decoration: const InputDecoration(
                      labelText: 'Room / group',
                    ),
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All statuses'),
                      ),
                      DropdownMenuItem(value: 'Ready', child: Text('Ready')),
                      DropdownMenuItem(
                        value: 'Monitoring',
                        child: Text('Monitoring'),
                      ),
                      DropdownMenuItem(
                        value: 'Attention',
                        child: Text('Attention'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Room status'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Room operations',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final room in filteredRooms) _ExamRoomTile(room: room),
            const SizedBox(height: 18),
            Text(
              'Incident reports',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final incident in _incidents)
              _IncidentTile(incident: incident),
          ],
        ),
      ),
    );
  }
}

class _ExamRoomTile extends StatelessWidget {
  const _ExamRoomTile({required this.room});

  final _ExamRoom room;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = room.status == 'Attention'
        ? scheme.error
        : room.status == 'Monitoring'
        ? scheme.secondary
        : scheme.primary;
    final checkInPercent = room.candidates == 0
        ? 0.0
        : room.checkedIn / room.candidates;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: room.status == 'Attention'
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
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${room.room} • ${room.exam}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.mode,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: room.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(
                label: '${room.checkedIn}/${room.candidates} checked in',
              ),
              _MiniPill(
                label:
                    '${room.onlineDevices}/${room.workstations} devices online',
              ),
              _MiniPill(label: '${room.whitelistedApps} app IDs ok'),
              _MiniPill(label: '${room.incidents} incidents'),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: checkInPercent,
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
                icon: const Icon(Icons.how_to_reg_outlined),
                label: const Text('Check-in'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.desktop_windows_outlined),
                label: const Text('Workstations'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.report_outlined),
                label: const Text('Report incident'),
              ),
              FilledButton.icon(
                onPressed: room.status == 'Ready' || room.status == 'Monitoring'
                    ? () {}
                    : null,
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Close room'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({required this.incident});

  final _InvigilationIncident incident;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final severityColor = incident.severity == 'High'
        ? scheme.error
        : incident.severity == 'Medium'
        ? scheme.secondary
        : scheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: severityColor.withValues(alpha: 0.12),
        foregroundColor: severityColor,
        child: const Icon(Icons.warning_amber_outlined),
      ),
      title: Text(
        '${incident.candidate} • ${incident.type}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${incident.room} • ${incident.status} • ${incident.time}',
      ),
      trailing: _StatusBadge(text: incident.severity, color: severityColor),
    );
  }
}

class _OpsChip extends StatelessWidget {
  const _OpsChip({required this.label, required this.icon});

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

class _ExamRoom {
  const _ExamRoom({
    required this.room,
    required this.exam,
    required this.mode,
    required this.candidates,
    required this.checkedIn,
    required this.workstations,
    required this.onlineDevices,
    required this.whitelistedApps,
    required this.incidents,
    required this.status,
  });

  final String room;
  final String exam;
  final String mode;
  final int candidates;
  final int checkedIn;
  final int workstations;
  final int onlineDevices;
  final int whitelistedApps;
  final int incidents;
  final String status;
}

class _InvigilationIncident {
  const _InvigilationIncident({
    required this.candidate,
    required this.room,
    required this.type,
    required this.severity,
    required this.status,
    required this.time,
  });

  final String candidate;
  final String room;
  final String type;
  final String severity;
  final String status;
  final String time;
}
