import 'package:flutter/material.dart';

class LecturerAssignmentsMarkingPanel extends StatefulWidget {
  const LecturerAssignmentsMarkingPanel({
    super.key,
    this.section = 'Marking & Grading',
  });

  final String section;

  @override
  State<LecturerAssignmentsMarkingPanel> createState() =>
      _LecturerAssignmentsMarkingPanelState();
}

class _LecturerAssignmentsMarkingPanelState
    extends State<LecturerAssignmentsMarkingPanel> {
  String _selectedCourse = 'CSC 305';
  String _selectedStatus = 'Pending Marking';
  _SubmissionReviewItem? _activeSubmission;
  _ExamMarkingSample? _activeExamScript;

  static const _assignments = [
    _AssignmentQueueItem(
      title: 'Graph Algorithms Practical',
      courseCode: 'CSC 305',
      submissions: 248,
      marked: 182,
      late: 14,
      flagged: 3,
      dueDate: '2026-06-18 17:00',
      status: 'Pending Marking',
    ),
    _AssignmentQueueItem(
      title: 'AI Search Strategy Report',
      courseCode: 'CSC 309',
      submissions: 197,
      marked: 88,
      late: 8,
      flagged: 11,
      dueDate: '2026-06-20 17:00',
      status: 'Integrity Review',
    ),
    _AssignmentQueueItem(
      title: 'Requirements Specification Draft',
      courseCode: 'SEN 301',
      submissions: 132,
      marked: 120,
      late: 4,
      flagged: 0,
      dueDate: '2026-06-15 12:00',
      status: 'Ready to Release',
    ),
  ];

  static const _submissions = [
    _SubmissionReviewItem(
      student: 'Ibrahim Yahaya',
      matricNo: '2023/C/SENG/0400',
      courseCode: 'CSC 305',
      submittedAt: '2026-06-17 21:42',
      score: 72,
      maxScore: 100,
      rubricStatus: 'Rubric partial',
      integrityStatus: 'Clean',
      feedback:
          'Good explanation of traversal logic. Improve complexity analysis.',
    ),
    _SubmissionReviewItem(
      student: 'Aisha Musa',
      matricNo: '2023/C/SENG/0188',
      courseCode: 'CSC 305',
      submittedAt: '2026-06-17 18:04',
      score: 86,
      maxScore: 100,
      rubricStatus: 'Rubric complete',
      integrityStatus: 'Clean',
      feedback: 'Excellent diagrams and implementation notes.',
    ),
    _SubmissionReviewItem(
      student: 'Blessing John',
      matricNo: '2022/C/CSC/0112',
      courseCode: 'CSC 309',
      submittedAt: '2026-06-20 19:10',
      score: 0,
      maxScore: 100,
      rubricStatus: 'Needs review',
      integrityStatus: 'Similarity flag',
      feedback: 'Possible shared content. Requires lecturer review.',
    ),
  ];

  static const _examSamples = [
    _ExamMarkingSample(
      courseCode: 'CSC 305',
      examTitle: 'Data Structures CBT + Theory',
      candidateNo: 'DLC/CSC305/044',
      student: 'Maryam Bello',
      objectiveScore: 32,
      theoryScore: 41,
      practicalScore: 0,
      maxScore: 100,
      markingGuide: 'Guide applied',
      status: 'Marked',
      note:
          'Strong tree traversal answer; minor deduction for missing heap case.',
    ),
    _ExamMarkingSample(
      courseCode: 'CSC 305',
      examTitle: 'Data Structures CBT + Theory',
      candidateNo: 'DLC/CSC305/071',
      student: 'Tunde Okafor',
      objectiveScore: 28,
      theoryScore: 0,
      practicalScore: 0,
      maxScore: 100,
      markingGuide: 'Needs theory marking',
      status: 'Pending Marking',
      note:
          'Objective section auto-scored. Theory response awaits lecturer review.',
    ),
    _ExamMarkingSample(
      courseCode: 'CSC 309',
      examTitle: 'Artificial Intelligence Practical',
      candidateNo: 'DLC/CSC309/118',
      student: 'Fatima Sani',
      objectiveScore: 24,
      theoryScore: 30,
      practicalScore: 26,
      maxScore: 100,
      markingGuide: 'Moderator queried',
      status: 'Integrity Review',
      note:
          'Practical trace is correct, but similarity flag needs lecturer comment.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filteredAssignments = _assignments
        .where(
          (item) =>
              _selectedCourse == 'All' || item.courseCode == _selectedCourse,
        )
        .where(
          (item) => _selectedStatus == 'All' || item.status == _selectedStatus,
        )
        .toList();
    final filteredSubmissions = _submissions
        .where(
          (item) =>
              _selectedCourse == 'All' || item.courseCode == _selectedCourse,
        )
        .toList();
    final filteredExamSamples = _examSamples
        .where(
          (item) =>
              _selectedCourse == 'All' || item.courseCode == _selectedCourse,
        )
        .where(
          (item) => _selectedStatus == 'All' || item.status == _selectedStatus,
        )
        .toList();

    if (widget.section == 'Results Submission') {
      return _LecturerResultsSubmissionPanel(
        selectedCourse: _selectedCourse,
        selectedStatus: _selectedStatus,
        examSamples: filteredExamSamples,
        onCourseChanged: (value) =>
            setState(() => _selectedCourse = value ?? 'All'),
        onStatusChanged: (value) =>
            setState(() => _selectedStatus = value ?? 'All'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_ind_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.section,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_task_outlined),
                  label: const Text('Create assignment'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _AssignmentChip(
                  label: 'Open assignments: 12',
                  icon: Icons.assignment_outlined,
                ),
                _AssignmentChip(
                  label: 'Pending marking: 302',
                  icon: Icons.edit_note_outlined,
                ),
                _AssignmentChip(
                  label: 'Exam scripts: 418',
                  icon: Icons.fact_check_outlined,
                ),
                _AssignmentChip(
                  label: 'Exam samples: 24',
                  icon: Icons.description_outlined,
                ),
                _AssignmentChip(
                  label: 'Late submissions: 26',
                  icon: Icons.schedule_outlined,
                ),
                _AssignmentChip(
                  label: 'Integrity flags: 14',
                  icon: Icons.gpp_maybe_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedCourse,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All courses'),
                      ),
                      DropdownMenuItem(
                        value: 'CSC 305',
                        child: Text('CSC 305'),
                      ),
                      DropdownMenuItem(
                        value: 'CSC 309',
                        child: Text('CSC 309'),
                      ),
                      DropdownMenuItem(
                        value: 'SEN 301',
                        child: Text('SEN 301'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedCourse = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Course'),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All statuses'),
                      ),
                      DropdownMenuItem(
                        value: 'Pending Marking',
                        child: Text('Pending Marking'),
                      ),
                      DropdownMenuItem(
                        value: 'Integrity Review',
                        child: Text('Integrity Review'),
                      ),
                      DropdownMenuItem(
                        value: 'Ready to Release',
                        child: Text('Ready to Release'),
                      ),
                      DropdownMenuItem(value: 'Marked', child: Text('Marked')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_activeSubmission != null || _activeExamScript != null) ...[
              if (_activeSubmission != null)
                _AssignmentMarkingWorkspace(
                  item: _activeSubmission!,
                  onClose: () => setState(() => _activeSubmission = null),
                ),
              if (_activeExamScript != null)
                _ExamScriptMarkingWorkspace(
                  item: _activeExamScript!,
                  onClose: () => setState(() => _activeExamScript = null),
                ),
              const SizedBox(height: 18),
            ],
            Text(
              'Assignment queue',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final assignment in filteredAssignments)
              _AssignmentQueueTile(
                item: assignment,
                onReview: () {
                  final submission = _submissions.firstWhere(
                    (item) => item.courseCode == assignment.courseCode,
                    orElse: () => _submissions.first,
                  );
                  setState(() {
                    _activeSubmission = submission;
                    _activeExamScript = null;
                  });
                },
              ),
            const SizedBox(height: 18),
            Text(
              'Submission review',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final submission in filteredSubmissions)
              _SubmissionReviewTile(
                item: submission,
                onOpen: () => setState(() {
                  _activeSubmission = submission;
                  _activeExamScript = null;
                }),
              ),
            const SizedBox(height: 18),
            Text(
              'Examination marking samples',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final sample in filteredExamSamples)
              _ExamMarkingSampleTile(
                item: sample,
                onOpen: () => setState(() {
                  _activeExamScript = sample;
                  _activeSubmission = null;
                }),
              ),
          ],
        ),
      ),
    );
  }
}

