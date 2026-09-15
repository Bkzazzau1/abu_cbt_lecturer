import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import 'lecturer_assignments_marking_panel_legacy.dart' as legacy;
import 'lecturer_connected_marking_panel.dart';

class LecturerAssignmentsMarkingPanel extends StatelessWidget {
  const LecturerAssignmentsMarkingPanel({
    super.key,
    this.section = 'Marking & Grading',
  });

  final String section;

  @override
  Widget build(BuildContext context) {
    final session = AuthSession.instance.session;
    final role = session?.primaryRole.isNotEmpty == true
        ? session!.primaryRole
        : (session?.roles.isNotEmpty == true ? session!.roles.first : '');

    if (role == 'lecturer') {
      return LecturerConnectedMarkingPanel(section: section);
    }

    return legacy.LecturerAssignmentsMarkingPanel(section: section);
  }
}
