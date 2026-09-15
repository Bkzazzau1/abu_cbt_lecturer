/// Everything in this file runs locally — no backend is required to demo
/// the Lecturer question-builder flow. Course lists, submitted papers, and
/// AI drafting all come from in-memory demo data. When a real backend is
/// ready to be wired in, this is the file to swap `ApiClient` calls back
/// into (the model classes/shapes below already match the documented
/// `/api/courses`, `/api/exams`, and `/api/ai/questions/draft` contracts).
class LecturerQuestionApi {
  LecturerQuestionApi();

  static final List<QuestionCourseOption> _courses = const [
    QuestionCourseOption(
      id: 1,
      code: 'CSC101',
      title: 'Introduction to Computer Science',
    ),
    QuestionCourseOption(
      id: 2,
      code: 'CSC102',
      title: 'Programming Fundamentals',
    ),
    QuestionCourseOption(id: 3, code: 'CSC305', title: 'Data Structures'),
  ];

  static final List<QuestionPaperItem> _demoPapers = [
    QuestionPaperItem.fromJson({
      'id': 9001,
      'course_code': 'CSC305',
      'course_title': 'Data Structures',
      'title': 'Data Structures Mid-Semester CBT',
      'status': 'approved',
      'duration_minutes': 60,
      'question_payload': {
        'questions': List.generate(
          20,
          (i) => {'marks': 2, 'prompt': 'Sample question ${i + 1}'},
        ),
      },
    }),
    QuestionPaperItem.fromJson({
      'id': 9000,
      'course_code': 'CSC101',
      'course_title': 'Introduction to Computer Science',
      'title': 'CSC101 First Semester Final',
      'status': 'closed',
      'duration_minutes': 90,
      'question_payload': {
        'questions': List.generate(
          30,
          (i) => {'marks': 1, 'prompt': 'Sample question ${i + 1}'},
        ),
      },
    }),
  ];