class _LecturerResultsSubmissionPanel extends StatelessWidget {
  const _LecturerResultsSubmissionPanel({
    required this.selectedCourse,
    required this.selectedStatus,
    required this.examSamples,
    required this.onCourseChanged,
    required this.onStatusChanged,
  });

  final String selectedCourse;
  final String selectedStatus;
  final List<_ExamMarkingSample> examSamples;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final submitted = examSamples.where((item) => item.status == 'Marked');
    final pending = examSamples.where((item) => item.status != 'Marked');
    final totalExamMarks = examSamples.fold<int>(
      0,
      (total, item) =>
          total + item.objectiveScore + item.theoryScore + item.practicalScore,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.publish_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Results Submission',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: submitted.isEmpty ? null : () {},
                  icon: const Icon(Icons.upload_outlined),
                  label: const Text('Submit selected batch'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _AssignmentChip(
                  label: 'Ready batches: ${submitted.length}',
                  icon: Icons.verified_outlined,
                ),
                _AssignmentChip(
                  label: 'Pending scripts: ${pending.length}',
                  icon: Icons.pending_actions_outlined,
                ),
                _AssignmentChip(
                  label: 'Exam total: $totalExamMarks',
                  icon: Icons.calculate_outlined,
                ),
                const _AssignmentChip(
                  label: 'Destination: Exam Officer',
                  icon: Icons.admin_panel_settings_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selectedCourse,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All courses'),
                      ),
                      DropdownMenuItem(
                        value: 'CSC 305',
                        child: Text('CSC 305'),
                      ),
                      DropdownMenuItem(
                        value: 'CSC 309',
                        child: Text('CSC 309'),
                      ),
                      DropdownMenuItem(
                        value: 'SEN 301',
                        child: Text('SEN 301'),
                      ),
                    ],
                    onChanged: onCourseChanged,
                    decoration: const InputDecoration(labelText: 'Course'),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selectedStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All statuses'),
                      ),
                      DropdownMenuItem(
                        value: 'Pending Marking',
                        child: Text('Pending Marking'),
                      ),
                      DropdownMenuItem(
                        value: 'Integrity Review',
                        child: Text('Integrity Review'),
                      ),
                      DropdownMenuItem(
                        value: 'Ready to Release',
                        child: Text('Ready to Release'),
                      ),
                      DropdownMenuItem(value: 'Marked', child: Text('Marked')),
                    ],
                    onChanged: onStatusChanged,
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Exam Officer result packages',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final item in examSamples)
              _ResultPackageTile(
                item: item,
                canSubmit: item.status == 'Marked',
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultPackageTile extends StatelessWidget {
  const _ResultPackageTile({required this.item, required this.canSubmit});

  final _ExamMarkingSample item;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final examTotal =
        item.objectiveScore + item.theoryScore + item.practicalScore;
    const assignmentTotal = 18;
    const caTotal = 12;
    final statusColor = canSubmit ? scheme.primary : scheme.secondary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
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
                      '${item.courseCode} • ${item.examTitle}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.student} • ${item.candidateNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: item.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: 'Assignments $assignmentTotal/20'),
              _MiniPill(label: 'CA $caTotal/20'),
              _MiniPill(label: 'Exam $examTotal/${item.maxScore}'),
              _MiniPill(label: 'Script attached'),
              _MiniPill(label: item.markingGuide),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.description_outlined),
                label: const Text('Review package'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save batch'),
              ),
              FilledButton.icon(
                onPressed: canSubmit ? () {} : null,
                icon: const Icon(Icons.publish_outlined),
                label: const Text('Submit to Exam Officer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExamMarkingSampleTile extends StatelessWidget {
  const _ExamMarkingSampleTile({required this.item, required this.onOpen});

  final _ExamMarkingSample item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = item.status == 'Integrity Review'
        ? scheme.error
        : item.status == 'Marked'
        ? scheme.primary
        : scheme.secondary;
    final totalScore =
        item.objectiveScore + item.theoryScore + item.practicalScore;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.status == 'Integrity Review'
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
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.courseCode} • ${item.examTitle}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.student} • ${item.candidateNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: item.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: 'Objective ${item.objectiveScore}'),
              _MiniPill(label: 'Theory ${item.theoryScore}'),
              _MiniPill(label: 'Practical ${item.practicalScore}'),
              _MiniPill(label: 'Total $totalScore/${item.maxScore}'),
              _MiniPill(label: item.markingGuide),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.note, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.description_outlined),
                label: const Text('Open script'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.rule_outlined),
                label: const Text('Marking guide'),
              ),
              OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Mark script'),
              ),
              FilledButton.icon(
                onPressed: item.status == 'Marked' ? () {} : null,
                icon: const Icon(Icons.publish_outlined),
                label: const Text('Submit result batch'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignmentQueueTile extends StatelessWidget {
  const _AssignmentQueueTile({required this.item, required this.onReview});

  final _AssignmentQueueItem item;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = item.status == 'Integrity Review'
        ? scheme.error
        : item.status == 'Ready to Release'
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
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.courseCode} • ${item.title}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${item.dueDate}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: item.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: '${item.submissions} submissions'),
              _MiniPill(label: '${item.marked} marked'),
              _MiniPill(label: '${item.late} late'),
              _MiniPill(label: '${item.flagged} flags'),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: item.submissions == 0 ? 0 : item.marked / item.submissions,
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Review submissions'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.rule_outlined),
                label: const Text('Rubric'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.publish_outlined),
                label: const Text('Release marks'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignmentMarkingWorkspace extends StatefulWidget {
  const _AssignmentMarkingWorkspace({
    required this.item,
    required this.onClose,
  });

  final _SubmissionReviewItem item;
  final VoidCallback onClose;

  @override
  State<_AssignmentMarkingWorkspace> createState() =>
      _AssignmentMarkingWorkspaceState();
}

class _AssignmentMarkingWorkspaceState
    extends State<_AssignmentMarkingWorkspace> {
  int _selectedLine = 2;
  Color _inkColor = Colors.green;
  double _inkSize = 4;
  _DrawingTool _drawingTool = _DrawingTool.pen;
  final List<_InkStroke> _strokes = [];
  final List<_ScriptAnnotation> _annotations = const [
    _ScriptAnnotation(
      line: 2,
      type: _AnnotationType.highlight,
      color: Colors.yellow,
      text: 'Good opening',
      strokeWidth: 4,
    ),
    _ScriptAnnotation(
      line: 5,
      type: _AnnotationType.underline,
      color: Colors.green,
      text: 'Correct BFS point',
      strokeWidth: 4,
    ),
  ].toList();
  final _noteController = TextEditingController(
    text: 'Add stronger complexity explanation.',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rate_review_outlined, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Open assignment submission',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: widget.item.student),
              _MiniPill(label: widget.item.matricNo),
              _MiniPill(label: widget.item.courseCode),
              _MiniPill(label: 'Submitted ${widget.item.submittedAt}'),
              _MiniPill(label: 'Read-only file'),
            ],
          ),
          const SizedBox(height: 14),
          _AnnotationToolbar(
            selectedLine: _selectedLine,
            inkColor: _inkColor,
            inkSize: _inkSize,
            drawingTool: _drawingTool,
            noteController: _noteController,
            lineCount: _assignmentSubmissionLines.length,
            onLineChanged: (value) => setState(() => _selectedLine = value),
            onInkChanged: (value) => setState(() => _inkColor = value),
            onInkSizeChanged: (value) => setState(() => _inkSize = value),
            onDrawingToolChanged: (value) =>
                setState(() => _drawingTool = value),
            onAddAnnotation: _addAnnotation,
            onUndoStroke: _undoStroke,
            onClearStrokes: _clearStrokes,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              final panelWidth = wide
                  ? (constraints.maxWidth - 14) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: panelWidth,
                    child: _AssignmentSubmissionFilePage(
                      item: widget.item,
                      annotations: _annotations,
                      strokes: _strokes,
                      drawingTool: _drawingTool,
                      onStrokeStart: _startStroke,
                      onStrokeUpdate: _appendStroke,
                    ),
                  ),
                  SizedBox(
                    width: panelWidth,
                    child: _AssignmentScoreForm(item: widget.item),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _addAnnotation(_AnnotationType type) {
    final note = _noteController.text.trim();
    setState(() {
      _annotations.add(
        _ScriptAnnotation(
          line: _selectedLine,
          type: type,
          color: _inkColor,
          text: type == _AnnotationType.inkMark
              ? (note.isEmpty ? '✓' : note)
              : (note.isEmpty ? type.label : note),
          strokeWidth: _inkSize,
        ),
      );
    });
  }

  void _startStroke(Offset point) {
    if (_drawingTool == _DrawingTool.none) {
      return;
    }
    setState(() {
      _strokes.add(
        _InkStroke(
          points: [point],
          color: _inkColor,
          strokeWidth: _inkSize,
          tool: _drawingTool,
        ),
      );
    });
  }

  void _appendStroke(Offset point) {
    if (_drawingTool == _DrawingTool.none || _strokes.isEmpty) {
      return;
    }
    setState(() => _strokes.last.points.add(point));
  }

  void _undoStroke() {
    if (_strokes.isEmpty) {
      return;
    }
    setState(() => _strokes.removeLast());
  }

  void _clearStrokes() {
    if (_strokes.isEmpty) {
      return;
    }
    setState(_strokes.clear);
  }
}

class _AssignmentScoreForm extends StatelessWidget {
  const _AssignmentScoreForm({required this.item});

  final _SubmissionReviewItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rubric-based grading',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const _ScoreFields(
          fields: [
            _ScoreField('Understanding', '25'),
            _ScoreField('Method', '20'),
            _ScoreField('Accuracy', '17'),
            _ScoreField('Presentation', '10'),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: '${item.score}',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Final score / ${item.maxScore}',
            prefixIcon: const Icon(Icons.score_outlined),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: item.feedback,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Feedback to student',
            prefixIcon: Icon(Icons.feedback_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save mark'),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send_outlined),
              label: const Text('Return feedback'),
            ),
          ],
        ),
      ],
    );
  }
}

