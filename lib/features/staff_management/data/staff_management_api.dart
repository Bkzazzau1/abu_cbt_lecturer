import '../../../core/network/api_client.dart';

class StaffManagementApi {
  StaffManagementApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StaffItem>> fetchStaff() async {
    try {
      final data = await _client.get('/api/staff');
      dynamic rows = data;
      if (data is Map) rows = data['items'] ?? data['data'] ?? data['results'];
      if (rows is! List) return const [];
      return rows.whereType<Map>().map((raw) {
        final json = raw.map((key, value) => MapEntry(key.toString(), value));
        return StaffItem.fromJson(json);
      }).toList();
    } catch (_) {
      return const [
        StaffItem(
          id: '1',
          staffNumber: 'SYS-001',
          name: 'System Admin',
          email: 'admin@fazam.tech',
          phone: '',
          primaryRole: 'system_admin',
          departmentId: '',
          active: true,
        ),
      ];
    }
  }

  Future<StaffReferenceData> fetchReferences() async {
    try {
      final results = await Future.wait<dynamic>([
        _client.get('/api/departments'),
        _client.get('/api/courses'),
      ]);
      return StaffReferenceData(
        departments: _referenceOptions(results[0], codeKey: 'code', titleKey: 'name'),
        courses: _referenceOptions(results[1], codeKey: 'code', titleKey: 'title'),
      );
    } catch (_) {
      return const StaffReferenceData(departments: [], courses: []);
    }
  }

  Future<void> createStaff(Map<String, dynamic> payload) async {
    await _client.post('/api/staff', body: payload);
  }

  Future<void> resetPassword({required String staffId, required String password}) async {
    await _client.post('/api/staff/$staffId/reset-password', body: {'password': password});
  }

  Future<void> updateStaffStatus({required String staffId, required bool active}) async {
    await _client.patch('/api/staff/$staffId/status', body: {'status': active ? 'active' : 'inactive'});
  }

  Future<void> assignRole({required String staffId, required String role, String? departmentId, String? courseId}) async {
    final numericStaffId = int.tryParse(staffId);
    if (numericStaffId == null) {
      throw const ApiException('Invalid staff selected');
    }

    final numericDepartmentId = int.tryParse(departmentId ?? '');
    final numericCourseId = int.tryParse(courseId ?? '');
    final useCourseScope = numericCourseId != null;

    final payload = <String, dynamic>{
      'staff_id': numericStaffId,
      'role': role,
      'scope': useCourseScope ? 'course' : 'department',
    };

    if (useCourseScope) {
      payload['course_id'] = numericCourseId;
    } else if (numericDepartmentId != null) {
      payload['department_id'] = numericDepartmentId;
    }

    await _client.post('/api/admin/staff-roles', body: payload);
  }

  List<ReferenceOption> _referenceOptions(dynamic data, {required String codeKey, required String titleKey}) {
    dynamic rows = data;
    if (data is Map) rows = data['items'] ?? data['data'] ?? data['results'];
    if (rows is! List) return const [];
    return rows.whereType<Map>().map((raw) {
      final json = raw.map((key, value) => MapEntry(key.toString(), value));
      final id = json['id']?.toString() ?? '';
      final code = json[codeKey]?.toString() ?? '';
      final title = json[titleKey]?.toString() ?? '';
      final label = [code, title].where((part) => part.isNotEmpty).join(' • ');
      return ReferenceOption(id: id, label: label.isEmpty ? id : label);
    }).where((option) => option.id.isNotEmpty).toList();
  }

  void close() => _client.close();
}

class StaffReferenceData {
  const StaffReferenceData({required this.departments, required this.courses});

  final List<ReferenceOption> departments;
  final List<ReferenceOption> courses;
}

class ReferenceOption {
  const ReferenceOption({required this.id, required this.label});

  final String id;
  final String label;
}

class StaffItem {
  const StaffItem({
    required this.id,
    required this.staffNumber,
    required this.name,
    required this.email,
    required this.phone,
    required this.primaryRole,
    required this.departmentId,
    required this.active,
  });

  final String id;
  final String staffNumber;
  final String name;
  final String email;
  final String phone;
  final String primaryRole;
  final String departmentId;
  final bool active;

  factory StaffItem.fromJson(Map<String, dynamic> json) {
    final name = [
      json['title']?.toString() ?? '',
      json['first_name']?.toString() ?? '',
      json['last_name']?.toString() ?? '',
    ].where((part) => part.trim().isNotEmpty).join(' ');
    final roles = json['roles'];
    String role = json['primary_role']?.toString() ?? json['role']?.toString() ?? '';
    String departmentId = json['department_id']?.toString() ?? '';
    if (role.isEmpty && roles is List && roles.isNotEmpty && roles.first is Map) {
      final firstRole = (roles.first as Map).map((key, value) => MapEntry(key.toString(), value));
      role = firstRole['code']?.toString() ?? '';
      departmentId = firstRole['scope_id']?.toString() ?? departmentId;
    }
    return StaffItem(
      id: json['id']?.toString() ?? '',
      staffNumber: json['staff_number']?.toString() ?? json['staff_id']?.toString() ?? '',
      name: name.isEmpty ? 'Unnamed staff' : name,
      email: json['email']?.toString() ?? json['identity']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      primaryRole: role.isEmpty ? 'lecturer' : role,
      departmentId: departmentId,
      active: (json['status']?.toString() ?? 'active') == 'active' && json['is_active'] != false,
    );
  }
}

const staffRoleOptions = [
  'system_admin',
  'academic_admin',
  'dean',
  'hod',
  'programme_coordinator',
  'exam_officer',
  'lecturer',
  'moderator',
  'proctor',
  'content_manager',
  'registry_officer',
  'student_affairs',
  'marker',
  'teaching_assistant',
  'dlc_director',
  'level_adviser',
  'invigilator',
  'academic_records',
];