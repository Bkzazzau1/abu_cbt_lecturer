import '../../../core/network/api_client.dart';
import '../models/lecturer_assessment.dart';

class LecturerAssessmentApi {
  LecturerAssessmentApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<LecturerAssessment>> fetchAssessments() async {
    final data = await _client.get('/api/lecturer/assessments');
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(LecturerAssessment.fromJson)
        .toList();
  }

  Future<LecturerAssessment> createAssessment({
    required String courseId,
    required String title,
    required String assessmentType,
    required int durationMinutes,
    String proctoringLevel = 'none',
    bool allowMobile = true,
  }) async {
    final data = await _client.post(
      '/api/lecturer/assessments',
      body: {
        'course_id': courseId,
        'title': title,
        'assessment_type': assessmentType,
        'duration_minutes': durationMinutes,
        'proctoring_level': proctoringLevel,
        'allow_mobile': allowMobile,
      },
    );
    return LecturerAssessment.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> publishAssessment(String assessmentId) async {
    await _client.post('/api/lecturer/assessments/$assessmentId/publish');
  }

  Future<void> closeAssessment(String assessmentId) async {
    await _client.post('/api/lecturer/assessments/$assessmentId/close');
  }

  void close() => _client.close();
}
