import 'dart:convert';

import 'package:http/http.dart' as http;

class InvigilatorEvidenceApi {
  InvigilatorEvidenceApi({
    this.baseUrl = 'https://api.fazam.tech',
    this.authTokenProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final Future<String?> Function()? authTokenProvider;
  final http.Client _client;

  Future<InvigilatorEvidenceQueue> fetchQueue({
    String severity = 'All',
    String status = 'All',
    String evidenceType = 'All',
  }) async {
    final uri = Uri.parse('$baseUrl/api/invigilator/evidence').replace(
      queryParameters: <String, String>{
        if (severity != 'All') 'severity': severity,
        if (status != 'All') 'status': status,
        if (evidenceType != 'All') 'evidence_type': evidenceType,
      },
    );
    final response = await _client.get(uri, headers: await _headers());
    if (response.statusCode != 200) {
      throw StateError('Failed to load evidence queue: ${response.statusCode}');
    }
    return InvigilatorEvidenceQueue.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<InvigilatorEvidenceDecision> decide({
    required String caseId,
    required String action,
    String note = '',
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/invigilator/evidence/$caseId/decision'),
      headers: await _headers(),
      body: jsonEncode(<String, Object?>{'action': action, 'note': note}),
    );
    if (response.statusCode != 200) {
      throw StateError('Failed to submit decision: ${response.statusCode}');
    }
    return InvigilatorEvidenceDecision.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = await authTokenProvider?.call();
    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }
}

class InvigilatorEvidenceQueue {
  const InvigilatorEvidenceQueue({
    required this.metrics,
    required this.items,
    required this.count,
    this.fromFallback = false,
  });

  final InvigilatorEvidenceMetrics metrics;
  final List<InvigilatorEvidenceCase> items;
  final int count;
  final bool fromFallback;

  factory InvigilatorEvidenceQueue.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const <Object?>[];
    return InvigilatorEvidenceQueue(
      metrics: InvigilatorEvidenceMetrics.fromJson(
        (json['metrics'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      items: rawItems
          .whereType<Map>()
          .map((item) => InvigilatorEvidenceCase.fromJson(item.cast<String, dynamic>()))
          .toList(),
      count: (json['count'] as num?)?.toInt() ?? rawItems.length,
    );
  }

  InvigilatorEvidenceQueue copyWith({bool? fromFallback}) {
    return InvigilatorEvidenceQueue(
      metrics: metrics,
      items: items,
      count: count,
      fromFallback: fromFallback ?? this.fromFallback,
    );
  }

  static InvigilatorEvidenceQueue fallback() {
    return InvigilatorEvidenceQueue(
      fromFallback: true,
      metrics: const InvigilatorEvidenceMetrics(
        openEvidence: 24,
        captured: 18,
        pendingCapture: 4,
        critical: 3,
        draftReports: 5,
      ),
      count: 4,
      items: const [
        InvigilatorEvidenceCase(
          id: 'case-001',
          candidate: 'Aisha Musa',
          matric: 'KASU/CSC/021',
          course: 'CSC 309 Artificial Intelligence',
          session: 'DLC Online Proctoring Group A',
          eventType: 'Multiple faces detected',
          severity: 'High',
          status: 'Pending review',
          riskScore: 86,
          confidence: 0.94,
          evidenceTypes: ['Camera', 'Manifest'],
          evidenceStatus: 'Captured',
          evidencePath: 'evidence://KASU/CSC/021/session-309/case-001.json',
          time: 'Today, 10:38',
          recommendation: 'Review camera frame evidence and escalate if second person remains visible.',
          decision: 'No decision yet',
        ),
        InvigilatorEvidenceCase(
          id: 'case-002',
          candidate: 'Bello Adamu',
          matric: 'KASU/CSC/044',
          course: 'CSC 309 Artificial Intelligence',
          session: 'DLC Online Proctoring Group A',
          eventType: 'Human voice detected',
          severity: 'High',
          status: 'Escalated',
          riskScore: 74,
          confidence: 0.89,
          evidenceTypes: ['Audio', 'Manifest'],
          evidenceStatus: 'Captured',
          evidencePath: 'evidence://KASU/CSC/044/session-309/case-002.json',
          time: 'Today, 10:42',
          recommendation: 'Listen to the short audio clip and compare with mouth movement timeline.',
          decision: 'Escalated to exam officer',
        ),
        InvigilatorEvidenceCase(
          id: 'case-003',
          candidate: 'Maryam Sani',
          matric: 'KASU/CSC/078',
          course: 'GST 211 Communication Skills',
          session: 'Morning CBT Block',
          eventType: 'Tab switching detected',
          severity: 'Medium',
          status: 'Pending review',
          riskScore: 46,
          confidence: 0.78,
          evidenceTypes: ['Screenshot', 'Manifest'],
          evidenceStatus: 'Pending capture',
          evidencePath: 'evidence://KASU/CSC/078/session-gst/case-003.json',
          time: 'Today, 10:51',
          recommendation: 'Confirm whether the system app lost focus or candidate attempted navigation.',
          decision: 'No decision yet',
        ),
        InvigilatorEvidenceCase(
          id: 'case-004',
          candidate: 'Usman Ibrahim',
          matric: 'KASU/BUS/012',
          course: 'ACC 201 Financial Accounting',
          session: 'Hybrid Practical Session',
          eventType: 'Phone detected',
          severity: 'Critical',
          status: 'Malpractice draft',
          riskScore: 112,
          confidence: 0.97,
          evidenceTypes: ['Camera', 'Screenshot', 'Manifest'],
          evidenceStatus: 'Captured',
          evidencePath: 'evidence://KASU/BUS/012/session-acc/case-004.json',
          time: 'Today, 11:06',
          recommendation: 'Prepare malpractice report if physical invigilator confirms device presence.',
          decision: 'Draft report opened',
        ),
      ],
    );
  }
}

class InvigilatorEvidenceMetrics {
  const InvigilatorEvidenceMetrics({
    required this.openEvidence,
    required this.captured,
    required this.pendingCapture,
    required this.critical,
    required this.draftReports,
  });

  final int openEvidence;
  final int captured;
  final int pendingCapture;
  final int critical;
  final int draftReports;

  factory InvigilatorEvidenceMetrics.fromJson(Map<String, dynamic> json) {
    return InvigilatorEvidenceMetrics(
      openEvidence: (json['open_evidence'] as num?)?.toInt() ?? 0,
      captured: (json['captured'] as num?)?.toInt() ?? 0,
      pendingCapture: (json['pending_capture'] as num?)?.toInt() ?? 0,
      critical: (json['critical'] as num?)?.toInt() ?? 0,
      draftReports: (json['draft_reports'] as num?)?.toInt() ?? 0,
    );
  }
}

class InvigilatorEvidenceCase {
  const InvigilatorEvidenceCase({
    required this.id,
    required this.candidate,
    required this.matric,
    required this.course,
    required this.session,
    required this.eventType,
    required this.severity,
    required this.status,
    required this.riskScore,
    required this.confidence,
    required this.evidenceTypes,
    required this.evidenceStatus,
    required this.evidencePath,
    required this.time,
    required this.recommendation,
    required this.decision,
  });

  final String id;
  final String candidate;
  final String matric;
  final String course;
  final String session;
  final String eventType;
  final String severity;
  final String status;
  final int riskScore;
  final double confidence;
  final List<String> evidenceTypes;
  final String evidenceStatus;
  final String evidencePath;
  final String time;
  final String recommendation;
  final String decision;

  factory InvigilatorEvidenceCase.fromJson(Map<String, dynamic> json) {
    return InvigilatorEvidenceCase(
      id: (json['id'] as String?) ?? '',
      candidate: (json['candidate'] as String?) ?? 'Unknown candidate',
      matric: (json['matric'] as String?) ?? '',
      course: (json['course'] as String?) ?? '',
      session: (json['session'] as String?) ?? '',
      eventType: (json['event_type'] as String?) ?? 'Integrity event',
      severity: (json['severity'] as String?) ?? 'Medium',
      status: (json['status'] as String?) ?? 'Pending review',
      riskScore: (json['risk_score'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      evidenceTypes: ((json['evidence_types'] as List?) ?? const <Object?>[])
          .map((item) => item.toString())
          .toList(),
      evidenceStatus: (json['evidence_status'] as String?) ?? 'Pending capture',
      evidencePath: (json['evidence_path'] as String?) ?? '',
      time: (json['time'] as String?) ?? '',
      recommendation: (json['recommendation'] as String?) ?? '',
      decision: (json['decision'] as String?) ?? 'No decision yet',
    );
  }
}

class InvigilatorEvidenceDecision {
  const InvigilatorEvidenceDecision({
    required this.caseId,
    required this.action,
    required this.status,
    required this.decision,
  });

  final String caseId;
  final String action;
  final String status;
  final String decision;

  factory InvigilatorEvidenceDecision.fromJson(Map<String, dynamic> json) {
    return InvigilatorEvidenceDecision(
      caseId: (json['case_id'] as String?) ?? '',
      action: (json['action'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      decision: (json['decision'] as String?) ?? '',
    );
  }
}
