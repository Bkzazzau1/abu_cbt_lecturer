import 'package:flutter/foundation.dart';

class LecturerCourseCollaborator {
  const LecturerCourseCollaborator({
    required this.name,
    this.role = 'Course Lecturer',
  });

  final String name;
  final String role;
}

class LecturerCourseSuggestion {
  LecturerCourseSuggestion({
    required this.id,
    required this.author,
    required this.message,
    required this.createdAt,
    this.resolved = false,
    this.resolvedBy = '',
  });

  final String id;
  final String author;
  final String message;
  final DateTime createdAt;
  bool resolved;
  String resolvedBy;
}

class LecturerCourseActivity {
  const LecturerCourseActivity({
    required this.actor,
    required this.action,
    required this.at,
  });

  final String actor;
  final String action;
  final DateTime at;
}

class LecturerCourseWorkItem {
  LecturerCourseWorkItem({
    required this.id,
    required this.courseCode,
    required this.category,
    required this.title,
    required this.details,
    required this.status,
    required this.createdBy,
    required this.lastEditedBy,
    this.locked = false,
    List<LecturerCourseSuggestion>? suggestions,
    List<LecturerCourseActivity>? activity,
  })  : suggestions = suggestions ?? <LecturerCourseSuggestion>[],
        activity = activity ?? <LecturerCourseActivity>[];

  final String id;
  final String courseCode;
  final String category;
  String title;
  String details;
  String status;
  final String createdBy;
  String lastEditedBy;
  bool locked;
  final List<LecturerCourseSuggestion> suggestions;
  final List<LecturerCourseActivity> activity;

  int get openSuggestionCount =>
      suggestions.where((suggestion) => !suggestion.resolved).length;
}

class LecturerCourseCollaborationState extends ChangeNotifier {
  LecturerCourseCollaborationState._();

  static final LecturerCourseCollaborationState instance =
      LecturerCourseCollaborationState._();

  final Map<String, List<LecturerCourseCollaborator>> _collaborators = {
    'CSC201': const [
      LecturerCourseCollaborator(name: 'Dr. Amina Bello'),
      LecturerCourseCollaborator(name: 'Dr. Yusuf Abdullahi'),
    ],
    'CSC305': const [
      LecturerCourseCollaborator(name: 'Dr. Amina Bello'),
      LecturerCourseCollaborator(name: 'Dr. Grace Adamu'),
    ],
    'CSC411': const [
      LecturerCourseCollaborator(name: 'Dr. Amina Bello'),
      LecturerCourseCollaborator(name: 'Dr. Sani Bello'),
    ],
  };

  final List<LecturerCourseWorkItem> _work = [
    LecturerCourseWorkItem(
      id: 'CSC305-exam-draft',
      courseCode: 'CSC 305',
      category: 'Exam Questions',
      title: 'Semester Examination Question Paper',
      details:
          'Shared draft for the course examination paper. Both assigned lecturers can review and improve the draft before final submission.',
      status: 'Draft',
      createdBy: 'Dr. Amina Bello',
      lastEditedBy: 'Dr. Grace Adamu',
      suggestions: [
        LecturerCourseSuggestion(
          id: 'suggestion-seed-1',
          author: 'Dr. Grace Adamu',
          message: 'Add one more applied question to balance the theory section.',
          createdAt: DateTime(2026, 9, 15, 10, 20),
        ),
      ],
      activity: [
        LecturerCourseActivity(
          actor: 'Dr. Amina Bello',
          action: 'Created the shared exam draft',
          at: DateTime(2026, 9, 15, 9, 0),
        ),
        LecturerCourseActivity(
          actor: 'Dr. Grace Adamu',
          action: 'Reviewed the shared exam draft',
          at: DateTime(2026, 9, 15, 10, 20),
        ),
      ],
    ),
    LecturerCourseWorkItem(
      id: 'CSC305-ca1-draft',
      courseCode: 'CSC 305',
      category: 'CA Questions',
      title: 'CA 1 CBT',
      details:
          'Shared CA 1 question draft. The teaching team can edit questions, marks, duration and review notes before scheduling.',
      status: 'Draft',
      createdBy: 'Dr. Grace Adamu',
      lastEditedBy: 'Dr. Grace Adamu',
    ),
    LecturerCourseWorkItem(
      id: 'CSC305-gradebook',
      courseCode: 'CSC 305',
      category: 'Gradebook',
      title: 'Students & Scores',
      details:
          'Shared course gradebook for CA 1, CA 2, exam scores, totals and final result review.',
      status: 'Open',
      createdBy: 'Dr. Amina Bello',
      lastEditedBy: 'Dr. Amina Bello',
    ),
    LecturerCourseWorkItem(
      id: 'CSC201-gradebook',
      courseCode: 'CSC 201',
      category: 'Gradebook',
      title: 'Students & Scores',
      details:
          'Shared course gradebook for CA 1, CA 2, exam scores, totals and final result review.',
      status: 'Open',
      createdBy: 'Dr. Amina Bello',
      lastEditedBy: 'Dr. Yusuf Abdullahi',
    ),
    LecturerCourseWorkItem(
      id: 'CSC411-gradebook',
      courseCode: 'CSC 411',
      category: 'Gradebook',
      title: 'Students & Scores',
      details:
          'Shared course gradebook for CA 1, CA 2, exam scores, totals and final result review.',
      status: 'Open',
      createdBy: 'Dr. Amina Bello',
      lastEditedBy: 'Dr. Sani Bello',
    ),
  ];

