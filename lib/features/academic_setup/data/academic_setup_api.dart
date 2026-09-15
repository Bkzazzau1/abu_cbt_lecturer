/// Everything in this file runs locally — no backend is required to demo the
/// General ICT Admin / HoD academic setup screen (faculties, departments,
/// programmes, courses, and lecturer assignment). When a real backend is
/// ready, this is the file to swap back to `ApiClient` calls against the
/// documented `/api/faculties`, `/api/departments`, `/api/programmes`,
/// `/api/courses`, and `/api/staff` contracts — the model shapes already
/// match them.
class AcademicSetupApi {
  AcademicSetupApi();

  static final List<Map<String, dynamic>> _demoFaculties = [
    {'id': '1', 'code': 'SCI', 'name': 'Science'},
  ];

  static final List<Map<String, dynamic>> _demoDepartments = [
    {'id': '1', 'faculty_id': '1', 'code': 'CSC', 'name': 'Computer Science'},
    {'id': '2', 'faculty_id': '1', 'code': 'MTH', 'name': 'Mathematics'},
  ];

  static final List<Map<String, dynamic>> _demoProgrammes = [
    {
      'id': '1',
      'department_id': '1',
      'code': 'CSC-BSC',
      'name': 'B.Sc. Computer Science',
      'level_type': 'undergraduate',
    },
  ];

  static final List<Map<String, dynamic>> _demoCourses = [
    {
      'id': '1',
      'department_id': '1',
      'programme_id': '1',
      'code': 'CSC101',
      'title': 'Introduction to Computer Science',
      'unit': '3',
      'semester': 'first',
      'level': '100',
      'is_active': true,
    },
    {
      'id': '2',
      'department_id': '1',
      'programme_id': '1',
      'code': 'CSC102',
      'title': 'Programming Fundamentals',
      'unit': '3',
      'semester': 'second',
      'level': '100',
      'is_active': true,
    },
    {
      'id': '3',
      'department_id': '1',
      'programme_id': '1',
      'code': 'CSC305',
      'title': 'Data Structures',
      'unit': '3',
      'semester': 'first',
      'level': '300',
      'is_active': true,
    },
  ];

  static final List<Map<String, dynamic>> _demoStaff = [
    {
      'id': '3',
      'first_name': 'Amina',
      'last_name': 'Bello',
      'email': 'lecturer.demo@abu.edu.ng',
      'primary_role': 'lecturer',
      'status': 'active',
    },
  ];

  Future<AcademicSetupData> fetchSetup() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return AcademicSetupData(
      faculties: _demoFaculties.map(AcademicFaculty.fromJson).toList(),
      departments: _demoDepartments.map(AcademicDepartment.fromJson).toList(),
      programmes: _demoProgrammes.map(AcademicProgramme.fromJson).toList(),
      courses: _demoCourses.map(AcademicCourse.fromJson).toList(),
      lecturers: _demoStaff
          .map(AcademicStaff.fromJson)
          .where((staff) => staff.role == 'lecturer' && staff.active)
          .toList(),
    );
  }

  Future<void> createFaculty(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _demoFaculties.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'code': payload['code']?.toString() ?? '',
      'name': payload['name']?.toString() ?? '',
    });
  }

  Future<void> createDepartment(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _demoDepartments.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'faculty_id': payload['faculty_id']?.toString() ?? '',
      'code': payload['code']?.toString() ?? '',
      'name': payload['name']?.toString() ?? '',
    });
  }

  Future<void> createProgramme(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _demoProgrammes.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'department_id': payload['department_id']?.toString() ?? '',
      'code': payload['code']?.toString() ?? '',
      'name': payload['name']?.toString() ?? '',
      'level_type': payload['level_type']?.toString() ?? '',
    });
  }

  Future<void> createCourse(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _demoCourses.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'department_id': payload['department_id']?.toString() ?? '',
      'programme_id': payload['programme_id']?.toString() ?? '',
      'code': payload['code']?.toString() ?? '',
      'title': payload['title']?.toString() ?? '',
      'unit': payload['unit']?.toString() ?? '',
      'semester': payload['semester']?.toString() ?? '',
      'level': payload['level']?.toString() ?? '',
      'is_active': true,
    });
  }

  Future<void> assignLecturer({
    required String courseId,
    required String lecturerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void close() {}
}

class AcademicSetupData {
  const AcademicSetupData({
    required this.faculties,
    required this.departments,
    required this.programmes,
    required this.courses,
    required this.lecturers,
  });

  final List<AcademicFaculty> faculties;
  final List<AcademicDepartment> departments;
  final List<AcademicProgramme> programmes;
  final List<AcademicCourse> courses;
  final List<AcademicStaff> lecturers;
}

class AcademicFaculty {
  const AcademicFaculty({
    required this.id,
    required this.name,
    required this.code,
  });

  final String id;
  final String name;
  final String code;

  factory AcademicFaculty.fromJson(Map<String, dynamic> json) =>
      AcademicFaculty(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unnamed faculty',
        code: json['code']?.toString() ?? '',
      );
}

class AcademicDepartment {
  const AcademicDepartment({
    required this.id,
    required this.facultyId,
    required this.name,
    required this.code,
  });

  final String id;
  final String facultyId;
  final String name;
  final String code;

  factory AcademicDepartment.fromJson(Map<String, dynamic> json) =>
      AcademicDepartment(
        id: json['id']?.toString() ?? '',
        facultyId: json['faculty_id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unnamed department',
        code: json['code']?.toString() ?? '',
      );
}

class AcademicProgramme {
  const AcademicProgramme({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.code,
    required this.levelType,
  });

  final String id;
  final String departmentId;
  final String name;
  final String code;
  final String levelType;

  factory AcademicProgramme.fromJson(Map<String, dynamic> json) =>
      AcademicProgramme(
        id: json['id']?.toString() ?? '',
        departmentId: json['department_id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unnamed programme',
        code: json['code']?.toString() ?? '',
        levelType: json['level_type']?.toString() ?? '',
      );
}

class AcademicCourse {
  const AcademicCourse({
    required this.id,
    required this.departmentId,
    required this.programmeId,
    required this.title,
    required this.code,
    required this.unit,
    required this.semester,
    required this.level,
    required this.active,
  });

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
  const AcademicStaff({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final bool active;

  factory AcademicStaff.fromJson(Map<String, dynamic> json) {
    final roles = json['roles'];
    String role = json['primary_role']?.toString() ?? '';
    if (role.isEmpty &&
        roles is List &&
        roles.isNotEmpty &&
        roles.first is Map) {
      final firstRole = (roles.first as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );
      role = firstRole['code']?.toString() ?? '';
    }
    final name = [
      json['first_name']?.toString() ?? '',
      json['last_name']?.toString() ?? '',
    ].where((part) => part.trim().isNotEmpty).join(' ');
    return AcademicStaff(
      id: json['id']?.toString() ?? '',
      name: name.isEmpty ? 'Unnamed staff' : name,
      email: json['email']?.toString() ?? '',
      role: role,
      active: (json['status']?.toString() ?? 'active') == 'active',
    );
  }
}