  Future<List<QuestionCourseOption>> fetchCourses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_courses);
  }

  Future<List<QuestionPaperItem>> fetchQuestionPapers() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_demoPapers);
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
    await Future.delayed(const Duration(milliseconds: 500));

    final course = _courses.where((item) => item.id == courseId).toList();
    final item = QuestionPaperItem.fromJson({
      'id': DateTime.now().millisecondsSinceEpoch,
      'course_code': course.isEmpty ? '' : course.first.code,
      'course_title': course.isEmpty ? '' : course.first.title,
      'title': title,
      'status': 'officer_review',
      'duration_minutes': durationMinutes,
      'question_payload': questionPayload,
    });
    _demoPapers.insert(0, item);
    return item;
  }

  /// Placeholder "upload" — returns a local marker URL instead of sending
  /// [bytes] anywhere. Good enough for the demo flow to show an "uploaded"
  /// state without a file-storage backend.
  Future<String> uploadFile({
    required List<int> bytes,
    required String fileName,
    required String category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return 'demo://uploads/$category/$fileName';
  }

  /// "Drafts" candidate questions for a topic using a local template
  /// generator — not a live AI model. Always succeeds so the demo flow
  /// never gets stuck waiting on a backend; the lecturer still reviews,
  /// edits, and chooses which (if any) drafts to add to the paper.
  Future<AiQuestionDraftResult> draftQuestions({
    required String topic,
    required String questionType,
    required int count,
    int marksPerQuestion = 1,
    String? courseLabel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final questions = List.generate(
      count,
      (i) => _generateDraft(topic, questionType, marksPerQuestion, i + 1),
    );
    return AiQuestionDraftResult.available(questions);
  }

  AiDraftedQuestion _generateDraft(
    String topic,
    String type,
    int marks,
    int number,
  ) {
    final cleanTopic = topic.trim();
    switch (type) {
      case 'single_choice':
        return AiDraftedQuestion(
          type: type,
          prompt: 'Which statement best describes $cleanTopic? (item $number)',
          marks: marks,
          options: [
            'The core defining property of $cleanTopic',
            'A common misconception about $cleanTopic',
            'A concept unrelated to $cleanTopic',
            'The opposite of $cleanTopic',
          ],
          correctOptionKey: 'A',
        );
      case 'multiple_choice':
        return AiDraftedQuestion(
          type: type,
          prompt:
              'Select all statements that correctly apply to $cleanTopic. (item $number)',
          marks: marks,
          options: [
            'A true statement about $cleanTopic',
            'Another true statement about $cleanTopic',
            'A statement unrelated to $cleanTopic',
            'A common misconception about $cleanTopic',
          ],
          correctOptionKey: 'A',
        );
      case 'fill_blank':
        return AiDraftedQuestion(
          type: type,
          prompt:
              'Complete the statement: $cleanTopic is best characterised by ____. (item $number)',
          marks: marks,
          answer: 'a defining property of $cleanTopic',
        );
      case 'essay':
      default:
        return AiDraftedQuestion(
          type: 'essay',
          prompt:
              'Discuss $cleanTopic, covering its key principles and one practical example. (item $number)',
          marks: marks,
          answer:
              'A strong answer explains the core idea of $cleanTopic, gives a '
              'correct supporting example, and notes at least one limitation '
              'or edge case.',
        );
    }
  }

  Future<List<ArchivedQuestionItem>> fetchArchivedQuestions() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final items = List<ArchivedQuestionItem>.from(_archivedQuestions)
      ..sort((a, b) => b.sessionStartYear.compareTo(a.sessionStartYear));
    return List.unmodifiable(items);
  }

  static final List<ArchivedQuestionItem> _archivedQuestions = [
    const ArchivedQuestionItem(
      id: 8001,
      sessionStartYear: 2025,
      courseCode: 'CSC305',
      courseTitle: 'Data Structures',
      paperTitle: 'Data Structures Mid-Semester CBT',
      questionText:
          'Explain how a binary search tree maintains O(log n) average '
          'lookup time and describe a scenario where it degrades to O(n).',
      type: 'essay',
      marks: 15,
      difficulty: 'high',
    ),
    const ArchivedQuestionItem(
      id: 8002,
      sessionStartYear: 2024,
      courseCode: 'CSC102',
      courseTitle: 'Programming Fundamentals',
      paperTitle: 'CSC102 Second Semester Final',
      questionText:
          'Write a function to compute the factorial of a number using '
          'recursion.',
      type: 'essay',
      marks: 10,
      difficulty: 'high',
    ),
    const ArchivedQuestionItem(
      id: 8003,
      sessionStartYear: 2023,
      courseCode: 'CSC101',
      courseTitle: 'Introduction to Computer Science',
      paperTitle: 'CSC101 First Semester Final',
      questionText: 'Which of the following best describes a compiler?',
      type: 'single_choice',
      marks: 2,
      difficulty: 'low',
    ),
    const ArchivedQuestionItem(
      id: 8004,
      sessionStartYear: 2022,
      courseCode: 'CSC305',
      courseTitle: 'Data Structures',
      paperTitle: 'Data Structures First Semester Final',
      questionText: 'Which data structure uses FIFO ordering?',
      type: 'single_choice',
      marks: 2,
      difficulty: 'low',
    ),
    const ArchivedQuestionItem(
      id: 8005,
      sessionStartYear: 2021,
      courseCode: 'CSC102',
      courseTitle: 'Programming Fundamentals',
      paperTitle: 'CSC102 Mid-Semester CBT',
      questionText:
          'What will be the output of the following loop: '
          'for (i = 0; i < 5; i++) print(i);?',
      type: 'single_choice',
      marks: 2,
      difficulty: 'low',
    ),
    const ArchivedQuestionItem(
      id: 8006,
      sessionStartYear: 2020,
      courseCode: 'CSC101',
      courseTitle: 'Introduction to Computer Science',
      paperTitle: 'CSC101 Mid-Semester CBT',
      questionText: 'Explain the difference between RAM and ROM.',
      type: 'essay',
      marks: 5,
      difficulty: 'low',
    ),
    const ArchivedQuestionItem(
      id: 8007,
      sessionStartYear: 2019,
      courseCode: 'CSC102',
      courseTitle: 'Programming Fundamentals',
      paperTitle: 'CSC102 First Semester Final',
      questionText:
          'Differentiate between a compile-time error and a run-time error, '
          'with examples.',
      type: 'essay',
      marks: 8,
      difficulty: 'medium',
    ),
    const ArchivedQuestionItem(
      id: 8008,
      sessionStartYear: 2018,
      courseCode: 'CSC305',
      courseTitle: 'Data Structures',
      paperTitle: 'Data Structures First Semester Final',
      questionText:
          'Compare the time complexity of insertion in an array versus a '
          'linked list.',
      type: 'essay',
      marks: 10,
      difficulty: 'medium',
    ),
  ];

  void close() {}
}

