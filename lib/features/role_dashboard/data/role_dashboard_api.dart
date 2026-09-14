import '../../../core/network/api_client.dart';

class RoleDashboardApi {
  RoleDashboardApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<RoleDashboardData> fetchForRole(String role) async {
    try {
      return await _fetchLiveForRole(role);
    } catch (_) {
      return _fallbackForRole(role);
    }
  }

  Future<RoleDashboardData> _fetchLiveForRole(String role) async {
    final normalized = role.toLowerCase().trim();
    if (normalized == 'exam_officer') {
      final results = await Future.wait<dynamic>([
        _client.get('/api/exam-officer/assessments'),
        _client.get('/api/exam-officer/ca-submissions'),
        _client.get('/api/exam-officer/marked-exam-scripts'),
      ]);
      return RoleDashboardData(
        title: 'Exam Officer live queue',
        sections: [
          RoleDashboardSection(
            kind: 'exam_assessment',
            title: 'Questions awaiting action',
            items: _items(results[0], 'title', 'status', 'assessment'),
          ),
          RoleDashboardSection(
            kind: 'ca_review',
            title: 'CA submissions',
            items: _items(results[1], 'summary', 'status', 'ca_submission'),
          ),
          RoleDashboardSection(
            kind: 'script_review',
            title: 'Marked scripts',
            items: _items(results[2], 'summary', 'status', 'marked_script'),
          ),
        ],
      );
    }
    if (normalized == 'moderator') {
      final data = await _client.get('/api/moderator/assessments');
      return RoleDashboardData(
        title: 'Moderator live queue',
        sections: [
          RoleDashboardSection(
            kind: 'moderator_assessment',
            title: 'Questions to review',
            items: _items(data, 'title', 'moderation_status', 'assessment'),
          ),
        ],
      );
    }
    if (normalized == 'hod' ||
        normalized == 'dlc_director' ||
        normalized == 'admin' ||
        normalized == 'system_admin' ||
        normalized == 'super_admin') {
      final results = await Future.wait<dynamic>([
        _client.get('/api/admin/staff'),
        _client.get('/api/lecturer/analytics/overview'),
        _client.get('/api/notifications'),
      ]);
      return RoleDashboardData(
        title: normalized == 'hod'
            ? 'HoD live command view'
            : 'DLC Director live command view',
        sections: [
          RoleDashboardSection(
            kind: 'staff',
            title: 'Staff records',
            items: _items(results[0], 'first_name', 'primary_role', 'staff'),
          ),
          RoleDashboardSection(
            kind: 'analytics',
            title: 'Lecturer analytics',
            items: [_analyticsItem(results[1])],
          ),
          RoleDashboardSection(
            kind: 'notifications',
            title: 'Recent alerts',
            items: _items(results[2], 'title', 'category', 'notification'),
          ),
        ],
      );
    }

    final results = await Future.wait<dynamic>([
      _client.get('/api/lecturer/analytics/overview'),
      _client.get('/api/lecturer/assignments'),
      _client.get('/api/lecturer/ca-submissions'),
      _client.get('/api/lecturer/marked-exam-scripts'),
    ]);
    return RoleDashboardData(
      title: 'Lecturer live workspace',
      sections: [
        RoleDashboardSection(
          kind: 'analytics',
          title: 'My analytics',
          items: [_analyticsItem(results[0])],
        ),
        RoleDashboardSection(
          kind: 'assignment',
          title: 'Assignments',
          items: _items(results[1], 'title', 'status', 'assignment'),
        ),
        RoleDashboardSection(
          kind: 'ca_submission',
          title: 'CA submissions',
          items: _items(results[2], 'summary', 'status', 'ca_submission'),
        ),
        RoleDashboardSection(
          kind: 'marked_script',
          title: 'Marked scripts',
          items: _items(results[3], 'summary', 'status', 'marked_script'),
        ),
      ],
    );
  }

