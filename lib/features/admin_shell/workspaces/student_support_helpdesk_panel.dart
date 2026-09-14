import 'package:flutter/material.dart';

class StudentSupportHelpdeskPanel extends StatefulWidget {
  const StudentSupportHelpdeskPanel({super.key});

  @override
  State<StudentSupportHelpdeskPanel> createState() =>
      _StudentSupportHelpdeskPanelState();
}

class _StudentSupportHelpdeskPanelState
    extends State<StudentSupportHelpdeskPanel> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  static const _tickets = [
    _SupportTicket(
      ticketNo: 'KSLAS-SUP-1042',
      student: 'Ibrahim Bashir Yahaya',
      matricNo: '2023/C/SENG/0400',
      category: 'Missing Result',
      priority: 'High',
      status: 'Assigned',
      owner: 'Records Department',
      summary:
          'CSC 309 exam score is missing after rewrite and still appears as carryover.',
      sla: 'Due today',
    ),
    _SupportTicket(
      ticketNo: 'KSLAS-SUP-1043',
      student: 'Aisha Bello',
      matricNo: '2024/DLC/SENG/0211',
      category: 'Course Registration',
      priority: 'Medium',
      status: 'Open',
      owner: 'Department Admin',
      summary: 'DLC semester 3 elective is not visible during registration.',
      sla: '1 day left',
    ),
    _SupportTicket(
      ticketNo: 'KSLAS-SUP-1044',
      student: 'Musa Abdullahi',
      matricNo: '2023/C/CSC/0172',
      category: 'Exam Incident',
      priority: 'High',
      status: 'Escalated',
      owner: 'Exam Office',
      summary:
          'Candidate was disconnected during CBT upload and needs submission verification.',
      sla: 'Overdue',
    ),
    _SupportTicket(
      ticketNo: 'KSLAS-SUP-1045',
      student: 'Maryam Sani',
      matricNo: '2022/PT/CSC/0088',
      category: 'Assignment',
      priority: 'Low',
      status: 'Resolved',
      owner: 'Lecturer',
      summary:
          'Assignment file uploaded late due to network issue; lecturer feedback requested.',
      sla: 'Closed',
    ),
  ];

  static const _activity = [
    _SupportActivity(
      title: 'Records requested exam-score audit',
      ticketNo: 'KSLAS-SUP-1042',
      actor: 'Records Department',
      detail:
          'CSC 309 result batch and student academic record are being reconciled.',
      time: 'Today, 12:08',
      severity: 'High',
    ),
    _SupportActivity(
      title: 'Exam office escalated CBT upload case',
      ticketNo: 'KSLAS-SUP-1044',
      actor: 'Exam Officer',
      detail: 'Submission sync logs requested from invigilation session.',
      time: 'Today, 11:52',
      severity: 'High',
    ),
    _SupportActivity(
      title: 'Assignment complaint resolved',
      ticketNo: 'KSLAS-SUP-1045',
      actor: 'Lecturer',
      detail: 'Feedback was published and the student was notified.',
      time: 'Yesterday, 16:20',
      severity: 'Low',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _tickets
        .where(
          (ticket) =>
              _selectedCategory == 'All' ||
              ticket.category == _selectedCategory,
        )
        .where(
          (ticket) =>
              _selectedStatus == 'All' || ticket.status == _selectedStatus,
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
                Icon(Icons.support_agent_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Student Support / Helpdesk',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('New ticket'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _HelpdeskChip(
                  label: 'Open tickets: 38',
                  icon: Icons.mark_unread_chat_alt_outlined,
                ),
                _HelpdeskChip(
                  label: 'Missing results: 9',
                  icon: Icons.workspace_premium_outlined,
                ),
                _HelpdeskChip(
                  label: 'Registration issues: 11',
                  icon: Icons.app_registration_outlined,
                ),
                _HelpdeskChip(
                  label: 'Exam follow-up: 6',
                  icon: Icons.assignment_outlined,
                ),
                _HelpdeskChip(
                  label: 'Overdue SLA: 4',
                  icon: Icons.timer_off_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedCategory,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All categories'),
                      ),
                      DropdownMenuItem(
                        value: 'Missing Result',
                        child: Text('Missing Result'),
                      ),
                      DropdownMenuItem(
                        value: 'Course Registration',
                        child: Text('Course Registration'),
                      ),
                      DropdownMenuItem(
                        value: 'Exam Incident',
                        child: Text('Exam Incident'),
                      ),
                      DropdownMenuItem(
                        value: 'Assignment',
                        child: Text('Assignment'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Category'),
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
                      DropdownMenuItem(value: 'Open', child: Text('Open')),
                      DropdownMenuItem(
                        value: 'Assigned',
                        child: Text('Assigned'),
                      ),
                      DropdownMenuItem(
                        value: 'Escalated',
                        child: Text('Escalated'),
                      ),
                      DropdownMenuItem(
                        value: 'Resolved',
                        child: Text('Resolved'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Ticket queue',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final ticket in filtered) _SupportTicketTile(ticket: ticket),
            const SizedBox(height: 18),
            Text(
              'Recent support activity',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final activity in _activity)
              _SupportActivityTile(activity: activity),
          ],
        ),
      ),
    );
  }
}

class _SupportTicketTile extends StatelessWidget {
  const _SupportTicketTile({required this.ticket});

  final _SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final priorityColor = ticket.priority == 'High'
        ? scheme.error
        : ticket.priority == 'Medium'
        ? scheme.secondary
        : scheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ticket.priority == 'High'
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
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ticket.ticketNo} • ${ticket.category}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ticket.student} • ${ticket.matricNo}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: ticket.priority, color: priorityColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ticket.summary,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: ticket.status),
              _MiniPill(label: ticket.owner),
              _MiniPill(label: ticket.sla),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Open'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.assignment_ind_outlined),
                label: const Text('Assign'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.escalator_warning_outlined),
                label: const Text('Escalate'),
              ),
              FilledButton.icon(
                onPressed: ticket.status == 'Resolved' ? null : () {},
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Resolve'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportActivityTile extends StatelessWidget {
  const _SupportActivityTile({required this.activity});

  final _SupportActivity activity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final severityColor = activity.severity == 'High'
        ? scheme.error
        : scheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: severityColor.withValues(alpha: 0.12),
        foregroundColor: severityColor,
        child: const Icon(Icons.history_outlined),
      ),
      title: Text(
        '${activity.title} • ${activity.ticketNo}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${activity.actor} • ${activity.detail} • ${activity.time}',
      ),
      trailing: _StatusBadge(text: activity.severity, color: severityColor),
    );
  }
}

class _HelpdeskChip extends StatelessWidget {
  const _HelpdeskChip({required this.label, required this.icon});

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

class _SupportTicket {
  const _SupportTicket({
    required this.ticketNo,
    required this.student,
    required this.matricNo,
    required this.category,
    required this.priority,
    required this.status,
    required this.owner,
    required this.summary,
    required this.sla,
  });

  final String ticketNo;
  final String student;
  final String matricNo;
  final String category;
  final String priority;
  final String status;
  final String owner;
  final String summary;
  final String sla;
}

class _SupportActivity {
  const _SupportActivity({
    required this.title,
    required this.ticketNo,
    required this.actor,
    required this.detail,
    required this.time,
    required this.severity,
  });

  final String title;
  final String ticketNo;
  final String actor;
  final String detail;
  final String time;
  final String severity;
}