const _examTranscriptLines = [
  'Question 1: Explain the difference between stack and queue data structures with suitable use cases.',
  'A stack is a linear data structure that follows last-in-first-out while a queue follows first-in-first-out.',
  'Stacks are useful in recursion, undo operations, expression parsing and browser history management.',
  'Queues are useful in scheduling, printer jobs, breadth-first search and customer service systems.',
  'Question 2: Describe how a binary search tree handles insertion and search operations.',
  'Insertion compares the new value with the root and moves left or right until an empty child position is found.',
  'Search follows the same comparison path and can be efficient when the tree is balanced.',
  'A limitation is that an unbalanced tree can degrade to linear search time.',
  'Question 3: Give one practical application of graph traversal in computer science.',
  'Graph traversal can be used for route discovery, social network analysis and dependency resolution.',
];

const _assignmentSubmissionLines = [
  '1. Introduction',
  'Graph traversal is a technique for visiting vertices and edges in a graph.',
  'The two common traversal strategies are breadth-first search and depth-first search.',
  'Both methods help solve problems such as path discovery, cycle detection and dependency ordering.',
  '2. Breadth-First Search',
  'Breadth-first search explores all neighbouring vertices before moving to the next level.',
  'It uses a queue and is suitable for finding the shortest path in an unweighted graph.',
  'The algorithm marks each visited vertex to avoid repeated processing.',
  '3. Depth-First Search',
  'Depth-first search follows one branch of the graph as far as possible before backtracking.',
  'It may be implemented with recursion or an explicit stack.',
  'DFS is useful for topological sorting, connected component detection and cycle checking.',
  '4. Complexity Analysis',
  'For an adjacency-list graph, both BFS and DFS run in O(V + E).',
  'The memory cost depends on the visited set and the queue or stack used during traversal.',
];

