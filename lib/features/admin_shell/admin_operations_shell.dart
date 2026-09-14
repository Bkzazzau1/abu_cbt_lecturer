import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../../data/mock_admin_repository.dart';
import '../../models/admin_role.dart';
import '../../models/dashboard_models.dart';
import 'workspaces/academic_records_overview_panel.dart';
import '../academic_setup/widgets/academic_setup_panel.dart';
import 'workspaces/cohort_management_panel.dart';
import 'workspaces/course_registration_approval_panel.dart';
import 'workspaces/departmental_exam_officer_overview_panel.dart';
import 'workspaces/dlc_director_overview_panel.dart';
import 'workspaces/exam_management_panel.dart';
import 'workspaces/exam_sessions_overview_panel.dart';
import 'workspaces/hod_department_overview_panel.dart';
import 'workspaces/invigilator_evidence_review_panel.dart';
import 'workspaces/lecturer_assignments_marking_panel.dart';
import 'workspaces/lecturer_course_delivery_flow_panel.dart';
import 'workspaces/lecturer_course_overview_panel.dart';
import 'workspaces/level_adviser_overview_panel.dart';
import 'workspaces/moderator_question_review_panel.dart';
import 'workspaces/records_department_panel.dart';
import 'workspaces/reports_analytics_panel.dart';
import 'workspaces/results_approval_release_panel.dart';
import 'workspaces/student_support_helpdesk_panel.dart';
import '../staff_management/widgets/staff_management_panel.dart';
import '../lecturer_questions/widgets/lecturer_question_live_panel.dart';
import 'widgets/admin_metric_card.dart';

const _operationsPages = [
  _OpsPage('Overview', Icons.dashboard_outlined),
  _OpsPage('Staff Management', Icons.badge_outlined),
  _OpsPage('Lecturer Monitoring', Icons.school_outlined),
  _OpsPage('Departments & Programmes', Icons.account_tree_outlined),
  _OpsPage('Course Management', Icons.menu_book_outlined),
  _OpsPage('Student Management', Icons.groups_2_outlined),
  _OpsPage('Exams & Assessments', Icons.assignment_outlined),
  _OpsPage('Approvals', Icons.fact_check_outlined),
  _OpsPage('System Activity', Icons.sensors_outlined),
  _OpsPage('Settings', Icons.settings_outlined),
];

const _hodPages = [
  _OpsPage('Department Overview', Icons.dashboard_outlined),
  _OpsPage('Lecturers', Icons.school_outlined),
  _OpsPage('Courses', Icons.menu_book_outlined),
  _OpsPage('Level Coordinators', Icons.supervisor_account_outlined),
  _OpsPage('Students', Icons.groups_2_outlined),
  _OpsPage('Course Materials', Icons.cloud_upload_outlined),
  _OpsPage('Assessment & Exams', Icons.assignment_outlined),
  _OpsPage('Moderation Status', Icons.rule_folder_outlined),
  _OpsPage('Results', Icons.workspace_premium_outlined),
  _OpsPage('Settings', Icons.settings_outlined),
];

const _lecturerPages = [
  _OpsPage('My Courses', Icons.dashboard_outlined),
  _OpsPage('Course Materials', Icons.upload_file_outlined),
  _OpsPage('Video Lectures', Icons.video_library_outlined),
  _OpsPage('Live Classes', Icons.live_tv_outlined),
  _OpsPage('Assignments', Icons.assignment_ind_outlined),
  _OpsPage('Quizzes & Tests', Icons.quiz_outlined),
  _OpsPage('Exam Questions', Icons.rule_folder_outlined),
  _OpsPage('Student Engagement', Icons.groups_2_outlined),
  _OpsPage('Marking & Grading', Icons.edit_note_outlined),
  _OpsPage('Results Submission', Icons.publish_outlined),
  _OpsPage('Messages / Q&A', Icons.forum_outlined),
  _OpsPage('Profile', Icons.person_outline),
];

