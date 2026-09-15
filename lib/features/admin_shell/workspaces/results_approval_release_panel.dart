import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../exam_workflow/data/exam_results_api.dart';
import 'exam_officer_academic_standing_panel.dart';
import 'exam_officer_level_results_panel.dart';
import 'exam_officer_results_panel.dart';
import 'exam_officer_script_archive_panel.dart';
import 'hod_level_results_panel.dart';
import 'results_approval_release_panel_legacy.dart' as legacy;

class ResultsApprovalReleasePanel extends StatelessWidget {
  const ResultsApprovalReleasePanel({super.key, this.api});

  final ExamResultsApi? api;

  @override
  Widget build(BuildContext context) {
    final session = AuthSession.instance.session;
    final role = session?.primaryRole.isNotEmpty == true
        ? session!.primaryRole
        : (session?.roles.isNotEmpty == true ? session!.roles.first : '');

    if (role == 'exam_officer') {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExamOfficerResultsPanel(),
          SizedBox(height: 16),
          ExamOfficerLevelResultsPanel(),
          SizedBox(height: 16),
          ExamOfficerAcademicStandingPanel(),
          SizedBox(height: 16),
          ExamOfficerScriptArchivePanel(),
        ],
      );
    }

    if (role == 'hod') {
      return const HodLevelResultsPanel();
    }

    return legacy.ResultsApprovalReleasePanel(api: api);
  }
}
