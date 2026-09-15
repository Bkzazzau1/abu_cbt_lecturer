import '../../lecturer_workflow/data/cbt_calendar_state.dart';
import 'exam_officer_invigilation_state.dart';
import 'exam_officer_workflow_state.dart';

class ExamOfficerDemoSeed {
  ExamOfficerDemoSeed._();

  static bool _seeded = false;

  static void ensureSeeded() {
    if (_seeded) return;
    _seeded = true;

    final workflow = ExamOfficerWorkflowState.instance;

    _ensurePaper(
      workflow,
      paperId: 7101,
      courseCode: 'CSC 101',
      courseTitle: 'Introduction to Computer Science',
      title: 'CSC 101 First Semester Examination',
      lecturerName: 'Dr. Hauwa Musa',
      durationMinutes: 120,
      totalMarks: 100,
      questions: const [
        {
          'type': 'single_choice',
          'prompt': 'Which component performs arithmetic and logical operations in a computer?',
          'marks': 10,
        },
        {
          'type': 'multiple_choice',
          'prompt': 'Select the examples of system software.',
          'marks': 20,
        },
        {
          'type': 'essay',
          'prompt': 'Explain the major functional units of a computer system.',
          'marks': 70,
        },
      ],
    );

    _ensurePaper(
      workflow,
      paperId: 7102,
      courseCode: 'CSC 103',
      courseTitle: 'Programming Fundamentals',
      title: 'CSC 103 First Semester Examination',
      lecturerName: 'Dr. Yusuf Abdullahi',
      durationMinutes: 120,
      totalMarks: 100,
      questions: const [
        {
          'type': 'single_choice',
          'prompt': 'Which control structure is used to repeat a block of statements?',
          'marks': 10,
        },
        {
          'type': 'fill_blank',
          'prompt': 'A reusable named block of code is called a _____.',
          'marks': 10,
        },
        {
          'type': 'essay',
          'prompt': 'Write an algorithm that accepts ten scores and prints their average.',
          'marks': 80,
        },
      ],
    );
    _advanceToWithModerator(workflow, 'paper-7102', 'Review coverage, clarity and mark allocation.');

    _ensurePaper(
      workflow,
      paperId: 7103,
      courseCode: 'CSC 201',
      courseTitle: 'Data Structures',
      title: 'CSC 201 First Semester Examination',
      lecturerName: 'Dr. Amina Bello',
      durationMinutes: 120,
      totalMarks: 100,
      questions: const [
        {
          'type': 'single_choice',
          'prompt': 'Which data structure follows LIFO ordering?',
          'marks': 10,
        },
        {
          'type': 'drag_drop',
          'prompt': 'Match Stack, Queue and Tree to their appropriate operations.',
          'marks': 20,
        },
        {
          'type': 'essay',
          'prompt': 'Compare linked lists and arrays and discuss when each should be used.',
          'marks': 70,
        },
      ],
    );
    _advanceToModerated(
      workflow,
      'paper-7103',
      'Moderation completed. Questions are balanced and suitable for the course outcomes.',
    );

    _ensurePaper(
      workflow,
      paperId: 7104,
      courseCode: 'CSC 203',
      courseTitle: 'Object-Oriented Programming',
      title: 'CSC 203 First Semester Examination',
      lecturerName: 'Dr. Salisu Garba',
      durationMinutes: 120,
      totalMarks: 100,
      questions: const [
        {
          'type': 'essay',
          'prompt': 'Explain encapsulation, inheritance and polymorphism with examples.',
          'marks': 60,
        },
        {
          'type': 'file_upload',
          'prompt': 'Submit a small class hierarchy implementation and explanation.',
          'marks': 40,
        },
      ],
    );
    final csc203 = _paper(workflow, 7104);
    if (csc203 != null &&
        csc203.status == ExamOfficerQuestionStatus.received) {
      workflow.returnQuestionToLecturer(
        csc203.id,
        'Please rebalance the paper and add an objective section before moderation.',
      );
    }

    _ensurePaper(
      workflow,
      paperId: 7105,
      courseCode: 'CSC 411',
      courseTitle: 'Artificial Intelligence',
      title: 'CSC 411 Second Semester Examination',
      lecturerName: 'Dr. Sani Bello',
      durationMinutes: 120,
      totalMarks: 100,
      questions: const [
        {
          'type': 'multiple_choice',
          'prompt': 'Select the uninformed search strategies.',
          'marks': 15,
        },
        {
          'type': 'image_question',
          'prompt': 'Study the search tree and identify the traversal order shown.',
          'marks': 20,
        },
        {
          'type': 'essay',
          'prompt': 'Compare heuristic search and uninformed search using a practical problem.',
          'marks': 65,
        },
      ],
    );
    _advanceToModerated(
      workflow,
      'paper-7105',
      'Moderation completed. Paper may proceed to scheduling when a suitable slot is selected.',
    );

    // The original seeded CSC 305 paper becomes a complete published-timetable sample.
    _advanceToModerated(
      workflow,
      'paper-7001',
      'Moderation completed. Database Systems paper approved without correction.',
    );
    _markReadyIfNeeded(workflow, 'paper-7001');
    _scheduleIfPossible(
      workflow,
      paperId: 'paper-7001',
      date: DateTime(2026, 9, 24),
      startTime: '09:00',
      venue: 'CBT Centre A',
    );

    _ensurePaper(
      workflow,
      paperId: 7106,
      courseCode: 'MTH 101',
      courseTitle: 'Elementary Mathematics',
      title: 'MTH 101 First Semester Examination',
      lecturerName: 'Dr. Zainab Ibrahim',
      durationMinutes: 120,
      totalMarks: 100,
      questions: const [
        {
          'type': 'single_choice',
          'prompt': 'Evaluate the given algebraic expression.',
          'marks': 20,
        },
        {
          'type': 'fill_blank',
          'prompt': 'The derivative of x squared is _____.',
          'marks': 20,
        },
        {
          'type': 'essay',
          'prompt': 'Solve the simultaneous equations and show all working.',
          'marks': 60,
        },
      ],
    );
    _advanceToModerated(
      workflow,
      'paper-7106',
      'Moderation completed. Mathematics paper approved for timetable placement.',
    );
    _markReadyIfNeeded(workflow, 'paper-7106');
    _scheduleIfPossible(
      workflow,
      paperId: 'paper-7106',
      date: DateTime(2026, 9, 24),
      startTime: '13:00',
      venue: 'CBT Centre B',
    );

    _ensurePaper(
      workflow,
      paperId: 7107,
      courseCode: 'CSC 413',
      courseTitle: 'Software Engineering',
      title: 'CSC 413 Second Semester Examination',
      lecturerName: 'Dr. Fatima Abdullahi',
      durationMinutes: 120,
      totalMarks: 100,
      questions: const [
        {
          'type': 'single_choice',
          'prompt': 'Which SDLC model is explicitly iterative?',
          'marks': 10,
        },
        {
          'type': 'essay',
          'prompt': 'Discuss requirements engineering and change management in a large software project.',
          'marks': 90,
        },
      ],
    );
    _advanceToModerated(
      workflow,
      'paper-7107',
      'Moderation completed and mark distribution confirmed.',
    );
    _markReadyIfNeeded(workflow, 'paper-7107');

    _seedInvigilation();
  }

