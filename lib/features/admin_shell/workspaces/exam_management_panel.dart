import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../exam_officer/data/exam_officer_demo_seed.dart';
import '../../exam_officer/data/exam_officer_demo_slots.dart';
import 'exam_management_panel_legacy.dart' as legacy;
import 'exam_officer_invigilation_panel.dart';
import 'exam_officer_marking_assignment_panel.dart';
import 'exam_officer_readiness_panel.dart';
import 'exam_officer_timetable_flow_panel.dart';
import 'ict_cbt_calendar_panel.dart';

class ExamManagementPanel extends StatelessWidget {
  const ExamManagementPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AuthSession.instance.session;
    final role = session?.primaryRole.isNotEmpty == true
        ? session!.primaryRole
        : (session?.roles.isNotEmpty == true ? session!.roles.first : '');

    if (role == 'ict_admin') {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IctCbtCalendarPanel(),
          SizedBox(height: 16),
          legacy.ExamManagementPanel(),
        ],
      );
    }

    if (role == 'exam_officer') {
      ExamOfficerDemoSlots.ensure();
      ExamOfficerDemoSeed.ensureSeeded();
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExamOfficerReadinessPanel(),
          SizedBox(height: 16),
          ExamOfficerTimetableFlowPanel(),
          SizedBox(height: 16),
          ExamOfficerInvigilationPanel(),
          SizedBox(height: 16),
          ExamOfficerMarkingAssignmentPanel(),
        ],
      );
    }

    return const legacy.ExamManagementPanel();
  }
}
