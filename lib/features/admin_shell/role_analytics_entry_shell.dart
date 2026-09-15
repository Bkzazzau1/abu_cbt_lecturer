import 'package:flutter/material.dart';

import '../../models/admin_role.dart';
import 'admin_operations_shell.dart';
import 'workspaces/exam_analytics_page.dart';
import 'workspaces/exam_malpractice_page.dart';

class RoleAnalyticsEntryShell extends StatelessWidget {
  const RoleAnalyticsEntryShell({
    super.key,
    required this.role,
  });

  final AdminRole role;

  @override
  Widget build(BuildContext context) {
    final isHod = role == AdminRole.hod;
    final isExamOfficer = role == AdminRole.examOfficer;
    return Stack(
      children: [
        AdminOperationsShell(initialRole: role, lockRole: true),
        Positioned(
          right: 22,
          bottom: 22,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isExamOfficer) ...[
                  FloatingActionButton.extended(
                    heroTag: 'exam-malpractice-${role.name}',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ExamMalpracticePage(),
                      ),
                    ),
                    icon: const Icon(Icons.gavel_outlined),
                    label: const Text('Malpractice & Incidents'),
                  ),
                  const SizedBox(height: 12),
                ],
                FloatingActionButton.extended(
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
