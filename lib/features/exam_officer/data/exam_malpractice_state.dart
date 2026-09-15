import 'package:flutter/foundation.dart';

enum ExamMalpracticeStatus {
  reported,
  evidenceReview,
  statementPending,
  readyForEscalation,
  escalatedToHod,
  committeeReview,
  decisionRecorded,
  closedNoCase,
}

extension ExamMalpracticeStatusX on ExamMalpracticeStatus {
  String get label {
    switch (this) {
      case ExamMalpracticeStatus.reported:
        return 'Reported';
      case ExamMalpracticeStatus.evidenceReview:
        return 'Evidence Review';
      case ExamMalpracticeStatus.statementPending:
        return 'Statement Pending';
      case ExamMalpracticeStatus.readyForEscalation:
        return 'Ready for Escalation';
      case ExamMalpracticeStatus.escalatedToHod:
        return 'Escalated to HoD';
      case ExamMalpracticeStatus.committeeReview:
        return 'Committee Review';
      case ExamMalpracticeStatus.decisionRecorded:
        return 'Decision Recorded';
      case ExamMalpracticeStatus.closedNoCase:
        return 'Closed — No Case';
    }
  }

  bool get isOpen =>
      this != ExamMalpracticeStatus.decisionRecorded &&
      this != ExamMalpracticeStatus.closedNoCase;
}

class ExamMalpracticeEvidence {
  const ExamMalpracticeEvidence({
    required this.id,
    required this.label,
    required this.type,
    required this.source,
    required this.reference,
    required this.capturedAt,
  });

  final String id;
  final String label;
  final String type;
  final String source;
  final String reference;
  final DateTime capturedAt;
}

class ExamMalpracticeStatement {
  const ExamMalpracticeStatement({
    required this.actor,
    required this.role,
    required this.statement,
    required this.recordedAt,
  });

  final String actor;
  final String role;
  final String statement;
  final DateTime recordedAt;
}

class ExamMalpracticeAuditEntry {
  const ExamMalpracticeAuditEntry({
    required this.actor,
    required this.action,
    required this.note,
    required this.createdAt,
  });

  final String actor;
  final String action;
  final String note;
  final DateTime createdAt;
}

class ExamMalpracticeCase {
  ExamMalpracticeCase({
    required this.id,
    required this.studentName,
    required this.matricNumber,
    required this.courseCode,
    required this.examTitle,
    required this.sitting,
    required this.venue,
    required this.reportedBy,
    required this.incidentType,
    required this.summary,
    required this.createdAt,
    this.status = ExamMalpracticeStatus.reported,
    List<ExamMalpracticeEvidence>? evidence,
    List<ExamMalpracticeStatement>? statements,
    List<ExamMalpracticeAuditEntry>? audit,
    this.escalationReference,
    this.externalDecision,
  })  : evidence = evidence ?? [],
        statements = statements ?? [],
        audit = audit ?? [];

  final String id;
  final String studentName;
  final String matricNumber;
  final String courseCode;
  final String examTitle;
  final String sitting;
  final String venue;
  final String reportedBy;
  final String incidentType;
  final String summary;
  final DateTime createdAt;
  ExamMalpracticeStatus status;
  final List<ExamMalpracticeEvidence> evidence;
  final List<ExamMalpracticeStatement> statements;
  final List<ExamMalpracticeAuditEntry> audit;
  String? escalationReference;
  String? externalDecision;
}

class ExamMalpracticeState extends ChangeNotifier {
  ExamMalpracticeState._() {
    _seed();
  }

  static final ExamMalpracticeState instance = ExamMalpracticeState._();

  final List<ExamMalpracticeCase> _cases = [];

  static const incidentTypes = [
    'Prohibited material',
    'Unauthorized device',
    'Communication / collusion',
    'Impersonation / identity concern',
    'Unauthorized assistance',
    'Exam conduct violation',
    'Other reported incident',
  ];

  List<ExamMalpracticeCase> get cases => List.unmodifiable(_cases);

  int get openCases => _cases.where((item) => item.status.isOpen).length;
  int get awaitingEvidenceOrStatement => _cases
      .where(
        (item) =>
            item.status == ExamMalpracticeStatus.reported ||
            item.status == ExamMalpracticeStatus.evidenceReview ||
            item.status == ExamMalpracticeStatus.statementPending,
      )
      .length;
  int get readyForEscalation => _cases
      .where((item) => item.status == ExamMalpracticeStatus.readyForEscalation)
      .length;
  int get escalated => _cases
      .where(
        (item) =>
            item.status == ExamMalpracticeStatus.escalatedToHod ||
            item.status == ExamMalpracticeStatus.committeeReview,
      )
      .length;
  int get concluded => _cases
      .where(
        (item) =>
            item.status == ExamMalpracticeStatus.decisionRecorded ||
            item.status == ExamMalpracticeStatus.closedNoCase,
      )
      .length;