const _levelAdviserPages = [
  _OpsPage('Overview', Icons.dashboard_outlined),
  _OpsPage('My Students', Icons.groups_2_outlined),
  _OpsPage('Course Registration', Icons.app_registration_outlined),
  _OpsPage('Student Progress', Icons.trending_up_outlined),
  _OpsPage('Attendance & Participation', Icons.fact_check_outlined),
  _OpsPage('Exam Eligibility', Icons.assignment_turned_in_outlined),
  _OpsPage('Complaints', Icons.support_agent_outlined),
  _OpsPage('Messages / Announcements', Icons.campaign_outlined),
  _OpsPage('Reports', Icons.analytics_outlined),
  _OpsPage('Profile', Icons.person_outline),
];

const _examOfficerPages = [
  _OpsPage('Exam Overview', Icons.dashboard_outlined),
  _OpsPage('Course Exam Readiness', Icons.fact_check_outlined),
  _OpsPage('Question Submission', Icons.quiz_outlined),
  _OpsPage('Moderation Tracking', Icons.rule_folder_outlined),
  _OpsPage('Exam Timetable', Icons.event_available_outlined),
  _OpsPage('Student Eligibility', Icons.groups_2_outlined),
  _OpsPage('Result Collection', Icons.inbox_outlined),
  _OpsPage('Result Verification', Icons.workspace_premium_outlined),
  _OpsPage('Exam Complaints', Icons.support_agent_outlined),
  _OpsPage('Reports', Icons.analytics_outlined),
  _OpsPage('Profile', Icons.person_outline),
];

const _moderatorPages = [
  _OpsPage('Review Dashboard', Icons.dashboard_outlined),
  _OpsPage('Question Papers', Icons.rule_folder_outlined),
  _OpsPage('Returned Papers', Icons.assignment_return_outlined),
  _OpsPage('Review History', Icons.manage_history_outlined),
  _OpsPage('Profile', Icons.person_outline),
];

const _invigilatorPages = [
  _OpsPage('Live Student Grid', Icons.grid_view_outlined),
  _OpsPage('AI Alert Queue', Icons.notification_important_outlined),
  _OpsPage('Evidence Review', Icons.perm_media_outlined),
  _OpsPage('Manual Decisions', Icons.fact_check_outlined),
  _OpsPage('Student Session Detail', Icons.person_search_outlined),
  _OpsPage('Room Scan Requests', Icons.video_camera_front_outlined),
  _OpsPage('Attendance & Check-in', Icons.how_to_reg_outlined),
  _OpsPage('Risk Timeline', Icons.timeline_outlined),
  _OpsPage('Malpractice Drafts', Icons.gpp_maybe_outlined),
  _OpsPage('Evidence Sync Status', Icons.cloud_sync_outlined),
  _OpsPage('Audit Trail', Icons.manage_history_outlined),
];

const _academicRecordsPages = [
  _OpsPage('Student Records', Icons.badge_outlined),
  _OpsPage('Admission / Matriculation', Icons.how_to_reg_outlined),
  _OpsPage('Course Registration Records', Icons.app_registration_outlined),
  _OpsPage('Programme & Level Records', Icons.account_tree_outlined),
  _OpsPage('Result Records', Icons.workspace_premium_outlined),
  _OpsPage('Carryover / Repeat Courses', Icons.repeat_outlined),
  _OpsPage('Academic Standing', Icons.trending_up_outlined),
  _OpsPage('Transcript Records', Icons.description_outlined),
  _OpsPage('Graduation / Clearance', Icons.verified_outlined),
  _OpsPage('Corrections & Audit Trail', Icons.manage_history_outlined),
  _OpsPage('Reports', Icons.analytics_outlined),
  _OpsPage('Profile', Icons.person_outline),
];

