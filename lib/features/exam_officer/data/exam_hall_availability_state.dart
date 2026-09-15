import 'package:flutter/foundation.dart';

import '../../lecturer_workflow/data/cbt_calendar_state.dart';
import 'exam_officer_workflow_state.dart';

enum ExamHallAvailabilityStatus { pending, approved, rejected }

enum HallTimeRequestType { examination, continuousAssessment }

extension ExamHallAvailabilityStatusLabel on ExamHallAvailabilityStatus {
  String get label {
    switch (this) {
      case ExamHallAvailabilityStatus.pending:
        return 'Pending ICT Check';
      case ExamHallAvailabilityStatus.approved:
        return 'Available';
      case ExamHallAvailabilityStatus.rejected:
        return 'Not Available';
    }
  }
}

extension HallTimeRequestTypeLabel on HallTimeRequestType {
  String get label {
    switch (this) {
      case HallTimeRequestType.examination:
        return 'Examination';
      case HallTimeRequestType.continuousAssessment:
        return 'CA';
    }
  }
}

class ExamHallDefinition {
  const ExamHallDefinition({
    required this.id,
    required this.name,
    required this.capacity,
  });

  final String id;
  final String name;
  final int capacity;
}

class CaHallSchedulePlan {
  const CaHallSchedulePlan({
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.caLabel,
    required this.title,
    required this.durationMinutes,
    required this.questions,
    required this.lecturerName,
  });

  final int courseId;
  final String courseCode;
  final String courseTitle;
  final String caLabel;
  final String title;
  final int durationMinutes;
  final List<CaQuestionSnapshot> questions;
  final String lecturerName;
}

