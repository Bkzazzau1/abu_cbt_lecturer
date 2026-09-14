import 'package:flutter/material.dart';

class ReportsAnalyticsPanel extends StatefulWidget {
  const ReportsAnalyticsPanel({super.key});

  @override
  State<ReportsAnalyticsPanel> createState() => _ReportsAnalyticsPanelState();
}

class _ReportsAnalyticsPanelState extends State<ReportsAnalyticsPanel> {
  String _selectedReport = 'Management Summary';
  String _selectedPeriod = 'Current Semester';

  static const _kpis = [
    _ReportKpi(
      label: 'Active students',
      value: '18,420',
      detail: 'Regular, part-time and DLC combined',
      trend: '+4.2%',
      status: 'Good',
      icon: Icons.school_outlined,
    ),
    _ReportKpi(
      label: 'Course registrations',
      value: '92.6%',
      detail: 'Approved or pending approval',
      trend: '+2.1%',
      status: 'Good',
      icon: Icons.app_registration_outlined,
    ),
    _ReportKpi(
      label: 'Exam operations reports',
      value: '47',
      detail: '24 open, 7 escalated',
      trend: '-11%',
      status: 'Watch',
      icon: Icons.report_problem_outlined,
    ),
    _ReportKpi(
      label: 'Support SLA',
      value: '89%',
      detail: 'Tickets resolved within SLA',
      trend: '+6%',
      status: 'Good',
      icon: Icons.support_agent_outlined,
    ),
  ];

  static const _reports = [
    _ReportRow(
      title: 'Management Summary',
      owner: 'Management',
      category: 'Executive',
      metric: 'Student, registration, exam, result and support overview',
      status: 'Ready',
      frequency: 'Weekly',
    ),
    _ReportRow(
      title: 'Student Performance',
      owner: 'Academic Planning',
      category: 'Academic',
      metric: 'CGPA bands, pass/fail, weak areas, carryover trends',
      status: 'Ready',
      frequency: 'Semester',
    ),
    _ReportRow(
      title: 'Exam Operations',
      owner: 'Exam Office',
      category: 'Operations',
      metric: 'Incidents, app ID exceptions, check-in issues, escalations',
      status: 'Review',
      frequency: 'Per exam block',
    ),
    _ReportRow(
      title: 'Attendance & Live Classes',
      owner: 'DLC Operations',
      category: 'Learning',
      metric: 'Live attendance, replay usage, missed sessions, engagement',
      status: 'Ready',
      frequency: 'Monthly',
    ),
    _ReportRow(
      title: 'Support SLA',
      owner: 'Student Support',
      category: 'Operations',
      metric: 'Open tickets, overdue SLA, category aging, escalation rate',
      status: 'Ready',
      frequency: 'Daily',
    ),
  ];

  static const _insights = [
    _InsightItem(
      title: 'High carryover concentration',
      detail:
          'CSC 309 and SEN 301 show repeated support/result-review activity this semester.',
      impact: 'Academic Risk',
      severity: 'High',
    ),
    _InsightItem(
      title: 'DLC attendance improvement',
      detail:
          'Replay usage is helping distance learners recover missed live classes.',
      impact: 'Learning Outcome',
      severity: 'Low',
    ),
    _InsightItem(
      title: 'CBT upload issues reduced',
      detail:
          'Session sync exceptions are lower after room monitoring improvements.',
      impact: 'Exam Operations',
      severity: 'Medium',
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
                Icon(Icons.analytics_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Reports & Analytics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export report'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 260,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedReport,
                    items: const [
                      DropdownMenuItem(
                        value: 'Management Summary',
                        child: Text('Management Summary'),
                      ),
                      DropdownMenuItem(
                        value: 'Student Performance',
                        child: Text('Student Performance'),
                      ),
                      DropdownMenuItem(
                        value: 'Exam Operations',
                        child: Text('Exam Operations'),
                      ),
                      DropdownMenuItem(
                        value: 'Support SLA',
                        child: Text('Support SLA'),
                      ),
                    ],
                    onChanged: (value) => setState(
                      () => _selectedReport = value ?? 'Management Summary',
                    ),
                    decoration: const InputDecoration(labelText: 'Report type'),
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedPeriod,
                    items: const [
                      DropdownMenuItem(
                        value: 'Current Semester',
                        child: Text('Current Semester'),
                      ),
                      DropdownMenuItem(
                        value: 'Current Session',
                        child: Text('Current Session'),
                      ),
                      DropdownMenuItem(
                        value: 'Last 30 Days',
                        child: Text('Last 30 Days'),
                      ),
                      DropdownMenuItem(value: 'Today', child: Text('Today')),
                    ],
                    onChanged: (value) => setState(
                      () => _selectedPeriod = value ?? 'Current Semester',
                    ),
                    decoration: const InputDecoration(labelText: 'Period'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [for (final kpi in _kpis) _KpiCard(kpi: kpi)],
            ),
            const SizedBox(height: 18),
            Text(
              'Report catalogue',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final report in _reports) _ReportTile(report: report),
            const SizedBox(height: 18),
            Text(
              'Key insights',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final insight in _insights) _InsightTile(insight: insight),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi});

  final _ReportKpi kpi;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = kpi.status == 'Watch'
        ? scheme.secondary
        : scheme.primary;

    return SizedBox(
      width: 245,
      child: Card.filled(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.12),
                foregroundColor: statusColor,
                child: Icon(kpi.icon),
              ),
              const SizedBox(height: 16),
              Text(
                kpi.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                kpi.label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                kpi.detail,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              _StatusBadge(text: kpi.trend, color: statusColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});

  final _ReportRow report;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = report.status == 'Review'
        ? scheme.secondary
        : scheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.12),
        foregroundColor: statusColor,
        child: const Icon(Icons.summarize_outlined),
      ),
      title: Text(
        '${report.title} • ${report.category}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${report.owner} • ${report.metric} • ${report.frequency}',
      ),
      trailing: _StatusBadge(text: report.status, color: statusColor),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});

  final _InsightItem insight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final severityColor = insight.severity == 'High'
        ? scheme.error
        : insight.severity == 'Medium'
        ? scheme.secondary
        : scheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: severityColor.withValues(alpha: 0.12),
        foregroundColor: severityColor,
        child: const Icon(Icons.insights_outlined),
      ),
      title: Text(
        '${insight.title} • ${insight.impact}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(insight.detail),
      trailing: _StatusBadge(text: insight.severity, color: severityColor),
    );
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

class _ReportKpi {
  const _ReportKpi({
    required this.label,
    required this.value,
    required this.detail,
    required this.trend,
    required this.status,
    required this.icon,
  });
  final String label;
  final String value;
  final String detail;
  final String trend;
  final String status;
  final IconData icon;
}

class _ReportRow {
  const _ReportRow({
    required this.title,
    required this.owner,
    required this.category,
    required this.metric,
    required this.status,
    required this.frequency,
  });
  final String title;
  final String owner;
  final String category;
  final String metric;
  final String status;
  final String frequency;
}

class _InsightItem {
  const _InsightItem({
    required this.title,
    required this.detail,
    required this.impact,
    required this.severity,
  });
  final String title;
  final String detail;
  final String impact;
  final String severity;
}
