import '../../../models/admin_role.dart';
import '../../../core/network/api_client.dart' show ApiException;

/// Everything in this file runs locally — no backend is required to demo the
/// General ICT Admin staff management screen. When a real backend is ready,
/// this is the file to swap back to `ApiClient` calls against the documented
/// `/api/staff`, `/api/departments`, `/api/courses`, and
/// `/api/admin/staff-roles` contracts — the model shapes already match them.
class StaffManagementApi {
  StaffManagementApi();

  static final List<Map<String, dynamic>> _demoStaff = [
    {
      'id': '1',
      'staff_number': 'SYS-001',
      'first_name': 'Chinedu',
      'last_name': 'Okafor',
      'email': 'ictadmin.demo@abu.edu.ng',
      'phone': '',
      'primary_role': 'ict_admin',
      'department_id': '',
      'status': 'active',
    },
    {
      'id': '2',
      'staff_number': 'HOD-001',
      'first_name': 'Fatima',
      'last_name': 'Sani',
      'email': 'hod.demo@abu.edu.ng',
      'phone': '',
      'primary_role': 'hod',
      'department_id': '1',
      'status': 'active',
    },
    {
      'id': '3',
      'staff_number': 'LEC-001',
      'first_name': 'Amina',
      'last_name': 'Bello',
      'email': 'lecturer.demo@abu.edu.ng',
      'phone': '',
      'primary_role': 'lecturer',
      'department_id': '1',
      'status': 'active',
    },
    {
      'id': '4',
      'staff_number': 'MOD-001',
      'first_name': 'Ibrahim',
      'last_name': 'Sule',
      'email': 'moderator.demo@abu.edu.ng',
      'phone': '',
      'primary_role': 'moderator',
      'department_id': '1',
      'status': 'active',
    },
    {
      'id': '5',
      'staff_number': 'EXO-001',
      'first_name': 'Musa',
      'last_name': 'Ibrahim',
      'email': 'examofficer.demo@abu.edu.ng',
      'phone': '',
      'primary_role': 'exam_officer',
      'department_id': '1',
      'status': 'active',
    },
  ];

  static final List<Map<String, dynamic>> _demoDepartments = [
    {'id': '1', 'code': 'CSC', 'name': 'Computer Science'},
    {'id': '2', 'code': 'MTH', 'name': 'Mathematics'},
  ];

  static final List<Map<String, dynamic>> _demoCourses = [
    {'id': '1', 'code': 'CSC101', 'title': 'Introduction to Computer Science'},
    {'id': '2', 'code': 'CSC102', 'title': 'Programming Fundamentals'},
    {'id': '3', 'code': 'CSC305', 'title': 'Data Structures'},
  ];

  Future<List<StaffItem>> fetchStaff() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _demoStaff
        .map((raw) => StaffItem.fromJson(Map<String, dynamic>.from(raw)))
        .toList();
  }

  Future<StaffReferenceData> fetchReferences() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return StaffReferenceData(
      departments: _demoDepartments
          .map(
            (raw) => ReferenceOption(
              id: raw['id'].toString(),
              label: '${raw['code']} • ${raw['name']}',
            ),
          )
          .toList(),
      courses: _demoCourses
          .map(
            (raw) => ReferenceOption(
              id: raw['id'].toString(),
              label: '${raw['code']} • ${raw['title']}',
            ),
          )
          .toList(),
    );
  }

  Future<void> createStaff(Map<String, dynamic> payload) async {
    if (!staffRoleOptions.contains(payload['role_code'])) {
      throw const ApiException('Unsupported staff role');
    }
    await Future.delayed(const Duration(milliseconds: 400));
    _demoStaff.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'staff_number': payload['staff_number']?.toString() ?? '',
      'first_name': payload['first_name']?.toString() ?? '',
      'last_name': payload['last_name']?.toString() ?? '',
      'email': payload['email']?.toString() ?? '',
      'phone': payload['phone']?.toString() ?? '',
      'primary_role': payload['role_code']?.toString() ?? 'lecturer',
      'department_id': payload['department_id']?.toString() ?? '',
      'status': 'active',
    });
  }

  Future<void> resetPassword({
    required String staffId,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> updateStaffStatus({
    required String staffId,
    required bool active,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final raw = _findStaff(staffId);
    raw['status'] = active ? 'active' : 'inactive';
  }

  Future<void> assignRole({
    required String staffId,
    required String role,
    String? departmentId,
    String? courseId,
  }) async {
    if (!staffRoleOptions.contains(role)) {
      throw const ApiException('Unsupported staff role');
    }
    await Future.delayed(const Duration(milliseconds: 300));
    final raw = _findStaff(staffId);
    raw['primary_role'] = role;
    if (departmentId != null && departmentId.isNotEmpty) {
      raw['department_id'] = departmentId;
    }
  }

  Map<String, dynamic> _findStaff(String staffId) {
    for (final raw in _demoStaff) {
      if (raw['id'] == staffId) return raw;
    }
    throw const ApiException('Staff not found');
  }

  void close() {}
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
    String role =
        json['primary_role']?.toString() ?? json['role']?.toString() ?? '';
    String departmentId = json['department_id']?.toString() ?? '';
    if (role.isEmpty &&
        roles is List &&
        roles.isNotEmpty &&
        roles.first is Map) {
      final firstRole = (roles.first as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );
      role = firstRole['code']?.toString() ?? '';
      departmentId = firstRole['scope_id']?.toString() ?? departmentId;
    }
    return StaffItem(
      id: json['id']?.toString() ?? '',
      staffNumber:
          json['staff_number']?.toString() ??
          json['staff_id']?.toString() ??
          '',
      name: name.isEmpty ? 'Unnamed staff' : name,
      email: json['email']?.toString() ?? json['identity']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      primaryRole: role.isEmpty ? 'lecturer' : role,
      departmentId: departmentId,
      active:
          (json['status']?.toString() ?? 'active') == 'active' &&
          json['is_active'] != false,
    );
  }
}
