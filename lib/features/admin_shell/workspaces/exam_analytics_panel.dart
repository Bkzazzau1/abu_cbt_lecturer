import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_analytics_state.dart';
import '../../exam_officer/data/exam_officer_academic_registry.dart';

enum ExamAnalyticsAudience { examOfficer, hod }

class ExamAnalyticsPanel extends StatefulWidget {
  const ExamAnalyticsPanel({
    super.key,
    required this.audience,
  });

  final ExamAnalyticsAudience audience;

  @override
  State<ExamAnalyticsPanel> createState() => _ExamAnalyticsPanelState();
}

class _ExamAnalyticsPanelState extends State<ExamAnalyticsPanel> {
  final ExamAnalyticsState _state = ExamAnalyticsState.instance;
  String _level = 'All Levels';
  String? _courseCode;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final visibleCourses = _state.coursesForLevel(_level);
        final selected = _selectedCourse(visibleCourses);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            const SizedBox(height: 16),
            _filters(context, visibleCourses, selected),
            const SizedBox(height: 16),
            _kpis(context),
            const SizedBox(height: 16),
            _decisionStrip(context),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1080;
                final width = wide
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: width,
                      child: _CoursePassRateCard(courses: visibleCourses),
                    ),
                    SizedBox(
                      width: width,
                      child: _ScoreDistributionCard(course: selected),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _HistoricalTrendCard(course: selected),
            const SizedBox(height: 16),
            _SelectedExamOverviewCard(course: selected),
            const SizedBox(height: 16),
            _LevelPerformanceCard(levels: _state.levelSummaries),
            const SizedBox(height: 16),
            _WeakCourseIntelligenceCard(
              courses: _state.weakCourses,
              audience: widget.audience,
            ),
            const SizedBox(height: 16),
            _HistoricalDataTable(course: selected),
          ],
        );
      },
    );
  }

  ExamAnalyticsCourseSnapshot _selectedCourse(
    List<ExamAnalyticsCourseSnapshot> visibleCourses,
  ) {
    if (visibleCourses.isEmpty) return _state.courses.first;
    if (_courseCode != null) {
      for (final item in visibleCourses) {
        if (item.courseCode == _courseCode) return item;
      }
    }
    return visibleCourses.first;
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isHod = widget.audience == ExamAnalyticsAudience.hod;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 16,
          runSpacing: 14,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                        child: const Icon(Icons.analytics_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isHod
                              ? 'Department Exam Analytics & Intelligence'
                              : 'Exam Analytics & Decision Intelligence',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isHod
                        ? 'Department-level evidence for academic supervision: performance trends, weak courses, historical movement, result quality, carryover pressure and examination readiness.'
                        : 'A single decision page for current examinations, historical performance, weak-course detection, candidate pressure, timetable coverage, invigilation readiness and result trends.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(Icons.history_outlined, size: 18),
                  label: Text('5-session trend'),
                ),
                Chip(
                  avatar: Icon(Icons.auto_graph_outlined, size: 18),
                  label: Text('Decision signals'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters(
    BuildContext context,
    List<ExamAnalyticsCourseSnapshot> courses,
    ExamAnalyticsCourseSnapshot selected,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 210,
              child: DropdownButtonFormField<String>(
                initialValue: _level,
                decoration: const InputDecoration(
                  labelText: 'Level',
                  prefixIcon: Icon(Icons.layers_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'All Levels',
                    child: Text('All Levels'),
                  ),
                  for (final level in ExamOfficerAcademicRegistry.levels)
                    DropdownMenuItem(value: level, child: Text(level)),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _level = value;
                    _courseCode = null;
                  });
                },
              ),
            ),
            SizedBox(
              width: 330,
              child: DropdownButtonFormField<String>(
                value: selected.courseCode,
                decoration: const InputDecoration(
                  labelText: 'Particular exam / course',
                  prefixIcon: Icon(Icons.manage_search_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final course in courses)
                    DropdownMenuItem(
                      value: course.courseCode,
                      child: Text(
                        '${course.courseCode} — ${course.courseTitle}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: courses.isEmpty
                    ? null
                    : (value) => setState(() => _courseCode = value),
              ),
            ),
            Chip(
              avatar: const Icon(Icons.school_outlined, size: 18),
              label: Text('${selected.level} • ${selected.semester}'),
            ),
            Chip(
              avatar: const Icon(Icons.calendar_month_outlined, size: 18),
              label: const Text('Current: 2025/2026'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpis(BuildContext context) {
    final all = _state.courses;
    final carryovers = all.fold<int>(
      0,
      (sum, item) => sum + item.carryoverCandidates,
    );
    final cards = [
      _AnalyticsKpi(
        label: 'Department pass rate',
        value: '${_state.departmentPassRate.toStringAsFixed(1)}%',
        detail: 'Weighted current-session performance',
        icon: Icons.task_alt_outlined,
      ),
      _AnalyticsKpi(
        label: 'Current average',
        value: _state.departmentAverage.toStringAsFixed(1),
        detail: 'Weighted department mean score',
        icon: Icons.insights_outlined,
      ),
      _AnalyticsKpi(
        label: 'Weak / watch courses',
        value: '${_state.weakCourses.length}',
        detail: 'Risk score requires management attention',
        icon: Icons.warning_amber_outlined,
      ),
      _AnalyticsKpi(
        label: 'Carryover registrations',
        value: '$carryovers',
        detail: 'Repeat/carryover load across exam courses',
        icon: Icons.replay_outlined,
      ),
      _AnalyticsKpi(
        label: 'Scheduled courses',
        value: '${_state.scheduledCourseCount}/${all.length}',
        detail: 'Courses with at least one timetable sitting',
        icon: Icons.event_available_outlined,
      ),
      _AnalyticsKpi(
        label: 'Invigilation covered',
        value:
            '${_state.fullyInvigilatedCourseCount}/${_state.scheduledCourseCount}',
        detail: 'Scheduled courses with posted invigilators',
        icon: Icons.groups_outlined,
      ),
      _AnalyticsKpi(
        label: 'Results verified',
        value: '${_state.resultReadyCourseCount}/${all.length}',
        detail: 'Verified or already forwarded result batches',
        icon: Icons.verified_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 1180
            ? (constraints.maxWidth - 48) / 4
            : constraints.maxWidth >= 700
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final item in cards)
              SizedBox(width: cardWidth, child: _KpiCard(item: item)),
          ],
        );
      },
    );
  }

  Widget _decisionStrip(BuildContext context) {
    final weak = _state.weakCourses;
    final scheme = Theme.of(context).colorScheme;
    final isHod = widget.audience == ExamAnalyticsAudience.hod;
    final top = weak.isEmpty ? null : weak.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, color: scheme.onSecondaryContainer),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Text(
              top == null
                  ? 'No course currently crosses the watch threshold. Continue monitoring historical trend and carryover pressure.'
                  : isHod
                      ? '${top.courseCode} currently has the strongest department attention signal (${top.riskScore}/100). Review ${top.riskReasons.take(3).join(', ')} before the next departmental decision meeting.'
                      : '${top.courseCode} currently has the strongest operational/academic risk signal (${top.riskScore}/100). Prioritise ${top.riskReasons.take(3).join(', ')} and track the next workflow action.',
              style: TextStyle(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsKpi {
  const _AnalyticsKpi({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.item});

  final _AnalyticsKpi item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, color: scheme.primary),
            const SizedBox(height: 14),
            Text(
              item.value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(item.label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              item.detail,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoursePassRateCard extends StatelessWidget {
  const _CoursePassRateCard({required this.courses});

  final List<ExamAnalyticsCourseSnapshot> courses;

  @override
  Widget build(BuildContext context) {
    final sorted = [...courses]..sort((a, b) => a.passRate.compareTo(b.passRate));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.bar_chart_outlined,
              title: 'Course pass-rate comparison',
              subtitle: 'Lowest pass rates appear first for faster intervention.',
            ),
            const SizedBox(height: 16),
            for (final course in sorted)
              Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: _MetricBar(
                  label: course.courseCode,
                  value: course.passRate,
                  suffix: '%',
                  trailing: course.riskLabel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScoreDistributionCard extends StatelessWidget {
  const _ScoreDistributionCard({required this.course});

  final ExamAnalyticsCourseSnapshot course;

  @override
  Widget build(BuildContext context) {
    final values = course.scoreBands.values.toList();
    final scheme = Theme.of(context).colorScheme;
    final colors = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.error,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.pie_chart_outline,
              title: '${course.courseCode} score distribution',
              subtitle: 'Current-session result rows grouped by score band.',
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: _DonutPainter(values: values, colors: colors),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${values.fold<int>(0, (a, b) => a + b)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const Text('result rows'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      for (var i = 0; i < course.scoreBands.length; i++)
                        SizedBox(
                          width: 120,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colors[i],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  '${course.scoreBands.keys.elementAt(i)}: ${course.scoreBands.values.elementAt(i)}',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricalTrendCard extends StatelessWidget {
  const _HistoricalTrendCard({required this.course});

  final ExamAnalyticsCourseSnapshot course;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.show_chart_outlined,
              title: '${course.courseCode} historical examination trend',
              subtitle:
                  'Five academic sessions: pass rate and average score on the same 0–100 scale.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _LegendDot(color: scheme.primary, label: 'Pass rate'),
                _LegendDot(color: scheme.secondary, label: 'Average score'),
                Text(
                  'Change vs previous session: ${course.passRateChange >= 0 ? '+' : ''}${course.passRateChange.toStringAsFixed(1)} pp',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 280,
              child: CustomPaint(
                painter: _TrendPainter(
                  points: course.history,
                  passColor: scheme.primary,
                  averageColor: scheme.secondary,
                  gridColor: scheme.outlineVariant,
                  textColor: scheme.onSurfaceVariant,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedExamOverviewCard extends StatelessWidget {
  const _SelectedExamOverviewCard({required this.course});

  final ExamAnalyticsCourseSnapshot course;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Registered candidates', '${course.registeredCandidates}'),
      ('Carryover candidates', '${course.carryoverCandidates}'),
      ('Class average', course.averageScore.toStringAsFixed(1)),
      ('Pass rate', '${course.passRate.toStringAsFixed(1)}%'),
      ('Fail rate', '${course.failRate.toStringAsFixed(1)}%'),
      ('Moderation adjustment', '${course.moderationAdjustment >= 0 ? '+' : ''}${course.moderationAdjustment}'),
      ('Exam sittings', '${course.sittingCount}'),
      ('Scheduled capacity', '${course.scheduledCapacity}'),
      ('Capacity coverage', '${course.capacityCoverage.toStringAsFixed(0)}%'),
      ('Invigilators posted', '${course.invigilatorCount}'),
      ('Question stage', course.questionStatus),
      ('Result stage', course.resultStatus),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.fact_check_outlined,
              title: '${course.courseCode} — full examination overview',
              subtitle:
                  '${course.courseTitle} • ${course.level} • ${course.semester}',
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth >= 1000
                    ? (constraints.maxWidth - 36) / 4
                    : constraints.maxWidth >= 620
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: width,
                        child: _InfoTile(label: item.$1, value: item.$2),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Decision signals',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.speed_outlined, size: 18),
                  label: Text('Risk ${course.riskScore}/100 • ${course.riskLabel}'),
                ),
                for (final reason in course.riskReasons)
                  Chip(label: Text(reason)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelPerformanceCard extends StatelessWidget {
  const _LevelPerformanceCard({required this.levels});

  final List<ExamAnalyticsLevelSummary> levels;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              icon: Icons.stacked_bar_chart_outlined,
              title: 'Performance by level',
              subtitle:
                  'Weighted pass rate across the courses registered to each level.',
            ),
            const SizedBox(height: 16),
            for (final level in levels)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        level.level,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(
                      child: _MetricBar(
                        label: '${level.courseCount} courses',
                        value: level.passRate,
                        suffix: '%',
                        trailing: '${level.weakCourses} weak/watch',
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 105,
                      child: Text(
                        'Avg ${level.averageScore.toStringAsFixed(1)}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeakCourseIntelligenceCard extends StatelessWidget {
  const _WeakCourseIntelligenceCard({
    required this.courses,
    required this.audience,
  });

  final List<ExamAnalyticsCourseSnapshot> courses;
  final ExamAnalyticsAudience audience;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.crisis_alert_outlined,
              title: 'Weak-course & attention intelligence',
              subtitle: audience == ExamAnalyticsAudience.hod
                  ? 'Courses ranked for HoD attention using performance, trend, carryover pressure and workflow readiness.'
                  : 'Courses ranked for Exam Officer follow-up using performance, trend, carryover pressure and operational readiness.',
            ),
            const SizedBox(height: 14),
            if (courses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No course currently crosses the watch threshold.')),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Course')),
                    DataColumn(label: Text('Risk')),
                    DataColumn(label: Text('Pass')),
                    DataColumn(label: Text('Average')),
                    DataColumn(label: Text('Trend')),
                    DataColumn(label: Text('Carryover')),
                    DataColumn(label: Text('Attention reason')),
                  ],
                  rows: [
                    for (final course in courses)
                      DataRow(
                        cells: [
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.courseCode,
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                                Text(course.level),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              '${course.riskScore}/100',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: course.riskScore >= 55
                                    ? scheme.error
                                    : scheme.secondary,
                              ),
                            ),
                          ),
                          DataCell(Text('${course.passRate.toStringAsFixed(1)}%')),
                          DataCell(Text(course.averageScore.toStringAsFixed(1))),
                          DataCell(
                            Text(
                              '${course.passRateChange >= 0 ? '+' : ''}${course.passRateChange.toStringAsFixed(1)} pp',
                            ),
                          ),
                          DataCell(Text('${course.carryoverRate.toStringAsFixed(1)}%')),
                          DataCell(
                            SizedBox(
                              width: 320,
                              child: Text(course.riskReasons.join(' • ')),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoricalDataTable extends StatelessWidget {
  const _HistoricalDataTable({required this.course});

  final ExamAnalyticsCourseSnapshot course;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.table_chart_outlined,
              title: '${course.courseCode} historical dataset',
              subtitle:
                  'Tabular evidence behind the trend chart. Previous sessions are seeded demo history; 2025/2026 reflects the current mock workflow.',
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Academic session')),
                  DataColumn(label: Text('Candidates')),
                  DataColumn(label: Text('Average score')),
                  DataColumn(label: Text('Pass rate')),
                  DataColumn(label: Text('Fail rate')),
                ],
                rows: [
                  for (final point in course.history)
                    DataRow(
                      cells: [
                        DataCell(Text(point.session)),
                        DataCell(Text('${point.candidateCount}')),
                        DataCell(Text(point.averageScore.toStringAsFixed(1))),
                        DataCell(Text('${point.passRate.toStringAsFixed(1)}%')),
                        DataCell(Text('${point.failRate.toStringAsFixed(1)}%')),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.suffix,
    required this.trailing,
  });

  final String label;
  final double value;
  final String suffix;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            Text(
              '${value.toStringAsFixed(1)}$suffix',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 10),
            Text(trailing, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: clamped / 100,
          minHeight: 9,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.values, required this.colors});

  final List<int> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (sum, item) => sum + item);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.42;
    final rect = Rect.fromCircle(center: center, radius: radius);
    if (total <= 0) return;

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.38
        ..strokeCap = StrokeCap.butt
        ..color = colors[i % colors.length];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.colors != colors;
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.points,
    required this.passColor,
    required this.averageColor,
    required this.gridColor,
    required this.textColor,
  });

  final List<ExamAnalyticsHistoryPoint> points;
  final Color passColor;
  final Color averageColor;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const left = 42.0;
    const right = 14.0;
    const top = 10.0;
    const bottom = 42.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final value in [0, 25, 50, 75, 100]) {
      final y = top + chartHeight * (1 - value / 100);
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
      _text(canvas, '$value', Offset(4, y - 7), 10, textColor);
    }

    final passPath = Path();
    final averagePath = Path();
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? left + chartWidth / 2
          : left + chartWidth * i / (points.length - 1);
      final passY = top + chartHeight * (1 - points[i].passRate / 100);
      final avgY = top + chartHeight * (1 - points[i].averageScore / 100);
      if (i == 0) {
        passPath.moveTo(x, passY);
        averagePath.moveTo(x, avgY);
      } else {
        passPath.lineTo(x, passY);
        averagePath.lineTo(x, avgY);
      }
      _text(
        canvas,
        points[i].session.replaceAll('20', '').replaceAll('/', '/'),
        Offset(x - 24, size.height - 26),
        9,
        textColor,
      );
      canvas.drawCircle(Offset(x, passY), 4, Paint()..color = passColor);
      canvas.drawCircle(Offset(x, avgY), 4, Paint()..color = averageColor);
    }

    canvas.drawPath(
      passPath,
      Paint()
        ..color = passColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      averagePath,
      Paint()
        ..color = averageColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _text(
    Canvas canvas,
    String text,
    Offset offset,
    double size,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) => true;
}