  List<LecturerCourseCollaborator> collaboratorsFor(String courseCode) =>
      List.unmodifiable(_collaborators[_normalize(courseCode)] ?? const []);

  List<LecturerCourseWorkItem> workFor(String courseCode) => List.unmodifiable(
        _work.where((item) => _normalize(item.courseCode) == _normalize(courseCode)),
      );

  LecturerCourseWorkItem workItem(String id) =>
      _work.firstWhere((item) => item.id == id);

  bool canEdit(String id) => !workItem(id).locked;

  void editWork({
    required String id,
    required String actor,
    required String title,
    required String details,
  }) {
    final item = workItem(id);
    if (item.locked) return;
    item.title = title.trim().isEmpty ? item.title : title.trim();
    item.details = details.trim().isEmpty ? item.details : details.trim();
    item.lastEditedBy = actor;
    item.activity.insert(
      0,
      LecturerCourseActivity(
        actor: actor,
        action: 'Edited shared ${item.category.toLowerCase()} work',
        at: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void addSuggestion({
    required String id,
    required String actor,
    required String message,
  }) {
    final clean = message.trim();
    if (clean.isEmpty) return;
    final item = workItem(id);
    item.suggestions.insert(
      0,
      LecturerCourseSuggestion(
        id: 'suggestion-${DateTime.now().microsecondsSinceEpoch}',
        author: actor,
        message: clean,
        createdAt: DateTime.now(),
      ),
    );
    item.activity.insert(
      0,
      LecturerCourseActivity(
        actor: actor,
        action: 'Added a suggestion',
        at: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void resolveSuggestion({
    required String workId,
    required String suggestionId,
    required String actor,
  }) {
    final item = workItem(workId);
    final suggestion = item.suggestions.firstWhere(
      (entry) => entry.id == suggestionId,
    );
    if (suggestion.resolved) return;
    suggestion.resolved = true;
    suggestion.resolvedBy = actor;
    item.activity.insert(
      0,
      LecturerCourseActivity(
        actor: actor,
        action: 'Resolved a suggestion from ${suggestion.author}',
        at: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void registerCaWork({
    required String courseCode,
    required String title,
    required String caLabel,
    required int questionCount,
    required int totalMarks,
    required String actor,
    required String status,
    required bool locked,
  }) {
    final id = '${_normalize(courseCode)}-${caLabel.replaceAll(' ', '').toLowerCase()}';
    final details =
        '$questionCount questions • $totalMarks marks • $caLabel • shared by the course teaching team';
    _upsertWork(
      id: id,
      courseCode: courseCode,
      category: 'CA Questions',
      title: title,
      details: details,
      actor: actor,
      status: status,
      locked: locked,
    );
  }

  void registerExamSubmission({
    required String courseCode,
    required String title,
    required int questionCount,
    required int totalMarks,
    required String actor,
  }) {
    _upsertWork(
      id: '${_normalize(courseCode)}-exam-submitted',
      courseCode: courseCode,
      category: 'Exam Questions',
      title: title,
      details: '$questionCount questions • $totalMarks marks',
      actor: actor,
      status: 'Submitted to Exam Officer',
      locked: true,
    );
  }

  void recordGradebookChange({
    required String courseCode,
    required String actor,
    required String action,
  }) {
    final id = '${_normalize(courseCode)}-gradebook';
    LecturerCourseWorkItem? item;
    for (final work in _work) {
      if (work.id == id) {
        item = work;
        break;
      }
    }
    item ??= LecturerCourseWorkItem(
      id: id,
      courseCode: courseCode,
      category: 'Gradebook',
      title: 'Students & Scores',
      details:
          'Shared course gradebook for CA 1, CA 2, exam scores, totals and final result review.',
      status: 'Open',
      createdBy: actor,
      lastEditedBy: actor,
    );
    if (!_work.contains(item)) _work.add(item);
    if (!item.locked) item.lastEditedBy = actor;
    item.activity.insert(
      0,
      LecturerCourseActivity(actor: actor, action: action, at: DateTime.now()),
    );
    notifyListeners();
  }

  void lockGradebook({
    required String courseCode,
    required String actor,
  }) {
    final id = '${_normalize(courseCode)}-gradebook';
    final item = _work.firstWhere((entry) => entry.id == id);
    item.locked = true;
    item.status = 'Submitted to Exam Officer';
    item.lastEditedBy = actor;
    item.activity.insert(
      0,
      LecturerCourseActivity(
        actor: actor,
        action: 'Submitted and locked the final gradebook',
        at: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void _upsertWork({
    required String id,
    required String courseCode,
    required String category,
    required String title,
    required String details,
    required String actor,
    required String status,
    required bool locked,
  }) {
    LecturerCourseWorkItem? existing;
    for (final item in _work) {
      if (item.id == id) {
        existing = item;
        break;
      }
    }
    if (existing == null) {
      existing = LecturerCourseWorkItem(
        id: id,
        courseCode: courseCode,
        category: category,
        title: title,
        details: details,
        status: status,
        createdBy: actor,
        lastEditedBy: actor,
        locked: locked,
      );
      _work.add(existing);
    } else {
      existing.title = title;
      existing.details = details;
      existing.status = status;
      existing.lastEditedBy = actor;
      existing.locked = locked;
    }
    existing.activity.insert(
      0,
      LecturerCourseActivity(
        actor: actor,
        action: locked ? 'Finalised $category' : 'Updated shared $category',
        at: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  String _normalize(String code) =>
      code.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}
