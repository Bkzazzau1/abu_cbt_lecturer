import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_session.dart';
import 'lecturer_course_collaboration_state.dart';

enum CbtSlotRequestStatus { pending, approved, rejected }

enum CaAssessmentStatus { scheduled, slotPending, slotRejected }

extension CbtSlotRequestStatusLabel on CbtSlotRequestStatus {
  String get label {
    switch (this) {
      case CbtSlotRequestStatus.pending:
        return 'Pending';
      case CbtSlotRequestStatus.approved:
        return 'Approved';
      case CbtSlotRequestStatus.rejected:
        return 'Rejected';
    }
  }
}

extension CaAssessmentStatusLabel on CaAssessmentStatus {
  String get label {
    switch (this) {
      case CaAssessmentStatus.scheduled:
        return 'Scheduled';
      case CaAssessmentStatus.slotPending:
        return 'Slot Request Pending';
      case CaAssessmentStatus.slotRejected:
        return 'Slot Request Rejected';
    }
  }
}

class CaQuestionSnapshot {
  const CaQuestionSnapshot({
    required this.type,
    required this.prompt,
    required this.marks,
    required this.answer,
    this.options = const [],
  });

  final String type;
  final String prompt;
  final int marks;
  final String answer;
  final List<String> options;
}

class CbtCalendarSlot {
  CbtCalendarSlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.capacity,
    this.enabled = true,
    this.bookedAssessmentId,
    this.bookedCourseCode,
    this.bookedCaLabel,
  });

  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String venue;
  final int capacity;
  bool enabled;
  String? bookedAssessmentId;
  String? bookedCourseCode;
  String? bookedCaLabel;

  bool get isBooked => bookedAssessmentId != null;
  bool get isAvailable => enabled && !isBooked;

  String get statusLabel {
    if (isBooked) return 'Booked';
    return enabled ? 'Available' : 'Unavailable';
  }

  String get dateLabel =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String get scheduleLabel => '$dateLabel • $startTime–$endTime • $venue';
}

class CbtSlotRequest {
  CbtSlotRequest({
    required this.id,
    required this.assessmentId,
    required this.lecturerName,
    required this.courseCode,
    required this.caLabel,
    required this.preferredDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.questionCount,
    required this.totalMarks,
    this.status = CbtSlotRequestStatus.pending,
    this.responseNote = '',
    this.approvedSlotId,
  });

  final String id;
  final String assessmentId;
  final String lecturerName;
  final String courseCode;
  final String caLabel;
  final DateTime preferredDate;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final int questionCount;
  final int totalMarks;
  CbtSlotRequestStatus status;
  String responseNote;
  String? approvedSlotId;

  String get dateLabel =>
      '${preferredDate.day.toString().padLeft(2, '0')}/${preferredDate.month.toString().padLeft(2, '0')}/${preferredDate.year}';
}

class CaAssessmentRecord {
  CaAssessmentRecord({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.caLabel,
    required this.title,
    required this.durationMinutes,
    required this.questions,
    required this.status,
    this.slotId,
    this.requestId,
  });

  final String id;
  final int courseId;
  final String courseCode;
  final String courseTitle;
  final String caLabel;
  final String title;
  final int durationMinutes;
  final List<CaQuestionSnapshot> questions;
  CaAssessmentStatus status;
  String? slotId;
  String? requestId;

  int get questionCount => questions.length;
  int get totalMarks =>
      questions.fold<int>(0, (total, question) => total + question.marks);
}

