import '../../../core/network/api_client.dart' show ApiException;

/// Everything in this file runs locally — no backend is required to demo the
/// exam officer / moderator workflow screens. The demo exams below cover
/// every stage of the lecturer -> exam officer -> moderator -> exam officer
/// -> HoD -> scheduling -> release pipeline. When a real backend is ready,
/// this is the file to swap back to `ApiClient` calls against the documented
/// `/api/exams` contract — the model shapes already match it.
class ExamWorkflowApi {
  ExamWorkflowApi();

  static final List<Map<String, dynamic>> _demoExams = [
    {
      'id': 7001,
      'course_code': 'CSC102',
      'course_title': 'Programming Fundamentals',
      'title': 'CSC102 Second Semester Final',
      'status': 'draft',
      'delivery_mode': 'cbt',
      'duration_minutes': 90,
      'venue': '',
      'question_payload': {
        'questions': List.generate(
          30,
          (i) => {
            'type': 'single_choice',
            'marks': 1,
            'prompt': 'Sample question ${i + 1}',
          },
        ),
        'workflow_notes': <Map<String, dynamic>>[],
      },
    },
    {
      'id': 7002,
      'course_code': 'CSC101',
      'course_title': 'Introduction to Computer Science',
      'title': 'CSC101 First Semester Final',
      'status': 'officer_review',
      'delivery_mode': 'cbt',
      'duration_minutes': 90,
      'venue': '',
      'question_payload': {
        'questions': List.generate(
          30,
          (i) => {
            'type': 'single_choice',
            'marks': 1,
            'prompt': 'Sample question ${i + 1}',
          },
        ),
        'workflow_notes': [
          {
            'action': 'submit-to-officer',
            'comment': 'Ready for exam officer review.',
            'user_id': 'demo-lecturer',
            'at': '2026-08-20T09:00:00Z',
          },
        ],
      },
    },
    {
      'id': 7003,
      'course_code': 'CSC305',
      'course_title': 'Data Structures',
      'title': 'Data Structures Mid-Semester CBT',
      'status': 'moderator_review',
      'delivery_mode': 'cbt',
      'duration_minutes': 60,
      'venue': '',
      'question_payload': {
        'questions': List.generate(
          20,
          (i) => {
            'type': 'essay',
            'marks': 2,
            'prompt': 'Sample question ${i + 1}',
          },
        ),
        'workflow_notes': [
          {
            'action': 'submit-to-officer',
            'comment': 'Please confirm marks scheme.',
            'user_id': 'demo-lecturer',
            'at': '2026-08-18T09:00:00Z',
          },
          {
            'action': 'send-to-moderator',
            'comment': 'Forwarding for moderation.',
            'user_id': 'demo-exam-officer',
            'at': '2026-08-19T09:00:00Z',
          },
        ],
      },
    },
    {
      'id': 7004,
      'course_code': 'CSC101',
      'course_title': 'Introduction to Computer Science',
      'title': 'CSC101 Mid-Semester CBT',
      'status': 'moderated',
      'delivery_mode': 'cbt',
      'duration_minutes': 60,
      'venue': '',
      'question_payload': {
        'questions': List.generate(
          15,
          (i) => {
            'type': 'single_choice',
            'marks': 1,
            'prompt': 'Sample question ${i + 1}',
          },
        ),
        'workflow_notes': [
          {
            'action': 'moderator-return',
            'comment': 'Approved, no corrections needed.',
            'user_id': 'demo-moderator',
            'at': '2026-08-15T09:00:00Z',
          },
        ],
      },
    },
    {
      'id': 7005,
      'course_code': 'CSC102',
      'course_title': 'Programming Fundamentals',
      'title': 'CSC102 Mid-Semester CBT',
      'status': 'lecturer_correction',
      'delivery_mode': 'cbt',
      'duration_minutes': 60,
      'venue': '',
      'question_payload': {
        'questions': List.generate(
          20,
          (i) => {
            'type': 'fill_blank',
            'marks': 1,
            'prompt': 'Sample question ${i + 1}',
          },
        ),
        'workflow_notes': [
          {
            'action': 'send-back-to-lecturer',
            'comment': 'Question 12 has two correct options — please fix.',
            'user_id': 'demo-moderator',
            'at': '2026-08-10T09:00:00Z',
          },
        ],
      },
    },
    {
      'id': 7006,
      'course_code': 'CSC305',
      'course_title': 'Data Structures',
      'title': 'Data Structures First Semester Final',
      'status': 'scheduled',
      'delivery_mode': 'cbt',
      'start_time': '2026-09-25T09:00:00Z',
      'end_time': '2026-09-25T11:00:00Z',
      'duration_minutes': 120,
      'venue': 'CBT Centre 1',
      'question_payload': {
        'questions': List.generate(
          30,
          (i) => {
            'type': 'single_choice',
            'marks': 1,
            'prompt': 'Sample question ${i + 1}',
          },
        ),
        'workflow_notes': [
          {
            'action': 'schedule',
            'comment': 'Exam scheduled for student access.',
            'user_id': 'demo-exam-officer',
            'at': '2026-09-01T09:00:00Z',
          },
        ],
      },
    },
    {
      'id': 7007,
      'course_code': 'CSC101',
      'course_title': 'Introduction to Computer Science',
      'title': 'CSC101 Previous Semester Final',
      'status': 'released',
      'delivery_mode': 'cbt',
      'start_time': '2026-04-10T09:00:00Z',
      'end_time': '2026-04-10T11:00:00Z',
      'duration_minutes': 120,
      'venue': 'ICT Lab A',
      'question_payload': {
        'questions': List.generate(
          30,
          (i) => {
            'type': 'single_choice',
            'marks': 1,
            'prompt': 'Sample question ${i + 1}',
          },
        ),
        'workflow_notes': [
          {
            'action': 'release',
            'comment': 'Released to students.',
            'user_id': 'demo-exam-officer',
            'at': '2026-04-09T09:00:00Z',
          },
        ],
      },
    },
  ];