const _supportPages = [
  _OpsPage('Support Dashboard', Icons.support_agent_outlined),
  _OpsPage('Open Tickets', Icons.mark_unread_chat_alt_outlined),
  _OpsPage('Academic Support Routing', Icons.alt_route_outlined),
  _OpsPage('Technical Issues', Icons.build_circle_outlined),
  _OpsPage('SLA Activity', Icons.timer_outlined),
  _OpsPage('Support Settings', Icons.settings_outlined),
];

const _reportPages = [
  _OpsPage('Reports Dashboard', Icons.analytics_outlined),
  _OpsPage('Management Reports', Icons.summarize_outlined),
  _OpsPage('Student Participation', Icons.groups_2_outlined),
  _OpsPage('Lecturer Performance', Icons.school_outlined),
  _OpsPage('Course Readiness', Icons.fact_check_outlined),
  _OpsPage('Exports', Icons.download_outlined),
];

bool _usesSectionOnlyWorkspace(AdminRole role) {
  switch (role) {
    case AdminRole.dlcDirector:
    case AdminRole.departmentAdmin:
    case AdminRole.facultyAdmin:
    case AdminRole.hod:
    case AdminRole.moderator:
    case AdminRole.lecturer:
    case AdminRole.levelAdviser:
    case AdminRole.examOfficer:
    case AdminRole.invigilator:
    case AdminRole.recordsDepartment:
    case AdminRole.supportTeam:
    case AdminRole.reportsTeam:
    case AdminRole.superAdmin:
      return true;
  }
}

List<_OpsPage> _pagesForRole(AdminRole role) {
  if (role == AdminRole.hod) {
    return _hodPages;
  }
  if (role == AdminRole.lecturer) {
    return _lecturerPages;
  }
  if (role == AdminRole.levelAdviser) {
    return _levelAdviserPages;
  }
  if (role == AdminRole.examOfficer) {
    return _examOfficerPages;
  }
  if (role == AdminRole.moderator) {
    return _moderatorPages;
  }
  if (role == AdminRole.invigilator) {
    return _invigilatorPages;
  }
  if (role == AdminRole.recordsDepartment) {
    return _academicRecordsPages;
  }
  if (role == AdminRole.supportTeam) {
    return _supportPages;
  }
  if (role == AdminRole.reportsTeam) {
    return _reportPages;
  }
  return _operationsPages;
}

String _workspaceTitleForRole(AdminRole role) {
  if (role == AdminRole.hod) {
    return 'HoD Workspace';
  }
  if (role == AdminRole.lecturer) {
    return 'Lecturer Workspace';
  }
  if (role == AdminRole.moderator) {
    return 'Moderator';
  }
  if (role == AdminRole.moderator) {
    return 'Moderator';
  }
  if (role == AdminRole.levelAdviser) {
    return 'Level Adviser Workspace';
  }
  if (role == AdminRole.examOfficer) {
    return 'Departmental Exam Officer';
  }
  if (role == AdminRole.invigilator) {
    return 'Invigilator Dashboard';
  }
  if (role == AdminRole.recordsDepartment) {
    return 'Academic Records';
  }
  if (role == AdminRole.supportTeam) {
    return 'Support Team Workspace';
  }
  if (role == AdminRole.reportsTeam) {
    return 'Reports Team Workspace';
  }
  if (role == AdminRole.dlcDirector) {
    return 'DLC Director';
  }
  return 'KSLAS Admin';
}

String _workspaceSubtitleForRole(AdminRole role) {
  if (role == AdminRole.hod) {
    return 'Department academic control';
  }
  if (role == AdminRole.lecturer) {
    return 'Assigned course delivery';
  }
  if (role == AdminRole.moderator) {
    return 'Question review and quality checks';
  }
  if (role == AdminRole.moderator) {
    return 'Question review and quality checks';
  }
  if (role == AdminRole.levelAdviser) {
    return 'Assigned level student monitoring';
  }
  if (role == AdminRole.examOfficer) {
    return 'Operational department exam coordination';
  }
  if (role == AdminRole.invigilator) {
    return 'Assigned exam monitoring, evidence review, check-in, and incident decisions only';
  }
  if (role == AdminRole.recordsDepartment) {
    return 'Official student academic records custody';
  }
  if (role == AdminRole.supportTeam) {
    return 'Private support and helpdesk route';
  }
  if (role == AdminRole.reportsTeam) {
    return 'Private reports and analytics route';
  }
  if (role == AdminRole.dlcDirector) {
    return 'Distance Learning command centre';
  }
  return 'Non-student operations';
}

