import 'package:flutter/material.dart';

class CohortManagementPanel extends StatefulWidget {
  const CohortManagementPanel({super.key});

  @override
  State<CohortManagementPanel> createState() => _CohortManagementPanelState();
}

class _CohortManagementPanelState extends State<CohortManagementPanel> {
  String _selectedMode = 'All';
  String _selectedStatus = 'All';

  static const _cohorts = [
    _CohortRecord(
      name: 'B.Sc Software Engineering 2023 Regular',
      cohortId: 'cohort-bsc-se-2023-regular',
      programme: 'B.Sc Software Engineering',
      department: 'Software Engineering',
      intakeYear: 2023,
      mode: 'Regular',
      level: 300,
      semester: 1,
      students: 218,
      status: 'Active',
      registration: 'Open',
      noticeTargeting: 'Enabled',
      resultMapping: 'Mapped',
    ),
    _CohortRecord(
      name: 'B.Sc Software Engineering 2024 DLC',
      cohortId: 'cohort-bsc-se-2024-dlc',
      programme: 'B.Sc Software Engineering DLC',
      department: 'DLC Computing',
      intakeYear: 2024,
      mode: 'Distance Learning',
      level: 200,
      semester: 3,
      students: 482,
      status: 'Review',
      registration: 'Pending Rules',
      noticeTargeting: 'Enabled',
      resultMapping: 'Needs Review',
    ),
    _CohortRecord(
      name: 'B.Sc Computer Science 2022 Part-Time',
      cohortId: 'cohort-bsc-csc-2022-pt',
      programme: 'B.Sc Computer Science',
      department: 'Computer Science',
      intakeYear: 2022,
      mode: 'Part-Time',
      level: 400,
      semester: 2,
      students: 164,
      status: 'Active',
      registration: 'Locked',
      noticeTargeting: 'Enabled',
      resultMapping: 'Mapped',
    ),
    _CohortRecord(
      name: 'GST 300 Shared Course Group',
      cohortId: 'cohort-gst-300-shared',
      programme: 'General Studies Courses',
      department: 'GST Unit',
      intakeYear: 2023,
      mode: 'Shared',
      level: 300,
      semester: 1,
      students: 1204,
      status: 'Active',
      registration: 'Course Linked',
      noticeTargeting: 'Enabled',
      resultMapping: 'Mapped',
    ),
  ];

  static const _actions = [
    _CohortAction(
      title: 'Course registration rules pending',
      cohortId: 'cohort-bsc-se-2024-dlc',
      owner: 'Department Admin',
      detail:
          'DLC semester 3 credit load and elective rules must be confirmed before registration opens.',
      severity: 'High',
    ),
    _CohortAction(
      title: 'Result mapping review',
      cohortId: 'cohort-bsc-se-2024-dlc',
      owner: 'Records Department',
      detail:
          'Repeat/carryover mapping for DLC students needs records confirmation.',
      severity: 'Medium',
    ),
    _CohortAction(
      title: 'Notice targeting verified',
      cohortId: 'cohort-bsc-se-2023-regular',
      owner: 'Exam Office',
      detail:
          'Cohort is available for targeted notices and acknowledgement tracking.',
      severity: 'Low',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _cohorts
        .where(
          (cohort) => _selectedMode == 'All' || cohort.mode == _selectedMode,
        )
        .where(
          (cohort) =>
              _selectedStatus == 'All' || cohort.status == _selectedStatus,
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
                Icon(Icons.groups_2_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cohort Management',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Create cohort'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _CohortChip(
                  label: 'Active cohorts: 62',
                  icon: Icons.groups_2_outlined,
                ),
                _CohortChip(label: 'Regular: 34', icon: Icons.school_outlined),
                _CohortChip(
                  label: 'Part-time: 11',
                  icon: Icons.schedule_outlined,
                ),
                _CohortChip(
                  label: 'DLC: 9',
                  icon: Icons.cast_for_education_outlined,
                ),
                _CohortChip(
                  label: 'Needs review: 8',
                  icon: Icons.report_problem_outlined,
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
                    initialValue: _selectedMode,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All modes')),
                      DropdownMenuItem(
                        value: 'Regular',
                        child: Text('Regular'),
                      ),
                      DropdownMenuItem(
                        value: 'Part-Time',
                        child: Text('Part-Time'),
                      ),
                      DropdownMenuItem(
                        value: 'Distance Learning',
                        child: Text('Distance Learning'),
                      ),
                      DropdownMenuItem(value: 'Shared', child: Text('Shared')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedMode = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Mode'),
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
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Review', child: Text('Review')),
                      DropdownMenuItem(
                        value: 'Archived',
                        child: Text('Archived'),
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
              'Cohort registry',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final cohort in filtered) _CohortTile(cohort: cohort),
            const SizedBox(height: 18),
            Text(
              'Cohort actions & risks',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final action in _actions) _CohortActionTile(action: action),
          ],
        ),
      ),
    );
  }
}

class _CohortTile extends StatelessWidget {
  const _CohortTile({required this.cohort});

  final _CohortRecord cohort;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = cohort.status == 'Review'
        ? scheme.error
        : scheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cohort.status == 'Review'
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
                      cohort.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cohort.cohortId} • ${cohort.programme} • ${cohort.department}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: cohort.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: '${cohort.intakeYear} intake'),
              _MiniPill(label: cohort.mode),
              _MiniPill(label: '${cohort.level} Level'),
              _MiniPill(label: 'Semester ${cohort.semester}'),
              _MiniPill(label: '${cohort.students} students'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: 'Registration: ${cohort.registration}'),
              _MiniPill(label: 'Notices: ${cohort.noticeTargeting}'),
              _MiniPill(label: 'Results: ${cohort.resultMapping}'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.people_outline),
                label: const Text('Students'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.app_registration_outlined),
                label: const Text('Registration rules'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.campaign_outlined),
                label: const Text('Notice target'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit cohort'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CohortActionTile extends StatelessWidget {
  const _CohortActionTile({required this.action});

  final _CohortAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final severityColor = action.severity == 'High'
        ? scheme.error
        : action.severity == 'Medium'
        ? scheme.secondary
        : scheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: severityColor.withValues(alpha: 0.12),
        foregroundColor: severityColor,
        child: const Icon(Icons.flag_outlined),
      ),
      title: Text(
        '${action.title} • ${action.cohortId}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text('${action.owner} • ${action.detail}'),
      trailing: _StatusBadge(text: action.severity, color: severityColor),
    );
  }
}

class _CohortChip extends StatelessWidget {
  const _CohortChip({required this.label, required this.icon});

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

class _CohortRecord {
  const _CohortRecord({
    required this.name,
    required this.cohortId,
    required this.programme,
    required this.department,
    required this.intakeYear,
    required this.mode,
    required this.level,
    required this.semester,
    required this.students,
    required this.status,
    required this.registration,
    required this.noticeTargeting,
    required this.resultMapping,
  });

  final String name;
  final String cohortId;
  final String programme;
  final String department;
  final int intakeYear;
  final String mode;
  final int level;
  final int semester;
  final int students;
  final String status;
  final String registration;
  final String noticeTargeting;
  final String resultMapping;
}

class _CohortAction {
  const _CohortAction({
    required this.title,
    required this.cohortId,
    required this.owner,
    required this.detail,
    required this.severity,
  });

  final String title;
  final String cohortId;
  final String owner;
  final String detail;
  final String severity;
}