  RoleDashboardData _fallbackForRole(String role) {
    final normalized = role.toLowerCase().trim();

    if (normalized == 'system_admin' ||
        normalized == 'super_admin' ||
        normalized == 'admin' ||
        normalized == 'dlc_director' ||
        normalized == 'hod') {
      return const RoleDashboardData(
        title: 'System Admin workspace',
        sections: [
          RoleDashboardSection(
            kind: 'staff',
            title: 'Staff and access',
            items: [
              RoleDashboardItem(
                id: 'staff-1',
                resourceType: 'staff',
                title: 'Manage staff accounts',
                subtitle:
                    'Create lecturers, exam officers, HoDs, invigilators, records staff, and DLC users',
                status: 'ready',
              ),
              RoleDashboardItem(
                id: 'role-1',
                resourceType: 'permission',
                title: 'Role permissions',
                subtitle:
                    'Control who can approve exams, review results, and view reports',
                status: 'ready',
              ),
            ],
          ),
          RoleDashboardSection(
            kind: 'analytics',
            title: 'Lecturer analytics',
            items: [
              RoleDashboardItem(
                id: 'analytics-1',
                resourceType: 'analytics',
                title: 'Lecturer performance overview',
                subtitle:
                    'Courses, teaching hours, uploads, marking progress, and student engagement',
                status: 'demo',
              ),
              RoleDashboardItem(
                id: 'analytics-2',
                resourceType: 'analytics',
                title: 'DLC command view',
                subtitle:
                    'Departments, programmes, courses, assessments, and live work alerts',
                status: 'demo',
              ),
            ],
          ),
        ],
      );
    }

    if (normalized == 'exam_officer') {
      return const RoleDashboardData(
        title: 'Exam Officer workspace',
        sections: [
          RoleDashboardSection(
            kind: 'exam',
            title: 'Exam readiness',
            items: [
              RoleDashboardItem(
                id: 'exam-1',
                resourceType: 'exam',
                title: 'Question submissions',
                subtitle:
                    'Track lecturer submission, moderation, HoD approval, and exam packaging',
                status: 'demo',
              ),
              RoleDashboardItem(
                id: 'exam-2',
                resourceType: 'exam',
                title: 'Student eligibility',
                subtitle:
                    'Check registration, payment status, attendance, and exam clearance',
                status: 'demo',
              ),
            ],
          ),
        ],
      );
    }

    return const RoleDashboardData(
      title: 'Staff workspace',
      sections: [
        RoleDashboardSection(
          kind: 'work',
          title: 'My work',
          items: [
            RoleDashboardItem(
              id: 'work-1',
              resourceType: 'task',
              title: 'Pending activities',
              subtitle:
                  'Your live work queue will appear here as backend modules are enabled',
              status: 'demo',
            ),
            RoleDashboardItem(
              id: 'work-2',
              resourceType: 'task',
              title: 'Notifications',
              subtitle:
                  'Important alerts, approvals, and updates will appear here',
              status: 'demo',
            ),
          ],
        ),
      ],
    );
  }

  Future<List<ReferenceOption>> fetchCourses() async {
    final data = await _client.get('/api/lecturer/courses');
    return _referenceOptions(data, fallbackTitle: 'Course');
  }

  Future<List<ReferenceOption>> fetchAssessments() async {
    final data = await _client.get('/api/lecturer/assessments');
    return _referenceOptions(data, fallbackTitle: 'Assessment');
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
    if (data is Map) return data['file_url']?.toString() ?? '';
    return '';
  }

  Future<void> examOfficerAssessmentAction(
    String id,
    String action,
    String feedback,
  ) async {
    await _client.post(
      '/api/exam-officer/assessments/$id/$action',
      body: {'feedback': feedback},
    );
  }

  Future<void> moderatorAssessmentAction(
    String id,
    String action,
    String feedback,
  ) async {
    await _client.post(
      '/api/moderator/assessments/$id/$action',
      body: {'feedback': feedback},
    );
  }

  Future<void> reviewCA(String id, String status, String feedback) async {
    await _client.patch(
      '/api/exam-officer/ca-submissions/$id/review',
      body: {'status': status, 'feedback': feedback},
    );
  }

  Future<void> reviewMarkedScript(
    String id,
    String status,
    String feedback,
  ) async {
    await _client.patch(
      '/api/exam-officer/marked-exam-scripts/$id/review',
      body: {'status': status, 'feedback': feedback},
    );
  }