class CbtCalendarState extends ChangeNotifier {
  CbtCalendarState._()
      : _slots = [
          CbtCalendarSlot(
            id: 'slot-1',
            date: DateTime(2026, 9, 21),
            startTime: '09:00',
            endTime: '10:00',
            venue: 'CBT Centre A',
            capacity: 250,
          ),
          CbtCalendarSlot(
            id: 'slot-2',
            date: DateTime(2026, 9, 21),
            startTime: '11:00',
            endTime: '12:00',
            venue: 'CBT Centre B',
            capacity: 180,
            enabled: false,
          ),
          CbtCalendarSlot(
            id: 'slot-3',
            date: DateTime(2026, 9, 22),
            startTime: '14:00',
            endTime: '15:00',
            venue: 'CBT Centre A',
            capacity: 250,
          ),
          CbtCalendarSlot(
            id: 'slot-4',
            date: DateTime(2026, 9, 23),
            startTime: '10:00',
            endTime: '11:00',
            venue: 'CBT Centre C',
            capacity: 120,
          ),
        ];

  static final CbtCalendarState instance = CbtCalendarState._();

  final List<CbtCalendarSlot> _slots;
  final List<CbtSlotRequest> _requests = [];
  final List<CaAssessmentRecord> _assessments = [];

  List<CbtCalendarSlot> get slots => List.unmodifiable(_slots);
  List<CbtCalendarSlot> get availableSlots =>
      _slots.where((slot) => slot.isAvailable).toList(growable: false);
  List<CbtSlotRequest> get requests => List.unmodifiable(_requests);
  List<CaAssessmentRecord> get assessments => List.unmodifiable(_assessments);

  String get _actor => AuthSession.instance.session?.name ?? 'Course Lecturer';

  void setSlotAvailability(String slotId, bool available) {
    final slot = _slot(slotId);
    if (slot.isBooked) return;
    slot.enabled = available;
    notifyListeners();
  }

