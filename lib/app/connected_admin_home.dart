import 'package:flutter/material.dart';

import '../features/admin_shell/role_locked_admin_shell.dart';

class ConnectedAdminHome extends StatelessWidget {
  const ConnectedAdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleLockedAdminShell();
  }
}