  static void _ensurePaper(
    ExamOfficerWorkflowState workflow, {
    required int paperId,
    required String courseCode,
    required String courseTitle,
    required String title,
    required String lecturerName,
    required int durationMinutes,
    required int totalMarks,
    required List<Map<String, dynamic>> questions,
  }) {
    if (_paper(workflow, paperId) != null) return;
    workflow.registerQuestionSubmission(
      paperId: paperId,
      courseCode: courseCode,
      courseTitle: courseTitle,
      title: title,
      lecturerName: lecturerName,
      questionCount: questions.length,
      totalMarks: totalMarks,
      durationMinutes: durationMinutes,
      questionPayload: {'questions': questions},
    );
  }

  static ExamOfficerQuestionPaper? _paper(
    ExamOfficerWorkflowState workflow,
    int paperId,
  ) {
    for (final paper in workflow.questionPapers) {
      if (paper.paperId == paperId) return paper;
    }
    return null;
  }

  static void _advanceToWithModerator(
    ExamOfficerWorkflowState workflow,
    String paperId,
    String note,
  ) {
    final paper = workflow.questionPapers.where((item) => item.id == paperId);
    if (paper.isEmpty) return;
    if (paper.first.status == ExamOfficerQuestionStatus.received) {
      workflow.sendQuestionToModerator(paperId, note);
    }
  }

