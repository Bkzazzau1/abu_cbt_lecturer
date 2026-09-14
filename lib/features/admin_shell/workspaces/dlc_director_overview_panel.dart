import 'package:flutter/material.dart';

class DlcDirectorOverviewPanel extends StatelessWidget {
  const DlcDirectorOverviewPanel({super.key});

  static const _progressItems = [
    _ProgressItem(
      'Student enrolment by programme',
      0.86,
      Icons.groups_2_outlined,
    ),
    _ProgressItem('Course upload progress', 0.72, Icons.cloud_upload_outlined),
    _ProgressItem('Lecturer activity', 0.78, Icons.school_outlined),
    _ProgressItem('Student login activity', 0.81, Icons.login_outlined),
    _ProgressItem('Exam readiness', 0.64, Icons.fact_check_outlined),
    _ProgressItem(
      'Result submission status',
      0.58,
      Icons.workspace_premium_outlined,
    ),
  ];

  static const _alerts = [
    _AlertItem(
      'CSC 301 exam questions not submitted',
      'Computer Science - 300L',
      Icons.quiz_outlined,
    ),
    _AlertItem(
      'BUS 101 moderation pending',
      'Faculty of Management',
      Icons.rule_folder_outlined,
    ),
    _AlertItem(
      'ACC 202 result not approved',
      'Exam Officer queue',
      Icons.assignment_late_outlined,
    ),
    _AlertItem(
      'Inactive level coordinator',
      'Public Administration - 200L',
      Icons.person_off_outlined,
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
                  Icons.cast_for_education_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'DLC Director Command Centre',
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
              'Administrative visibility across staff, lecturers, programmes, students, courses, exams, approvals, support, and reports.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 920;
                final chartWidth = wide
                    ? (constraints.maxWidth - 14) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    SizedBox(
                      width: chartWidth,
                      child: _ProgressPanel(items: _progressItems),
                    ),
                    SizedBox(
                      width: chartWidth,
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

class DlcDirectorSectionPanel extends StatelessWidget {
  const DlcDirectorSectionPanel({super.key, required this.section});

  final String section;

  static const _sections = {
    'Staff Management': _DirectorSectionConfig(
      title: 'Staff Management',
      subtitle:
          'Supervise DLC staff accounts, role coverage, access requests, and inactive staff.',
      icon: Icons.manage_accounts_outlined,
      metrics: [
        _DirectorMetric('Active staff', '118', Icons.badge_outlined),
        _DirectorMetric('Role gaps', '7', Icons.person_search_outlined),
        _DirectorMetric('Pending access', '14', Icons.lock_clock_outlined),
      ],
      tasks: [
        'Approve new departmental officer access',
        'Review inactive course support staff',
        'Confirm reporting team separation from academic roles',
      ],
    ),
    'Lecturer Monitoring': _DirectorSectionConfig(
      title: 'Lecturer Monitoring',
      subtitle:
          'Track course delivery, materials, live classes, assignment marking, and result readiness.',
      icon: Icons.school_outlined,
      metrics: [
        _DirectorMetric('Active lecturers', '64', Icons.groups_outlined),
        _DirectorMetric('Materials due', '11', Icons.upload_file_outlined),
        _DirectorMetric('Marking overdue', '9', Icons.edit_note_outlined),
      ],
      tasks: [
        'CSC 305 exam scripts still awaiting theory marking',
        'CSC 201 live session attendance report ready',
        'SEN 301 assignment feedback delayed by 2 days',
      ],
    ),
    'Departments & Programmes': _DirectorSectionConfig(
      title: 'Departments & Programmes',
      subtitle:
          'View department structure, programmes, levels, cohorts, and academic ownership.',
      icon: Icons.account_tree_outlined,
      metrics: [
        _DirectorMetric('Departments', '12', Icons.apartment_outlined),
        _DirectorMetric('Programmes', '38', Icons.menu_book_outlined),
        _DirectorMetric('Cohorts', '62', Icons.diversity_3_outlined),
      ],
      tasks: [
        'Computer Science 300L adviser reassignment pending',
        'Public Administration 200L cohort needs approval',
        'DLC programme ownership audit due this week',
      ],
    ),
    'Course Management': _DirectorSectionConfig(
      title: 'Course Management',
      subtitle:
          'Monitor course registration approvals, course visibility, and material readiness.',
      icon: Icons.fact_check_outlined,
      metrics: [
        _DirectorMetric('Courses live', '214', Icons.menu_book_outlined),
        _DirectorMetric('Reg exceptions', '31', Icons.rule_outlined),
        _DirectorMetric('Needs upload', '18', Icons.cloud_upload_outlined),
      ],
      tasks: [
        'CSC 305 material package ready for final publishing',
        'BUS 101 registration exception needs department decision',
        'GST 303 course outline missing lecturer confirmation',
      ],
    ),
    'Student Management': _DirectorSectionConfig(
      title: 'Student Management',
      subtitle:
          'Supervise student records, engagement, attendance risk, and cohort health.',
      icon: Icons.groups_2_outlined,
      metrics: [
        _DirectorMetric('Students', '18,420', Icons.person_outline),
        _DirectorMetric('At risk', '286', Icons.warning_amber_outlined),
        _DirectorMetric('Record issues', '42', Icons.folder_off_outlined),
      ],
      tasks: [
        'Review students with repeated live-session absence',
        'Resolve duplicate records sent by Academic Records',
        'Confirm carryover visibility for 400L students',
      ],
    ),
    'Exams & Assessments': _DirectorSectionConfig(
      title: 'Exams & Assessments',
      subtitle:
          'Watch examination readiness, question moderation, invigilation setup, and incidents.',
      icon: Icons.assignment_outlined,
      metrics: [
        _DirectorMetric('Exam drafts', '44', Icons.quiz_outlined),
        _DirectorMetric('Moderation', '9', Icons.rule_folder_outlined),
        _DirectorMetric('Incidents', '3', Icons.report_outlined),
      ],
      tasks: [
        'CSC 301 questions not submitted',
        'CBT venue readiness report awaiting exam officer',
        'Moderator returned BUS 101 question set for correction',
      ],
    ),
    'Approvals': _DirectorSectionConfig(
      title: 'Approvals',
      subtitle:
          'Director-level approvals for policies, escalations, publishing, and release gates.',
      icon: Icons.approval_outlined,
      metrics: [
        _DirectorMetric('Pending', '23', Icons.pending_actions_outlined),
        _DirectorMetric('Escalated', '5', Icons.priority_high_outlined),
        _DirectorMetric('Released', '71', Icons.verified_outlined),
      ],
      tasks: [
        'Approve result release batch after Exam Officer sign-off',
        'Review returned moderation correction summary',
        'Approve new staff access scope for support team',
      ],
    ),
    'System Activity': _DirectorSectionConfig(
      title: 'System Activity',
      subtitle:
          'Monitor portal health, login activity, integrations, audit trails, and live activity.',
      icon: Icons.monitor_heart_outlined,
      metrics: [
        _DirectorMetric('Live users', '1,842', Icons.sensors_outlined),
        _DirectorMetric('Sync issues', '4', Icons.sync_problem_outlined),
        _DirectorMetric('Audit events', '918', Icons.history_outlined),
      ],
      tasks: [
        'Student portal sync completed for assignments',
        'Two support-team route access attempts blocked',
        'Attendance reports synced to records queue',
      ],
    ),
    'Settings': _DirectorSectionConfig(
      title: 'Director Settings',
      subtitle:
          'Control supervisory defaults, route visibility, approval thresholds, and reports.',
      icon: Icons.settings_outlined,
      metrics: [
        _DirectorMetric('Policies', '12', Icons.policy_outlined),
        _DirectorMetric('Locked routes', '8', Icons.lock_outline),
        _DirectorMetric('Report rules', '16', Icons.tune_outlined),
      ],
      tasks: [
        'Keep support and reports activities private to those teams',
        'Require moderation before exam question release',
        'Enable director summaries without exposing invigilator workspaces',
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    if (section == 'Overview') {
      return const DlcDirectorOverviewPanel();
    }

    final config =
        _sections[section] ??
        _DirectorSectionConfig(
          title: section,
          subtitle: 'Director-only supervisory section.',
          icon: Icons.dashboard_customize_outlined,
          metrics: const [
            _DirectorMetric('Open items', '0', Icons.inbox_outlined),
            _DirectorMetric('Alerts', '0', Icons.notifications_none_outlined),
            _DirectorMetric('Ready', '0', Icons.verified_outlined),
          ],
          tasks: const ['No active director action in this section'],
        );

    return _DirectorSectionWorkspace(config: config);
  }
}

class _DirectorSectionWorkspace extends StatelessWidget {
  const _DirectorSectionWorkspace({required this.config});

  final _DirectorSectionConfig config;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(config.icon, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    config.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Review section'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(config.subtitle, style: text.bodyMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final metric in config.metrics)
                  _DirectorMetricChip(metric: metric),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Director action list',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final task in config.tasks) _DirectorTaskRow(task),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectorMetricChip extends StatelessWidget {
  const _DirectorMetricChip({required this.metric});

  final _DirectorMetric metric;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(metric.icon, color: scheme.primary),
          const SizedBox(width: 10),
          Text(
            '${metric.label}: ${metric.value}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _DirectorTaskRow extends StatelessWidget {
  const _DirectorTaskRow(this.task);

  final String task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: scheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(task)),
        ],
      ),
    );
  }
}

class _DirectorSectionConfig {
  const _DirectorSectionConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.metrics,
    required this.tasks,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<_DirectorMetric> metrics;
  final List<String> tasks;
}

class _DirectorMetric {
  const _DirectorMetric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.items});

  final List<_ProgressItem> items;

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
              'Operational charts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final item in items) _ProgressRow(item: item),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.item});

  final _ProgressItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(item.value * 100).round()}%'),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: item.value,
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

  final List<_AlertItem> alerts;

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
              'Priority alerts',
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

  final _AlertItem alert;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alert.icon, color: scheme.error),
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
                  maxLines: 1,
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

class _ProgressItem {
  const _ProgressItem(this.label, this.value, this.icon);

  final String label;
  final double value;
  final IconData icon;
}

class _AlertItem {
  const _AlertItem(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}