IconData _workspaceIconForRole(AdminRole role) {
  if (role == AdminRole.hod) {
    return Icons.account_tree_outlined;
  }
  if (role == AdminRole.lecturer) {
    return Icons.school_outlined;
  }
  if (role == AdminRole.moderator) {
    return Icons.rule_folder_outlined;
  }
  if (role == AdminRole.moderator) {
    return Icons.rule_folder_outlined;
  }
  if (role == AdminRole.levelAdviser) {
    return Icons.person_search_outlined;
  }
  if (role == AdminRole.examOfficer) {
    return Icons.assignment_turned_in_outlined;
  }
  if (role == AdminRole.invigilator) {
    return Icons.verified_user_outlined;
  }
  if (role == AdminRole.recordsDepartment) {
    return Icons.badge_outlined;
  }
  if (role == AdminRole.supportTeam) {
    return Icons.support_agent_outlined;
  }
  if (role == AdminRole.reportsTeam) {
    return Icons.analytics_outlined;
  }
  if (role == AdminRole.dlcDirector) {
    return Icons.cast_for_education_outlined;
  }
  return Icons.account_balance_outlined;
}

class AdminOperationsShell extends StatefulWidget {
  const AdminOperationsShell({
    super.key,
    this.initialRole,
    this.lockRole = false,
  });

  final AdminRole? initialRole;
  final bool lockRole;

  @override
  State<AdminOperationsShell> createState() => _AdminOperationsShellState();
}

class _AdminOperationsShellState extends State<AdminOperationsShell> {
  final MockAdminRepository _repository = const MockAdminRepository();
  late AdminRole _selectedRole;
  int _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? AdminRole.dlcDirector;
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 800;
    final pages = _pagesForRole(_selectedRole);
    return Scaffold(
      appBar: compact
          ? AppBar(
              title: const Text('KSLAS Admin'),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout_outlined),
                ),
              ],
            )
          : null,
      drawer: compact && !widget.lockRole
          ? _RoleDrawer(selectedRole: _selectedRole, onRoleChanged: _changeRole)
          : null,
      body: Row(
        children: [
          if (!compact)
            _AdminSideBar(
              selectedPage: _selectedPage,
              selectedRole: _selectedRole,
              pages: pages,
              onPageChanged: (value) => setState(() => _selectedPage = value),
              onRoleChanged: _changeRole,
              lockRole: widget.lockRole,
              onLogout: _signOut,
            ),
          Expanded(
            child: _AdminOperationsWorkspace(
              pageLabel: pages[_selectedPage].label,
              selectedRole: _selectedRole,
              repository: _repository,
              compact: compact,
            ),
          ),
        ],
      ),
      bottomNavigationBar: compact
          ? NavigationBar(
              selectedIndex: _selectedPage > 4 ? 4 : _selectedPage,
              onDestinationSelected: (value) =>
                  setState(() => _selectedPage = value),
              destinations: [
                for (final page in pages.take(5))
                  NavigationDestination(
                    icon: Icon(page.icon),
                    label: page.label,
                  ),
              ],
            )
          : null,
    );
  }

  void _changeRole(AdminRole role) {
    if (widget.lockRole) return;
    setState(() {
      _selectedRole = role;
      _selectedPage = 0;
    });
  }

  Future<void> _signOut() async {
    await AuthSession.instance.signOut();
  }
}