  void registerIncident({
    required String studentName,
    required String matricNumber,
    required String courseCode,
    required String examTitle,
    required String sitting,
    required String venue,
    required String reportedBy,
    required String incidentType,
    required String summary,
  }) {
    final now = DateTime.now();
    final id = 'MP-${now.microsecondsSinceEpoch.toString().substring(6)}';
    final item = ExamMalpracticeCase(
      id: id,
      studentName: studentName.trim(),
      matricNumber: matricNumber.trim(),
      courseCode: courseCode.trim().toUpperCase(),
      examTitle: examTitle.trim(),
      sitting: sitting.trim(),
      venue: venue.trim(),
      reportedBy: reportedBy.trim(),
      incidentType: incidentType,
      summary: summary.trim(),
      createdAt: now,
    );
    item.audit.add(
      ExamMalpracticeAuditEntry(
        actor: 'Exam Officer',
        action: 'Incident Registered',
        note: 'Case opened from an examination incident report.',
        createdAt: now,
      ),
    );
    _cases.insert(0, item);
    notifyListeners();
  }

  void startEvidenceReview(String caseId) {
    final item = _case(caseId);
    if (item.status != ExamMalpracticeStatus.reported) return;
    item.status = ExamMalpracticeStatus.evidenceReview;
    _audit(item, 'Exam Officer', 'Evidence Review Started',
        'Incident evidence and source records opened for review.');
  }

  void addEvidence({
    required String caseId,
    required String label,
    required String type,
    required String source,
    required String reference,
  }) {
    final item = _case(caseId);
    final now = DateTime.now();
    item.evidence.add(
      ExamMalpracticeEvidence(
        id: 'EV-${now.microsecondsSinceEpoch}',
        label: label.trim(),
        type: type.trim(),
        source: source.trim(),
        reference: reference.trim(),
        capturedAt: now,
      ),
    );
    _audit(
      item,
      'Exam Officer',
      'Evidence Added',
      '${label.trim()} • Source: ${source.trim()} • Ref: ${reference.trim()}',
    );
  }

  void requestStatement(String caseId, String note) {
    final item = _case(caseId);
    if (item.status == ExamMalpracticeStatus.escalatedToHod ||
        item.status == ExamMalpracticeStatus.committeeReview ||
        item.status == ExamMalpracticeStatus.decisionRecorded ||
        item.status == ExamMalpracticeStatus.closedNoCase) {
      return;
    }
    item.status = ExamMalpracticeStatus.statementPending;
    _audit(
      item,
      'Exam Officer',
      'Statement Requested',
      note.trim().isEmpty
          ? 'A formal statement was requested for the case file.'
          : note.trim(),
    );
  }

  void addStatement({
    required String caseId,
    required String actor,
    required String role,
    required String statement,
  }) {
    final item = _case(caseId);
    final now = DateTime.now();
    item.statements.add(
      ExamMalpracticeStatement(
        actor: actor.trim(),
        role: role.trim(),
        statement: statement.trim(),
        recordedAt: now,
      ),
    );
    _audit(
      item,
      'Exam Officer',
      'Statement Recorded',
      '${role.trim()} statement recorded from ${actor.trim()}.',
    );
  }

  void markReadyForEscalation(String caseId, String note) {
    final item = _case(caseId);
    if (item.status == ExamMalpracticeStatus.decisionRecorded ||
        item.status == ExamMalpracticeStatus.closedNoCase ||
        item.status == ExamMalpracticeStatus.escalatedToHod ||
        item.status == ExamMalpracticeStatus.committeeReview) {
      return;
    }
    item.status = ExamMalpracticeStatus.readyForEscalation;
    _audit(
      item,
      'Exam Officer',
      'Case Prepared for Escalation',
      note.trim().isEmpty
          ? 'Evidence and statements reviewed. Case file prepared for HoD review.'
          : note.trim(),
    );
  }

