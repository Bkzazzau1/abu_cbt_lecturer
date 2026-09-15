import 'package:flutter/foundation.dart';

class LecturerDemoQuestionSubmission {
  const LecturerDemoQuestionSubmission({
    required this.paperId,
    required this.courseCode,
    required this.courseTitle,
    required this.title,
    required this.questionCount,
    required this.totalMarks,
    required this.status,
  });

  final int paperId;
  final String courseCode;
  final String courseTitle;
  final String title;
  final int questionCount;
  final int totalMarks;
  final String status;
}

class LecturerDemoMarkingQuestion {
  const LecturerDemoMarkingQuestion({
    required this.id,
    required this.question,
    required this.candidateAnswer,
    required this.markingGuide,
    required this.maxMark,
  });

  final String id;
  final String question;
  final String candidateAnswer;
  final String markingGuide;
  final int maxMark;
}

enum LecturerDemoScriptStatus {
  pendingMarking,
  marked,
  integrityReview,
  submittedToExamOfficer,
}

extension LecturerDemoScriptStatusLabel on LecturerDemoScriptStatus {
  String get label {
    switch (this) {
      case LecturerDemoScriptStatus.pendingMarking:
        return 'Pending Marking';
      case LecturerDemoScriptStatus.marked:
        return 'Marked';
      case LecturerDemoScriptStatus.integrityReview:
        return 'Integrity Review';
      case LecturerDemoScriptStatus.submittedToExamOfficer:
        return 'Submitted to Exam Officer';
    }
  }
}

class LecturerDemoExamScript {
  LecturerDemoExamScript({
    required this.id,
    required this.courseCode,
    required this.examTitle,
    required this.candidateNo,
    required this.student,
    required this.objectiveScore,
    required this.questions,
    required this.status,
    this.summary = '',
    Map<String, int?>? marks,
  }) : marks = marks ?? {for (final question in questions) question.id: null};

  final String id;
  final String courseCode;
  final String examTitle;
  final String candidateNo;
  final String student;
  final int objectiveScore;
  final List<LecturerDemoMarkingQuestion> questions;
  final Map<String, int?> marks;
  LecturerDemoScriptStatus status;
  String summary;

  int get theoryScore => questions.fold<int>(
    0,
    (total, question) => total + (marks[question.id] ?? 0),
  );

  int get theoryMax => questions.fold<int>(
    0,
    (total, question) => total + question.maxMark,
  );

  int get examScore => objectiveScore + theoryScore;
  int get examMax => 40 + theoryMax;

  bool get markingComplete =>
      questions.every((question) => marks[question.id] != null);

  String get grade {
    final score = examMax == 0 ? 0 : (examScore * 100 / examMax);
    if (score >= 70) return 'A';
    if (score >= 60) return 'B';
    if (score >= 50) return 'C';
    if (score >= 45) return 'D';
    if (score >= 40) return 'E';
    return 'F';
  }
}

class LecturerDemoState extends ChangeNotifier {
  LecturerDemoState._();

  static final LecturerDemoState instance = LecturerDemoState._();

  LecturerDemoQuestionSubmission? _latestQuestionSubmission;
  bool _questionEditorLocked = false;

  LecturerDemoQuestionSubmission? get latestQuestionSubmission =>
      _latestQuestionSubmission;
  bool get questionEditorLocked => _questionEditorLocked;