enum _AnnotationType {
  highlight('Highlight'),
  underline('Underline'),
  comment('Comment'),
  note('Note'),
  inkMark('Ink mark');

  const _AnnotationType(this.label);

  final String label;
}

enum _DrawingTool {
  none('Move', Icons.pan_tool_alt_outlined),
  pen('Pen', Icons.edit_outlined),
  highlighter('Highlighter', Icons.brush_outlined);

  const _DrawingTool(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _InkStroke {
  _InkStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.tool,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final _DrawingTool tool;
}

class _ScriptAnnotation {
  const _ScriptAnnotation({
    required this.line,
    required this.type,
    required this.color,
    required this.text,
    required this.strokeWidth,
  });

  final int line;
  final _AnnotationType type;
  final Color color;
  final String text;
  final double strokeWidth;
}

class _AssignmentSubmissionFilePage extends StatelessWidget {
  const _AssignmentSubmissionFilePage({
    required this.item,
    required this.annotations,
    required this.strokes,
    required this.drawingTool,
    required this.onStrokeStart,
    required this.onStrokeUpdate,
  });

  final _SubmissionReviewItem item;
  final List<_ScriptAnnotation> annotations;
  final List<_InkStroke> strokes;
  final _DrawingTool drawingTool;
  final ValueChanged<Offset> onStrokeStart;
  final ValueChanged<Offset> onStrokeUpdate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fileName =
        '${item.courseCode.toLowerCase()}_${item.matricNo.replaceAll('/', '_')}.pdf';

    return _DrawableScriptSurface(
      strokes: strokes,
      drawingTool: drawingTool,
      onStrokeStart: onStrokeStart,
      onStrokeUpdate: onStrokeUpdate,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'KADUNA STATE UNIVERSITY',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Distance Learning Centre - Assignment Submission File',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniPill(label: fileName),
                _MiniPill(label: item.student),
                _MiniPill(label: item.matricNo),
                _MiniPill(label: item.courseCode),
              ],
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < _assignmentSubmissionLines.length; i++)
              _TranscriptLine(
                lineNumber: i + 1,
                text: _assignmentSubmissionLines[i],
                annotations: annotations
                    .where((annotation) => annotation.line == i + 1)
                    .toList(),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('Open sample file'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Download sample'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamScriptMarkingWorkspace extends StatefulWidget {
  const _ExamScriptMarkingWorkspace({
    required this.item,
    required this.onClose,
  });

  final _ExamMarkingSample item;
  final VoidCallback onClose;

  @override
  State<_ExamScriptMarkingWorkspace> createState() =>
      _ExamScriptMarkingWorkspaceState();
}

class _ExamScriptMarkingWorkspaceState
    extends State<_ExamScriptMarkingWorkspace> {
  int _selectedLine = 2;
  Color _inkColor = Colors.red;
  double _inkSize = 4;
  _DrawingTool _drawingTool = _DrawingTool.pen;
  final List<_InkStroke> _strokes = [];
  late final List<_ExamQuestionMark> _assignmentMarks;
  late final List<_ExamQuestionMark> _caMarks;
  late final List<_ExamQuestionMark> _questionMarks;
  late final TextEditingController _examinerSummaryController;
  bool _submittedToExamOfficer = false;
  final List<_ScriptAnnotation> _annotations = const [
    _ScriptAnnotation(
      line: 2,
      type: _AnnotationType.highlight,
      color: Colors.amber,
      text: 'Relevant point',
      strokeWidth: 4,
    ),
    _ScriptAnnotation(
      line: 4,
      type: _AnnotationType.underline,
      color: Colors.green,
      text: 'Good explanation',
      strokeWidth: 4,
    ),
    _ScriptAnnotation(
      line: 6,
      type: _AnnotationType.comment,
      color: Colors.red,
      text: 'Needs example',
      strokeWidth: 4,
    ),
  ].toList();

  final _noteController = TextEditingController(
    text: 'Clarify time complexity before final score.',
  );

  @override
  void initState() {
    super.initState();
    _assignmentMarks = _buildAssignmentMarks(widget.item);
    _caMarks = _buildCaMarks(widget.item);
    _questionMarks = _buildQuestionMarks(widget.item);
    _examinerSummaryController = TextEditingController(text: widget.item.note);
    for (final mark in [..._assignmentMarks, ..._caMarks, ..._questionMarks]) {
      mark.controller.addListener(_refreshTotal);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _examinerSummaryController.dispose();
    for (final mark in [..._assignmentMarks, ..._caMarks, ..._questionMarks]) {
      mark.controller
        ..removeListener(_refreshTotal)
        ..dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = _totalScore;
    final maxTotal = _maxTotal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined, color: scheme.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kaduna State University examination transcript',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: widget.item.student),
              _MiniPill(label: widget.item.candidateNo),
              _MiniPill(label: widget.item.courseCode),
              _MiniPill(label: 'Current total $total/$maxTotal'),
              _MiniPill(label: 'Read-only transcript'),
              _MiniPill(
                label: _submittedToExamOfficer
                    ? 'Submitted to Exam Officer'
                    : 'Draft marking',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AnnotationToolbar(
            selectedLine: _selectedLine,
            inkColor: _inkColor,
            inkSize: _inkSize,
            drawingTool: _drawingTool,
            noteController: _noteController,
            lineCount: _examTranscriptLines.length,
            onLineChanged: (value) => setState(() => _selectedLine = value),
            onInkChanged: (value) => setState(() => _inkColor = value),
            onInkSizeChanged: (value) => setState(() => _inkSize = value),
            onDrawingToolChanged: (value) =>
                setState(() => _drawingTool = value),
            onAddAnnotation: _addAnnotation,
            onUndoStroke: _undoStroke,
            onClearStrokes: _clearStrokes,
          ),
          const SizedBox(height: 14),
          _ExamTranscriptPage(
            item: widget.item,
            annotations: _annotations,
            strokes: _strokes,
            drawingTool: _drawingTool,
            onStrokeStart: _startStroke,
            onStrokeUpdate: _appendStroke,
          ),
          const SizedBox(height: 14),
          _ExamScoreSummary(
            item: widget.item,
            assignmentMarks: _assignmentMarks,
            caMarks: _caMarks,
            questionMarks: _questionMarks,
            assignmentTotal: _assignmentTotal,
            assignmentMaxTotal: _assignmentMaxTotal,
            caTotal: _caTotal,
            caMaxTotal: _caMaxTotal,
            total: total,
            maxTotal: maxTotal,
            summaryController: _examinerSummaryController,
            submittedToExamOfficer: _submittedToExamOfficer,
            onSubmitToExamOfficer: _submitToExamOfficer,
          ),
        ],
      ),
    );
  }

  int get _assignmentTotal => _assignmentMarks.fold(
    0,
    (total, mark) => total + _parseMark(mark.controller.text, mark.maxMark),
  );

  int get _assignmentMaxTotal =>
      _assignmentMarks.fold(0, (total, mark) => total + mark.maxMark);

  int get _caOnlyTotal => _caMarks.fold(
    0,
    (total, mark) => total + _parseMark(mark.controller.text, mark.maxMark),
  );

  int get _caOnlyMaxTotal =>
      _caMarks.fold(0, (total, mark) => total + mark.maxMark);

  int get _caTotal => _assignmentTotal + _caOnlyTotal;

  int get _caMaxTotal => _assignmentMaxTotal + _caOnlyMaxTotal;

  int get _totalScore => _questionMarks.fold(
    0,
    (total, mark) => total + _parseMark(mark.controller.text, mark.maxMark),
  );

  int get _maxTotal =>
      _questionMarks.fold(0, (total, mark) => total + mark.maxMark);

  List<_ExamQuestionMark> _buildAssignmentMarks(_ExamMarkingSample item) {
    return [
      _ExamQuestionMark(
        question: 'Assignment 1',
        maxMark: 10,
        controller: TextEditingController(
          text: item.courseCode == 'CSC 305' ? '8' : '7',
        ),
      ),
      _ExamQuestionMark(
        question: 'Assignment 2',
        maxMark: 10,
        controller: TextEditingController(
          text: item.courseCode == 'CSC 305' ? '7' : '8',
        ),
      ),
    ];
  }

  List<_ExamQuestionMark> _buildCaMarks(_ExamMarkingSample item) {
    return [
      _ExamQuestionMark(
        question: 'Quiz / Test',
        maxMark: 5,
        controller: TextEditingController(
          text: item.status == 'Marked' ? '4' : '3',
        ),
      ),
      _ExamQuestionMark(
        question: 'Attendance / Engagement',
        maxMark: 5,
        controller: TextEditingController(text: '4'),
      ),
      _ExamQuestionMark(
        question: 'Practical / Lab CA',
        maxMark: 10,
        controller: TextEditingController(
          text: item.practicalScore > 0 ? '8' : '0',
        ),
      ),
    ];
  }

  List<_ExamQuestionMark> _buildQuestionMarks(_ExamMarkingSample item) {
    final manualTotal = item.theoryScore + item.practicalScore;
    final q1 = (manualTotal * 0.34).round().clamp(0, 20);
    final q2 = (manualTotal * 0.33).round().clamp(0, 20);
    final q3 = (manualTotal - q1 - q2).clamp(0, 20);

    return [
      _ExamQuestionMark(
        question: 'Objective CBT',
        maxMark: 40,
        controller: TextEditingController(text: '${item.objectiveScore}'),
        readOnly: true,
      ),
      _ExamQuestionMark(
        question: 'Question 1 - data structure explanation',
        maxMark: 20,
        controller: TextEditingController(text: '$q1'),
      ),
      _ExamQuestionMark(
        question: 'Question 2 - binary search tree',
        maxMark: 20,
        controller: TextEditingController(text: '$q2'),
      ),
      _ExamQuestionMark(
        question: 'Question 3 - graph traversal application',
        maxMark: 20,
        controller: TextEditingController(text: '$q3'),
      ),
    ];
  }

  int _parseMark(String value, int maxMark) {
    final parsed = int.tryParse(value.trim()) ?? 0;
    return parsed.clamp(0, maxMark);
  }

  void _refreshTotal() {
    if (mounted) {
      setState(() => _submittedToExamOfficer = false);
    }
  }

  void _submitToExamOfficer() {
    setState(() => _submittedToExamOfficer = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Marked script for ${widget.item.candidateNo} submitted to Exam Officer with CA $_caTotal/$_caMaxTotal and exam $_totalScore/$_maxTotal.',
        ),
      ),
    );
  }

  void _addAnnotation(_AnnotationType type) {
    final note = _noteController.text.trim();
    setState(() {
      _annotations.add(
        _ScriptAnnotation(
          line: _selectedLine,
          type: type,
          color: _inkColor,
          text: note.isEmpty ? type.label : note,
          strokeWidth: _inkSize,
        ),
      );
    });
  }

  void _startStroke(Offset point) {
    if (_drawingTool == _DrawingTool.none) {
      return;
    }
    setState(() {
      _strokes.add(
        _InkStroke(
          points: [point],
          color: _inkColor,
          strokeWidth: _inkSize,
          tool: _drawingTool,
        ),
      );
    });
  }

  void _appendStroke(Offset point) {
    if (_drawingTool == _DrawingTool.none || _strokes.isEmpty) {
      return;
    }
    setState(() => _strokes.last.points.add(point));
  }

  void _undoStroke() {
    if (_strokes.isEmpty) {
      return;
    }
    setState(() => _strokes.removeLast());
  }

  void _clearStrokes() {
    if (_strokes.isEmpty) {
      return;
    }
    setState(_strokes.clear);
  }
}

class _AnnotationToolbar extends StatelessWidget {
  const _AnnotationToolbar({
    required this.selectedLine,
    required this.inkColor,
    required this.inkSize,
    required this.drawingTool,
    required this.noteController,
    required this.lineCount,
    required this.onLineChanged,
    required this.onInkChanged,
    required this.onInkSizeChanged,
    required this.onDrawingToolChanged,
    required this.onAddAnnotation,
    required this.onUndoStroke,
    required this.onClearStrokes,
  });