  void escalateToHod(String caseId, String note) {
    final item = _case(caseId);
    if (item.status != ExamMalpracticeStatus.readyForEscalation) return;
    final now = DateTime.now();
    item.status = ExamMalpracticeStatus.escalatedToHod;
    item.escalationReference = 'HOD-MP-${now.millisecondsSinceEpoch}';
    _audit(
      item,
      'Exam Officer',
      'Escalated to HoD',
      note.trim().isEmpty
          ? 'Case file forwarded for authorized academic/disciplinary review.'
          : note.trim(),
    );
  }

  void markCommitteeReview(String caseId, String note) {
    final item = _case(caseId);
    if (item.status != ExamMalpracticeStatus.escalatedToHod) return;
    item.status = ExamMalpracticeStatus.committeeReview;
    _audit(
      item,
      'Exam Officer',
      'Committee Review Recorded',
      note.trim().isEmpty
          ? 'Authorized committee review is in progress.'
          : note.trim(),
    );
  }

  void recordExternalDecision({
    required String caseId,
    required String authority,
    required String decision,
  }) {
    final item = _case(caseId);
    if (item.status != ExamMalpracticeStatus.escalatedToHod &&
        item.status != ExamMalpracticeStatus.committeeReview) {
      return;
    }
    item.externalDecision = '${authority.trim()}: ${decision.trim()}';
    item.status = ExamMalpracticeStatus.decisionRecorded;
    _audit(
      item,
      'Exam Officer',
      'Authorized Decision Recorded',
      item.externalDecision!,
    );
  }

  void closeNoCase(String caseId, String reason) {
    final item = _case(caseId);
    if (item.status == ExamMalpracticeStatus.escalatedToHod ||
        item.status == ExamMalpracticeStatus.committeeReview ||
        item.status == ExamMalpracticeStatus.decisionRecorded) {
      return;
    }
    item.status = ExamMalpracticeStatus.closedNoCase;
    _audit(
      item,
      'Exam Officer',
      'Closed — No Case Established',
      reason.trim().isEmpty
          ? 'Review did not establish a case requiring escalation.'
          : reason.trim(),
    );
  }

  ExamMalpracticeCase _case(String id) =>
      _cases.firstWhere((item) => item.id == id);