/// The academic session (e.g. 2026 -> "2026/2027") the CBT platform
/// currently treats as "now", used to work out which archived questions are
/// still inside the 5-year no-repeat window. Nigerian university sessions
/// typically begin around September/October, so a date before September is
/// still counted as part of the session that started the previous year.
int currentAcademicSessionStartYear([DateTime? now]) {
  final today = now ?? DateTime.now();
  return today.month >= 9 ? today.year : today.year - 1;
}

String formatAcademicSession(int startYear) => '$startYear/${startYear + 1}';

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

/// A single question from a past exam session, kept indefinitely so lecturers
/// (and, eventually, an AI duplicate-check) can see whether a question has
/// been asked before and how long until it is eligible to be reused. The
/// platform enforces a five-session no-repeat window: a question stays
/// locked until [eligibleAgainSessionStart].
class ArchivedQuestionItem {
  const ArchivedQuestionItem({
    required this.id,
    required this.sessionStartYear,
    required this.courseCode,
    required this.courseTitle,
    required this.paperTitle,
    required this.questionText,
    required this.type,
    required this.marks,
    required this.difficulty,
  });

  static const int noRepeatWindowSessions = 5;

  final int id;
  final int sessionStartYear;
  final String courseCode;
  final String courseTitle;
  final String paperTitle;
  final String questionText;
  final String type;
  final int marks;

  /// One of 'low', 'medium', or 'high'.
  final String difficulty;

  String get session => formatAcademicSession(sessionStartYear);

  int get eligibleAgainSessionStart =>
      sessionStartYear + noRepeatWindowSessions;

  String get eligibleAgainSession =>
      formatAcademicSession(eligibleAgainSessionStart);

  bool isLocked([DateTime? now]) =>
      currentAcademicSessionStartYear(now) < eligibleAgainSessionStart;

  String get courseLabel {
    final parts = [
      courseCode,
      courseTitle,
    ].where((item) => item.trim().isNotEmpty);
    return parts.join(' - ');
  }

  String get difficultyLabel => difficulty.isEmpty
      ? 'Unrated'
      : difficulty[0].toUpperCase() + difficulty.substring(1);

  String get typeLabel => type
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

/// One AI-drafted candidate question, before the lecturer has reviewed it.
class AiDraftedQuestion {
  const AiDraftedQuestion({
    required this.type,
    required this.prompt,
    required this.marks,
    this.options = const [],
    this.correctOptionKey,
    this.answer = '',
  });

  final String type;
  final String prompt;
  final int marks;

  /// Plain option text in display order (A, B, C, ...) — only populated for
  /// single/multiple choice questions.
  final List<String> options;

  /// Key ('A', 'B', ...) of the option the AI believes is correct, for
  /// single-choice drafts. Always re-check before trusting this.
  final String? correctOptionKey;

  /// Suggested model answer/rubric text, for essay or fill-in-the-blank
  /// drafts.
  final String answer;

  factory AiDraftedQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions.map((item) => item.toString()).toList()
        : <String>[];

    return AiDraftedQuestion(
      type: (json['type'] ?? json['question_type'] ?? '').toString(),
      prompt: (json['prompt'] ?? json['question_text'] ?? '').toString(),
      marks: int.tryParse(json['marks']?.toString() ?? '') ?? 1,
      options: options,
      correctOptionKey: json['correct_option']?.toString(),
      answer: (json['answer'] ?? json['model_answer'] ?? '').toString(),
    );
  }
}

/// Outcome of an AI question-drafting request. Kept as an explicit result
/// type (rather than a plain list) so this file's shape survives an eventual
/// swap to a real backend, where "no drafts" and "service unreachable" are
/// meaningfully different outcomes for the UI to show.
class AiQuestionDraftResult {
  const AiQuestionDraftResult._({
    required this.available,
    this.questions = const [],
    this.message,
  });

  final bool available;
  final List<AiDraftedQuestion> questions;
  final String? message;

  factory AiQuestionDraftResult.available(List<AiDraftedQuestion> questions) =>
      AiQuestionDraftResult._(available: true, questions: questions);

  factory AiQuestionDraftResult.unavailable([String? message]) =>
      AiQuestionDraftResult._(
        available: false,
        message: message ?? 'AI question drafting is unavailable right now.',
      );
}
