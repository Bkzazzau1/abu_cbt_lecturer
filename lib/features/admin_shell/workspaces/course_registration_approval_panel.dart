import 'package:flutter/material.dart';

class CourseRegistrationApprovalPanel extends StatelessWidget {
  const CourseRegistrationApprovalPanel({super.key});

  static const _requests = [
    _RegistrationRequest(
      student: 'Aisha Musa',
      matricNo: '2023/C/SENG/0188',
      programme: 'B.Sc Software Engineering',
      level: '300 Level',
      credits: 22,
      carryovers: 1,
      status: 'Carryover Review',
      issue: 'CSC 209 previous grade F. Confirm repeat eligibility.',
    ),
    _RegistrationRequest(
      student: 'Ibrahim Yahaya',
      matricNo: '2023/C/SENG/0400',
      programme: 'B.Sc Software Engineering',
      level: '300 Level',
      credits: 19,
      carryovers: 1,
      status: 'Submitted',
      issue:
          'Carryover selected from released record. Awaiting records confirmation.',
    ),
    _RegistrationRequest(
      student: 'Blessing John',
      matricNo: '2022/C/CSC/0112',
      programme: 'B.Sc Computer Science',
      level: '400 Level',
      credits: 27,
      carryovers: 2,
      status: 'Overload',
      issue: 'Credit load exceeds 24. Level adviser waiver required.',
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
                Icon(Icons.app_registration_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Course Registration Approval',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.rule_outlined),
                  label: const Text('Rules'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _ApprovalChip(
                  label: 'Pending: 31',
                  icon: Icons.pending_actions_outlined,
                ),
                _ApprovalChip(
                  label: 'Carryover review: 14',
                  icon: Icons.replay_circle_filled_outlined,
                ),
                _ApprovalChip(
                  label: 'Overload waiver: 6',
                  icon: Icons.warning_amber_outlined,
                ),
                _ApprovalChip(
                  label: 'Ready to approve: 11',
                  icon: Icons.verified_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final request in _requests)
              _RegistrationRequestTile(request: request),
          ],
        ),
      ),
    );
  }
}

class _RegistrationRequestTile extends StatelessWidget {
  const _RegistrationRequestTile({required this.request});

  final _RegistrationRequest request;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = request.status == 'Overload'
        ? scheme.error
        : request.status == 'Carryover Review'
        ? scheme.secondary
        : scheme.primary;

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
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.student} • ${request.matricNo}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text('${request.programme} • ${request.level}'),
                  ],
                ),
              ),
              _StatusBadge(text: request.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: '${request.credits} credits'),
              _MiniPill(label: '${request.carryovers} carryover/repeat'),
              _MiniPill(label: 'Core checked'),
              _MiniPill(label: 'Electives checked'),
            ],
          ),
          const SizedBox(height: 10),
          Text(request.issue, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Review'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Approve'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.close_outlined),
                label: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApprovalChip extends StatelessWidget {
  const _ApprovalChip({required this.label, required this.icon});

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

class _RegistrationRequest {
  const _RegistrationRequest({
    required this.student,
    required this.matricNo,
    required this.programme,
    required this.level,
    required this.credits,
    required this.carryovers,
    required this.status,
    required this.issue,
  });

  final String student;
  final String matricNo;
  final String programme;
  final String level;
  final int credits;
  final int carryovers;
  final String status;
  final String issue;
}
