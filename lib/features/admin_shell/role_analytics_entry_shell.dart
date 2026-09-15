import 'package:flutter/material.dart';

import '../../models/admin_role.dart';
import 'admin_operations_shell.dart';
import 'workspaces/exam_analytics_page.dart';

class RoleAnalyticsEntryShell extends StatelessWidget {
  const RoleAnalyticsEntryShell({
    super.key,
    required this.role,
  });

  final AdminRole role;

  @override
  Widget build(BuildContext context) {
    final isHod = role == AdminRole.hod;
    return Stack(
      children: [
        AdminOperationsShell(initialRole: role, lockRole: true),
        Positioned(
          right: 22,
          bottom: 22,
          child: SafeArea(
            child: FloatingActionButton.extended(
              heroTag: 'exam-analytics-${role.name}',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => isHod
                      ? const ExamAnalyticsPage.hod()
                      : const ExamAnalyticsPage.examOfficer(),
                ),
              ),
              icon: const Icon(Icons.analytics_outlined),
              label: Text(isHod ? 'Department Analytics' : 'Exam Analytics'),
            ),
          ),
        ),
      ],
    );
  }
}
