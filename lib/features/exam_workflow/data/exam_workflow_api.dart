import '../../../core/network/api_client.dart';

class ExamWorkflowApi {
  ExamWorkflowApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<ExamWorkflowItem>> fetchExams() async {
    final data = await _client.get('/api/exams');
    dynamic rows = data;
    if (data is Map) {
      rows = data['items'] ?? data['data'] ?? data['results'];
    }
    if (rows is! List) return const [];

    return rows.whereType<Map>().map((raw) {
      final json = raw.map((key, value) => MapEntry(key.toString(), value));
      return ExamWorkflowItem.fromJson(json);
    }).toList();
  }

  Future<ExamWorkflowItem> submitToOfficer(int examId, String comment) {
    return _postAction(examId, 'submit-to-officer', comment);
  }

  Future<ExamWorkflowItem> sendToModerator(int examId, String comment) {
    return _postAction(examId, 'send-to-moderator', comment);
  }

  Future<ExamWorkflowItem> moderatorReturn(int examId, String comment) {
    return _postAction(examId, 'moderator-return', comment);
  }

  Future<ExamWorkflowItem> sendBackToLecturer(int examId, String comment) {
    return _postAction(examId, 'send-back-to-lecturer', comment);
  }

  Future<ExamWorkflowItem> releaseExam(int examId, String comment) async {
    final data = await _client.post(
      '/api/exams/$examId/release',
      body: {'comment': comment},
    );
    return ExamWorkflowItem.fromJson(_asStringMap(data));
  }

  Future<ExamWorkflowItem> scheduleExam({
    required int examId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    required String venue,
    required String comment,
    List<int> invigilatorIds = const [],
  }) async {
    final data = await _client.post(
      '/api/exams/$examId/schedule',
      body: {
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'duration_minutes': durationMinutes,
        'venue': venue,
        'invigilator_ids': invigilatorIds,
        'comment': comment,
      },
    );
    return ExamWorkflowItem.fromJson(_asStringMap(data));
  }

  Future<ExamWorkflowItem> _postAction(
    int examId,
    String action,
    String comment,
  ) async {
    final data = await _client.post(
      '/api/exams/$examId/$action',
      body: {'comment': comment},
    );
    return ExamWorkflowItem.fromJson(_asStringMap(data));
  }

  Map<String, dynamic> _asStringMap(dynamic data) {
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  void close() => _client.close();
}

class ExamWorkflowItem {
  const ExamWorkflowItem({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.title,
    required this.status,
    required this.deliveryMode,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.venue,
    required this.questionCount,
    required this.questionTypes,
    required this.workflowNotes,
    this.questionPayload = const {},
  });

  final int id;
  final String courseCode;
  final String courseTitle;
  final String title;
  final String status;
  final String deliveryMode;
  final DateTime? startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final String venue;
  final int questionCount;
  final List<String> questionTypes;
  final List<ExamWorkflowNote> workflowNotes;
  final Map<String, dynamic> questionPayload;

  factory ExamWorkflowItem.fromJson(Map<String, dynamic> json) {
    final questionPayload = _map(json['question_payload']);
    final questions = _collectQuestions(questionPayload);
    final types =
        questions
            .map(
              (item) =>
                  (item['type'] ?? item['question_type'])?.toString() ?? '',
            )
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final rawNotes = questionPayload['workflow_notes'];
    final notes = rawNotes is List
        ? rawNotes.whereType<Map>().map((raw) {
            return ExamWorkflowNote.fromJson(
              raw.map((key, value) => MapEntry(key.toString(), value)),
            );
          }).toList()
        : <ExamWorkflowNote>[];

    return ExamWorkflowItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      courseCode: json['course_code']?.toString() ?? '',
      courseTitle: json['course_title']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled exam',
      status: json['status']?.toString() ?? 'draft',
      deliveryMode: json['delivery_mode']?.toString() ?? '',
      startTime: DateTime.tryParse(json['start_time']?.toString() ?? ''),
      endTime: DateTime.tryParse(json['end_time']?.toString() ?? ''),
      durationMinutes:
          int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0,
      venue: json['venue']?.toString() ?? '',
      questionCount: questions.length,
      questionTypes: types,
      workflowNotes: notes,
      questionPayload: questionPayload,
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map)
      return value.map((key, item) => MapEntry(key.toString(), item));
    return const {};
  }

  static List<Map<String, dynamic>> _collectQuestions(
    Map<String, dynamic> payload,
  ) {
    final out = <Map<String, dynamic>>[];

    final questions = payload['questions'];
    if (questions is List) {
      out.addAll(
        questions.whereType<Map>().map((raw) {
          return raw.map((key, value) => MapEntry(key.toString(), value));
        }),
      );
    }

    final sections = payload['sections'];
    if (sections is List) {
      for (final section in sections.whereType<Map>()) {
        final items = section['questions'];
        if (items is List) {
          out.addAll(
            items.whereType<Map>().map((raw) {
              return raw.map((key, value) => MapEntry(key.toString(), value));
            }),
          );
        }
      }
    }

    return out;
  }

  String get statusLabel => _humanStatus(status);
  String get deliveryLabel => _humanStatus(deliveryMode);
  String get courseLabel =>
      [courseCode, courseTitle].where((e) => e.trim().isNotEmpty).join(' • ');

  String get scheduleLabel {
    if (startTime == null) return 'Not scheduled';
    final local = startTime!.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)} ${_two(local.hour)}:${_two(local.minute)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _humanStatus(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

class ExamWorkflowNote {
  const ExamWorkflowNote({
    required this.action,
    required this.comment,
    required this.userId,
    required this.at,
  });

  final String action;
  final String comment;
  final String userId;
  final String at;

  factory ExamWorkflowNote.fromJson(Map<String, dynamic> json) {
    return ExamWorkflowNote(
      action: json['action']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      at: json['at']?.toString() ?? '',
    );
  }

  String get actionLabel => ExamWorkflowItem._humanStatus(action);
}