class ExamHallAvailabilityRequest {
  ExamHallAvailabilityRequest({
    required this.id,
    required this.requestType,
    required this.sourceId,
    required this.hallId,
    required this.hallName,
    required this.capacity,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.caPlan,
    this.status = ExamHallAvailabilityStatus.pending,
    this.responseNote = '',
    this.approvedSlotId,
    this.scheduledAssessmentId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final HallTimeRequestType requestType;
  final String sourceId;
  final String hallId;
  final String hallName;
  final int capacity;
  final DateTime date;
  final String startTime;
  final String endTime;
  final CaHallSchedulePlan? caPlan;
  ExamHallAvailabilityStatus status;
  String responseNote;
  String? approvedSlotId;
  String? scheduledAssessmentId;
  final DateTime createdAt;

  String get paperId => sourceId;

  String get dateLabel =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String get timeLabel => '$startTime–$endTime';
  String get scheduleLabel => '$dateLabel • $timeLabel • $hallName';
}

class ExamHallAvailabilityState extends ChangeNotifier {
  ExamHallAvailabilityState._() {
    _requests.addAll([
      ExamHallAvailabilityRequest(
        id: 'hall-history-7',
        requestType: HallTimeRequestType.continuousAssessment,
        sourceId: 'history-ca-7',
        hallId: 'hall-a',
        hallName: 'CBT Centre A',
        capacity: 250,
        date: DateTime(2026, 9, 15),
        startTime: '14:00',
        endTime: '15:00',
        status: ExamHallAvailabilityStatus.approved,
        responseNote: 'Hall and time confirmed available by ICT.',
        createdAt: DateTime(2026, 9, 15, 10, 20),
      ),
      ExamHallAvailabilityRequest(
        id: 'hall-history-6',
        requestType: HallTimeRequestType.examination,
        sourceId: 'history-exam-6',
        hallId: 'hall-main',
        hallName: 'Multi-Purpose CBT Hall',
        capacity: 300,
        date: DateTime(2026, 9, 20),
        startTime: '09:00',
        endTime: '12:00',
        status: ExamHallAvailabilityStatus.approved,
        responseNote: 'Hall and time confirmed available by ICT.',
        createdAt: DateTime(2026, 9, 15, 9, 45),
      ),
      ExamHallAvailabilityRequest(
        id: 'hall-history-5',
        requestType: HallTimeRequestType.continuousAssessment,
        sourceId: 'history-ca-5',
        hallId: 'hall-b',
        hallName: 'CBT Centre B',
        capacity: 180,
        date: DateTime(2026, 9, 19),
        startTime: '10:00',
        endTime: '11:00',
        status: ExamHallAvailabilityStatus.rejected,
        responseNote: 'Hall reserved for maintenance during the requested period.',
        createdAt: DateTime(2026, 9, 15, 9, 10),
      ),
      ExamHallAvailabilityRequest(
        id: 'hall-history-4',
        requestType: HallTimeRequestType.examination,
        sourceId: 'history-exam-4',
        hallId: 'hall-c',
        hallName: 'CBT Centre C',
        capacity: 120,
        date: DateTime(2026, 9, 19),
        startTime: '13:00',
        endTime: '16:00',
        status: ExamHallAvailabilityStatus.rejected,
        responseNote: 'Requested period overlaps an existing hall booking.',
        createdAt: DateTime(2026, 9, 14, 16, 5),
      ),
      ExamHallAvailabilityRequest(
        id: 'hall-history-3',
        requestType: HallTimeRequestType.examination,
        sourceId: 'history-exam-3',
        hallId: 'hall-a',
        hallName: 'CBT Centre A',
        capacity: 250,
        date: DateTime(2026, 9, 18),
        startTime: '13:00',
        endTime: '16:00',
        status: ExamHallAvailabilityStatus.approved,
        responseNote: 'Hall and time confirmed available by ICT.',
        createdAt: DateTime(2026, 9, 14, 14, 30),
      ),
      ExamHallAvailabilityRequest(
        id: 'hall-history-2',
        requestType: HallTimeRequestType.continuousAssessment,
        sourceId: 'history-ca-2',
        hallId: 'hall-c',
        hallName: 'CBT Centre C',
        capacity: 120,
        date: DateTime(2026, 9, 18),
        startTime: '11:00',
        endTime: '12:00',
        status: ExamHallAvailabilityStatus.approved,
        responseNote: 'Hall and time confirmed available by ICT.',
        createdAt: DateTime(2026, 9, 14, 13, 50),
      ),
      ExamHallAvailabilityRequest(
        id: 'hall-history-1',
        requestType: HallTimeRequestType.examination,
        sourceId: 'history-only',
        hallId: 'hall-b',
        hallName: 'CBT Centre B',
        capacity: 180,
        date: DateTime(2026, 9, 18),
        startTime: '09:00',
        endTime: '12:00',
        status: ExamHallAvailabilityStatus.rejected,
        responseNote: 'Hall already reserved for another university activity.',
        createdAt: DateTime(2026, 9, 14, 12, 15),
      ),
    ]);
  }

  static final ExamHallAvailabilityState instance =
      ExamHallAvailabilityState._();

  static const halls = [
    ExamHallDefinition(id: 'hall-a', name: 'CBT Centre A', capacity: 250),
    ExamHallDefinition(id: 'hall-b', name: 'CBT Centre B', capacity: 180),
    ExamHallDefinition(id: 'hall-c', name: 'CBT Centre C', capacity: 120),
    ExamHallDefinition(
      id: 'hall-main',
      name: 'Multi-Purpose CBT Hall',
      capacity: 300,
    ),
  ];

  final List<ExamHallAvailabilityRequest> _requests = [];

  List<ExamHallAvailabilityRequest> get requests => List.unmodifiable(_requests);

  List<ExamHallAvailabilityRequest> requestsForPaper(String paperId) =>
      _requests
          .where(
            (item) =>
                item.requestType == HallTimeRequestType.examination &&
                item.sourceId == paperId,
          )
          .toList(growable: false);

  List<ExamHallAvailabilityRequest> requestsForCaSource(String sourceId) =>
      _requests
          .where(
            (item) =>
                item.requestType == HallTimeRequestType.continuousAssessment &&
                item.sourceId == sourceId,
          )
          .toList(growable: false);

  List<ExamHallAvailabilityRequest> pendingForPaper(String paperId) =>
      requestsForPaper(paperId)
          .where((item) => item.status == ExamHallAvailabilityStatus.pending)
          .toList(growable: false);

  ExamHallAvailabilityRequest? requestById(String id) {
    for (final request in _requests) {
      if (request.id == id) return request;
    }
    return null;
  }

  ExamHallAvailabilityRequest requestAvailability({
    required String paperId,
    required String hallId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) {
    return _createRequest(
      requestType: HallTimeRequestType.examination,
      sourceId: paperId,
      hallId: hallId,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );
  }

  ExamHallAvailabilityRequest requestCaAvailability({
    required int courseId,
    required String courseCode,
    required String courseTitle,
    required String caLabel,
    required String title,
    required int durationMinutes,
    required List<CaQuestionSnapshot> questions,
    required String lecturerName,
    required String hallId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) {
    final now = DateTime.now().microsecondsSinceEpoch;
    final plan = CaHallSchedulePlan(
      courseId: courseId,
      courseCode: courseCode,
      courseTitle: courseTitle,
      caLabel: caLabel,
      title: title,
      durationMinutes: durationMinutes,
      questions: List<CaQuestionSnapshot>.unmodifiable(questions),
      lecturerName: lecturerName,
    );
    return _createRequest(
      requestType: HallTimeRequestType.continuousAssessment,
      sourceId: 'ca-plan-$now',
      hallId: hallId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      caPlan: plan,
    );
  }

  ExamHallAvailabilityRequest reassignCaAvailability({
    required String rejectedRequestId,
    required String hallId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) {
    final previous = _request(rejectedRequestId);
    if (previous.requestType != HallTimeRequestType.continuousAssessment ||
        previous.caPlan == null) {
      throw StateError('This is not a CA hall/time request.');
    }
    if (previous.status != ExamHallAvailabilityStatus.rejected) {
      throw StateError('Only a rejected CA request can be reassigned.');
    }
    return _createRequest(
      requestType: HallTimeRequestType.continuousAssessment,
      sourceId: previous.sourceId,
      hallId: hallId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      caPlan: previous.caPlan,
    );
  }

  ExamHallAvailabilityRequest _createRequest({
    required HallTimeRequestType requestType,
    required String sourceId,
    required String hallId,
    required DateTime date,
    required String startTime,
    required String endTime,
    CaHallSchedulePlan? caPlan,
  }) {
    final hall = halls.firstWhere((item) => item.id == hallId);
    if (_minutes(startTime, endTime) <= 0) {
      throw StateError('End time must be later than start time.');
    }
    final duplicate = _requests.any(
      (item) =>
          item.sourceId == sourceId &&
          item.status == ExamHallAvailabilityStatus.pending &&
          item.hallId == hallId &&
          _sameDay(item.date, date) &&
          item.startTime == startTime &&
          item.endTime == endTime,
    );
    if (duplicate) {
      throw StateError('This hall and time request is already pending with ICT.');
    }

    final request = ExamHallAvailabilityRequest(
      id: 'hall-req-${DateTime.now().microsecondsSinceEpoch}',
      requestType: requestType,
      sourceId: sourceId,
      hallId: hall.id,
      hallName: hall.name,
      capacity: hall.capacity,
      date: date,
      startTime: startTime,
      endTime: endTime,
      caPlan: caPlan,
    );
    _requests.insert(0, request);
    notifyListeners();
    return request;
  }

  bool hasOperationalConflict(ExamHallAvailabilityRequest request) {
    final calendar = CbtCalendarState.instance;
    return calendar.slots.any(
      (slot) =>
          slot.venue == request.hallName &&
          _sameDay(slot.date, request.date) &&
          (slot.isBooked || !slot.enabled) &&
          _overlaps(
            request.startTime,
            request.endTime,
            slot.startTime,
            slot.endTime,
          ),
    );
  }

  void approve(String requestId) {
    final request = _request(requestId);
    if (request.status != ExamHallAvailabilityStatus.pending) return;
    if (hasOperationalConflict(request)) {
      throw StateError('This hall is not available at the requested time.');
    }

    final calendar = CbtCalendarState.instance;
    final slot = _resolveOrCreateSlot(calendar, request);

    if (request.requestType == HallTimeRequestType.examination) {
      ExamOfficerWorkflowState.instance.scheduleExamSitting(
        paperId: request.sourceId,
        slotId: slot.id,
      );
    } else {
      final plan = request.caPlan;
      if (plan == null) {
        throw StateError('CA scheduling information is unavailable.');
      }
      if (_minutes(request.startTime, request.endTime) < plan.durationMinutes) {
        throw StateError('The approved time is shorter than the CA duration.');
      }
      final assessment = calendar.scheduleCa(
        courseId: plan.courseId,
        courseCode: plan.courseCode,
        courseTitle: plan.courseTitle,
        caLabel: plan.caLabel,
        title: plan.title,
        durationMinutes: plan.durationMinutes,
        questions: plan.questions,
        slotId: slot.id,
        actor: plan.lecturerName,
      );
      request.scheduledAssessmentId = assessment.id;
    }

    request.status = ExamHallAvailabilityStatus.approved;
    request.responseNote = 'Hall and time confirmed available by ICT.';
    request.approvedSlotId = slot.id;
    notifyListeners();
  }

  CbtCalendarSlot _resolveOrCreateSlot(
    CbtCalendarState calendar,
    ExamHallAvailabilityRequest request,
  ) {
    for (final candidate in calendar.slots) {
      if (candidate.isAvailable &&
          candidate.venue == request.hallName &&
          _sameDay(candidate.date, request.date) &&
          candidate.startTime == request.startTime &&
          candidate.endTime == request.endTime) {
        return candidate;
      }
    }

    final before = calendar.slots.map((item) => item.id).toSet();
    calendar.addSlot(
      date: request.date,
      startTime: request.startTime,
      endTime: request.endTime,
      venue: request.hallName,
      capacity: request.capacity,
    );
    return calendar.slots.firstWhere((item) => !before.contains(item.id));
  }

  void reject(String requestId, {String note = ''}) {
    final request = _request(requestId);
    if (request.status != ExamHallAvailabilityStatus.pending) return;
    request.status = ExamHallAvailabilityStatus.rejected;
    request.responseNote = note.trim().isEmpty
        ? 'Hall or time is not available.'
        : note.trim();
    notifyListeners();
  }

  ExamHallAvailabilityRequest _request(String id) =>
      _requests.firstWhere((item) => item.id == id);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _overlaps(String startA, String endA, String startB, String endB) {
  final a1 = _clock(startA);
  final a2 = _clock(endA);
  final b1 = _clock(startB);
  final b2 = _clock(endB);
  return a1 < b2 && b1 < a2;
}

int _minutes(String start, String end) => _clock(end) - _clock(start);

int _clock(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return 0;
  return (int.tryParse(parts[0]) ?? 0) * 60 +
      (int.tryParse(parts[1]) ?? 0);
}