class _AdminSideBar extends StatelessWidget {
  const _AdminSideBar({
    required this.selectedPage,
    required this.selectedRole,
    required this.pages,
    required this.onPageChanged,
    required this.onRoleChanged,
    required this.lockRole,
    required this.onLogout,
  });

  final int selectedPage;
  final AdminRole selectedRole;
  final List<_OpsPage> pages;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<AdminRole> onRoleChanged;
  final bool lockRole;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 310,
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: Icon(_workspaceIconForRole(selectedRole)),
              ),
              title: Text(
                _workspaceTitleForRole(selectedRole),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(_workspaceSubtitleForRole(selectedRole)),
              trailing: IconButton(
                tooltip: 'Sign out',
                onPressed: onLogout,
                icon: const Icon(Icons.logout_outlined),
              ),
            ),
            const SizedBox(height: 10),
            if (!lockRole) ...[
              DropdownButtonFormField<AdminRole>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Workspace role',
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                ),
                items: [
                  for (final role in AdminRole.values)
                    DropdownMenuItem(value: role, child: Text(role.label)),
                ],
                onChanged: (role) {
                  if (role != null) onRoleChanged(role);
                },
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 16),
            for (var i = 0; i < pages.length; i++)
              _NavigationTile(
                page: pages[i],
                selected: selectedPage == i,
                onTap: () => onPageChanged(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final _OpsPage page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(page.icon),
      title: Text(page.label),
      onTap: onTap,
    );
  }
}

class _RoleDrawer extends StatelessWidget {
  const _RoleDrawer({required this.selectedRole, required this.onRoleChanged});

