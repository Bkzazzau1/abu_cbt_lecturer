import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../../models/admin_role.dart';
import '../../exam_officer/data/exam_officer_demo_seed.dart';
import '../../exam_officer/data/exam_officer_demo_slots.dart';
import 'exam_management_panel_legacy.dart' as legacy;
import 'exam_officer_invigilation_panel.dart';
import 'exam_officer_marking_assignment_panel.dart';
import 'exam_officer_readiness_panel.dart';
import 'exam_officer_timetable_flow_panel.dart';
import 'ict_hall_time_approval_panel.dart';

class ExamManagementPanel extends StatelessWidget {
  const ExamManagementPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AuthSession.instance.session;
    final roleCode = session?.primaryRole.isNotEmpty == true
        ? session!.primaryRole
        : (session?.roles.isNotEmpty == true ? session!.roles.first : '');
    final role = adminRoleFromCode(roleCode);

    if (role == AdminRole.ictAdmin) {
      return const IctHallTimeApprovalPanel();
    }

    if (role == AdminRole.examOfficer || role == AdminRole.hod) {
      ExamOfficerDemoSlots.ensure();
      ExamOfficerDemoSeed.ensureSeeded();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (role == AdminRole.hod) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chief Exam Officer Authority',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'The HoD may exercise departmental exam operations directly or delegate routine execution to the appointed Exam Officer. All actions remain within the same audit workflow.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const ExamOfficerReadinessPanel(),
          const SizedBox(height: 16),
          const ExamOfficerTimetableFlowPanel(),
          const SizedBox(height: 16),
          const ExamOfficerInvigilationPanel(),
          const SizedBox(height: 16),
          const ExamOfficerMarkingAssignmentPanel(),
        ],
      );
    }

    return const legacy.ExamManagementPanel();
  }
}