  static void _advanceToModerated(
    ExamOfficerWorkflowState workflow,
    String paperId,
    String note,
  ) {
    final paper = workflow.questionPapers.where((item) => item.id == paperId);
    if (paper.isEmpty) return;
    if (paper.first.status == ExamOfficerQuestionStatus.received) {
      workflow.sendQuestionToModerator(
        paperId,
        'Please moderate the paper and confirm assessment quality.',
      );
    }
    final refreshed = workflow.questionPapers.firstWhere((item) => item.id == paperId);
    if (refreshed.status == ExamOfficerQuestionStatus.withModerator) {
      workflow.recordModeratorReturn(paperId, note);
    }
  }

  static void _markReadyIfNeeded(
    ExamOfficerWorkflowState workflow,
    String paperId,
  ) {
    final matches = workflow.questionPapers.where((item) => item.id == paperId);
    if (matches.isEmpty) return;
    if (matches.first.status == ExamOfficerQuestionStatus.moderated) {
      workflow.markQuestionReady(
        paperId,
        'Moderation complete. Paper released for timetable scheduling.',
      );
    }
  }

  static void _scheduleIfPossible(
    ExamOfficerWorkflowState workflow, {
    required String paperId,
    required DateTime date,
    required String startTime,
    required String venue,
  }) {
    final paperMatches = workflow.questionPapers.where((item) => item.id == paperId);
    if (paperMatches.isEmpty) return;
    if (workflow.schedulesForPaper(paperMatches.first.paperId).isNotEmpty) return;

    final calendar = CbtCalendarState.instance;
    final slots = calendar.slots.where(
      (slot) =>
          slot.date.year == date.year &&
          slot.date.month == date.month &&
          slot.date.day == date.day &&
          slot.startTime == startTime &&
          slot.venue == venue &&
          slot.isAvailable,
    );
    if (slots.isEmpty) return;

    try {
      workflow.scheduleExamSitting(paperId: paperId, slotId: slots.first.id);
    } catch (_) {
      // Demo seeding must never block the real workflow if a tester changed a slot.
    }
  }

  static void _seedInvigilation() {
    final state = ExamOfficerInvigilationState.instance;
    if (state.assignments.isNotEmpty) return;

    String? idFor(String name) {
      for (final staff in state.staff) {
        if (staff.name == name) return staff.id;
      }
      return null;
    }

    void post(String courseCode, String role, List<String> names) {
      final ids = <String>{};
      for (final name in names) {
        final id = idFor(name);
        if (id != null) ids.add(id);
      }
      if (ids.isEmpty) return;
      try {
        state.assignMany(
          staffIds: ids,
          courseCodes: {courseCode},
          dutyRole: role,
        );
      } catch (_) {
        // Ignore a demo posting if the tester has already created a conflicting duty.
      }
    }

    post('CSC 305', 'Chief Invigilator', ['Dr. Hauwa Musa']);
    post('CSC 305', 'Invigilator', ['Dr. Grace Adamu', 'Dr. Maryam Lawal']);
    post('MTH 101', 'Chief Invigilator', ['Dr. Yusuf Abdullahi']);
    post('MTH 101', 'Invigilator', ['Dr. Usman Kabir', 'Dr. Grace Adamu']);
  }
}
