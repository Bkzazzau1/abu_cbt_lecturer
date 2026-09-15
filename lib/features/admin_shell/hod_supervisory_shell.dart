import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import 'workspaces/exam_analytics_panel.dart';
import 'workspaces/exam_management_panel.dart';
import 'workspaces/hod_academic_resources_panel.dart';
import 'workspaces/hod_department_overview_panel.dart';
import 'workspaces/hod_level_results_panel.dart';
import 'workspaces/hod_malpractice_cases_panel.dart';
import 'workspaces/hod_staff_appointments_panel.dart';
import 'workspaces/moderator_question_review_panel.dart';

class HodSupervisoryShell extends StatefulWidget {
  const HodSupervisoryShell({super.key});

  @override
  State<HodSupervisoryShell> createState() => _HodSupervisoryShellState();
}

class _HodSupervisoryShellState extends State<HodSupervisoryShell> {
  int _selectedIndex = 0;

  static const _pages = [
    _HodPage('Department Overview', Icons.dashboard_outlined),
    _HodPage('Staff & Appointments', Icons.badge_outlined),
    _HodPage('Academic Register', Icons.school_outlined),
    _HodPage('Chief Exam Operations', Icons.assignment_turned_in_outlined),
    _HodPage('Question & Moderation', Icons.rule_folder_outlined),
    _HodPage('Malpractice Cases', Icons.gavel_outlined),
    _HodPage('Results', Icons.workspace_premium_outlined),
    _HodPage('Department Analytics', Icons.analytics_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 860;
    return Scaffold(
      appBar: compact
          ? AppBar(
              title: const Text('HoD — Computer Science'),
              actions: [
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: () => AuthSession.instance.signOut(),
                  icon: const Icon(Icons.logout_outlined),
                ),
              ],
            )
          : null,
      drawer: compact
          ? Drawer(
              child: _HodNavigation(
                selectedIndex: _selectedIndex,
                onSelected: (value) {
                  setState(() => _selectedIndex = value);
                  Navigator.of(context).pop();
                },
                onLogout: () => AuthSession.instance.signOut(),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!compact)
            _HodNavigation(
              selectedIndex: _selectedIndex,
              onSelected: (value) => setState(() => _selectedIndex = value),
              onLogout: () => AuthSession.instance.signOut(),
            ),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 14 : 26,
                  compact ? 10 : 22,
                  compact ? 14 : 26,
                  28,
                ),
                child: _buildPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return const HodDepartmentOverviewPanel();
      case 1:
        return const HodStaffAppointmentsPanel();
      case 2:
        return const HodAcademicResourcesPanel();
      case 3:
        return const ExamManagementPanel();
      case 4:
        return const ModeratorQuestionReviewPanel(
          mode: QuestionReviewMode.examOfficer,
        );
      case 5:
        return const HodMalpracticeCasesPanel();
      case 6:
        return const HodLevelResultsPanel();
      case 7:
        return const ExamAnalyticsPanel(audience: ExamAnalyticsAudience.hod);
      default:
        return const HodDepartmentOverviewPanel();
    }
  }
}

class _HodNavigation extends StatelessWidget {
  const _HodNavigation({
    required this.selectedIndex,
    required this.onSelected,
    required this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      child: SizedBox(
        width: 300,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  child: const Icon(Icons.account_tree_outlined),
                ),
                title: const Text(
                  'HoD Workspace',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Chief Exam Officer • Department Head'),
                trailing: IconButton(
                  tooltip: 'Sign out',
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_outlined),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Chief Exam Officer authority\nCreates Lecturer, Moderator and Exam Officer accounts; appoints course lecturers/moderators; delegates routine exam operations but may intervene directly.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < _HodSupervisoryShellState._pages.length; i++)
                ListTile(
                  selected: selectedIndex == i,
                  selectedTileColor: scheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  leading: Icon(_HodSupervisoryShellState._pages[i].icon),
                  title: Text(_HodSupervisoryShellState._pages[i].label),
                  onTap: () => onSelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HodPage {
  const _HodPage(this.label, this.icon);

  final String label;
  final IconData icon;
}
