export 'lecturer_question_api_legacy.dart' hide LecturerQuestionApi;

import '../../../core/auth/auth_session.dart';
import '../../lecturer_workflow/data/lecturer_course_collaboration_state.dart';
import '../../lecturer_workflow/data/lecturer_course_materials_state.dart';
import '../../lecturer_workflow/data/lecturer_demo_state.dart';
import '../../lecturer_workflow/data/lecturer_gradebook_state.dart';
import 'lecturer_question_api_legacy.dart' as legacy;

class LecturerQuestionApi extends legacy.LecturerQuestionApi {
  LecturerQuestionApi();

  static final List<legacy.QuestionPaperItem> _connectedPapers = [];

  @override
  Future<List<legacy.QuestionCourseOption>> fetchCourses() async {
    final courses = LecturerGradebookState.instance.courses;
    return List.unmodifiable([
      for (var i = 0; i < courses.length; i++)
        legacy.QuestionCourseOption(
          id: i + 1,
          code: courses[i].code.replaceAll(' ', ''),
          title: courses[i].title,
        ),
    ]);
  }

  @override
  Future<List<legacy.QuestionPaperItem>> fetchQuestionPapers() async {
    final oldItems = await super.fetchQuestionPapers();
    return List.unmodifiable([..._connectedPapers, ...oldItems]);
  }

  @override
  Future<legacy.AiQuestionDraftResult> draftQuestions({
    required String topic,
    required String questionType,
    required int count,
    int marksPerQuestion = 1,
    String? courseLabel,
  }) {
    final materialContext =
        LecturerCourseMaterialsState.instance.aiContextForCourseLabel(courseLabel);
    final groundedTopic = materialContext.isEmpty
        ? topic
        : '$topic. Use these course sources as context:\n$materialContext';
    return super.draftQuestions(
      topic: groundedTopic,
      questionType: questionType,
      count: count,
      marksPerQuestion: marksPerQuestion,
      courseLabel: courseLabel,
    );
  }

  @override
  Future<legacy.QuestionPaperItem> submitQuestionPaper({
    required int courseId,
    required int lecturerId,
    required int examOfficerId,
    required String title,
    required String description,
    required String instructions,
    required int durationMinutes,
    required Map<String, dynamic> questionPayload,
  }) async {
    final courses = await fetchCourses();
    final matches = courses.where((item) => item.id == courseId).toList();
    final selected = matches.isEmpty ? null : matches.first;
    final item = legacy.QuestionPaperItem.fromJson({
      'id': DateTime.now().millisecondsSinceEpoch,
      'course_code': selected?.code ?? '',
      'course_title': selected?.title ?? '',
      'title': title,
      'status': 'officer_review',
      'duration_minutes': durationMinutes,
      'question_payload': questionPayload,
    });
    _connectedPapers.insert(0, item);

    LecturerDemoState.instance.recordQuestionSubmission(
      paperId: item.id,
      courseCode: item.courseCode,
      courseTitle: item.courseTitle,
      title: item.title,
      questionCount: item.questionCount,
      totalMarks: item.totalMarks,
    );

    LecturerCourseCollaborationState.instance.registerExamSubmission(
      courseCode: item.courseCode,
      title: item.title,
      questionCount: item.questionCount,
      totalMarks: item.totalMarks,
      actor: AuthSession.instance.session?.name ?? 'Course Lecturer',
    );

    return item;
  }
}