  void _audit(
    ExamMalpracticeCase item,
    String actor,
    String action,
    String note,
  ) {
    item.audit.add(
      ExamMalpracticeAuditEntry(
        actor: actor,
        action: action,
        note: note,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void _seed() {
    if (_cases.isNotEmpty) return;

    final c1 = ExamMalpracticeCase(
      id: 'MP-2026-014',
      studentName: 'Usman Abdullahi',
      matricNumber: '2023/C/CSC/0068',
      courseCode: 'CSC 305',
      examTitle: 'Database Systems Examination',
      sitting: '24 Sep 2026 • 09:00–11:00',
      venue: 'CBT Centre A',
      reportedBy: 'Chief Invigilator — Dr. Grace Adamu',
      incidentType: 'Unauthorized device',
      summary:
          'A secondary mobile device was reported during the examination. The device was secured and the incident was documented for formal review.',
      createdAt: DateTime(2026, 9, 24, 9, 42),
      status: ExamMalpracticeStatus.evidenceReview,
      evidence: [
        ExamMalpracticeEvidence(
          id: 'EV-014-1',
          label: 'Invigilator incident form',
          type: 'Incident report',
          source: 'Chief Invigilator',
          reference: 'IR-CSC305-014',
          capturedAt: DateTime(2026, 9, 24, 9, 48),
        ),
        ExamMalpracticeEvidence(
          id: 'EV-014-2',
          label: 'Secured device custody record',
          type: 'Physical evidence record',
          source: 'Exam Hall Desk',
          reference: 'CUSTODY-014',
          capturedAt: DateTime(2026, 9, 24, 9, 51),
        ),
      ],
      audit: [
        ExamMalpracticeAuditEntry(
          actor: 'Chief Invigilator',
          action: 'Incident Reported',
          note: 'Incident documented during the sitting.',
          createdAt: DateTime(2026, 9, 24, 9, 45),
        ),
        ExamMalpracticeAuditEntry(
          actor: 'Exam Officer',
          action: 'Evidence Review Started',
          note: 'Case file opened and custody records checked.',
          createdAt: DateTime(2026, 9, 24, 11, 18),
        ),
      ],
    );

    final c2 = ExamMalpracticeCase(
      id: 'MP-2026-011',
      studentName: 'Fatima Garba',
      matricNumber: '2024/C/CSC/0009',
      courseCode: 'CSC 201',
      examTitle: 'Data Structures Examination',
      sitting: '26 Sep 2026 • 09:00–11:00',
      venue: 'CBT Centre A',
      reportedBy: 'Invigilator — Dr. Kabiru Umar',
      incidentType: 'Communication / collusion',
      summary:
          'An invigilator reported repeated communication attempts between candidates. Statements and seating-position records were collected for review.',
      createdAt: DateTime(2026, 9, 26, 10, 13),
      status: ExamMalpracticeStatus.statementPending,
      evidence: [
        ExamMalpracticeEvidence(
          id: 'EV-011-1',
          label: 'Seating position record',
          type: 'Hall record',
          source: 'CBT Centre A',
          reference: 'SEAT-26A-09',
          capturedAt: DateTime(2026, 9, 26, 10, 20),
        ),
      ],
      statements: [
        ExamMalpracticeStatement(
          actor: 'Dr. Kabiru Umar',
          role: 'Invigilator',
          statement:
              'I observed repeated attempts to communicate and reported the incident to the Chief Invigilator.',
          recordedAt: DateTime(2026, 9, 26, 12, 5),
        ),
      ],
      audit: [
        ExamMalpracticeAuditEntry(
          actor: 'Exam Officer',
          action: 'Statement Requested',
          note: 'Candidate statement requested before case-file completion.',
          createdAt: DateTime(2026, 9, 26, 13, 10),
        ),
      ],
    );

    final c3 = ExamMalpracticeCase(
      id: 'MP-2026-006',
      studentName: 'Musa Ibrahim',
      matricNumber: '2022/C/CSC/0132',
      courseCode: 'CSC 411',
      examTitle: 'Artificial Intelligence Examination',
      sitting: '28 Sep 2026 • 13:00–15:00',
      venue: 'CBT Centre B',
      reportedBy: 'Chief Invigilator — Dr. Sani Bello',
      incidentType: 'Impersonation / identity concern',
      summary:
          'Identity details presented during check-in did not match the registered candidate record. The sitting was documented and the case file was escalated after statements were collected.',
      createdAt: DateTime(2026, 9, 28, 13, 8),
      status: ExamMalpracticeStatus.escalatedToHod,
      escalationReference: 'HOD-MP-2026-006',
      evidence: [
        ExamMalpracticeEvidence(
          id: 'EV-006-1',
          label: 'Candidate identity check record',
          type: 'Identity record',
          source: 'Exam Check-in Desk',
          reference: 'IDCHECK-006',
          capturedAt: DateTime(2026, 9, 28, 13, 10),
        ),
        ExamMalpracticeEvidence(
          id: 'EV-006-2',
          label: 'Chief Invigilator report',
          type: 'Incident report',
          source: 'Chief Invigilator',
          reference: 'IR-CSC411-006',
          capturedAt: DateTime(2026, 9, 28, 15, 20),
        ),
      ],
      statements: [
        ExamMalpracticeStatement(
          actor: 'Musa Ibrahim',
          role: 'Candidate',
          statement:
              'Candidate statement recorded and attached to the official case file.',
          recordedAt: DateTime(2026, 9, 28, 16, 5),
        ),
      ],
      audit: [
        ExamMalpracticeAuditEntry(
          actor: 'Exam Officer',
          action: 'Escalated to HoD',
          note: 'Evidence package and statements forwarded for authorized review.',
          createdAt: DateTime(2026, 9, 29, 9, 15),
        ),
      ],
    );

    final c4 = ExamMalpracticeCase(
      id: 'MP-2026-003',
      studentName: 'Aisha Muhammad',
      matricNumber: '2024/C/CSC/0001',
      courseCode: 'CSC 201',
      examTitle: 'Data Structures Examination',
      sitting: '20 Sep 2026 • 09:00–11:00',
      venue: 'CBT Centre C',
      reportedBy: 'Invigilator — Dr. Yusuf Abdullahi',
      incidentType: 'Exam conduct violation',
      summary:
          'A conduct concern was reported and reviewed. Available records did not establish a case requiring disciplinary escalation.',
      createdAt: DateTime(2026, 9, 20, 10, 22),
      status: ExamMalpracticeStatus.closedNoCase,
      audit: [
        ExamMalpracticeAuditEntry(
          actor: 'Exam Officer',
          action: 'Closed — No Case Established',
          note: 'Review completed; no disciplinary escalation required.',
          createdAt: DateTime(2026, 9, 21, 12, 30),
        ),
      ],
    );

    _cases.addAll([c1, c2, c3, c4]);
  }
}
