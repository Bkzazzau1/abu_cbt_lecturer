import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../models/admin_role.dart';
import 'admin_operations_shell.dart';
import 'ict_availability_shell.dart';

class RoleLockedAdminShell extends StatelessWidget {
  const RoleLockedAdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AuthSession.instance.session;
    final code = session?.primaryRole.isNotEmpty == true
        ? session!.primaryRole
        : (session?.roles.isNotEmpty == true ? session!.roles.first : null);
    final role = adminRoleFromCode(code);
    if (role == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ABU CBT Admin')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'This account does not have access to ABU CBT Admin.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Contact the General ICT Admin for an authorised staff role.',
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => AuthSession.instance.signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (role == AdminRole.ictAdmin) {
      return const IctAvailabilityShell();
    }

    return AdminOperationsShell(initialRole: role, lockRole: true);
  }
}