  Future<List<ExamWorkflowItem>> fetchExams() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _demoExams
        .map((raw) => ExamWorkflowItem.fromJson(_deepCopy(raw)))
        .toList();
  }

  Future<ExamWorkflowItem> submitToOfficer(int examId, String comment) {
    return _postAction(examId, 'submit-to-officer', 'officer_review', comment);
  }

  Future<ExamWorkflowItem> sendToModerator(int examId, String comment) {
    return _postAction(
      examId,
      'send-to-moderator',
      'moderator_review',
      comment,
    );
  }

  Future<ExamWorkflowItem> moderatorReturn(int examId, String comment) {
    return _postAction(examId, 'moderator-return', 'moderated', comment);
  }

  Future<ExamWorkflowItem> sendBackToLecturer(int examId, String comment) {
    return _postAction(
      examId,
      'send-back-to-lecturer',
      'lecturer_correction',
      comment,
    );
  }

  Future<ExamWorkflowItem> releaseExam(int examId, String comment) {
    return _postAction(examId, 'release', 'released', comment);
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
    await Future.delayed(const Duration(milliseconds: 400));
    final raw = _findRaw(examId);
    raw['start_time'] = startTime.toUtc().toIso8601String();
    raw['end_time'] = endTime.toUtc().toIso8601String();
    raw['duration_minutes'] = durationMinutes;
    raw['venue'] = venue;
    raw['status'] = 'scheduled';
    _appendNote(raw, 'schedule', comment, 'demo-exam-officer');
    return ExamWorkflowItem.fromJson(_deepCopy(raw));
  }

  Future<ExamWorkflowItem> _postAction(
    int examId,
    String action,
    String nextStatus,
    String comment,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final raw = _findRaw(examId);
    raw['status'] = nextStatus;
    _appendNote(raw, action, comment, 'demo-user');
    return ExamWorkflowItem.fromJson(_deepCopy(raw));
  }

  Map<String, dynamic> _findRaw(int examId) {
    for (final raw in _demoExams) {
      if (raw['id'] == examId) return raw;
    }
    throw const ApiException('Exam not found');
  }

  void _appendNote(
    Map<String, dynamic> raw,
    String action,
    String comment,
    String userId,
  ) {
    final payload = Map<String, dynamic>.from(
      raw['question_payload'] as Map? ?? const {},
    );
    final notes = List<Map<String, dynamic>>.from(
      (payload['workflow_notes'] as List? ?? const []).whereType<Map>().map(
        (note) => Map<String, dynamic>.from(note),
      ),
    );
    notes.insert(0, {
      'action': action,
      'comment': comment,
      'user_id': userId,
      'at': DateTime.now().toUtc().toIso8601String(),
    });
    payload['workflow_notes'] = notes;
    raw['question_payload'] = payload;
  }

  Map<String, dynamic> _deepCopy(Map<String, dynamic> raw) {
    final copy = Map<String, dynamic>.from(raw);
    final payload = copy['question_payload'];
    if (payload is Map) {
      copy['question_payload'] = Map<String, dynamic>.from(payload);
    }
    return copy;
  }

  void close() {}
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
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
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
