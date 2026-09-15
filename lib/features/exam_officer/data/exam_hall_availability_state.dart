import 'package:flutter/foundation.dart';

import '../../lecturer_workflow/data/cbt_calendar_state.dart';
import 'exam_officer_workflow_state.dart';

enum ExamHallAvailabilityStatus { pending, approved, rejected }

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

class ExamHallAvailabilityRequest {
  ExamHallAvailabilityRequest({
    required this.id,
    required this.paperId,
    required this.hallId,
    required this.hallName,
    required this.capacity,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = ExamHallAvailabilityStatus.pending,
    this.responseNote = '',
    this.approvedSlotId,
  });

  final String id;
  final String paperId;
  final String hallId;
  final String hallName;
  final int capacity;
  final DateTime date;
  final String startTime;
  final String endTime;
  ExamHallAvailabilityStatus status;
  String responseNote;
  String? approvedSlotId;
  final DateTime createdAt = DateTime.now();

  String get dateLabel =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String get timeLabel => '$startTime–$endTime';
  String get scheduleLabel => '$dateLabel • $timeLabel • $hallName';
}

class ExamHallAvailabilityState extends ChangeNotifier {
  ExamHallAvailabilityState._() {
    _requests.addAll([
      ExamHallAvailabilityRequest(
        id: 'hall-history-1',
        paperId: 'history-only',
        hallId: 'hall-b',
        hallName: 'CBT Centre B',
        capacity: 180,
        date: DateTime(2026, 9, 18),
        startTime: '09:00',
        endTime: '12:00',
        status: ExamHallAvailabilityStatus.rejected,
        responseNote: 'Hall already reserved for another university activity.',
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
      _requests.where((item) => item.paperId == paperId).toList(growable: false);

  List<ExamHallAvailabilityRequest> pendingForPaper(String paperId) =>
      _requests
          .where(
            (item) =>
                item.paperId == paperId &&
                item.status == ExamHallAvailabilityStatus.pending,
          )
          .toList(growable: false);

  ExamHallAvailabilityRequest requestAvailability({
    required String paperId,
    required String hallId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) {
    final hall = halls.firstWhere((item) => item.id == hallId);
    if (_minutes(startTime, endTime) <= 0) {
      throw StateError('End time must be later than start time.');
    }
    final duplicate = _requests.any(
      (item) =>
          item.paperId == paperId &&
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
      paperId: paperId,
      hallId: hall.id,
      hallName: hall.name,
      capacity: hall.capacity,
      date: date,
      startTime: startTime,
      endTime: endTime,
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
    CbtCalendarSlot? slot;
    for (final candidate in calendar.slots) {
      if (candidate.isAvailable &&
          candidate.venue == request.hallName &&
          _sameDay(candidate.date, request.date) &&
          candidate.startTime == request.startTime &&
          candidate.endTime == request.endTime) {
        slot = candidate;
        break;
      }
    }

    if (slot == null) {
      final before = calendar.slots.map((item) => item.id).toSet();
      calendar.addSlot(
        date: request.date,
        startTime: request.startTime,
        endTime: request.endTime,
        venue: request.hallName,
        capacity: request.capacity,
      );
      slot = calendar.slots.firstWhere((item) => !before.contains(item.id));
    }

    ExamOfficerWorkflowState.instance.scheduleExamSitting(
      paperId: request.paperId,
      slotId: slot.id,
    );
    request.status = ExamHallAvailabilityStatus.approved;
    request.responseNote = 'Hall and time confirmed available by ICT.';
    request.approvedSlotId = slot.id;
    notifyListeners();
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
