import '../../../core/network/api_client.dart';

class LecturerQuestionApi {
  LecturerQuestionApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<QuestionCourseOption>> fetchCourses() async {
    try {
      final data = await _client.get('/api/courses');
      final rows = _rows(data);

      final courses = rows
          .whereType<Map>()
          .map((raw) {
            final json = raw.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            return QuestionCourseOption.fromJson(json);
          })
          .where((item) => item.id > 0)
          .toList();

      if (courses.isNotEmpty) return courses;
    } catch (_) {
      // Lecturer accounts may not have full course-list permission yet.
      // Use assigned local options until the lecturer-course endpoint is connected.
    }

    return const [
      QuestionCourseOption(
        id: 2,
        code: 'CSC102',
        title: 'Programming Fundamentals',
      ),
      QuestionCourseOption(
        id: 1,
        code: 'CSC101',
        title: 'Introduction to Computer Science',
      ),
    ];
  }

  Future<List<QuestionPaperItem>> fetchQuestionPapers() async {
    try {
      final data = await _client.get('/api/exams');
      final rows = _rows(data);

      return rows.whereType<Map>().map((raw) {
        final json = raw.map((key, value) => MapEntry(key.toString(), value));
        return QuestionPaperItem.fromJson(json);
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<QuestionPaperItem> submitQuestionPaper({
    required int courseId,
    required int lecturerId,
    required int examOfficerId,
    required String title,
    required String description,
    required String instructions,
    required int durationMinutes,
    required Map<String, dynamic> questionPayload,
  }) async {
    final startTime = DateTime.now().toUtc().add(const Duration(days: 2));
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    final data = await _client.post(
      '/api/exams',
      body: {
        'course_id': courseId,
        'title': title,
        'description': description,
        'instructions': instructions,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration_minutes': durationMinutes,
        'delivery_mode': 'remote_proctored',
        'question_payload': questionPayload,
        'lecturer_id': lecturerId,
        'exam_officer_id': examOfficerId,
        'status': 'officer_review',
      },
    );

    return QuestionPaperItem.fromJson(_asMap(data));
  }

  Future<String> uploadFile({
    required List<int> bytes,
    required String fileName,
    required String category,
  }) async {
    final data = await _client.uploadBytes(
      path: '/api/uploads',
      bytes: bytes,
      fileName: fileName,
      category: category,
    );
    final json = _asMap(data);
    return (json['url'] ?? json['file_url'] ?? json['path'] ?? '').toString();
  }

  List<dynamic> _rows(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final value = data['items'] ?? data['data'] ?? data['results'];
      if (value is List) return value;
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  void close() => _client.close();
}

class QuestionCourseOption {
  const QuestionCourseOption({
    required this.id,
    required this.code,
    required this.title,
  });

  final int id;
  final String code;
  final String title;

  factory QuestionCourseOption.fromJson(Map<String, dynamic> json) {
    return QuestionCourseOption(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
    );
  }

  String get label {
    final parts = [code, title].where((item) => item.trim().isNotEmpty);
    return parts.join(' - ');
  }
}

class QuestionPaperItem {
  const QuestionPaperItem({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.title,
    required this.status,
    required this.durationMinutes,
    required this.questionCount,
    required this.totalMarks,
  });

  final int id;
  final String courseCode;
  final String courseTitle;
  final String title;
  final String status;
  final int durationMinutes;
  final int questionCount;
  final int totalMarks;

  factory QuestionPaperItem.fromJson(Map<String, dynamic> json) {
    final payload = json['question_payload'];
    final questionPayload = payload is Map
        ? payload.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    final questions = _collectQuestions(questionPayload);

    return QuestionPaperItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      courseCode: json['course_code']?.toString() ?? '',
      courseTitle: json['course_title']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled question paper',
      status: json['status']?.toString() ?? 'draft',
      durationMinutes:
          int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 0,
      questionCount: questions.length,
      totalMarks: questions.fold<int>(
        0,
        (total, item) =>
            total + (int.tryParse(item['marks']?.toString() ?? '') ?? 0),
      ),
    );
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

  String get statusLabel => status
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');

  String get courseLabel {
    final parts = [
      courseCode,
      courseTitle,
    ].where((item) => item.trim().isNotEmpty);
    return parts.join(' - ');
  }
}