  Future<void> createAssignment(Map<String, dynamic> payload) async {
    await _client.post('/api/lecturer/assignments', body: payload);
  }

  Future<void> submitCA(Map<String, dynamic> payload) async {
    await _client.post('/api/lecturer/ca-submissions', body: payload);
  }

  Future<void> submitMarkedScripts(Map<String, dynamic> payload) async {
    await _client.post('/api/lecturer/marked-exam-scripts', body: payload);
  }

  List<ReferenceOption> _referenceOptions(
    dynamic data, {
    required String fallbackTitle,
  }) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((raw) {
          final json = raw.map((key, value) => MapEntry(key.toString(), value));
          final course = json['course'];
          final nestedCourse = course is Map
              ? course.map((key, value) => MapEntry(key.toString(), value))
              : null;
          final id =
              json['id']?.toString() ??
              json['course_id']?.toString() ??
              nestedCourse?['id']?.toString() ??
              '';
          final code =
              json['code']?.toString() ??
              nestedCourse?['code']?.toString() ??
              '';
          final title =
              json['title']?.toString() ??
              nestedCourse?['title']?.toString() ??
              fallbackTitle;
          final label = [
            code,
            title,
          ].where((part) => part.isNotEmpty).join(' • ');
          return ReferenceOption(id: id, label: label.isEmpty ? id : label);
        })
        .where((option) => option.id.isNotEmpty)
        .toList();
  }

  List<RoleDashboardItem> _items(
    dynamic data,
    String titleKey,
    String statusKey,
    String resourceType,
  ) {
    if (data is! List) return const [];
    return data.whereType<Map>().map((raw) {
      final json = raw.map((key, value) => MapEntry(key.toString(), value));
      final course = json['course'];
      final subtitle = course is Map
          ? [
              course['code']?.toString() ?? '',
              course['title']?.toString() ?? '',
            ].where((part) => part.isNotEmpty).join(' • ')
          : json['identity']?.toString() ??
                json['message']?.toString() ??
                json['academic_session']?.toString() ??
                '';
      final fallbackTitle =
          [json['title'], json['first_name'], json['summary'], json['identity']]
              .where(
                (value) => value != null && value.toString().trim().isNotEmpty,
              )
              .map((value) => value.toString())
              .firstOrNull;
      return RoleDashboardItem(
        id: json['id']?.toString() ?? '',
        resourceType: resourceType,
        title: json[titleKey]?.toString().trim().isNotEmpty == true
            ? json[titleKey].toString()
            : fallbackTitle ?? 'Record',
        subtitle: subtitle,
        status: json[statusKey]?.toString() ?? 'open',
      );
    }).toList();
  }

  RoleDashboardItem _analyticsItem(dynamic data) {
    if (data is Map) {
      final summary = data['summary'];
      if (summary is Map) {
        final courses = summary['assigned_courses']?.toString() ?? '0';
        final pending = summary['pending_marking']?.toString() ?? '0';
        final submissions = summary['submissions_received']?.toString() ?? '0';
        return RoleDashboardItem(
          id: '',
          resourceType: 'analytics',
          title: '$courses courses • $submissions submissions',
          subtitle: 'Pending marking: $pending',
          status: 'live',
        );
      }
    }
    return const RoleDashboardItem(
      id: '',
      resourceType: 'analytics',
      title: 'Analytics unavailable',
      subtitle: 'No live summary returned yet',
      status: 'pending',
    );
  }

  void close() => _client.close();
}

class ReferenceOption {
  const ReferenceOption({required this.id, required this.label});
  final String id;
  final String label;
}

class RoleDashboardData {
  const RoleDashboardData({required this.title, required this.sections});

  final String title;
  final List<RoleDashboardSection> sections;
}

class RoleDashboardSection {
  const RoleDashboardSection({
    required this.kind,
    required this.title,
    required this.items,
  });

  final String kind;
  final String title;
  final List<RoleDashboardItem> items;
}

class RoleDashboardItem {
  const RoleDashboardItem({
    required this.id,
    required this.resourceType,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String id;
  final String resourceType;
  final String title;
  final String subtitle;
  final String status;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
