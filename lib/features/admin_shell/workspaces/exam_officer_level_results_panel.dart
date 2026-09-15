import 'package:flutter/material.dart';

import '../../exam_officer/data/level_result_moderation_state.dart';

class ExamOfficerLevelResultsPanel extends StatefulWidget {
  const ExamOfficerLevelResultsPanel({super.key});

  @override
  State<ExamOfficerLevelResultsPanel> createState() =>
      _ExamOfficerLevelResultsPanelState();
}

class _ExamOfficerLevelResultsPanelState
    extends State<ExamOfficerLevelResultsPanel> {
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
                    Icons.groups_2_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Level Result Moderation',
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
                'After lecturer marking and Exam Officer verification, results are assembled by level. The Exam Officer may send a level directly to the HoD or open result moderation after the departmental meeting. Any approved mark adjustment is applied uniformly to that level while the original lecturer marks remain visible.',
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
              _pill('${board.verifiedCourses}/${board.courses.length} verified'),
              _pill('${board.studentScoreRows} result rows'),
              _pill('Original avg ${board.originalAverage.toStringAsFixed(1)}'),
              _pill('Adjustment $adjustment'),
              _pill('Moderated avg ${board.moderatedAverage.toStringAsFixed(1)}'),
            ],
          ),
          if (board.meetingReference.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Departmental meeting: ${board.meetingReference}',
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
                label: const Text('Inspect Level Results'),
              ),
              if (board.status == LevelResultStatus.readyForDecision ||
                  board.status == LevelResultStatus.returnedToExamOfficer) ...[
                FilledButton.tonalIcon(
                  onPressed: () => _openModeration(board),
                  icon: const Icon(Icons.meeting_room_outlined),
                  label: const Text('Open Level Moderation'),
                ),
                FilledButton.icon(
                  onPressed: () => _sendDirect(board),
                  icon: const Icon(Icons.forward_to_inbox_outlined),
                  label: const Text('Send to HoD — No Moderation'),
                ),
              ],
              if (board.status == LevelResultStatus.moderationInProgress) ...[
                FilledButton.tonalIcon(
                  onPressed: () => _applyAdjustment(board),
                  icon: const Icon(Icons.exposure_outlined),
                  label: const Text('Set Level Adjustment'),
                ),
                FilledButton.icon(
                  onPressed: () => _sendModerated(board),
                  icon: const Icon(Icons.forward_to_inbox_outlined),
                  label: const Text('Send Moderated Level to HoD'),
                ),
              ],
              if (board.status == LevelResultStatus.waitingHodApproval)
                const Chip(
                  avatar: Icon(Icons.hourglass_top_outlined, size: 18),
                  label: Text('Waiting for HoD approval'),
                ),
              if (board.status == LevelResultStatus.hodApproved)
                const Chip(
                  avatar: Icon(Icons.verified_outlined, size: 18),
                  label: Text('Approved by HoD — awaiting publication'),
                ),
              if (board.status == LevelResultStatus.published)
                const Chip(
                  avatar: Icon(Icons.public_outlined, size: 18),
                  label: Text('Level results published'),
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

  Future<void> _openModeration(LevelResultBoard board) async {
    final meeting = TextEditingController();
    final note = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Open ${board.level} Result Moderation'),
        content: SizedBox(
          width: 620,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: meeting,
                decoration: const InputDecoration(
                  labelText: 'Departmental meeting reference/title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: note,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Meeting / moderation note',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Moderation'),
          ),
        ],
      ),
    );
    if (result != true) {
      meeting.dispose();
      note.dispose();
      return;
    }
    try {
      _state.openModeration(
        level: board.level,
        meetingReference: meeting.text,
        note: note.text,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
    meeting.dispose();
    note.dispose();
  }

  Future<void> _applyAdjustment(LevelResultBoard board) async {
    final adjustment = TextEditingController(text: '${board.adjustment}');
    final note = TextEditingController(text: board.moderationNote);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${board.level} Uniform Mark Adjustment'),
        content: SizedBox(
          width: 620,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: adjustment,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                decoration: const InputDecoration(
                  labelText: 'Adjustment (e.g. 3 or -2)',
                  helperText: 'Applied to every final result score in this level; scores remain between 0 and 100.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: note,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Departmental decision / reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply Adjustment'),
          ),
        ],
      ),
    );
    if (result == true) {
      final value = int.tryParse(adjustment.text.trim());
      if (value == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter a whole-number adjustment.')),
          );
        }
      } else {
        try {
          _state.applyLevelAdjustment(
            level: board.level,
            adjustment: value,
            note: note.text,
          );
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(error.toString())));
          }
        }
      }
    }
    adjustment.dispose();
    note.dispose();
  }

  Future<void> _sendDirect(LevelResultBoard board) async {
    final note = await _noteDialog(
      title: 'Send ${board.level} to HoD',
      hint: 'Optional note for the HoD. No level mark adjustment will be applied.',
    );
    if (note == null) return;
    try {
      _state.sendToHod(
        level: board.level,
        note: note,
        withoutModeration: true,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _sendModerated(LevelResultBoard board) async {
    final note = await _noteDialog(
      title: 'Submit Moderated ${board.level} Results',
      hint: 'Add the note that should accompany the moderated level package to the HoD.',
    );
    if (note == null) return;
    try {
      _state.sendToHod(
        level: board.level,
        note: note,
        withoutModeration: false,
      );
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
        title: Text('${board.level} Result Package'),
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
                  Text(
                    '${course.lecturers.join(' / ')} • ${course.students.length} result rows • original avg ${course.originalAverage.toStringAsFixed(1)} • moderated avg ${course.moderatedAverage(board.adjustment).toStringAsFixed(1)}',
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
                        DataColumn(label: Text('Moderated')),
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
