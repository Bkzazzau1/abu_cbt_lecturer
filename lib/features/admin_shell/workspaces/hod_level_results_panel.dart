import 'package:flutter/material.dart';

import '../../exam_officer/data/level_result_moderation_state.dart';

class HodLevelResultsPanel extends StatefulWidget {
  const HodLevelResultsPanel({super.key});

  @override
  State<HodLevelResultsPanel> createState() => _HodLevelResultsPanelState();
}

class _HodLevelResultsPanelState extends State<HodLevelResultsPanel> {
  final LevelResultModerationState _state = LevelResultModerationState.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'HoD Level Result Approval & Publication',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'The HoD receives complete level result packages from the Exam Officer. Review the original marks, any departmental moderation adjustment, and the audit trail before approving. Results are published one level at a time only after HoD approval.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              for (final board in _state.boards) _boardCard(context, board),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boardCard(BuildContext context, LevelResultBoard board) {
    final scheme = Theme.of(context).colorScheme;
    final adjustment = board.adjustment >= 0
        ? '+${board.adjustment}'
        : '${board.adjustment}';
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
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                board.level,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              Chip(label: Text(board.status.label)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('${board.courses.length} courses'),
              _pill('${board.studentScoreRows} result rows'),
              _pill('Original avg ${board.originalAverage.toStringAsFixed(1)}'),
              _pill('Adjustment $adjustment'),
              _pill('Moderated avg ${board.moderatedAverage.toStringAsFixed(1)}'),
              if (board.departmentalMeetingHeld)
                _pill('Departmental meeting recorded'),
            ],
          ),
          if (board.meetingReference.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Meeting: ${board.meetingReference}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
          if (board.moderationNote.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              board.moderationNote,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _inspect(board),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Review Level Package'),
              ),
              if (board.status == LevelResultStatus.waitingHodApproval) ...[
                FilledButton.tonalIcon(
                  onPressed: () => _returnToExamOfficer(board),
                  icon: const Icon(Icons.assignment_return_outlined),
                  label: const Text('Return to Exam Officer'),
                ),
                FilledButton.icon(
                  onPressed: () => _approve(board),
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Approve Level Results'),
                ),
              ],
              if (board.status == LevelResultStatus.hodApproved)
                FilledButton.icon(
                  onPressed: () => _publish(board),
                  icon: const Icon(Icons.publish_outlined),
                  label: const Text('Publish This Level'),
                ),
              if (board.status == LevelResultStatus.published)
                const Chip(
                  avatar: Icon(Icons.public_outlined, size: 18),
                  label: Text('Published'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) => Chip(
        visualDensity: VisualDensity.compact,
        label: Text(text),
      );

  Future<void> _approve(LevelResultBoard board) async {
    final note = await _noteDialog(
      title: 'Approve ${board.level} Results',
      hint: 'Approval note for the audit trail.',
    );
    if (note == null) return;
    _state.hodApprove(level: board.level, note: note);
  }

  Future<void> _returnToExamOfficer(LevelResultBoard board) async {
    final note = await _noteDialog(
      title: 'Return ${board.level} Results',
      hint: 'Explain what the Exam Officer or department must review.',
    );
    if (note == null) return;
    _state.hodReturn(level: board.level, note: note);
  }

  Future<void> _publish(LevelResultBoard board) async {
    final note = await _noteDialog(
      title: 'Publish ${board.level} Results',
      hint: 'Optional publication note.',
    );
    if (note == null) return;
    try {
      _state.publishLevel(level: board.level, note: note);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<String?> _noteDialog({required String title, required String hint}) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Note',
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  void _inspect(LevelResultBoard board) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${board.level} — HoD Review'),
        content: SizedBox(
          width: 980,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final course in board.courses) ...[
                  Text(
                    '${course.courseCode} • ${course.courseTitle}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Matric')),
                        DataColumn(label: Text('Student')),
                        DataColumn(label: Text('Original')),
                        DataColumn(label: Text('Adjustment')),
                        DataColumn(label: Text('Final')),
                        DataColumn(label: Text('Grade')),
                      ],
                      rows: [
                        for (final row in course.students)
                          DataRow(cells: [
                            DataCell(Text(row.matricNumber)),
                            DataCell(Text(row.studentName)),
                            DataCell(Text('${row.originalScore}')),
                            DataCell(Text(board.adjustment >= 0
                                ? '+${board.adjustment}'
                                : '${board.adjustment}')),
                            DataCell(Text('${row.moderatedScore(board.adjustment)}')),
                            DataCell(Text(row.gradeFor(board.adjustment))),
                          ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (board.audit.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Audit Trail',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  for (final item in board.audit)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('${item.actor} • ${item.action}: ${item.note}'),
                    ),
                ],
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
}