  final List<LecturerDemoExamScript> _scripts = [
    LecturerDemoExamScript(
      id: 'CSC305-044',
      courseCode: 'CSC 305',
      examTitle: 'Data Structures CBT + Theory',
      candidateNo: 'ABU/CSC305/044',
      student: 'Maryam Bello',
      objectiveScore: 32,
      status: LecturerDemoScriptStatus.marked,
      summary: 'Marked and ready for result submission.',
      marks: {'q1': 18, 'q2': 16, 'q3': 7},
      questions: const [
        LecturerDemoMarkingQuestion(
          id: 'q1',
          question:
              'Explain the difference between stack and queue data structures with suitable use cases.',
          candidateAnswer:
              'A stack follows last-in-first-out while a queue follows first-in-first-out. Stacks are used in recursion, undo operations and browser history. Queues are used in scheduling, printer jobs and breadth-first search.',
          markingGuide:
              'Award marks for LIFO stack, FIFO queue, at least one correct stack use case and at least one correct queue use case.',
          maxMark: 20,
        ),
        LecturerDemoMarkingQuestion(
          id: 'q2',
          question:
              'Describe how a binary search tree handles insertion and search operations.',
          candidateAnswer:
              'Insertion compares the value with the root and moves left or right until an empty position is found. Search follows the same comparison path. A balanced tree is efficient, while an unbalanced tree can degrade to linear search time.',
          markingGuide:
              'Award marks for comparison-based traversal, correct insertion point, search path, balanced-tree efficiency and worst-case linear degradation.',
          maxMark: 20,
        ),
        LecturerDemoMarkingQuestion(
          id: 'q3',
          question:
              'Give one practical application of graph traversal in computer science.',
          candidateAnswer:
              'Graph traversal is used for route discovery and social network analysis.',
          markingGuide:
              'Award marks for one valid graph traversal application and a correct explanation of how traversal is used.',
          maxMark: 20,
        ),
      ],
    ),
    LecturerDemoExamScript(
      id: 'CSC305-071',
      courseCode: 'CSC 305',
      examTitle: 'Data Structures CBT + Theory',
      candidateNo: 'ABU/CSC305/071',
      student: 'Tunde Okafor',
      objectiveScore: 28,
      status: LecturerDemoScriptStatus.pendingMarking,
      questions: const [
        LecturerDemoMarkingQuestion(
          id: 'q1',
          question:
              'Explain the difference between stack and queue data structures with suitable use cases.',
          candidateAnswer:
              'Stack uses LIFO. Queue uses FIFO. Stack can be used for undo and queue can be used for scheduling.',
          markingGuide:
              'Award marks for LIFO stack, FIFO queue, at least one correct stack use case and at least one correct queue use case.',
          maxMark: 20,
        ),
        LecturerDemoMarkingQuestion(
          id: 'q2',
          question:
              'Describe how a binary search tree handles insertion and search operations.',
          candidateAnswer:
              'Values smaller than a node move left and larger values move right. Insertion stops at an empty child and searching stops when the value is found or there is no child to continue.',
          markingGuide:
              'Award marks for comparison-based traversal, correct insertion point, search path, balanced-tree efficiency and worst-case linear degradation.',
          maxMark: 20,
        ),
        LecturerDemoMarkingQuestion(
          id: 'q3',
          question:
              'Give one practical application of graph traversal in computer science.',
          candidateAnswer:
              'Breadth-first search can find shortest paths in an unweighted network.',
          markingGuide:
              'Award marks for one valid graph traversal application and a correct explanation of how traversal is used.',
          maxMark: 20,
        ),
      ],
    ),
    LecturerDemoExamScript(
      id: 'CSC309-118',
      courseCode: 'CSC 309',
      examTitle: 'Artificial Intelligence Practical',
      candidateNo: 'ABU/CSC309/118',
      student: 'Fatima Sani',
      objectiveScore: 24,
      status: LecturerDemoScriptStatus.integrityReview,
      marks: {'q1': 12, 'q2': 10, 'q3': 8},
      questions: const [
        LecturerDemoMarkingQuestion(
          id: 'q1',
          question: 'Explain breadth-first and depth-first search.',
          candidateAnswer:
              'Breadth-first search explores level by level with a queue, while depth-first search follows a branch using recursion or a stack.',
          markingGuide:
              'Award marks for correct BFS order and queue, correct DFS depth-first behaviour and stack or recursion.',
          maxMark: 20,
        ),
        LecturerDemoMarkingQuestion(
          id: 'q2',
          question: 'Explain one heuristic search strategy.',
          candidateAnswer:
              'A-star combines path cost with a heuristic estimate to choose the next state.',
          markingGuide:
              'Award marks for a valid heuristic search method, its evaluation rule and how it guides state expansion.',
          maxMark: 20,
        ),
        LecturerDemoMarkingQuestion(
          id: 'q3',
          question:
              'State one practical application of artificial intelligence search.',
          candidateAnswer:
              'Search can be used for route planning and game decision making.',
          markingGuide:
              'Award marks for one valid AI search application with a correct explanation.',
          maxMark: 20,
        ),
      ],
    ),
  ];

  List<LecturerDemoExamScript> get scripts => List.unmodifiable(_scripts);

  void recordQuestionSubmission({
    required int paperId,
    required String courseCode,
    required String courseTitle,
    required String title,
    required int questionCount,
    required int totalMarks,
  }) {
    _latestQuestionSubmission = LecturerDemoQuestionSubmission(
      paperId: paperId,
      courseCode: courseCode,
      courseTitle: courseTitle,
      title: title,
      questionCount: questionCount,
      totalMarks: totalMarks,
      status: 'Submitted to Exam Officer',
    );
    _questionEditorLocked = true;
    notifyListeners();
  }

  void startNewQuestionPaper() {
    _questionEditorLocked = false;
    notifyListeners();
  }

  void updateQuestionMark(String scriptId, String questionId, int? mark) {
    final script = _script(scriptId);
    final question =
        script.questions.firstWhere((item) => item.id == questionId);
    script.marks[questionId] = mark?.clamp(0, question.maxMark).toInt();
    if (script.status == LecturerDemoScriptStatus.marked ||
        script.status == LecturerDemoScriptStatus.submittedToExamOfficer) {
      script.status = LecturerDemoScriptStatus.pendingMarking;
    }
    notifyListeners();
  }

  void updateSummary(String scriptId, String summary) {
    _script(scriptId).summary = summary;
    notifyListeners();
  }

  void completeMarking(String scriptId) {
    final script = _script(scriptId);
    if (!script.markingComplete) return;
    script.status = LecturerDemoScriptStatus.marked;
    notifyListeners();
  }

  void submitScriptToExamOfficer(String scriptId) {
    final script = _script(scriptId);
    if (script.status != LecturerDemoScriptStatus.marked) return;
    script.status = LecturerDemoScriptStatus.submittedToExamOfficer;
    notifyListeners();
  }

  void submitReadyBatch({String? courseCode}) {
    for (final script in _scripts) {
      if (courseCode != null &&
          courseCode != 'All' &&
          script.courseCode != courseCode) {
        continue;
      }
      if (script.status == LecturerDemoScriptStatus.marked) {
        script.status = LecturerDemoScriptStatus.submittedToExamOfficer;
      }
    }
    notifyListeners();
  }

  LecturerDemoExamScript _script(String id) =>
      _scripts.firstWhere((script) => script.id == id);
}
