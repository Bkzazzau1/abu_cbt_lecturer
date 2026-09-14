import '../../../core/network/api_client.dart';

class ReviewEvidenceApi {
  ReviewEvidenceApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<ReviewEvidenceCase>> listCases({
    String? status,
    String? attentionLevel,
    String? assignedRole,
    String? courseCode,
    String? attemptId,
  }) async {
    final query = <String, String>{};
    void addIfPresent(String key, String? value) {
      final clean = value?.trim() ?? '';
      if (clean.isNotEmpty && clean != 'all') query[key] = clean;
    }

    addIfPresent('status', status);
    addIfPresent('attention_level', attentionLevel);
    addIfPresent('assigned_role', assignedRole);
    addIfPresent('course_code', courseCode);
    addIfPresent('attempt_id', attemptId);

    final response = await _client.get(
      '/api/review/evidence-cases',
      query: query.isEmpty ? null : query,
    );
    if (response is! List) return const <ReviewEvidenceCase>[];
    return response
        .whereType<Map>()
        .map(
          (item) =>
              ReviewEvidenceCase.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<ReviewEvidenceCase> takeAction({
    required String caseId,
    required String action,
    String? actorId,
    String? actorRole,
    String? comment,
  }) async {
    final response = await _client.post(
      '/api/review/evidence-cases/$caseId/$action',
      body: <String, Object?>{
        if ((actorId ?? '').trim().isNotEmpty) 'actor_id': actorId,
        if ((actorRole ?? '').trim().isNotEmpty) 'actor_role': actorRole,
        if ((comment ?? '').trim().isNotEmpty) 'comment': comment,
      },
    );
    if (response is! Map) {
      throw const ApiException('Unexpected review case response');
    }
    return ReviewEvidenceCase.fromJson(Map<String, dynamic>.from(response));
  }

  void close() => _client.close();
}

class ReviewEvidenceCase {
  const ReviewEvidenceCase({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.matricNumber,
    required this.courseCode,
    required this.courseTitle,
    required this.assessmentTitle,
    required this.sessionId,
    required this.attemptId,
    required this.attentionLevel,
    required this.status,
    required this.riskLevel,
    required this.riskPoints,
    required this.reviewSummary,
    required this.assignedRole,
    required this.evidenceFiles,
    required this.timeline,
    required this.actions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewEvidenceCase.fromJson(Map<String, dynamic> json) {
    return ReviewEvidenceCase(
      id: _string(json['id']),
      studentId: _string(json['student_id']),
      studentName: _string(json['student_name'], fallback: 'Student'),
      matricNumber: _string(json['matric_number']),
      courseCode: _string(json['course_code']),
      courseTitle: _string(json['course_title']),
      assessmentTitle: _string(json['assessment_title']),
      sessionId: _string(json['session_id']),
      attemptId: _string(json['attempt_id']),
      attentionLevel: _string(
        json['attention_level'],
        fallback: 'medium_attention_required',
      ),
      status: _string(json['status'], fallback: 'awaiting_review'),
      riskLevel: _string(json['risk_level']),
      riskPoints: _int(json['risk_points']),
      reviewSummary: _string(
        json['review_summary'],
        fallback: 'Activity records are available for human review.',
      ),
      assignedRole: _string(json['assigned_role']),
      evidenceFiles: _list(
        json['evidence_files'],
      ).map(ReviewEvidenceFile.fromJson).toList(),
      timeline: _list(
        json['timeline'],
      ).map(ReviewTimelineItem.fromJson).toList(),
      actions: _list(json['actions']).map(ReviewAction.fromJson).toList(),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );
  }

  final String id;
  final String studentId;
  final String studentName;
  final String matricNumber;
  final String courseCode;
  final String courseTitle;
  final String assessmentTitle;
  final String sessionId;
  final String attemptId;
  final String attentionLevel;
  final String status;
  final String riskLevel;
  final int riskPoints;
  final String reviewSummary;
  final String assignedRole;
  final List<ReviewEvidenceFile> evidenceFiles;
  final List<ReviewTimelineItem> timeline;
  final List<ReviewAction> actions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get courseLabel {
    final code = courseCode.trim();
    final title = courseTitle.trim();
    if (code.isEmpty && title.isEmpty) return 'Course not specified';
    if (code.isEmpty) return title;
    if (title.isEmpty) return code;
    return '$code - $title';
  }

  String get assessmentLabel => assessmentTitle.trim().isEmpty
      ? 'Assessment not specified'
      : assessmentTitle.trim();

  String get studentLabel {
    final matric = matricNumber.trim();
    if (matric.isEmpty) return studentName;
    return '$studentName • $matric';
  }

  ReviewEvidenceCase copyWith({String? status, List<ReviewAction>? actions}) {
    return ReviewEvidenceCase(
      id: id,
      studentId: studentId,
      studentName: studentName,
      matricNumber: matricNumber,
      courseCode: courseCode,
      courseTitle: courseTitle,
      assessmentTitle: assessmentTitle,
      sessionId: sessionId,
      attemptId: attemptId,
      attentionLevel: attentionLevel,
      status: status ?? this.status,
      riskLevel: riskLevel,
      riskPoints: riskPoints,
      reviewSummary: reviewSummary,
      assignedRole: assignedRole,
      evidenceFiles: evidenceFiles,
      timeline: timeline,
      actions: actions ?? this.actions,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ReviewEvidenceFile {
  const ReviewEvidenceFile({
    required this.id,
    required this.title,
    required this.evidenceType,
    required this.sourceKey,
    required this.fileUrl,
    required this.status,
    required this.detail,
  });

  factory ReviewEvidenceFile.fromJson(Map<String, dynamic> json) {
    return ReviewEvidenceFile(
      id: _string(json['id']),
      title: _string(json['title'], fallback: 'Evidence file'),
      evidenceType: _string(json['evidence_type']),
      sourceKey: _string(json['source_key']),
      fileUrl: _string(json['file_url']),
      status: _string(json['status'], fallback: 'available'),
      detail: _string(json['detail']),
    );
  }

  final String id;
  final String title;
  final String evidenceType;
  final String sourceKey;
  final String fileUrl;
  final String status;
  final String detail;
}

class ReviewTimelineItem {
  const ReviewTimelineItem({
    required this.id,
    required this.eventType,
    required this.message,
    required this.alertLevel,
    required this.eventTime,
    required this.metadata,
  });

  factory ReviewTimelineItem.fromJson(Map<String, dynamic> json) {
    return ReviewTimelineItem(
      id: _string(json['id']),
      eventType: _string(json['event_type']),
      message: _string(json['message'], fallback: 'Activity record saved.'),
      alertLevel: _string(json['alert_level']),
      eventTime: _date(json['event_time']),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const <String, dynamic>{},
    );
  }

  final String id;
  final String eventType;
  final String message;
  final String alertLevel;
  final DateTime? eventTime;
  final Map<String, dynamic> metadata;

  List<String> get signalGroups => _stringValues(metadata['signal_groups']);
  List<String> get reasons => _stringValues(metadata['reasons']);

  String get modelLabel {
    final id = _string(metadata['model_id']);
    final version = _string(metadata['model_version']);
    if (id.isEmpty) return '';
    return version.isEmpty ? id : '$id v$version';
  }

  bool get observableBehaviourOnly =>
      metadata['observable_behaviour_only'] == true;
}

class ReviewAction {
  const ReviewAction({
    required this.id,
    required this.actorRole,
    required this.action,
    required this.comment,
    required this.fromStatus,
    required this.toStatus,
    required this.createdAt,
  });

  factory ReviewAction.fromJson(Map<String, dynamic> json) {
    return ReviewAction(
      id: _string(json['id']),
      actorRole: _string(json['actor_role']),
      action: _string(json['action']),
      comment: _string(json['comment']),
      fromStatus: _string(json['from_status']),
      toStatus: _string(json['to_status']),
      createdAt: _date(json['created_at']),
    );
  }

  final String id;
  final String actorRole;
  final String action;
  final String comment;
  final String fromStatus;
  final String toStatus;
  final DateTime? createdAt;
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<String> _stringValues(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String _string(dynamic value, {String fallback = ''}) {
  final clean = value?.toString().trim() ?? '';
  return clean.isEmpty ? fallback : clean;
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _date(dynamic value) {
  final clean = value?.toString().trim() ?? '';
  if (clean.isEmpty) return null;
  return DateTime.tryParse(clean)?.toLocal();
}

String reviewLabel(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return 'Not specified';
  return clean
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
