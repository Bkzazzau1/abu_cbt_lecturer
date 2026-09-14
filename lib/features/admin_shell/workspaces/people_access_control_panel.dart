import 'package:flutter/material.dart';

class PeopleAccessControlPanel extends StatefulWidget {
  const PeopleAccessControlPanel({super.key});

  @override
  State<PeopleAccessControlPanel> createState() =>
      _PeopleAccessControlPanelState();
}

class _PeopleAccessControlPanelState extends State<PeopleAccessControlPanel> {
  String _selectedRole = 'All';
  String _selectedUnit = 'All';

  static const _staff = [
    _StaffAccount(
      name: 'Dr. A. Musa',
      staffId: 'STAFF-0012',
      role: 'Lecturer',
      unit: 'Computing',
      status: 'Active',
      permissions: 'Courses, Assignments, Marking, Notices',
      workload: '6 courses',
    ),
    _StaffAccount(
      name: 'Dr. L. Ibrahim',
      staffId: 'STAFF-0094',
      role: 'Moderator',
      unit: 'Computing',
      status: 'Active',
      permissions: 'Question Review, Rubrics, Comments',
      workload: '14 question sets',
    ),
    _StaffAccount(
      name: 'Mrs. Z. Bello',
      staffId: 'STAFF-0028',
      role: 'Exam Officer',
      unit: 'Faculty Office',
      status: 'Active',
      permissions: 'Exam Scheduling, Notices, Release Control',
      workload: '42 exams',
    ),
    _StaffAccount(
      name: 'Mr. S. Bala',
      staffId: 'STAFF-0041',
      role: 'Records Department',
      unit: 'Academic Registry',
      status: 'Active',
      permissions: 'Student Records, CGPA, Transcript Preview',
      workload: '74 record reviews',
    ),
    _StaffAccount(
      name: 'Mrs. E. John',
      staffId: 'STAFF-0181',
      role: 'Invigilator',
      unit: 'CBT Centre',
      status: 'Pending Setup',
      permissions: 'Check-in, Room Monitoring, Incidents',
      workload: '5 rooms',
    ),
  ];

  static const _rolePolicies = [
    _RolePolicy(
      role: 'Lecturer',
      policy:
          'Can manage own courses, assignments, marks, course notices and question drafts only.',
      risk: 'Medium',
    ),
    _RolePolicy(
      role: 'Moderator',
      policy:
          'Can review question sets, add comments, approve or return to lecturer.',
      risk: 'High',
    ),
    _RolePolicy(
      role: 'Exam Officer',
      policy:
          'Can schedule exams, publish official notices, package questions and release results.',
      risk: 'Critical',
    ),
    _RolePolicy(
      role: 'Records Department',
      policy:
          'Can reconcile student records, CGPA, transcript preview, cohorts and carryovers.',
      risk: 'Critical',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _staff
        .where((staff) => _selectedRole == 'All' || staff.role == _selectedRole)
        .where((staff) => _selectedUnit == 'All' || staff.unit == _selectedUnit)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'People / Staff Roles & Access Control',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Add staff'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _PeopleChip(
                  label: 'Staff accounts: 148',
                  icon: Icons.badge_outlined,
                ),
                _PeopleChip(
                  label: 'Active roles: 11',
                  icon: Icons.admin_panel_settings_outlined,
                ),
                _PeopleChip(
                  label: 'Pending setup: 8',
                  icon: Icons.pending_actions_outlined,
                ),
                _PeopleChip(
                  label: 'High-risk permissions: 14',
                  icon: Icons.security_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All roles')),
                      DropdownMenuItem(
                        value: 'Lecturer',
                        child: Text('Lecturer'),
                      ),
                      DropdownMenuItem(
                        value: 'Moderator',
                        child: Text('Moderator'),
                      ),
                      DropdownMenuItem(
                        value: 'Exam Officer',
                        child: Text('Exam Officer'),
                      ),
                      DropdownMenuItem(
                        value: 'Records Department',
                        child: Text('Records Department'),
                      ),
                      DropdownMenuItem(
                        value: 'Invigilator',
                        child: Text('Invigilator'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedRole = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedUnit,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All units')),
                      DropdownMenuItem(
                        value: 'Computing',
                        child: Text('Computing'),
                      ),
                      DropdownMenuItem(
                        value: 'Faculty Office',
                        child: Text('Faculty Office'),
                      ),
                      DropdownMenuItem(
                        value: 'Academic Registry',
                        child: Text('Academic Registry'),
                      ),
                      DropdownMenuItem(
                        value: 'CBT Centre',
                        child: Text('CBT Centre'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedUnit = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Staff accounts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final staff in filtered) _StaffTile(staff: staff),
            const SizedBox(height: 18),
            Text(
              'Permission policies',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final policy in _rolePolicies) _RolePolicyTile(policy: policy),
          ],
        ),
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({required this.staff});

  final _StaffAccount staff;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = staff.status == 'Active'
        ? scheme.primary
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
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${staff.name} • ${staff.staffId}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${staff.role} • ${staff.unit}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: staff.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: staff.permissions),
              _MiniPill(label: staff.workload),
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
                label: const Text('Profile'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('Permissions'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.assignment_ind_outlined),
                label: const Text('Assign work'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RolePolicyTile extends StatelessWidget {
  const _RolePolicyTile({required this.policy});

  final _RolePolicy policy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final riskColor = policy.risk == 'Critical'
        ? scheme.error
        : policy.risk == 'High'
        ? scheme.secondary
        : scheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: riskColor.withValues(alpha: 0.12),
        foregroundColor: riskColor,
        child: const Icon(Icons.security_outlined),
      ),
      title: Text(
        policy.role,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(policy.policy),
      trailing: _StatusBadge(text: policy.risk, color: riskColor),
    );
  }
}

class _PeopleChip extends StatelessWidget {
  const _PeopleChip({required this.label, required this.icon});

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

class _StaffAccount {
  const _StaffAccount({
    required this.name,
    required this.staffId,
    required this.role,
    required this.unit,
    required this.status,
    required this.permissions,
    required this.workload,
  });

  final String name;
  final String staffId;
  final String role;
  final String unit;
  final String status;
  final String permissions;
  final String workload;
}

class _RolePolicy {
  const _RolePolicy({
    required this.role,
    required this.policy,
    required this.risk,
  });

  final String role;
  final String policy;
  final String risk;
}