  void addSlot({
    required DateTime date,
    required String startTime,
    required String endTime,
    required String venue,
    required int capacity,
  }) {
    _slots.add(
      CbtCalendarSlot(
        id: 'slot-${DateTime.now().microsecondsSinceEpoch}',
        date: date,
        startTime: startTime,
        endTime: endTime,
        venue: venue,
        capacity: capacity,
      ),
    );
    _slots.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.startTime.compareTo(b.startTime);
    });
    notifyListeners();
  }

  CaAssessmentRecord scheduleCa({
    required int courseId,
    required String courseCode,
    required String courseTitle,
    required String caLabel,
    required String title,
    required int durationMinutes,
    required List<CaQuestionSnapshot> questions,
    required String slotId,
  }) {
    final slot = _slot(slotId);
    if (!slot.isAvailable) {
      throw StateError('The selected CBT slot is no longer available.');
    }

    final assessment = CaAssessmentRecord(
      id: 'ca-${DateTime.now().microsecondsSinceEpoch}',
      courseId: courseId,
      courseCode: courseCode,
      courseTitle: courseTitle,
      caLabel: caLabel,
      title: title,
      durationMinutes: durationMinutes,
      questions: List.unmodifiable(questions),
      status: CaAssessmentStatus.scheduled,
      slotId: slot.id,
    );
    _assessments.insert(0, assessment);
    slot.bookedAssessmentId = assessment.id;
    slot.bookedCourseCode = courseCode;
    slot.bookedCaLabel = caLabel;
    LecturerCourseCollaborationState.instance.registerCaWork(
      courseCode: courseCode,
      title: title,
      caLabel: caLabel,
      questionCount: assessment.questionCount,
      totalMarks: assessment.totalMarks,
      actor: _actor,
      status: 'Scheduled',
      locked: true,
    );
    notifyListeners();
    return assessment;
  }

  CbtSlotRequest requestSlot({
    required int courseId,
    required String courseCode,
    required String courseTitle,
    required String caLabel,
    required String title,
    required int durationMinutes,
    required List<CaQuestionSnapshot> questions,
    required String lecturerName,
    required DateTime preferredDate,
    required String startTime,
    required String endTime,
  }) {
    final assessment = CaAssessmentRecord(
      id: 'ca-${DateTime.now().microsecondsSinceEpoch}',
      courseId: courseId,
      courseCode: courseCode,
      courseTitle: courseTitle,
      caLabel: caLabel,
      title: title,
      durationMinutes: durationMinutes,
      questions: List.unmodifiable(questions),
      status: CaAssessmentStatus.slotPending,
    );
    final request = CbtSlotRequest(
      id: 'req-${DateTime.now().microsecondsSinceEpoch}',
      assessmentId: assessment.id,
      lecturerName: lecturerName,
      courseCode: courseCode,
      caLabel: caLabel,
      preferredDate: preferredDate,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      questionCount: assessment.questionCount,
      totalMarks: assessment.totalMarks,
    );
    assessment.requestId = request.id;
    _assessments.insert(0, assessment);
    _requests.insert(0, request);
    LecturerCourseCollaborationState.instance.registerCaWork(
      courseCode: courseCode,
      title: title,
      caLabel: caLabel,
      questionCount: assessment.questionCount,
      totalMarks: assessment.totalMarks,
      actor: lecturerName,
      status: 'Slot Request Pending',
      locked: false,
    );
    notifyListeners();
    return request;
  }

  void approveRequest(String requestId) {
    final request = _request(requestId);
    if (request.status != CbtSlotRequestStatus.pending) return;
    final assessment = _assessment(request.assessmentId);
    final slot = CbtCalendarSlot(
      id: 'slot-${DateTime.now().microsecondsSinceEpoch}',
      date: request.preferredDate,
      startTime: request.startTime,
      endTime: request.endTime,
      venue: 'CBT Centre A',
      capacity: 250,
      bookedAssessmentId: assessment.id,
      bookedCourseCode: assessment.courseCode,
      bookedCaLabel: assessment.caLabel,
    );
    _slots.add(slot);
    request.status = CbtSlotRequestStatus.approved;
    request.approvedSlotId = slot.id;
    request.responseNote = 'CBT slot approved by ICT Admin.';
    assessment.status = CaAssessmentStatus.scheduled;
    assessment.slotId = slot.id;
    LecturerCourseCollaborationState.instance.registerCaWork(
      courseCode: assessment.courseCode,
      title: assessment.title,
      caLabel: assessment.caLabel,
      questionCount: assessment.questionCount,
      totalMarks: assessment.totalMarks,
      actor: 'ICT Admin',
      status: 'Scheduled',
      locked: true,
    );
    notifyListeners();
  }

  void rejectRequest(String requestId, {String note = ''}) {
    final request = _request(requestId);
    if (request.status != CbtSlotRequestStatus.pending) return;
    request.status = CbtSlotRequestStatus.rejected;
    request.responseNote = note.trim().isEmpty
        ? 'CBT slot request rejected by ICT Admin.'
        : note.trim();
    final assessment = _assessment(request.assessmentId);
    assessment.status = CaAssessmentStatus.slotRejected;
    LecturerCourseCollaborationState.instance.registerCaWork(
      courseCode: assessment.courseCode,
      title: assessment.title,
      caLabel: assessment.caLabel,
      questionCount: assessment.questionCount,
      totalMarks: assessment.totalMarks,
      actor: 'ICT Admin',
      status: 'Slot Request Rejected',
      locked: false,
    );
    notifyListeners();
  }

  CbtCalendarSlot? slotForAssessment(CaAssessmentRecord assessment) {
    final id = assessment.slotId;
    if (id == null) return null;
    for (final slot in _slots) {
      if (slot.id == id) return slot;
    }
    return null;
  }

  CbtSlotRequest? requestForAssessment(CaAssessmentRecord assessment) {
    final id = assessment.requestId;
    if (id == null) return null;
    for (final request in _requests) {
      if (request.id == id) return request;
    }
    return null;
  }

  CbtCalendarSlot _slot(String id) =>
      _slots.firstWhere((slot) => slot.id == id);
  CbtSlotRequest _request(String id) =>
      _requests.firstWhere((request) => request.id == id);
  CaAssessmentRecord _assessment(String id) =>
      _assessments.firstWhere((assessment) => assessment.id == id);
}
