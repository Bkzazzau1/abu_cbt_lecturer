import 'exam_hall_availability_state.dart';
import 'exam_officer_workflow_state.dart';

/// Compatibility layer for legacy shared exam workflow methods that still
/// create review notes with `Exam Officer` as the actor.
///
/// The HoD is the department's Chief Exam Officer and can use those same
/// operational controls. This bridge preserves the real human actor without
/// rewriting historical Exam Officer actions. It also remembers examination
/// hall/time requests initiated while the HoD workspace is active so that a
/// later ICT availability approval attributes the resulting schedule action
/// to the HoD who initiated the academic request, not to ICT.
class ChiefExamAuditBridge {
  ChiefExamAuditBridge._() {
    _snapshotWorkflow();
    for (final request in _hallState.requests) {
      _seenHallRequestIds.add(request.id);
    }
    _workflow.addListener(_onWorkflowChanged);
    _hallState.addListener(_onHallChanged);
  }

  static final ChiefExamAuditBridge instance = ChiefExamAuditBridge._();

  static const hodActor = 'HoD / Chief Exam Officer';

  final ExamOfficerWorkflowState _workflow = ExamOfficerWorkflowState.instance;
  final ExamHallAvailabilityState _hallState = ExamHallAvailabilityState.instance;

  final Map<int, int> _paperNoteCounts = <int, int>{};
  final Map<String, int> _resultNoteCounts = <String, int>{};
  final Set<String> _seenHallRequestIds = <String>{};

  /// Number of future schedule notes that belong to HoD-originated hall/time
  /// requests. A counter is used instead of a set because a paper may require
  /// multiple sittings.
  final Map<String, int> _hodScheduleCredits = <String, int>{};

  bool _hodWorkspaceActive = false;
  bool _processing = false;

  void enterHodWorkspace() {
    _snapshotWorkflow();
    for (final request in _hallState.requests) {
      _seenHallRequestIds.add(request.id);
    }
    _hodWorkspaceActive = true;
  }

  void leaveHodWorkspace() {
    _hodWorkspaceActive = false;
    _snapshotWorkflow();
  }

  void _onHallChanged() {
    for (final request in _hallState.requests) {
      if (!_seenHallRequestIds.add(request.id)) continue;
      if (!_hodWorkspaceActive) continue;
      if (request.requestType != HallTimeRequestType.examination) continue;

      _hodScheduleCredits.update(
        request.sourceId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
  }

  void _onWorkflowChanged() {
    if (_processing) return;
    _processing = true;
    try {
      for (final paper in _workflow.questionPapers) {
        final previousCount = _paperNoteCounts[paper.paperId] ?? 0;
        final start = previousCount.clamp(0, paper.notes.length).toInt();

        for (var i = start; i < paper.notes.length; i++) {
          final note = paper.notes[i];
          if (note.actor != 'Exam Officer') continue;

          final schedulingAction =
              note.action == 'Exam Fully Scheduled' ||
              note.action == 'Exam Sitting Scheduled';
          final scheduleCredit = _hodScheduleCredits[paper.id] ?? 0;
          final belongsToHod =
              _hodWorkspaceActive || (schedulingAction && scheduleCredit > 0);

          if (!belongsToHod) continue;

          paper.notes[i] = ExamOfficerReviewNote(
            actor: hodActor,
            action: note.action,
            note: note.note,
          );

          if (schedulingAction && scheduleCredit > 0) {
            if (scheduleCredit == 1) {
              _hodScheduleCredits.remove(paper.id);
            } else {
              _hodScheduleCredits[paper.id] = scheduleCredit - 1;
            }
          }
        }

        _paperNoteCounts[paper.paperId] = paper.notes.length;
      }

      for (final batch in _workflow.resultBatches) {
        final previousCount = _resultNoteCounts[batch.id] ?? 0;
        final start = previousCount.clamp(0, batch.notes.length).toInt();

        for (var i = start; i < batch.notes.length; i++) {
          final note = batch.notes[i];
          if (!_hodWorkspaceActive || note.actor != 'Exam Officer') continue;
          batch.notes[i] = ExamOfficerReviewNote(
            actor: hodActor,
            action: note.action,
            note: note.note,
          );
        }

        _resultNoteCounts[batch.id] = batch.notes.length;
      }
    } finally {
      _processing = false;
    }
  }

  void _snapshotWorkflow() {
    for (final paper in _workflow.questionPapers) {
      _paperNoteCounts[paper.paperId] = paper.notes.length;
    }
    for (final batch in _workflow.resultBatches) {
      _resultNoteCounts[batch.id] = batch.notes.length;
    }
  }
}
