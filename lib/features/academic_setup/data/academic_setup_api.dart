import '../../../core/network/api_client.dart';

class AcademicSetupApi {
  AcademicSetupApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AcademicSetupData> fetchSetup() async {
    final results = await Future.wait<dynamic>([
      _client.get('/api/faculties'),
      _client.get('/api/departments'),
      _client.get('/api/programmes'),
      _client.get('/api/courses'),
      _client.get('/api/staff'),
    ]);
    return AcademicSetupData(
      faculties: _list(results[0]).map(AcademicFaculty.fromJson).toList(),
      departments: _list(results[1]).map(AcademicDepartment.fromJson).toList(),
      programmes: _list(results[2]).map(AcademicProgramme.fromJson).toList(),
      courses: _list(results[3]).map(AcademicCourse.fromJson).toList(),
      lecturers: _list(results[4]).map(AcademicStaff.fromJson).where((staff) => staff.role == 'lecturer' && staff.active).toList(),
    );
  }

  Future<void> createFaculty(Map<String, dynamic> payload) async {
    await _client.post('/api/faculties', body: payload);
  }

  Future<void> createDepartment(Map<String, dynamic> payload) async {
    await _client.post('/api/departments', body: payload);
  }

  Future<void> createProgramme(Map<String, dynamic> payload) async {
    await _client.post('/api/programmes', body: payload);
  }

  Future<void> createCourse(Map<String, dynamic> payload) async {
    await _client.post('/api/courses', body: payload);
  }

  Future<void> assignLecturer({required String courseId, required String lecturerId}) async {
    await _client.post('/api/courses/$courseId/lecturers', body: {'lecturer_id': int.tryParse(lecturerId) ?? lecturerId});
  }

  List<Map<String, dynamic>> _list(dynamic data) {
    dynamic rows = data;
    if (data is Map) rows = data['items'] ?? data['data'] ?? data['results'];
    if (rows is! List) return const [];
    return rows.whereType<Map>().map((raw) => raw.map((key, value) => MapEntry(key.toString(), value))).toList();
  }

  void close() => _client.close();
}

class AcademicSetupData {
  const AcademicSetupData({required this.faculties, required this.departments, required this.programmes, required this.courses, required this.lecturers});

  final List<AcademicFaculty> faculties;
  final List<AcademicDepartment> departments;
  final List<AcademicProgramme> programmes;
  final List<AcademicCourse> courses;
  final List<AcademicStaff> lecturers;
}

class AcademicFaculty {
  const AcademicFaculty({required this.id, required this.name, required this.code});

  final String id;
  final String name;
  final String code;

  factory AcademicFaculty.fromJson(Map<String, dynamic> json) => AcademicFaculty(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? 'Unnamed faculty',
    code: json['code']?.toString() ?? '',
  );
}

class AcademicDepartment {
  const AcademicDepartment({required this.id, required this.facultyId, required this.name, required this.code});

  final String id;
  final String facultyId;
  final String name;
  final String code;

  factory AcademicDepartment.fromJson(Map<String, dynamic> json) => AcademicDepartment(
    id: json['id']?.toString() ?? '',
    facultyId: json['faculty_id']?.toString() ?? '',
    name: json['name']?.toString() ?? 'Unnamed department',
    code: json['code']?.toString() ?? '',
  );
}

class AcademicProgramme {
  const AcademicProgramme({required this.id, required this.departmentId, required this.name, required this.code, required this.levelType});

  final String id;
  final String departmentId;
  final String name;
  final String code;
  final String levelType;

  factory AcademicProgramme.fromJson(Map<String, dynamic> json) => AcademicProgramme(
    id: json['id']?.toString() ?? '',
    departmentId: json['department_id']?.toString() ?? '',
    name: json['name']?.toString() ?? 'Unnamed programme',
    code: json['code']?.toString() ?? '',
    levelType: json['level_type']?.toString() ?? '',
  );
}

class AcademicCourse {
  const AcademicCourse({required this.id, required this.departmentId, required this.programmeId, required this.title, required this.code, required this.unit, required this.semester, required this.level, required this.active});

  final String id;
  final String departmentId;
  final String programmeId;
  final String title;
  final String code;
  final String unit;
  final String semester;
  final String level;
  final bool active;

  factory AcademicCourse.fromJson(Map<String, dynamic> json) => AcademicCourse(
    id: json['id']?.toString() ?? '',
    departmentId: json['department_id']?.toString() ?? '',
    programmeId: json['programme_id']?.toString() ?? '',
    title: json['title']?.toString() ?? 'Untitled course',
    code: json['code']?.toString() ?? '',
    unit: json['unit']?.toString() ?? '',
    semester: json['semester']?.toString() ?? '',
    level: json['level']?.toString() ?? '',
    active: json['is_active'] != false,
  );
}

class AcademicStaff {
  const AcademicStaff({required this.id, required this.name, required this.email, required this.role, required this.active});

  final String id;
  final String name;
  final String email;
  final String role;
  final bool active;

  factory AcademicStaff.fromJson(Map<String, dynamic> json) {
    final roles = json['roles'];
    String role = json['primary_role']?.toString() ?? '';
    if (role.isEmpty && roles is List && roles.isNotEmpty && roles.first is Map) {
      final firstRole = (roles.first as Map).map((key, value) => MapEntry(key.toString(), value));
      role = firstRole['code']?.toString() ?? '';
    }
    final name = [json['first_name']?.toString() ?? '', json['last_name']?.toString() ?? ''].where((part) => part.trim().isNotEmpty).join(' ');
    return AcademicStaff(
      id: json['id']?.toString() ?? '',
      name: name.isEmpty ? 'Unnamed staff' : name,
      email: json['email']?.toString() ?? '',
      role: role,
      active: (json['status']?.toString() ?? 'active') == 'active',
    );
  }
}