  final AdminRole selectedRole;
  final ValueChanged<AdminRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Switch workspace',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final role in AdminRole.values)
              RadioListTile<AdminRole>(
                value: role,
                // ignore: deprecated_member_use
                groupValue: selectedRole,
                // ignore: deprecated_member_use
                onChanged: (role) {
                  if (role != null) {
                    onRoleChanged(role);
                    Navigator.of(context).maybePop();
                  }
                },
                title: Text(role.label),
                subtitle: Text(role.scope),
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminOperationsWorkspace extends StatelessWidget {
  const _AdminOperationsWorkspace({
    required this.pageLabel,
    required this.selectedRole,
    required this.repository,
    required this.compact,
  });

  final String pageLabel;
  final AdminRole selectedRole;
  final MockAdminRepository repository;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final metrics = repository.metricsFor(selectedRole);
    final tasks = repository.tasksFor(selectedRole, pageLabel: pageLabel);
    final workflows = repository.workflowsFor(pageLabel, role: selectedRole);
    final width = MediaQuery.sizeOf(context).width;
    final sectionOnly = _usesSectionOnlyWorkspace(selectedRole);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          if (!sectionOnly) ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 28,
                compact ? 8 : 24,
                compact ? 16 : 28,
                16,
              ),
              sliver: SliverToBoxAdapter(
                child: _Header(role: selectedRole, pageLabel: pageLabel),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 28),
              sliver: SliverGrid.builder(
                itemCount: metrics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: compact
                      ? 1
                      : width > 1180
                      ? 4
                      : 2,
                  mainAxisExtent: AdminMetricCard.gridExtent,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) =>
                    AdminMetricCard(metric: metrics[index]),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 28,
                18,
                compact ? 16 : 28,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _WorkflowPanel(workflows: workflows),
              ),
            ),
          ],
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 28,
              sectionOnly
                  ? compact
                        ? 8
                        : 24
                  : compact
                  ? 16
                  : 28,
              compact ? 16 : 28,
              compact ? 16 : 28,
            ),
            sliver: SliverToBoxAdapter(
              child: _PrimaryPanel(
                pageLabel: pageLabel,
                selectedRole: selectedRole,
                tasks: tasks,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryPanel extends StatelessWidget {
  const _PrimaryPanel({
    required this.pageLabel,
    required this.selectedRole,
    required this.tasks,
  });

  final String pageLabel;
  final AdminRole selectedRole;
  final List<AdminTask> tasks;

  @override
  Widget build(BuildContext context) {
    if (selectedRole == AdminRole.supportTeam &&
        _supportPages.any((page) => page.label == pageLabel)) {
      return const StudentSupportHelpdeskPanel();
    }
    if (selectedRole == AdminRole.reportsTeam &&
        _reportPages.any((page) => page.label == pageLabel)) {
      return const ReportsAnalyticsPanel();
    }

    if (selectedRole == AdminRole.levelAdviser) {
      if (pageLabel == 'Overview') {
        return const LevelAdviserOverviewPanel();
      }
      if (pageLabel == 'My Students' ||
          pageLabel == 'Student Progress' ||
          pageLabel == 'Attendance & Participation' ||
          pageLabel == 'Exam Eligibility') {
        return const RecordsDepartmentPanel();
      }
      if (pageLabel == 'Course Registration') {
        return const CourseRegistrationApprovalPanel();
      }
      return _TaskPanel(tasks: tasks);
    }

    if (selectedRole == AdminRole.lecturer) {
      if (pageLabel == 'My Courses') {
        return const LecturerCourseOverviewPanel();
      }
      if (pageLabel == 'Exam Questions') {
        return const LecturerQuestionLivePanel();
      }
      if (pageLabel == 'Course Materials' ||
          pageLabel == 'Video Lectures' ||
          pageLabel == 'Live Classes' ||
          pageLabel == 'Assignments' ||
          pageLabel == 'Quizzes & Tests' ||
          pageLabel == 'Student Engagement' ||
          pageLabel == 'Messages / Q&A' ||
          pageLabel == 'Profile') {
        return LecturerCourseDeliveryFlowPanel(section: pageLabel);
      }
      if (pageLabel == 'Marking & Grading' ||
          pageLabel == 'Results Submission') {
        return LecturerAssignmentsMarkingPanel(section: pageLabel);
      }
      return _TaskPanel(tasks: tasks);
    }

    if (selectedRole == AdminRole.moderator) {
      if (pageLabel == 'Review Dashboard' ||
          pageLabel == 'Question Papers' ||
          pageLabel == 'Returned Papers' ||
          pageLabel == 'Review History') {
        return const ModeratorQuestionReviewPanel(
          mode: QuestionReviewMode.moderator,
        );
      }
      if (pageLabel == 'Profile') {
        return _TaskPanel(tasks: tasks);
      }
      return const ModeratorQuestionReviewPanel(
        mode: QuestionReviewMode.moderator,
      );
    }

    if (selectedRole == AdminRole.invigilator) {
      if (_invigilatorPages.any((page) => page.label == pageLabel)) {
        return InvigilatorEvidenceReviewPanel(section: pageLabel);
      }
      return _TaskPanel(tasks: tasks);
    }

    if (selectedRole == AdminRole.examOfficer) {
      if (pageLabel == 'Exam Overview') {
        return const DepartmentalExamOfficerOverviewPanel();
      }
      if (pageLabel == 'Course Exam Readiness' ||
          pageLabel == 'Exam Timetable') {
        return const ExamManagementPanel();
      }
      if (pageLabel == 'Question Submission' ||
          pageLabel == 'Moderation Tracking') {
        return const ModeratorQuestionReviewPanel(
          mode: QuestionReviewMode.examOfficer,
        );
      }
      if (pageLabel == 'Student Eligibility' ||
          pageLabel == 'Result Collection' ||
          pageLabel == 'Result Verification') {
        return const ResultsApprovalReleasePanel();
      }
      return _TaskPanel(tasks: tasks);
    }

    if (selectedRole == AdminRole.recordsDepartment) {
      if (pageLabel == 'Student Records') {
        return const AcademicRecordsOverviewPanel();
      }
      if (pageLabel == 'Course Registration Records' ||
          pageLabel == 'Programme & Level Records' ||
          pageLabel == 'Carryover / Repeat Courses' ||
          pageLabel == 'Academic Standing' ||
          pageLabel == 'Transcript Records' ||
          pageLabel == 'Graduation / Clearance' ||
          pageLabel == 'Corrections & Audit Trail') {
        return const RecordsDepartmentPanel();
      }
      if (pageLabel == 'Result Records') {
        return const ResultsApprovalReleasePanel();
      }
      return _TaskPanel(tasks: tasks);
    }

    if (selectedRole == AdminRole.dlcDirector &&
        _operationsPages.any((page) => page.label == pageLabel)) {
      return DlcDirectorSectionPanel(section: pageLabel);
    }
    if (pageLabel == 'Department Overview') {
      return const HodDepartmentOverviewPanel();
    }
    if (pageLabel == 'Departments & Programmes') {
      return const AcademicSetupPanel();
    }
    if (pageLabel == 'Student Management') {
      return const CohortManagementPanel();
    }
    if (pageLabel == 'Students') {
      return const RecordsDepartmentPanel();
    }
    if (pageLabel == 'Course Management') {
      return const AcademicSetupPanel();
    }
    if (pageLabel == 'Courses') {
      return const CourseRegistrationApprovalPanel();
    }
    if (pageLabel == 'Lecturer Monitoring') {
      return const LecturerAssignmentsMarkingPanel();
    }
    if (pageLabel == 'Lecturers' || pageLabel == 'Course Materials') {
      return const LecturerAssignmentsMarkingPanel();
    }
    if (pageLabel == 'Exams & Assessments') {
      return const ExamManagementPanel();
    }
    if (pageLabel == 'Assessment & Exams') {
      return const ExamManagementPanel();
    }
    if (pageLabel == 'System Activity') {
      return const ExamSessionsOverviewPanel();
    }
    if (pageLabel == 'Level Coordinators') {
      return const CohortManagementPanel();
    }
    if (pageLabel == 'Records') {
      return const RecordsDepartmentPanel();
    }
    if (pageLabel == 'Approvals') {
      return const ModeratorQuestionReviewPanel(
        mode: QuestionReviewMode.examOfficer,
      );
    }
    if (pageLabel == 'Moderation Status') {
      return const ModeratorQuestionReviewPanel(
        mode: QuestionReviewMode.examOfficer,
      );
    }
    if (pageLabel == 'Results') {
      return const ResultsApprovalReleasePanel();
    }
    if (pageLabel == 'Staff Management') {
      return const StaffManagementPanel();
    }
    return _TaskPanel(tasks: tasks);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.role, required this.pageLabel});

  final AdminRole role;
  final String pageLabel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pageLabel, style: text.labelLarge),
              const SizedBox(height: 4),
              Text(
                '${role.label} workspace',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(role.scope, style: text.bodyLarge),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_task_outlined),
          label: Text(pageLabel == 'Notices' ? 'Publish notice' : 'New action'),
        ),
      ],
    );
  }
}

class _WorkflowPanel extends StatelessWidget {
  const _WorkflowPanel({required this.workflows});

  final List<String> workflows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workspace coverage',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final workflow in workflows)
                  Chip(
                    avatar: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(workflow),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskPanel extends StatelessWidget {
  const _TaskPanel({required this.tasks});

  final List<AdminTask> tasks;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority work queue',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final task in tasks) _TaskTile(task: task),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final AdminTask task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = task.status.color(scheme);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(task.ownerRole.icon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(task.description),
                const SizedBox(height: 4),
                Text(
                  '${task.ownerRole.label} • ${task.due}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          _StatusPill(status: task.status),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final WorkStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color(Theme.of(context).colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          status.label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _OpsPage {
  const _OpsPage(this.label, this.icon);

  final String label;
  final IconData icon;
}
