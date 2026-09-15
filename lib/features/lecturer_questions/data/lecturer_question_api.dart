export 'lecturer_question_api_legacy.dart' hide LecturerQuestionApi;

import '../../../core/auth/auth_session.dart';
import '../../lecturer_workflow/data/lecturer_course_collaboration_state.dart';
import '../../lecturer_workflow/data/lecturer_demo_state.dart';
import 'lecturer_question_api_legacy.dart' as legacy;

class LecturerQuestionApi extends legacy.LecturerQuestionApi {
  LecturerQuestionApi();

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
    final item = await super.submitQuestionPaper(
      courseId: courseId,
      lecturerId: lecturerId,
      examOfficerId: examOfficerId,
      title: title,
      description: description,
      instructions: instructions,
      durationMinutes: durationMinutes,
      questionPayload: questionPayload,
    );

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
