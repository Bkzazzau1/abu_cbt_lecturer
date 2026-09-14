class LecturerAssessment {
  const LecturerAssessment({
    required this.id,
    required this.title,
    required this.assessmentType,
    required this.status,
    required this.totalMarks,
    required this.durationMinutes,
    required this.proctoringLevel,
    required this.questionCount,
    this.courseCode,
  });

  final String id;
  final String title;
  final String assessmentType;
  final String status;
  final double totalMarks;
  final int durationMinutes;
  final String proctoringLevel;
  final int questionCount;
  final String? courseCode;

  factory LecturerAssessment.fromJson(Map<String, dynamic> json) {
    final course = json['course'];
    final questions = json['questions'];
    return LecturerAssessment(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled assessment',
      assessmentType: json['assessment_type']?.toString() ?? 'assessment',
      status: json['status']?.toString() ?? 'draft',
      totalMarks: double.tryParse(json['total_marks']?.toString() ?? '0') ?? 0,
      durationMinutes: int.tryParse(json['duration_minutes']?.toString() ?? '0') ?? 0,
      proctoringLevel: json['proctoring_level']?.toString() ?? 'none',
      questionCount: questions is List ? questions.length : 0,
      courseCode: course is Map ? course['code']?.toString() : null,
    );
  }

  String get displayType => assessmentType
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
