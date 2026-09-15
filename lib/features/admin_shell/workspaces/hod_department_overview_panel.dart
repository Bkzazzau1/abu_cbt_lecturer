import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_malpractice_state.dart';
import '../../exam_officer/data/exam_officer_demo_seed.dart';
import '../../exam_officer/data/exam_officer_invigilation_state.dart';
import '../../exam_officer/data/exam_officer_workflow_state.dart';
import '../../exam_officer/data/level_result_moderation_state.dart';
import '../../staff_management/data/department_staff_appointments_state.dart';

class HodDepartmentOverviewPanel extends StatefulWidget {
  const HodDepartmentOverviewPanel({super.key});

  @override
  State<HodDepartmentOverviewPanel> createState() =>
      _HodDepartmentOverviewPanelState();
}

class _HodDepartmentOverviewPanelState
    extends State<HodDepartmentOverviewPanel> {
  final ExamOfficerWorkflowState _workflow = ExamOfficerWorkflowState.instance;
  final ExamOfficerInvigilationState _invigilation =
      ExamOfficerInvigilationState.instance;
  final ExamMalpracticeState _malpractice = ExamMalpracticeState.instance;
  final LevelResultModerationState _results = LevelResultModerationState.instance;
  final DepartmentStaffAppointmentsState _appointments =
      DepartmentStaffAppointmentsState.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExamOfficerDemoSeed.ensureSeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _workflow,
      builder: (context, _) => AnimatedBuilder(
        animation: _invigilation,
        builder: (context, __) => AnimatedBuilder(
          animation: _malpractice,
          builder: (context, ___) => AnimatedBuilder(
            animation: _results,
            builder: (context, ____) => AnimatedBuilder(
              animation: _appointments,
              builder: (context, _____) => _content(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appointedLecturers = <String>{};
    final appointedModerators = <String>{};
    for (final course in _workflow.courseRegistrations) {
      appointedLecturers.addAll(_appointments.lecturersFor(course.courseCode));
      appointedModerators.addAll(_appointments.moderatorsFor(course.courseCode));
    }

    final moderationAttention = _workflow.questionPapers
        .where(
          (paper) =>
              paper.status == ExamOfficerQuestionStatus.withModerator ||
              paper.status == ExamOfficerQuestionStatus.correctionRequested,
        )
        .length;
    final scheduledPapers = _workflow.questionPapers
        .where((paper) => paper.status == ExamOfficerQuestionStatus.scheduled)
        .length;
    final missingInvigilation = _workflow.questionPapers.where((paper) {
      final scheduled = _workflow.schedulesForPaper(paper.paperId).isNotEmpty;
      return scheduled &&
          _invigilation.assignmentsForCourse(paper.courseCode).isEmpty;
    }).length;
    final waitingResultApproval = _results.boards
        .where((board) => board.status == LevelResultStatus.waitingHodApproval)
        .length;
    final malpracticeWaiting = _malpractice.cases
        .where((item) => item.status == ExamMalpracticeStatus.escalatedToHod)
        .length;

    final cards = [
      _Metric(
        'Students',
        '${_workflow.totalLevelStudents}',
        Icons.groups_2_outlined,
      ),
      _Metric(
        'Appointed lecturers',
        '${appointedLecturers.length}',
        Icons.school_outlined,
      ),
      _Metric(
        'Moderator pool',
        '${appointedModerators.length}',
        Icons.rule_folder_outlined,
      ),
      _Metric(
        'Registered courses',
        '${_workflow.courseRegistrations.length}',
        Icons.menu_book_outlined,
      ),
      _Metric(
        'Exam papers',
        '${_workflow.questionPapers.length}',
        Icons.description_outlined,
      ),
      _Metric(
        'Fully scheduled',
        '$scheduledPapers',
        Icons.event_available_outlined,
      ),
      _Metric(
        'Results awaiting HoD',
        '$waitingResultApproval',
        Icons.workspace_premium_outlined,
      ),
      _Metric(
        'Malpractice awaiting HoD',
        '$malpracticeWaiting',
        Icons.gavel_outlined,
      ),
    ];

    final decisionItems = <_DecisionItem>[
      if (moderationAttention > 0)
        _DecisionItem(
          'Moderation requires attention',
          '$moderationAttention paper(s) are with a moderator or returned for correction.',
          Icons.rule_folder_outlined,
        ),
      if (missingInvigilation > 0)
        _DecisionItem(
          'Invigilation coverage gap',
          '$missingInvigilation scheduled exam(s) currently have no posted invigilator.',
          Icons.person_off_outlined,
        ),
      if (waitingResultApproval > 0)
        _DecisionItem(
          'Level results awaiting decision',
          '$waitingResultApproval level package(s) are waiting for final HoD review.',
          Icons.workspace_premium_outlined,
        ),
      if (malpracticeWaiting > 0)
        _DecisionItem(
          'Escalated malpractice cases',
          '$malpracticeWaiting case file(s) require HoD review or committee referral.',
          Icons.gavel_outlined,
        ),
      if (_workflow.totalCarryoverRegistrations > 0)
        _DecisionItem(
          'Carryover pressure',
          '${_workflow.totalCarryoverRegistrations} carryover registrations are present across department courses.',
          Icons.replay_outlined,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: const Icon(Icons.account_tree_outlined),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Computer Science Department Command Overview',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'The HoD is the departmental Chief Exam Officer and academic authority. This dashboard combines staff appointments, course allocation, exam operations, moderation, invigilation, malpractice and level-result decisions. Routine execution may be delegated to the Exam Officer, while the HoD retains authority to intervene directly.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 1120
                ? (constraints.maxWidth - 36) / 4
                : constraints.maxWidth >= 700
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in cards)
                  SizedBox(width: width, child: _MetricCard(item: item)),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final width = wide
                ? (constraints.maxWidth - 14) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: width,
                  child: _DecisionQueue(items: decisionItems),
                ),
                SizedBox(
                  width: width,
                  child: _LevelSnapshot(workflow: _workflow),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.item});

  final _Metric item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(item.icon, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    item.label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
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

class _DecisionItem {
  const _DecisionItem(this.title, this.detail, this.icon);

  final String title;
  final String detail;
  final IconData icon;
}

class _DecisionQueue extends StatelessWidget {
  const _DecisionQueue({required this.items});

  final List<_DecisionItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HoD attention queue',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text('Items requiring Chief Exam Officer or HoD attention.'),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No current department alert.')),
              )
            else
              for (final item in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                    child: Icon(item.icon),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(item.detail),
                ),
          ],
        ),
      ),
    );
  }
}

class _LevelSnapshot extends StatelessWidget {
  const _LevelSnapshot({required this.workflow});

  final ExamOfficerWorkflowState workflow;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Level & registration snapshot',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text('Current department population and course load by level.'),
            const SizedBox(height: 12),
            for (final level in workflow.levels)
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        level,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${workflow.cohortCount(level)} students • ${workflow.coursesForLevel(level).length} courses',
                      ),
                    ),
                    Text(
                      '${workflow.coursesForLevel(level).fold<int>(0, (sum, course) => sum + course.carryoverCount)} carryover',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