  final int selectedLine;
  final Color inkColor;
  final double inkSize;
  final _DrawingTool drawingTool;
  final TextEditingController noteController;
  final int lineCount;
  final ValueChanged<int> onLineChanged;
  final ValueChanged<Color> onInkChanged;
  final ValueChanged<double> onInkSizeChanged;
  final ValueChanged<_DrawingTool> onDrawingToolChanged;
  final ValueChanged<_AnnotationType> onAddAnnotation;
  final VoidCallback onUndoStroke;
  final VoidCallback onClearStrokes;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.black,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marking ink and annotation tools',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: selectedLine,
                items: [
                  for (var i = 1; i <= lineCount; i++)
                    DropdownMenuItem(value: i, child: Text('Line $i')),
                ],
                onChanged: (value) => onLineChanged(value ?? selectedLine),
                decoration: const InputDecoration(labelText: 'Target line'),
              ),
            ),
            for (final color in colors)
              Tooltip(
                message: 'Ink color',
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onInkChanged(color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: inkColor == color
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: 220,
              child: Row(
                children: [
                  const Icon(Icons.line_weight_outlined),
                  Expanded(
                    child: Slider(
                      value: inkSize,
                      min: 2,
                      max: 10,
                      divisions: 8,
                      label: '${inkSize.round()} px',
                      onChanged: onInkSizeChanged,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 410,
              child: SegmentedButton<_DrawingTool>(
                selected: {drawingTool},
                showSelectedIcon: false,
                segments: [
                  for (final tool in _DrawingTool.values)
                    ButtonSegment(
                      value: tool,
                      icon: Icon(tool.icon),
                      label: Text(tool.label),
                    ),
                ],
                onSelectionChanged: (selection) =>
                    onDrawingToolChanged(selection.first),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Comment / note text',
            prefixIcon: Icon(Icons.sticky_note_2_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => onAddAnnotation(_AnnotationType.highlight),
              icon: const Icon(Icons.format_color_fill_outlined),
              label: const Text('Highlight line'),
            ),
            OutlinedButton.icon(
              onPressed: () => onAddAnnotation(_AnnotationType.underline),
              icon: const Icon(Icons.format_underlined),
              label: const Text('Underline'),
            ),
            OutlinedButton.icon(
              onPressed: () => onAddAnnotation(_AnnotationType.comment),
              icon: const Icon(Icons.comment_outlined),
              label: const Text('Add comment'),
            ),
            OutlinedButton.icon(
              onPressed: () => onAddAnnotation(_AnnotationType.note),
              icon: const Icon(Icons.sticky_note_2_outlined),
              label: const Text('Add note'),
            ),
            FilledButton.icon(
              onPressed: drawingTool == _DrawingTool.none
                  ? () => onDrawingToolChanged(_DrawingTool.pen)
                  : null,
              icon: const Icon(Icons.gesture_outlined),
              label: const Text('Draw on script'),
            ),
            OutlinedButton.icon(
              onPressed: onUndoStroke,
              icon: const Icon(Icons.undo_outlined),
              label: const Text('Undo ink'),
            ),
            OutlinedButton.icon(
              onPressed: onClearStrokes,
              icon: const Icon(Icons.layers_clear_outlined),
              label: const Text('Clear ink'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExamTranscriptPage extends StatelessWidget {
  const _ExamTranscriptPage({
    required this.item,
    required this.annotations,
    required this.strokes,
    required this.drawingTool,
    required this.onStrokeStart,
    required this.onStrokeUpdate,
  });

  final _ExamMarkingSample item;
  final List<_ScriptAnnotation> annotations;
  final List<_InkStroke> strokes;
  final _DrawingTool drawingTool;
  final ValueChanged<Offset> onStrokeStart;
  final ValueChanged<Offset> onStrokeUpdate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _DrawableScriptSurface(
      strokes: strokes,
      drawingTool: drawingTool,
      onStrokeStart: onStrokeStart,
      onStrokeUpdate: onStrokeUpdate,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'KADUNA STATE UNIVERSITY',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Distance Learning Centre - Examination Transcript',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniPill(label: item.examTitle),
                _MiniPill(label: item.courseCode),
                _MiniPill(label: item.candidateNo),
                _MiniPill(label: item.student),
              ],
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < _examTranscriptLines.length; i++)
              _TranscriptLine(
                lineNumber: i + 1,
                text: _examTranscriptLines[i],
                annotations: annotations
                    .where((annotation) => annotation.line == i + 1)
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _DrawableScriptSurface extends StatelessWidget {
  const _DrawableScriptSurface({
    required this.child,
    required this.strokes,
    required this.drawingTool,
    required this.onStrokeStart,
    required this.onStrokeUpdate,
  });

  final Widget child;
  final List<_InkStroke> strokes;
  final _DrawingTool drawingTool;
  final ValueChanged<Offset> onStrokeStart;
  final ValueChanged<Offset> onStrokeUpdate;

  @override
  Widget build(BuildContext context) {
    final drawingEnabled = drawingTool != _DrawingTool.none;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _InkStrokePainter(strokes)),
            ),
          ),
          if (drawingEnabled)
            Positioned.fill(
              child: MouseRegion(
                cursor: SystemMouseCursors.precise,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) => onStrokeStart(details.localPosition),
                  onPanUpdate: (details) =>
                      onStrokeUpdate(details.localPosition),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InkStrokePainter extends CustomPainter {
  const _InkStrokePainter(this.strokes);

  final List<_InkStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) {
        continue;
      }

      final paint = Paint()
        ..color = stroke.tool == _DrawingTool.highlighter
            ? stroke.color.withValues(alpha: 0.32)
            : stroke.color
        ..strokeWidth = stroke.tool == _DrawingTool.highlighter
            ? stroke.strokeWidth * 3
            : stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          paint.strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }

      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        final current = stroke.points[i];
        final previous = stroke.points[i - 1];
        final midpoint = Offset(
          (previous.dx + current.dx) / 2,
          (previous.dy + current.dy) / 2,
        );
        path.quadraticBezierTo(
          previous.dx,
          previous.dy,
          midpoint.dx,
          midpoint.dy,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _InkStrokePainter oldDelegate) {
    return true;
  }
}

class _TranscriptLine extends StatelessWidget {
  const _TranscriptLine({
    required this.lineNumber,
    required this.text,
    required this.annotations,
  });

  final int lineNumber;
  final String text;
  final List<_ScriptAnnotation> annotations;

  @override
  Widget build(BuildContext context) {
    final highlights = annotations
        .where((annotation) => annotation.type == _AnnotationType.highlight)
        .toList();
    final highlight = highlights.isEmpty ? null : highlights.last;
    final underlines = annotations
        .where((annotation) => annotation.type == _AnnotationType.underline)
        .toList();
    final underline = underlines.isEmpty ? null : underlines.last;
    final inkMarks = annotations
        .where((annotation) => annotation.type == _AnnotationType.inkMark)
        .toList();
    final comments = annotations
        .where(
          (annotation) =>
              annotation.type == _AnnotationType.comment ||
              annotation.type == _AnnotationType.note,
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: highlight?.color.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '$lineNumber',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      decoration: underline == null
                          ? TextDecoration.none
                          : TextDecoration.underline,
                      decorationColor: underline?.color,
                      decorationThickness: underline == null
                          ? null
                          : (underline.strokeWidth / 2).clamp(1.5, 4),
                    ),
                  ),
                ),
                if (inkMarks.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final mark in inkMarks) _InkMark(annotation: mark),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final comment in comments)
                    _AnnotationChip(annotation: comment),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InkMark extends StatelessWidget {
  const _InkMark({required this.annotation});

  final _ScriptAnnotation annotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.12,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: annotation.color.withValues(alpha: 0.75),
              width: (annotation.strokeWidth / 2).clamp(1.5, 4),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            annotation.text,
            style: TextStyle(
              color: annotation.color,
              fontSize: (16 + annotation.strokeWidth * 2).clamp(18, 30),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnotationChip extends StatelessWidget {
  const _AnnotationChip({required this.annotation});

  final _ScriptAnnotation annotation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: annotation.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: annotation.color.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '${annotation.type.label}: ${annotation.text}',
          style: TextStyle(
            color: annotation.color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ExamScoreSummary extends StatelessWidget {
  const _ExamScoreSummary({
    required this.item,
    required this.assignmentMarks,
    required this.caMarks,
    required this.questionMarks,
    required this.assignmentTotal,
    required this.assignmentMaxTotal,
    required this.caTotal,
    required this.caMaxTotal,
    required this.total,
    required this.maxTotal,
    required this.summaryController,
    required this.submittedToExamOfficer,
    required this.onSubmitToExamOfficer,
  });

  final _ExamMarkingSample item;
  final List<_ExamQuestionMark> assignmentMarks;
  final List<_ExamQuestionMark> caMarks;
  final List<_ExamQuestionMark> questionMarks;
  final int assignmentTotal;
  final int assignmentMaxTotal;
  final int caTotal;
  final int caMaxTotal;
  final int total;
  final int maxTotal;
  final TextEditingController summaryController;
  final bool submittedToExamOfficer;
  final VoidCallback onSubmitToExamOfficer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question marks and exam officer submission',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniPill(label: 'Candidate ${item.candidateNo}'),
            _MiniPill(
              label: 'Assignments $assignmentTotal/$assignmentMaxTotal',
            ),
            _MiniPill(label: 'CA $caTotal/$caMaxTotal'),
            _MiniPill(label: 'Exam $total/$maxTotal'),
            _MiniPill(label: item.markingGuide),
            _MiniPill(
              label: submittedToExamOfficer
                  ? 'Sent to Exam Officer'
                  : 'Not yet submitted',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MarkEntryGroup(title: 'Assignment marks', marks: assignmentMarks),
        const SizedBox(height: 12),
        _MarkEntryGroup(title: 'Other CA marks', marks: caMarks),
        const SizedBox(height: 12),
        _MarkEntryGroup(
          title: 'Examination question marks',
          marks: questionMarks,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.secondary.withValues(alpha: 0.28)),
          ),
          child: Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _SummaryTotal(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Assignment total',
                value: '$assignmentTotal/$assignmentMaxTotal',
              ),
              _SummaryTotal(
                icon: Icons.fact_check_outlined,
                label: 'CA total',
                value: '$caTotal/$caMaxTotal',
              ),
              _SummaryTotal(
                icon: Icons.description_outlined,
                label: 'Exam total',
                value: '$total/$maxTotal',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Icon(Icons.calculate_outlined, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Exam Officer package: CA $caTotal/$caMaxTotal plus examination script $total/$maxTotal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: summaryController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Lecturer marking summary for Exam Officer',
            prefixIcon: Icon(Icons.comment_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save annotations'),
            ),
            FilledButton.icon(
              onPressed: onSubmitToExamOfficer,
              icon: const Icon(Icons.publish_outlined),
              label: const Text('Submit to Exam Officer'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MarkEntryGroup extends StatelessWidget {
  const _MarkEntryGroup({required this.title, required this.marks});

  final String title;
  final List<_ExamQuestionMark> marks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [for (final mark in marks) _MarkEntryField(mark: mark)],
        ),
      ],
    );
  }
}

class _MarkEntryField extends StatelessWidget {
  const _MarkEntryField({required this.mark});

  final _ExamQuestionMark mark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextFormField(
        controller: mark.controller,
        readOnly: mark.readOnly,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '${mark.question} / ${mark.maxMark}',
          helperText: mark.readOnly ? 'Auto-marked' : 'Lecturer recorded mark',
          prefixIcon: Icon(
            mark.readOnly ? Icons.verified_outlined : Icons.edit_note_outlined,
          ),
          suffixText: '/ ${mark.maxMark}',
        ),
      ),
    );
  }
}

class _SummaryTotal extends StatelessWidget {
  const _SummaryTotal({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: scheme.secondary),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _ExamQuestionMark {
  const _ExamQuestionMark({
    required this.question,
    required this.maxMark,
    required this.controller,
    this.readOnly = false,
  });

  final String question;
  final int maxMark;
  final TextEditingController controller;
  final bool readOnly;
}

class _ScoreFields extends StatelessWidget {
  const _ScoreFields({required this.fields});

  final List<_ScoreField> fields;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final field in fields)
          SizedBox(
            width: 150,
            child: TextFormField(
              initialValue: field.initialValue,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: field.label),
            ),
          ),
      ],
    );
  }
}

class _ScoreField {
  const _ScoreField(this.label, this.initialValue);

  final String label;
  final String initialValue;
}

class _SubmissionReviewTile extends StatelessWidget {
  const _SubmissionReviewTile({required this.item, required this.onOpen});

  final _SubmissionReviewItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final flagged = item.integrityStatus != 'Clean';
    final statusColor = flagged ? scheme.error : scheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: flagged
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
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.student} • ${item.matricNo}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.courseCode} • Submitted ${item.submittedAt}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: item.integrityStatus, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: 'Score ${item.score}/${item.maxScore}'),
              _MiniPill(label: item.rubricStatus),
              _MiniPill(label: item.integrityStatus),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.feedback, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.file_open_outlined),
                label: const Text('Open submission'),
              ),
              OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Grade'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.feedback_outlined),
                label: const Text('Send feedback'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignmentChip extends StatelessWidget {
  const _AssignmentChip({required this.label, required this.icon});

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

class _AssignmentQueueItem {
  const _AssignmentQueueItem({
    required this.title,
    required this.courseCode,
    required this.submissions,
    required this.marked,
    required this.late,
    required this.flagged,
    required this.dueDate,
    required this.status,
  });

  final String title;
  final String courseCode;
  final int submissions;
  final int marked;
  final int late;
  final int flagged;
  final String dueDate;
  final String status;
}

class _SubmissionReviewItem {
  const _SubmissionReviewItem({
    required this.student,
    required this.matricNo,
    required this.courseCode,
    required this.submittedAt,
    required this.score,
    required this.maxScore,
    required this.rubricStatus,
    required this.integrityStatus,
    required this.feedback,
  });

  final String student;
  final String matricNo;
  final String courseCode;
  final String submittedAt;
  final int score;
  final int maxScore;
  final String rubricStatus;
  final String integrityStatus;
  final String feedback;
}

class _ExamMarkingSample {
  const _ExamMarkingSample({
    required this.courseCode,
    required this.examTitle,
    required this.candidateNo,
    required this.student,
    required this.objectiveScore,
    required this.theoryScore,
    required this.practicalScore,
    required this.maxScore,
    required this.markingGuide,
    required this.status,
    required this.note,
  });

  final String courseCode;
  final String examTitle;
  final String candidateNo;
  final String student;
  final int objectiveScore;
  final int theoryScore;
  final int practicalScore;
  final int maxScore;
  final String markingGuide;
  final String status;
  final String note;
}
