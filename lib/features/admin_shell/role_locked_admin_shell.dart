import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../models/admin_role.dart';
import 'admin_operations_shell.dart';

class RoleLockedAdminShell extends StatefulWidget {
  const RoleLockedAdminShell({super.key});

  @override
  State<RoleLockedAdminShell> createState() => _RoleLockedAdminShellState();
}

class _RoleLockedAdminShellState extends State<RoleLockedAdminShell> {
  StaffSession? get _session => AuthSession.instance.session;

  @override
  Widget build(BuildContext context) {
    return AdminOperationsShell(
      initialRole: _adminRoleFromSession(),
      lockRole: true,
    );
  }

  AdminRole _adminRoleFromSession() {
    final session = _session;
    final rawRole = session?.primaryRole.isNotEmpty == true
        ? session!.primaryRole
        : (session?.roles.isNotEmpty == true
              ? session!.roles.first
              : 'lecturer');
    final role = rawRole.toLowerCase().trim();

    switch (role) {
      case 'admin':
      case 'super_admin':
      case 'superadmin':
      case 'system_admin':
        return AdminRole.superAdmin;
      case 'dlc_director':
      case 'dlc director':
        return AdminRole.dlcDirector;
      case 'hod':
      case 'head_of_department':
        return AdminRole.hod;
      case 'exam_officer':
      case 'exam officer':
      case 'departmental_exam_officer':
        return AdminRole.examOfficer;
      case 'moderator':
        return AdminRole.moderator;
      case 'invigilator':
      case 'proctor':
        return AdminRole.invigilator;
      case 'academic_records':
      case 'records_department':
      case 'academic records':
        return AdminRole.recordsDepartment;
      case 'level_adviser':
      case 'level adviser':
      case 'level_coordinator':
        return AdminRole.levelAdviser;
      case 'support':
      case 'support_team':
        return AdminRole.supportTeam;
      case 'reports':
      case 'reports_team':
        return AdminRole.reportsTeam;
      case 'lecturer':
      default:
        return AdminRole.lecturer;
    }
  }
}
