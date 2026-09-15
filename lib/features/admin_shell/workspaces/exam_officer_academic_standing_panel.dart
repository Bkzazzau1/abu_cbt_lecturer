import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_academic_registry.dart';
import '../../exam_officer/data/exam_officer_academic_standing_state.dart';

class ExamOfficerAcademicStandingPanel extends StatefulWidget {
  const ExamOfficerAcademicStandingPanel({super.key});

  @override
  State<ExamOfficerAcademicStandingPanel> createState() =>
      _ExamOfficerAcademicStandingPanelState();
}

class _ExamOfficerAcademicStandingPanelState
    extends State<ExamOfficerAcademicStandingPanel> {
  final ExamOfficerAcademicStandingState _state =
      ExamOfficerAcademicStandingState.instance;
  final TextEditingController _searchController = TextEditingController();

  String _level = 'All Levels';
  String _standing = 'All Standing';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final all = _state.allRecords;
        final filtered = _filtered(all);
        final probation = all
            .where((item) => item.standing == AcademicStandingStatus.probation)
            .length;
        final withdrawal = all
            .where(
              (item) =>
                  item.standing == AcademicStandingStatus.withdrawalReview,
            )
            .length;
        final good = all.length - probation - withdrawal;
        final failedEntries = all.fold<int>(
          0,
          (sum, item) => sum + item.failedCourses,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final cardWidth = width > 1100
                            ? (width - 36) / 4
                            : width > 650
                                ? (width - 12) / 2
                                : width;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _metric(
                              context,
                              width: cardWidth,
                              icon: Icons.groups_2_outlined,
                              label: 'Students Calculated',
                              value: '${all.length}',
                              detail: ExamOfficerAcademicStandingState
                                  .academicSession,
                            ),
                            _metric(
                              context,
                              width: cardWidth,
                              icon: Icons.verified_outlined,
                              label: 'Good Standing',
                              value: '$good',
                              detail: 'CGPA 1.00 and above',
                            ),
                            _metric(
                              context,
                              width: cardWidth,
                              icon: Icons.warning_amber_outlined,
                              label: 'Probation',
                              value: '$probation',
                              detail: 'CGPA below 1.00',
                            ),
                            _metric(
                              context,
                              width: cardWidth,
                              icon: Icons.report_problem_outlined,
                              label: 'Withdrawal Review',
                              value: '$withdrawal',
                              detail: 'Consecutive probation flag',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _policyCard(context, failedEntries),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student GPA / CGPA Register',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Calculations use course credit units and the final score after any level-wide departmental moderation adjustment. Previous cumulative totals are carried forward into the CGPA.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _filters(context),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text('No student matches these filters.'),
                        ),
                      )
                    else
                      for (final record in filtered)
                        _studentCard(context, record),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _probationPanel(context),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: const Icon(Icons.calculate_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GPA / CGPA & Academic Standing',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                'Exam Officer computation of semester GPA, cumulative CGPA, credit points, failed-course entries and students requiring probation or withdrawal review.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metric(
    BuildContext context, {
    required double width,
    required IconData icon,
    required String label,
    required String value,
    required String detail,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _policyCard(BuildContext context, int failedEntries) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'ABU classified-degree scale:',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const Text('A 80–100 = 5'),
          const Text('B 60–79 = 4'),
          const Text('C 50–59 = 3'),
          const Text('D 45–49 = 2'),
          const Text('E 40–44 = 1'),
          const Text('F 0–39 = 0'),
          Text(
            '$failedEntries failed course entr${failedEntries == 1 ? 'y' : 'ies'} in the current calculation set',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context) {
    final levelItems = ['All Levels', ...ExamOfficerAcademicRegistry.levels];
    const standingItems = [
      'All Standing',
      'Good Standing',
      'Probation',
      'Withdrawal Review',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final search = TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Search student / matric number',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        );
        final level = DropdownButtonFormField<String>(
          initialValue: _level,
          decoration: const InputDecoration(
            labelText: 'Level',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final item in levelItems)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: (value) => setState(() => _level = value ?? 'All Levels'),
        );
        final standing = DropdownButtonFormField<String>(
          initialValue: _standing,
          decoration: const InputDecoration(
            labelText: 'Academic standing',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final item in standingItems)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: (value) =>
              setState(() => _standing = value ?? 'All Standing'),
        );

        if (compact) {
          return Column(
            children: [
              search,
              const SizedBox(height: 10),
              level,
              const SizedBox(height: 10),
              standing,
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 2, child: search),
            const SizedBox(width: 10),
            Expanded(child: level),
            const SizedBox(width: 10),
            Expanded(child: standing),
          ],
        );
      },
    );
  }

  List<StudentAcademicStanding> _filtered(
    List<StudentAcademicStanding> records,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return records.where((record) {
      if (_level != 'All Levels' && record.level != _level) return false;
      if (_standing != 'All Standing' && record.standing.label != _standing) {
        return false;
      }
      if (query.isNotEmpty &&
          !record.studentName.toLowerCase().contains(query) &&
          !record.matricNumber.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  Widget _studentCard(BuildContext context, StudentAcademicStanding record) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (record.standing) {
      AcademicStandingStatus.goodStanding => scheme.primary,
      AcademicStandingStatus.probation => scheme.secondary,
      AcademicStandingStatus.withdrawalReview => scheme.error,
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.studentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${record.matricNumber} • ${record.level} • ${record.semester}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Chip(
                avatar: Icon(
                  record.standing == AcademicStandingStatus.goodStanding
                      ? Icons.verified_outlined
                      : Icons.warning_amber_outlined,
                  size: 18,
                  color: color,
                ),
                label: Text(record.standing.label),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('GPA ${record.gpa.toStringAsFixed(2)}'),
              _pill('CGPA ${record.cgpa.toStringAsFixed(2)}'),
              _pill('RCU ${record.currentRegisteredUnits}'),
              _pill('CP ${record.currentCreditPoints}'),
              _pill('TRCU ${record.cumulativeRegisteredUnits}'),
              _pill('TCP ${record.cumulativeCreditPoints}'),
              _pill('${record.failedCourses} failed course(s)'),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showCalculation(context, record),
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Review Calculation'),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) => Chip(
        visualDensity: VisualDensity.compact,
        label: Text(text),
      );

  Widget _probationPanel(BuildContext context) {
    final flagged = [
      ..._state.probationList,
      ..._state.withdrawalReviewList,
    ];
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: scheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Probation & Withdrawal Review List',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                Chip(label: Text('${flagged.length} flagged')),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'The system calculates the standing; the Exam Officer prepares the list for departmental review. A withdrawal-review flag is not an automatic withdrawal decision.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            if (flagged.isEmpty)
              const Text('No student is currently below the standing threshold.')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Matric')),
                    DataColumn(label: Text('Student')),
                    DataColumn(label: Text('Level')),
                    DataColumn(label: Text('GPA')),
                    DataColumn(label: Text('CGPA')),
                    DataColumn(label: Text('Probation Semesters')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: [
                    for (final record in flagged)
                      DataRow(
                        cells: [
                          DataCell(Text(record.matricNumber)),
                          DataCell(Text(record.studentName)),
                          DataCell(Text(record.level)),
                          DataCell(Text(record.gpa.toStringAsFixed(2))),
                          DataCell(Text(record.cgpa.toStringAsFixed(2))),
                          DataCell(Text('${record.probationSemesterCount}')),
                          DataCell(Text(record.standing.label)),
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

  Future<void> _showCalculation(
    BuildContext context,
    StudentAcademicStanding record,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${record.studentName} — GPA / CGPA Calculation'),
        content: SizedBox(
          width: 980,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.matricNumber} • ${record.level} • ${record.academicSession} • ${record.semester}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Course')),
                      DataColumn(label: Text('CU')),
                      DataColumn(label: Text('Original')),
                      DataColumn(label: Text('Moderation')),
                      DataColumn(label: Text('Final')),
                      DataColumn(label: Text('Grade')),
                      DataColumn(label: Text('GP')),
                      DataColumn(label: Text('Credit Point')),
                    ],
                    rows: [
                      for (final result in record.currentResults)
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${result.courseCode} • ${result.courseTitle}',
                              ),
                            ),
                            DataCell(Text('${result.creditUnits}')),
                            DataCell(Text('${result.originalScore}')),
                            DataCell(
                              Text(
                                result.levelAdjustment >= 0
                                    ? '+${result.levelAdjustment}'
                                    : '${result.levelAdjustment}',
                              ),
                            ),
                            DataCell(Text('${result.finalScore}')),
                            DataCell(Text(result.grade)),
                            DataCell(Text('${result.gradePoint}')),
                            DataCell(Text('${result.creditPoints}')),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _formulaLine(
                  'Current semester',
                  'CP ${record.currentCreditPoints} ÷ RCU ${record.currentRegisteredUnits} = GPA ${record.gpa.toStringAsFixed(2)}',
                ),
                _formulaLine(
                  'Previous cumulative',
                  'TCP ${record.previousCreditPoints} • TRCU ${record.previousRegisteredUnits}',
                ),
                _formulaLine(
                  'New cumulative',
                  '(Previous TCP ${record.previousCreditPoints} + Current CP ${record.currentCreditPoints}) ÷ (Previous TRCU ${record.previousRegisteredUnits} + Current RCU ${record.currentRegisteredUnits}) = CGPA ${record.cgpa.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Academic standing: ${record.standing.label}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _formulaLine(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
