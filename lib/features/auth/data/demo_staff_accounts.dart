import '../../../models/admin_role.dart';

/// Local-only demo staff identities, one per supported portal role. Signing
/// in with one of these builds a session payload shaped exactly like the
/// real `/api/auth/login` response and feeds it straight to
/// [AuthSession.saveLogin], bypassing the backend entirely — for exploring
/// the admin app without a live `ABU_CBT_API_BASE_URL` deployment.
class DemoStaffAccount {
  const DemoStaffAccount({
    required this.role,
    required this.roleCode,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.staffId,
    required this.email,
  });

  final AdminRole role;
  final String roleCode;
  final String title;
  final String firstName;
  final String lastName;
  final String staffId;
  final String email;

  String get fullName => '$title $firstName $lastName';

  Map<String, dynamic> toLoginPayload() {
    return {
      'access_token': 'demo-$roleCode-token',
      'user': {
        'id': staffId,
        'email': email,
        'title': title,
        'first_name': firstName,
        'last_name': lastName,
        'roles': [
          {'code': roleCode, 'is_primary': true},
        ],
      },
    };
  }
}

const demoStaffAccounts = <DemoStaffAccount>[
  DemoStaffAccount(
    role: AdminRole.lecturer,
    roleCode: 'lecturer',
    title: 'Dr.',
    firstName: 'Amina',
    lastName: 'Bello',
    staffId: '1001',
    email: 'lecturer.demo@abu.edu.ng',
  ),
  DemoStaffAccount(
    role: AdminRole.moderator,
    roleCode: 'moderator',
    title: 'Dr.',
    firstName: 'Ibrahim',
    lastName: 'Sule',
    staffId: 'DEMO-MOD-001',
    email: 'moderator.demo@abu.edu.ng',
  ),
  DemoStaffAccount(
    role: AdminRole.examOfficer,
    roleCode: 'exam_officer',
    title: 'Mr.',
    firstName: 'Musa',
    lastName: 'Ibrahim',
    staffId: 'DEMO-EXO-001',
    email: 'examofficer.demo@abu.edu.ng',
  ),
  DemoStaffAccount(
    role: AdminRole.hod,
    roleCode: 'hod',
    title: 'Prof.',
    firstName: 'Fatima',
    lastName: 'Sani',
    staffId: 'DEMO-HOD-001',
    email: 'hod.demo@abu.edu.ng',
  ),
  DemoStaffAccount(
    role: AdminRole.ictAdmin,
    roleCode: 'ict_admin',
    title: 'Mr.',
    firstName: 'Chinedu',
    lastName: 'Okafor',
    staffId: 'DEMO-ICT-001',
    email: 'ictadmin.demo@abu.edu.ng',
  ),
];
