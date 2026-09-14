import 'package:flutter/material.dart';

import '../models/admin_role.dart';
import '../models/dashboard_models.dart';

class MockAdminRepository {
  const MockAdminRepository();

  List<AdminMetric> metricsFor(AdminRole role) {
    if (role == AdminRole.lecturer) {
      return const [
        AdminMetric(
          label: 'Assigned Courses',
          value: '3',
          detail: 'Courses assigned by HoD, coordinator, or DLC admin',
          icon: Icons.menu_book_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Course Students',
          value: '804',
          detail: 'Students enrolled across assigned DLC courses',
          icon: Icons.groups_2_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Materials Uploaded',
          value: '31/38',
          detail: 'Outlines, notes, slides, guides, and reading links',
          icon: Icons.upload_file_outlined,
          status: WorkStatus.complete,
        ),
        AdminMetric(
          label: 'Video Lectures',
          value: '24/34',
          detail: 'Published videos, views, and completion tracking',
          icon: Icons.video_library_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Pending Marking',
          value: '116',
          detail: 'Assignments, essays, practical work, and exam scripts',
          icon: Icons.edit_note_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Exam Questions',
          value: '4',
          detail: 'Drafts, marking guides, moderation, and corrections',
          icon: Icons.quiz_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Student Questions',
          value: '19',
          detail: 'Course forum, Q&A, and private academic messages',
          icon: Icons.forum_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Scores Submitted',
          value: '8/12',
          detail: 'CA, quiz, exam, and final course scores submitted',
          icon: Icons.publish_outlined,
          status: WorkStatus.normal,
        ),
      ];
    }

    if (role == AdminRole.recordsDepartment) {
      return const [
        AdminMetric(
          label: 'Total DLC Students',
          value: '18,420',
          detail:
              'Official student academic profiles and matriculation records',
          icon: Icons.badge_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Complete Registration',
          value: '17,642',
          detail: 'Students with official semester course registration records',
          icon: Icons.app_registration_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Approved Results',
          value: '2,184',
          detail: 'Approved result records stored after academic workflow',
          icon: Icons.workspace_premium_outlined,
          status: WorkStatus.complete,
        ),
        AdminMetric(
          label: 'Pending Results',
          value: '276',
          detail: 'Awaiting approved departmental, faculty, or senate status',
          icon: Icons.pending_actions_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Missing Results',
          value: '43',
          detail: 'Missing CA, exam score, grade, or approved result records',
          icon: Icons.rule_folder_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Carryover Cases',
          value: '780',
          detail:
              'Failed, repeat, outstanding, spillover, and missing-grade cases',
          icon: Icons.repeat_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Transcript Requests',
          value: '164',
          detail: 'Official transcript preparation and approval tracking',
          icon: Icons.description_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Correction Requests',
          value: '28',
          detail:
              'Logged corrections with reason, authority, and supporting documents',
          icon: Icons.manage_history_outlined,
          status: WorkStatus.urgent,
        ),
      ];
    }

    if (role == AdminRole.invigilator) {
      return const [
        AdminMetric(
          label: 'Assigned Rooms',
          value: '5',
          detail: '2 currently in progress',
          icon: Icons.meeting_room_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Check-ins',
          value: '487',
          detail: '96% verified',
          icon: Icons.how_to_reg_outlined,
          status: WorkStatus.complete,
        ),
        AdminMetric(
          label: 'Open Incidents',
          value: '3',
          detail: 'Needs closing notes',
          icon: Icons.gpp_maybe_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Device Flags',
          value: '12',
          detail: 'Review before submission',
          icon: Icons.devices_other_outlined,
          status: WorkStatus.warning,
        ),
      ];
    }

    if (role == AdminRole.moderator) {
      return const [
        AdminMetric(
          label: 'Question Sets',
          value: '14',
          detail: 'Awaiting moderation comments',
          icon: Icons.rule_folder_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Rubrics',
          value: '9',
          detail: 'Essay and practical marking rubrics to verify',
          icon: Icons.fact_check_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Returned to Lecturer',
          value: '3',
          detail: 'Needs correction before exam officer approval',
          icon: Icons.undo_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Approved',
          value: '28',
          detail: 'Ready for exam office packaging',
          icon: Icons.verified_outlined,
          status: WorkStatus.complete,
        ),
      ];
    }

    if (role == AdminRole.examOfficer) {
      return const [
        AdminMetric(
          label: 'Exam Courses',
          value: '32',
          detail: 'Departmental courses scheduled for exam',
          icon: Icons.menu_book_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Questions Submitted',
          value: '28',
          detail: '4 pending lecturer submissions',
          icon: Icons.quiz_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Questions Approved',
          value: '22',
          detail: '6 still awaiting moderation clearance',
          icon: Icons.verified_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Eligible Students',
          value: '1,180',
          detail: '70 students not yet eligible for exams',
          icon: Icons.fact_check_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Submitted Results',
          value: '18',
          detail: '14 result batches still pending from lecturers',
          icon: Icons.inbox_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Malpractice Cases',
          value: '4',
          detail: 'AI proctoring and invigilator evidence under review',
          icon: Icons.gpp_maybe_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Exam Complaints',
          value: '13',
          detail:
              'Access, allocation, submission, timer, and eligibility cases',
          icon: Icons.support_agent_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Timetable Status',
          value: '88%',
          detail: 'CBT, online, take-home, practical, and oral exam slots',
          icon: Icons.event_available_outlined,
          status: WorkStatus.normal,
        ),
      ];
    }

    if (role == AdminRole.dlcDirector) {
      return const [
        AdminMetric(
          label: 'Total Students',
          value: '12,480',
          detail: 'Active DLC learners across programmes and levels',
          icon: Icons.groups_2_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Total Lecturers',
          value: '184',
          detail: 'Assigned to courses, moderation, and live classes',
          icon: Icons.school_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Departments',
          value: '18',
          detail: 'DLC departments with active programme oversight',
          icon: Icons.account_tree_outlined,
          status: WorkStatus.complete,
        ),
        AdminMetric(
          label: 'Programmes',
          value: '42',
          detail: 'Undergraduate and professional distance programmes',
          icon: Icons.cast_for_education_outlined,
          status: WorkStatus.complete,
        ),
        AdminMetric(
          label: 'Pending Uploads',
          value: '37',
          detail: 'Lecture notes, videos, quizzes, and course materials',
          icon: Icons.cloud_upload_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Upcoming Exams',
          value: '23',
          detail: 'Timetable, moderation, proctoring, and CBT readiness',
          icon: Icons.event_available_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Complaints',
          value: '58',
          detail: 'Academic, payment, technical, and support cases',
          icon: Icons.support_agent_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Submitted Results',
          value: '71%',
          detail: 'Courses with lecturer, moderator, and HoD progress',
          icon: Icons.workspace_premium_outlined,
          status: WorkStatus.normal,
        ),
      ];
    }

    if (role == AdminRole.hod) {
      return const [
        AdminMetric(
          label: 'DLC Students',
          value: '1,250',
          detail: 'Computer Science students across 100L to 400L',
          icon: Icons.groups_2_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Department Lecturers',
          value: '18',
          detail: 'Lecturers assigned to DLC departmental courses',
          icon: Icons.school_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Department Courses',
          value: '42',
          detail: '35 active and 7 pending departmental courses',
          icon: Icons.menu_book_outlined,
          status: WorkStatus.complete,
        ),
        AdminMetric(
          label: 'Missing Materials',
          value: '7',
          detail: 'Courses without complete notes, outlines, or guides',
          icon: Icons.cloud_off_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Pending Videos',
          value: '72',
          detail: 'Expected video lectures not uploaded by lecturers',
          icon: Icons.video_library_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Awaiting Moderation',
          value: '11',
          detail: 'Questions, rubrics, and assessments with moderators',
          icon: Icons.rule_folder_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Results Pending',
          value: '15',
          detail: 'Courses not yet ready for departmental review',
          icon: Icons.workspace_premium_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Academic Complaints',
          value: '24',
          detail: 'Missing score, registration, lecturer, and assessment cases',
          icon: Icons.support_agent_outlined,
          status: WorkStatus.urgent,
        ),
      ];
    }

    if (role == AdminRole.levelAdviser) {
      return const [
        AdminMetric(
          label: 'Assigned Level',
          value: '200L',
          detail: 'Computer Science DLC students assigned to this adviser',
          icon: Icons.person_search_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Total Students',
          value: '420',
          detail: '390 active and 30 inactive students',
          icon: Icons.groups_2_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Registration Issues',
          value: '18',
          detail: 'Incomplete, wrong, missing, or awaiting approval cases',
          icon: Icons.app_registration_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Exam Not Eligible',
          value: '22',
          detail:
              'Students missing registration, quizzes, assignments, or participation',
          icon: Icons.assignment_late_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'Open Complaints',
          value: '11',
          detail: 'Academic complaints for assigned level only',
          icon: Icons.support_agent_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Assignment Participation',
          value: '83%',
          detail: 'Submission rate across assigned level courses',
          icon: Icons.assignment_turned_in_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Quiz Participation',
          value: '80%',
          detail: 'Quiz attempts and missed assessment checks',
          icon: Icons.quiz_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'At-Risk Students',
          value: '34',
          detail: 'Inactive, low participation, or unresolved academic issues',
          icon: Icons.flag_outlined,
          status: WorkStatus.urgent,
        ),
      ];
    }

    if (role == AdminRole.supportTeam) {
      return const [
        AdminMetric(
          label: 'Open Tickets',
          value: '58',
          detail: 'Academic, technical, access, and escalation tickets',
          icon: Icons.mark_unread_chat_alt_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Urgent Cases',
          value: '9',
          detail: 'Missing score, exam incident, and access escalations',
          icon: Icons.priority_high_outlined,
          status: WorkStatus.urgent,
        ),
        AdminMetric(
          label: 'SLA On Track',
          value: '86%',
          detail: 'Tickets handled within current support targets',
          icon: Icons.timer_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Resolved Today',
          value: '34',
          detail: 'Closed support cases with audit notes',
          icon: Icons.check_circle_outline,
          status: WorkStatus.complete,
        ),
      ];
    }

    if (role == AdminRole.reportsTeam) {
      return const [
        AdminMetric(
          label: 'Scheduled Reports',
          value: '18',
          detail: 'Management, academic, support, and activity reports',
          icon: Icons.summarize_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Exports Ready',
          value: '11',
          detail: 'PDF, Excel, and CSV report packages',
          icon: Icons.download_outlined,
          status: WorkStatus.complete,
        ),
        AdminMetric(
          label: 'Pending Reviews',
          value: '6',
          detail: 'Reports waiting for data-quality checks',
          icon: Icons.fact_check_outlined,
          status: WorkStatus.warning,
        ),
        AdminMetric(
          label: 'Data Alerts',
          value: '3',
          detail: 'Missing activity, result, or support data signals',
          icon: Icons.report_problem_outlined,
          status: WorkStatus.urgent,
        ),
      ];
    }

    return const [
      AdminMetric(
        label: 'Active Exams',
        value: '18',
        detail: '4 running now',
        icon: Icons.event_available_outlined,
        status: WorkStatus.normal,
      ),
      AdminMetric(
        label: 'Pending Approvals',
        value: '27',
        detail: 'Notices, registration, results and exam actions',
        icon: Icons.fact_check_outlined,
        status: WorkStatus.warning,
      ),
      AdminMetric(
        label: 'Incident Reports',
        value: '3',
        detail: '1 escalated',
        icon: Icons.report_problem_outlined,
        status: WorkStatus.urgent,
      ),
      AdminMetric(
        label: 'Released Results',
        value: '64%',
        detail: '12 courses published',
        icon: Icons.workspace_premium_outlined,
        status: WorkStatus.complete,
      ),
    ];
  }

  List<AdminTask> tasksFor(AdminRole role, {required String pageLabel}) {
    if (role == AdminRole.dlcDirector) {
      switch (pageLabel) {
        case 'Staff Management':
          return const [
            AdminTask(
              title: 'Approve new DLC quality assurance officer account',
              ownerRole: AdminRole.dlcDirector,
              due: 'Today, 11:30 AM',
              status: WorkStatus.warning,
              description:
                  'Confirm department scope, programme access, and reporting permissions.',
            ),
            AdminTask(
              title: 'Reset access for inactive level coordinator',
              ownerRole: AdminRole.departmentAdmin,
              due: 'Today, 2:00 PM',
              status: WorkStatus.urgent,
              description:
                  'Coordinator has not logged in during course registration week.',
            ),
          ];
        case 'Lecturer Monitoring':
          return const [
            AdminTask(
              title: 'Escalate lecturers with missing video lectures',
              ownerRole: AdminRole.lecturer,
              due: 'Today',
              status: WorkStatus.urgent,
              description:
                  'Nine courses have fewer than half of expected video lectures uploaded.',
            ),
            AdminTask(
              title: 'Review lecturer engagement report',
              ownerRole: AdminRole.dlcDirector,
              due: 'Tomorrow',
              status: WorkStatus.warning,
              description:
                  'Compare notes, videos, quizzes, assignments, and student engagement.',
            ),
          ];
        case 'Exams & Assessments':
          return const [
            AdminTask(
              title: 'Coordinate DLC exam readiness approval',
              ownerRole: AdminRole.examOfficer,
              due: 'Today, 4:00 PM',
              status: WorkStatus.warning,
              description:
                  'Confirm question moderation, proctoring setup, CBT support, and timetable coverage.',
            ),
            AdminTask(
              title: 'Investigate incomplete 300L timetable',
              ownerRole: AdminRole.departmentAdmin,
              due: 'Today',
              status: WorkStatus.urgent,
              description:
                  'Computer Science 300L still has two courses without exam slots.',
            ),
          ];
        case 'Approvals':
          return const [
            AdminTask(
              title: 'Approve course activation batch',
              ownerRole: AdminRole.dlcDirector,
              due: 'Today, 3:00 PM',
              status: WorkStatus.warning,
              description:
                  'Courses require lecturer, moderator, assessment, and exam readiness checks.',
            ),
            AdminTask(
              title: 'Review special student cases',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Tomorrow',
              status: WorkStatus.normal,
              description:
                  'Coordinate without bypassing HoD, moderator, exam officer, and records authority.',
            ),
          ];
      }
    }

    if (role == AdminRole.hod) {
      switch (pageLabel) {
        case 'Lecturers':
          return const [
            AdminTask(
              title: 'Assign lecturer to CSC 301 Distributed Systems',
              ownerRole: AdminRole.hod,
              due: 'Today, 12:00 PM',
              status: WorkStatus.warning,
              description:
                  'Course is active but still missing a confirmed lecturer and coordinator.',
            ),
            AdminTask(
              title: 'Follow up delayed lecturer uploads',
              ownerRole: AdminRole.lecturer,
              due: 'Today',
              status: WorkStatus.urgent,
              description:
                  'Three lecturers have pending notes, videos, or quizzes for active DLC courses.',
            ),
          ];
        case 'Courses':
        case 'Course Materials':
          return const [
            AdminTask(
              title: 'Flag CSC 205 course outline as incomplete',
              ownerRole: AdminRole.hod,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Course outline is missing before departmental readiness sign-off.',
            ),
            AdminTask(
              title: 'Review CSC 102 lecture notes awaiting approval',
              ownerRole: AdminRole.moderator,
              due: 'Tomorrow',
              status: WorkStatus.normal,
              description:
                  'Moderator feedback is ready for HoD academic quality review.',
            ),
          ];
        case 'Assessment & Exams':
        case 'Moderation Status':
          return const [
            AdminTask(
              title: 'Review pending CSC 301 exam questions',
              ownerRole: AdminRole.hod,
              due: 'Today, 3:00 PM',
              status: WorkStatus.urgent,
              description:
                  'Lecturer submission is late and moderation cannot start.',
            ),
            AdminTask(
              title: 'Confirm BUS 101 moderation handoff',
              ownerRole: AdminRole.moderator,
              due: 'Tomorrow',
              status: WorkStatus.warning,
              description:
                  'HoD review is required before exam officer packaging.',
            ),
          ];
        case 'Results':
          return const [
            AdminTask(
              title: 'Review departmental result summary',
              ownerRole: AdminRole.hod,
              due: 'Today, 4:00 PM',
              status: WorkStatus.warning,
              description:
                  'Check missing scores, pass rate, failed students, and irregular result patterns.',
            ),
            AdminTask(
              title: 'Recommend approved result batch to exam officer',
              ownerRole: AdminRole.examOfficer,
              due: 'Friday',
              status: WorkStatus.normal,
              description:
                  'Preserve lecturer, moderator, HoD, exam officer, and senate workflow.',
            ),
          ];
      }
    }

    if (role == AdminRole.lecturer) {
      switch (pageLabel) {
        case 'Course Materials':
          return const [
            AdminTask(
              title: 'Upload CSC 305 course outline correction',
              ownerRole: AdminRole.lecturer,
              due: 'Today, 1:00 PM',
              status: WorkStatus.warning,
              description:
                  'Moderator requested an updated outline before publication.',
            ),
            AdminTask(
              title: 'Publish Week 6 database indexing slides',
              ownerRole: AdminRole.lecturer,
              due: 'Tomorrow',
              status: WorkStatus.normal,
              description:
                  'Slides and reading links are ready for student access.',
            ),
          ];
        case 'Video Lectures':
        case 'Live Classes':
          return const [
            AdminTask(
              title: 'Upload Week 4 CSC 411 practical video',
              ownerRole: AdminRole.lecturer,
              due: 'Today',
              status: WorkStatus.urgent,
              description:
                  'Video lecture is required before the weekend live class.',
            ),
            AdminTask(
              title: 'Schedule CSC 201 live class on recursion',
              ownerRole: AdminRole.lecturer,
              due: 'Tomorrow, 10:00 AM',
              status: WorkStatus.warning,
              description: 'Attach notes and enable attendance tracking.',
            ),
          ];
        case 'Assignments':
        case 'Quizzes & Tests':
          return const [
            AdminTask(
              title: 'Create CSC 305 Assignment 3 rubric',
              ownerRole: AdminRole.lecturer,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Include marks, late rule, essay response, and file upload settings.',
            ),
            AdminTask(
              title: 'Review quiz auto-marking exceptions',
              ownerRole: AdminRole.lecturer,
              due: 'Friday',
              status: WorkStatus.normal,
              description:
                  'Short answer and essay questions require manual marking.',
            ),
          ];
        case 'Exam Questions':
          return const [
            AdminTask(
              title: 'Submit CSC 201 exam questions for moderation',
              ownerRole: AdminRole.lecturer,
              due: 'Today, 4:00 PM',
              status: WorkStatus.urgent,
              description:
                  'Attach marking guide; final exam publication requires moderator, HoD, and exam officer workflow.',
            ),
            AdminTask(
              title: 'Respond to moderator correction comments',
              ownerRole: AdminRole.moderator,
              due: 'Tomorrow',
              status: WorkStatus.warning,
              description:
                  'Two essay questions need clearer scoring breakdown.',
            ),
          ];
        case 'Student Engagement':
        case 'Messages / Q&A':
          return const [
            AdminTask(
              title: 'Reply to CSC 305 student questions',
              ownerRole: AdminRole.lecturer,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Nineteen academic questions are waiting in course Q&A.',
            ),
            AdminTask(
              title: 'Follow up inactive students',
              ownerRole: AdminRole.levelAdviser,
              due: 'Tomorrow',
              status: WorkStatus.normal,
              description:
                  'Students missed videos, downloads, assignments, or quizzes.',
            ),
          ];
        case 'Marking & Grading':
        case 'Results Submission':
          return const [
            AdminTask(
              title: 'Mark pending CSC 305 theory exam scripts',
              ownerRole: AdminRole.lecturer,
              due: 'Today',
              status: WorkStatus.urgent,
              description:
                  'Objective scores are auto-marked; theory scripts need lecturer academic decision.',
            ),
            AdminTask(
              title: 'Submit CSC 201 CA and exam scores',
              ownerRole: AdminRole.lecturer,
              due: 'Friday',
              status: WorkStatus.warning,
              description:
                  'Scores move to moderator or HoD review before exam office processing.',
            ),
          ];
      }
    }

    if (role == AdminRole.levelAdviser) {
      switch (pageLabel) {
        case 'My Students':
          return const [
            AdminTask(
              title: 'Review 30 inactive 200L students',
              ownerRole: AdminRole.levelAdviser,
              due: 'Today',
              status: WorkStatus.urgent,
              description:
                  'Check login, video views, downloads, submissions, quiz attempts, and forum participation.',
            ),
            AdminTask(
              title: 'Flag students with weak academic standing',
              ownerRole: AdminRole.levelAdviser,
              due: 'Tomorrow',
              status: WorkStatus.warning,
              description:
                  'Prepare follow-up list before escalation to HoD or lecturer.',
            ),
          ];
        case 'Course Registration':
          return const [
            AdminTask(
              title: 'Resolve incomplete course registrations',
              ownerRole: AdminRole.levelAdviser,
              due: 'Today, 2:00 PM',
              status: WorkStatus.warning,
              description:
                  'Students with wrong, missing, or unapproved compulsory courses need academic guidance.',
            ),
            AdminTask(
              title: 'Escalate serious registration exceptions to HoD',
              ownerRole: AdminRole.hod,
              due: 'Tomorrow',
              status: WorkStatus.normal,
              description:
                  'Level adviser helps students fix academic issues, then escalates unresolved cases.',
            ),
          ];
        case 'Student Progress':
        case 'Attendance & Participation':
          return const [
            AdminTask(
              title: 'Follow up students below participation threshold',
              ownerRole: AdminRole.levelAdviser,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Participation includes login activity, video views, live class attendance, downloads, assignments, quizzes, and forum activity.',
            ),
            AdminTask(
              title: 'Send reminder to students who missed quizzes',
              ownerRole: AdminRole.levelAdviser,
              due: 'Tomorrow',
              status: WorkStatus.normal,
              description:
                  'Coordinate with course lecturers where assessment windows need clarification.',
            ),
          ];
        case 'Exam Eligibility':
          return const [
            AdminTask(
              title: 'Review 22 exam eligibility risks',
              ownerRole: AdminRole.levelAdviser,
              due: 'Today, 4:00 PM',
              status: WorkStatus.urgent,
              description:
                  'Check registration, assignments, quizzes, payment signal, participation, and serious academic issues.',
            ),
            AdminTask(
              title: 'Escalate unresolved exam cases',
              ownerRole: AdminRole.examOfficer,
              due: 'Friday',
              status: WorkStatus.warning,
              description:
                  'Exam eligibility issues move to exam officer or HoD after adviser review.',
            ),
          ];
        case 'Complaints':
          return const [
            AdminTask(
              title: 'Handle missing CA score complaint',
              ownerRole: AdminRole.levelAdviser,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Academic complaint should be routed to lecturer or HoD, not the private support team queue.',
            ),
            AdminTask(
              title: 'Forward technical access issue to ICT support',
              ownerRole: AdminRole.supportTeam,
              due: 'Today',
              status: WorkStatus.normal,
              description:
                  'Level adviser can escalate technical issues without viewing support team activity.',
            ),
          ];
        case 'Messages / Announcements':
          return const [
            AdminTask(
              title: 'Send course registration deadline notice',
              ownerRole: AdminRole.levelAdviser,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Message all 200L Computer Science DLC students before the Friday deadline.',
            ),
            AdminTask(
              title: 'Send exam readiness reminder',
              ownerRole: AdminRole.levelAdviser,
              due: 'Tomorrow',
              status: WorkStatus.normal,
              description:
                  'Target selected students with pending registration, assignments, or quizzes.',
            ),
          ];
        case 'Reports':
          return const [
            AdminTask(
              title: 'Generate 200L exam eligibility report',
              ownerRole: AdminRole.levelAdviser,
              due: 'Friday',
              status: WorkStatus.normal,
              description:
                  'Level report includes student list, registration, inactive students, complaints, participation, and at-risk cases.',
            ),
          ];
      }
    }

    if (role == AdminRole.examOfficer) {
      switch (pageLabel) {
        case 'Course Exam Readiness':
          return const [
            AdminTask(
              title: 'Confirm readiness for CSC 301 Operating Systems',
              ownerRole: AdminRole.examOfficer,
              due: 'Today, 1:00 PM',
              status: WorkStatus.warning,
              description:
                  'Check lecturer, moderator, students, question status, exam date, mode, and readiness before HoD confirmation.',
            ),
            AdminTask(
              title: 'Escalate four courses not ready for exam',
              ownerRole: AdminRole.hod,
              due: 'Today',
              status: WorkStatus.urgent,
              description:
                  'HoD remains Chief Departmental Exam Officer for final academic supervision.',
            ),
          ];
        case 'Question Submission':
          return const [
            AdminTask(
              title: 'Send reminder for CSC 405 exam question',
              ownerRole: AdminRole.lecturer,
              due: 'Today',
              status: WorkStatus.urgent,
              description:
                  'Lecturer has not submitted question and marking guide before the deadline.',
            ),
            AdminTask(
              title: 'Track corrected questions from lecturers',
              ownerRole: AdminRole.examOfficer,
              due: 'Tomorrow',
              status: WorkStatus.warning,
              description:
                  'Exam officer tracks corrections but does not secretly edit academic questions.',
            ),
          ];
        case 'Moderation Tracking':
          return const [
            AdminTask(
              title: 'Review six pending moderation workflows',
              ownerRole: AdminRole.moderator,
              due: 'Today, 3:00 PM',
              status: WorkStatus.warning,
              description:
                  'Workflow is Lecturer to Moderator to Exam Officer to HoD final departmental confirmation.',
            ),
          ];
        case 'Exam Timetable':
          return const [
            AdminTask(
              title: 'Publish departmental CBT and online exam timetable',
              ownerRole: AdminRole.examOfficer,
              due: 'Friday',
              status: WorkStatus.normal,
              description:
                  'Assign date, time, exam mode, CBT hall or online room, then notify students and lecturers.',
            ),
          ];
        case 'Student Eligibility':
          return const [
            AdminTask(
              title: 'Review 70 non-eligible students',
              ownerRole: AdminRole.examOfficer,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Check registration, payment signal, required CA, assignments, participation, and unresolved restrictions.',
            ),
          ];
        case 'Invigilation / Proctoring':
        case 'Exam Attendance':
          return const [
            AdminTask(
              title: 'Assign invigilators for online proctored groups',
              ownerRole: AdminRole.examOfficer,
              due: 'Tomorrow',
              status: WorkStatus.warning,
              description:
                  'Track face mismatch, tab switching, suspicious movement, network interruption, late login, and absence signals.',
            ),
          ];
        case 'Malpractice Reports':
          return const [
            AdminTask(
              title: 'Compile four malpractice reports for HoD review',
              ownerRole: AdminRole.examOfficer,
              due: 'Today, 4:00 PM',
              status: WorkStatus.urgent,
              description:
                  'Attach invigilator report, AI proctoring evidence, status, and recommendation.',
            ),
          ];
        case 'Result Collection':
        case 'Result Verification':
          return const [
            AdminTask(
              title: 'Check 14 pending result submissions',
              ownerRole: AdminRole.lecturer,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Collect scores from lecturers and verify missing CA, exam scores, totals, grades, duplicates, carryovers, absences, and malpractice flags.',
            ),
            AdminTask(
              title: 'Prepare verified result sheet for HoD review',
              ownerRole: AdminRole.hod,
              due: 'Friday',
              status: WorkStatus.normal,
              description:
                  'Exam officer prepares completeness checks; HoD remains Chief Departmental Exam Officer.',
            ),
          ];
        case 'Exam Complaints':
          return const [
            AdminTask(
              title: 'Triage exam access and submission complaints',
              ownerRole: AdminRole.examOfficer,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Technical issues go to ICT; academic question or score issues go to lecturer or HoD.',
            ),
          ];
        case 'Reports':
          return const [
            AdminTask(
              title: 'Prepare final departmental exam report',
              ownerRole: AdminRole.examOfficer,
              due: 'Friday',
              status: WorkStatus.normal,
              description:
                  'Include readiness, question submission, moderation, timetable, eligibility, attendance, malpractice, and result submission reports.',
            ),
          ];
      }
    }

    if (role == AdminRole.recordsDepartment) {
      switch (pageLabel) {
        case 'Admission / Matriculation':
          return const [
            AdminTask(
              title: 'Verify new DLC matriculation number batch',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Today, 1:00 PM',
              status: WorkStatus.warning,
              description:
                  'Confirm admission session, programme, department, faculty, level, and mode of study.',
            ),
          ];
        case 'Course Registration Records':
          return const [
            AdminTask(
              title: 'Store approved 200L course registration records',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Workflow: Student registers, Level Adviser reviews, HoD confirms, Academic Records stores official record.',
            ),
            AdminTask(
              title: 'Audit wrong and missing course registrations',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Tomorrow',
              status: WorkStatus.normal,
              description:
                  'Check compulsory, elective, carryover, late, and awaiting-approval registration records.',
            ),
          ];
        case 'Result Records':
          return const [
            AdminTask(
              title: 'Store approved CSC 305 result batch',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Academic Records stores approved results only after lecturer, exam officer, HoD, board/faculty/senate approval workflow.',
            ),
            AdminTask(
              title: 'Review 43 missing result records',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Friday',
              status: WorkStatus.urgent,
              description:
                  'Track missing CA score, exam score, total, grade, grade point, GPA, CGPA, and approval status.',
            ),
          ];
        case 'Carryover / Repeat Courses':
          return const [
            AdminTask(
              title: 'Reconcile carryover and repeat course list',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Today',
              status: WorkStatus.warning,
              description:
                  'Track failed, repeat, outstanding, spillover, and missing-grade course records.',
            ),
          ];
        case 'Academic Standing':
          return const [
            AdminTask(
              title: 'Generate probation and low-CGPA review list',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Tomorrow',
              status: WorkStatus.warning,
              description:
                  'Identify good standing, probation, low CGPA, outstanding courses, and graduation eligibility.',
            ),
          ];
        case 'Transcript Records':
          return const [
            AdminTask(
              title: 'Prepare transcript request batch',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Friday',
              status: WorkStatus.normal,
              description:
                  'Transcript release must follow university approval rules and official transcript format.',
            ),
          ];
        case 'Graduation / Clearance':
          return const [
            AdminTask(
              title: 'Check graduation clearance eligibility',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Friday',
              status: WorkStatus.warning,
              description:
                  'Confirm completed courses, carryovers, CGPA, outstanding records, and clearance status.',
            ),
          ];
        case 'Corrections & Audit Trail':
          return const [
            AdminTask(
              title: 'Process approved CSC 201 grade correction',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Today',
              status: WorkStatus.urgent,
              description:
                  'Log previous value, new value, reason, date, approval authority, officer, and supporting document.',
            ),
          ];
        case 'Reports':
          return const [
            AdminTask(
              title: 'Generate missing result and carryover report',
              ownerRole: AdminRole.recordsDepartment,
              due: 'Friday',
              status: WorkStatus.normal,
              description:
                  'Academic records reports cover official student records, registration, results, carryover, probation, graduation, transcript requests, and statistics.',
            ),
          ];
      }
    }

    if (role == AdminRole.supportTeam) {
      return const [
        AdminTask(
          title: 'Triage missing score support queue',
          ownerRole: AdminRole.supportTeam,
          due: 'Today, 12:00 PM',
          status: WorkStatus.urgent,
          description:
              'Route academic cases to HoD or lecturer without exposing support activity to other roles.',
        ),
        AdminTask(
          title: 'Close resolved technical access tickets',
          ownerRole: AdminRole.supportTeam,
          due: 'Today',
          status: WorkStatus.warning,
          description:
              'Attach support notes and SLA status before closing tickets.',
        ),
      ];
    }

    if (role == AdminRole.reportsTeam) {
      return const [
        AdminTask(
          title: 'Generate DLC management report export',
          ownerRole: AdminRole.reportsTeam,
          due: 'Friday',
          status: WorkStatus.normal,
          description:
              'Prepare PDF, Excel, and CSV outputs for authorised management distribution.',
        ),
        AdminTask(
          title: 'Validate lecturer performance dataset',
          ownerRole: AdminRole.reportsTeam,
          due: 'Tomorrow',
          status: WorkStatus.warning,
          description:
              'Check upload, engagement, marking, and score-submission data before release.',
        ),
      ];
    }

    if (role == AdminRole.invigilator) {
      return const [
        AdminTask(
          title: 'Review phone-like object alert with evidence',
          ownerRole: AdminRole.invigilator,
          due: 'Now',
          status: WorkStatus.urgent,
          description:
              'AI flagged object detection for manual review; open camera frame and decide clear, warn, escalate, or attach to report.',
        ),
        AdminTask(
          title: 'Verify late check-in identity and device ID',
          ownerRole: AdminRole.invigilator,
          due: 'Today, 9:15 AM',
          status: WorkStatus.warning,
          description:
              'Confirm candidate face, matric number, whitelisted workstation, and check-in reason before approving exam start.',
        ),
        AdminTask(
          title: 'Resolve pending evidence sync queue',
          ownerRole: AdminRole.invigilator,
          due: 'Today, 10:00 AM',
          status: WorkStatus.normal,
          description:
              'Check evidence uploaded, local pending evidence, and ledger pending status for assigned exam group.',
        ),
      ];
    }

    if (pageLabel == 'Notices') {
      return const [
        AdminTask(
          title: 'Publish exam office notice for 300 Level CSC cohort',
          ownerRole: AdminRole.examOfficer,
          due: 'Today, 1:00 PM',
          status: WorkStatus.warning,
          description:
              'Notice must target programme, level, semester and cohort only.',
        ),
        AdminTask(
          title: 'Review lecturer course notice before publishing',
          ownerRole: AdminRole.lecturer,
          due: 'Today, 3:00 PM',
          status: WorkStatus.normal,
          description: 'Course notices must not appear to unrelated students.',
        ),
      ];
    }

    if (pageLabel == 'Course Registration') {
      return const [
        AdminTask(
          title: 'Approve carryover/repeat registration batch',
          ownerRole: AdminRole.recordsDepartment,
          due: 'Today, 2:30 PM',
          status: WorkStatus.urgent,
          description:
              'Confirm failed, absent and missing-result courses before final approval.',
        ),
        AdminTask(
          title: 'Review overload waiver requests',
          ownerRole: AdminRole.levelAdviser,
          due: 'Tomorrow',
          status: WorkStatus.warning,
          description:
              'Students above credit limit require adviser and records confirmation.',
        ),
      ];
    }

    if (pageLabel == 'Records') {
      return const [
        AdminTask(
          title: 'Verify CGPA recalculation queue',
          ownerRole: AdminRole.recordsDepartment,
          due: 'Today, 4:00 PM',
          status: WorkStatus.warning,
          description:
              'Reconcile released results, repeated courses and transcript preview records.',
        ),
        AdminTask(
          title: 'Update cohort mappings for new intake',
          ownerRole: AdminRole.departmentAdmin,
          due: 'Friday',
          status: WorkStatus.normal,
          description:
              'Programme, level, semester, mode and department cohorts must be current.',
        ),
      ];
    }

    return [
      AdminTask(
        title: role == AdminRole.lecturer
            ? 'Upload CSC 204 answer guide'
            : 'Approve CSC 204 question paper',
        ownerRole: role == AdminRole.superAdmin ? AdminRole.examOfficer : role,
        due: 'Today, 2:00 PM',
        status: WorkStatus.warning,
        description:
            'Final moderation is waiting for an administrative sign-off.',
      ),
      const AdminTask(
        title: 'Resolve biometric mismatch list',
        ownerRole: AdminRole.invigilator,
        due: 'Today, 4:30 PM',
        status: WorkStatus.urgent,
        description:
            'Three candidates need identity notes attached to their exam record.',
      ),
      const AdminTask(
        title: 'Publish level adviser clearance report',
        ownerRole: AdminRole.levelAdviser,
        due: 'Tomorrow',
        status: WorkStatus.normal,
        description:
            'Registration exceptions and course carry-over lists are ready.',
      ),
      const AdminTask(
        title: 'Review departmental result summary',
        ownerRole: AdminRole.hod,
        due: 'Friday',
        status: WorkStatus.normal,
        description:
            'Pass rate trends and missing CA scores have been generated.',
      ),
    ];
  }

  List<String> workflowsFor(String pageLabel, {AdminRole? role}) {
    if (role == AdminRole.invigilator) {
      switch (pageLabel) {
        case 'Live Student Grid':
          return const [
            'Active students only',
            'Camera, mic, screen, network, and device status',
            'Risk colour status',
            'Integrity score',
            'Last detected event',
          ];
        case 'AI Alert Queue':
          return const [
            'Critical alerts first',
            'Manual-review alerts',
            'Evidence-captured alerts',
            'Face, object, audio, and screen activity detection',
            'Unreviewed alert count',
          ];
        case 'Evidence Review':
          return const [
            'Camera frame evidence',
            'Screenshot evidence',
            'Audio clip evidence',
            'AI confidence and detector source',
            'Ledger reference',
          ];
        case 'Manual Decisions':
          return const [
            'Clear false alarm',
            'Warn student',
            'Request scan or recheck',
            'Escalate to chief invigilator',
            'Pause, resume, or terminate session',
          ];
        case 'Student Session Detail':
          return const [
            'Live camera preview',
            'Face, object, audio, and screen status',
            'Risk timeline',
            'Device and network information',
            'Exam progress',
          ];
        case 'Room Scan Requests':
          return const [
            'Request desk scan',
            'Request left and right scan',
            'Request behind-monitor scan',
            'Request ID and face recheck',
            'Request microphone check',
          ];
        case 'Attendance & Check-in':
          return const [
            'Checked-in students',
            'Absent students',
            'Approve late check-in',
            'Verify identity and device ID',
            'Mark present or absent',
          ];
        case 'Risk Timeline':
          return const [
            'Face verified',
            'Exam started',
            'Detector events',
            'Evidence captured',
            'Invigilator decisions',
          ];
        case 'Malpractice Drafts':
          return const [
            'Selected evidence list',
            'AI confidence scores',
            'Invigilator decision',
            'Final recommendation',
            'Submit or export report',
          ];
        case 'Evidence Sync Status':
          return const [
            'Evidence uploaded',
            'Evidence pending locally',
            'Ledger pending',
            'Sync failed',
            'Network-aware status',
          ];
        case 'Audit Trail':
          return const [
            'Reviewer identity',
            'Decision timestamp',
            'Evidence used',
            'Warning and escalation record',
            'Report creation log',
          ];
      }
    }

    if (role == AdminRole.lecturer) {
      switch (pageLabel) {
        case 'My Courses':
          return const [
            'Assigned courses only',
            'Course status and moderator visibility',
            'Student count per course',
            'Upload progress',
            'Assessment readiness',
          ];
        case 'Course Materials':
          return const [
            'Course outline uploads',
            'Lecture notes and slides',
            'Reading materials and links',
            'Practical guides',
            'Draft, submitted, approved, rejected, and published states',
          ];
        case 'Video Lectures':
          return const [
            'Video upload and links',
            'Week and topic tracking',
            'Approval status',
            'Student views',
            'Completion rate',
          ];
        case 'Live Classes':
          return const [
            'Create live classes',
            'Set date, time, and topic',
            'Attach course materials',
            'Start class and track attendance',
            'Share recordings where allowed',
          ];
        case 'Quizzes & Tests':
          return const [
            'Objective and true/false questions',
            'Short answer and essays',
            'Matching and image-based questions',
            'Time limits and attempts',
            'Auto and manual marking',
          ];
        case 'Exam Questions':
          return const [
            'Create exam questions',
            'Upload marking guide',
            'Submit for moderation',
            'Receive correction comments',
            'Resubmit corrected questions',
          ];
        case 'Student Engagement':
          return const [
            'Students enrolled',
            'Video watch and notes download activity',
            'Assignment and quiz participation',
            'Inactive students',
            'Students at academic risk',
          ];
        case 'Marking & Grading':
          return const [
            'Assignment marking',
            'Essay and short-answer grading',
            'Practical and project marking',
            'AI-assisted suggestions',
            'Lecturer final academic authority',
          ];
        case 'Results Submission':
          return const [
            'Assignment scores',
            'Quiz and CA scores',
            'Exam scores',
            'Final course score',
            'Moderator, HoD, and exam office review flow',
          ];
        case 'Messages / Q&A':
          return const [
            'Course discussion forum',
            'Student questions',
            'Announcements',
            'Private academic messages',
            'Frequently asked questions',
          ];
      }
    }

    if (role == AdminRole.levelAdviser) {
      switch (pageLabel) {
        case 'Overview':
          return const [
            'Assigned level only',
            'Registration and progress monitoring',
            'Participation and attendance signals',
            'Exam eligibility risks',
            'Escalation to HoD, lecturer, exam officer, ICT, or DLC Director',
          ];
        case 'My Students':
          return const [
            'Student profiles',
            'Registration status',
            'Activity status',
            'Academic standing',
            'Exam eligibility and complaint status',
          ];
        case 'Course Registration':
          return const [
            'Completed registrations',
            'Incomplete registrations',
            'Wrong courses',
            'Missing compulsory courses',
            'Awaiting approval cases',
          ];
        case 'Student Progress':
          return const [
            'Assignment submission rate',
            'Quiz participation',
            'Lecture video completion',
            'Continuous assessment performance',
            'Students at academic risk',
          ];
        case 'Attendance & Participation':
          return const [
            'Login activity',
            'Video lecture views',
            'Live class attendance',
            'Material downloads',
            'Forum participation',
          ];
        case 'Exam Eligibility':
          return const [
            'Registration completed',
            'Assignments submitted',
            'Quizzes attempted',
            'Minimum participation reached',
            'Escalation to exam officer or HoD',
          ];
        case 'Complaints':
          return const [
            'Wrong course registration',
            'Missing course or CA score',
            'Lecturer response issue',
            'Assignment or quiz issue',
            'Academic escalation without support-team activity access',
          ];
        case 'Messages / Announcements':
          return const [
            'Send to all students in level',
            'Send to selected students',
            'Remind inactive students',
            'Exam readiness notice',
            'Registration deadline notice',
          ];
        case 'Reports':
          return const [
            'Level student list',
            'Registration report',
            'Inactive student report',
            'Exam eligibility report',
            'Participation and at-risk reports',
          ];
      }
    }

    if (role == AdminRole.examOfficer) {
      switch (pageLabel) {
        case 'Exam Overview':
          return const [
            'Departmental exam coordination',
            'HoD final academic supervision',
            'Question and moderation visibility',
            'Eligibility, attendance, and incident tracking',
            'Result collection and verification',
          ];
        case 'Course Exam Readiness':
          return const [
            'Course exam list',
            'Lecturer and moderator assignment',
            'Question and moderation status',
            'Exam date and mode',
            'Readiness status',
          ];
        case 'Question Submission':
          return const [
            'Submitted and pending questions',
            'Late submissions',
            'Rejected and corrected questions',
            'Final approved questions',
            'Marking guide uploads',
          ];
        case 'Moderation Tracking':
          return const [
            'Pending moderation',
            'Moderator comments',
            'Questions needing correction',
            'Resubmitted questions',
            'HoD final confirmation',
          ];
        case 'Exam Timetable':
          return const [
            'Create exam timetable',
            'Assign date and time',
            'Select exam mode',
            'Assign CBT hall or online room',
            'Publish and notify',
          ];
        case 'Student Eligibility':
          return const [
            'Eligible and non-eligible students',
            'Missing registration',
            'Payment and CA checks',
            'Incomplete participation',
            'Unresolved academic restrictions',
          ];
        case 'Invigilation / Proctoring':
          return const [
            'Assign invigilators',
            'Assign exam rooms',
            'Online proctoring status',
            'AI proctoring flags',
            'Disconnected and absent students',
          ];
        case 'Exam Attendance':
          return const [
            'Present and absent students',
            'Late students',
            'Disconnected students',
            'Successful and failed submissions',
            'Special cases',
          ];
        case 'Malpractice Reports':
          return const [
            'Incident evidence',
            'Invigilator reports',
            'AI proctoring evidence',
            'Escalation to HoD or exam committee',
            'Recommendations',
          ];
        case 'Result Collection':
          return const [
            'Submitted result batches',
            'Pending lecturer results',
            'Missing CA and exam scores',
            'Incomplete results',
            'Late submissions',
          ];
        case 'Result Verification':
          return const [
            'All registered students captured',
            'Totals and grades checked',
            'Duplicate and carryover checks',
            'Absent and malpractice flags',
            'Prepared for HoD review',
          ];
        case 'Exam Complaints':
          return const [
            'Access and allocation complaints',
            'Submission failure',
            'Timer and question issues',
            'Eligibility disputes',
            'Technical or academic routing',
          ];
        case 'Reports':
          return const [
            'Exam readiness report',
            'Question submission report',
            'Moderation and timetable reports',
            'Eligibility, attendance, and malpractice reports',
            'Final departmental exam report',
          ];
      }
    }

    if (role == AdminRole.recordsDepartment) {
      switch (pageLabel) {
        case 'Student Records':
          return const [
            'Official student academic profiles',
            'Matriculation and admission records',
            'Programme, department, faculty, and level',
            'DLC mode and current semester',
            'Academic status history',
          ];
        case 'Admission / Matriculation':
          return const [
            'Admission records',
            'Matriculation numbers',
            'Admission session',
            'Programme and level mapping',
            'Official profile verification',
          ];
        case 'Course Registration Records':
          return const [
            'Registered courses by semester',
            'Compulsory, elective, and carryover courses',
            'Missing and wrong registration',
            'Late registration',
            'Official approval status',
          ];
        case 'Programme & Level Records':
          return const [
            'Programme records',
            'Level records',
            'Department and faculty mapping',
            'Current semester',
            'Academic history structure',
          ];
        case 'Result Records':
          return const [
            'Approved result records only',
            'CA, exam, total, grade, and grade point',
            'Semester GPA and CGPA',
            'Missing result tracking',
            'Carryover record creation',
          ];
        case 'Carryover / Repeat Courses':
          return const [
            'Failed courses',
            'Carryover courses',
            'Repeat courses',
            'Outstanding courses',
            'Spillover status',
          ];
        case 'Academic Standing':
          return const [
            'Good standing',
            'Probation and low CGPA',
            'Outstanding courses',
            'Graduation eligibility',
            'Not eligible for graduation',
          ];
        case 'Transcript Records':
          return const [
            'Semester result history',
            'Course codes and titles',
            'Credit units and grades',
            'GPA and CGPA',
            'Official transcript preparation',
          ];
        case 'Graduation / Clearance':
          return const [
            'Graduation eligibility',
            'Outstanding course checks',
            'Approved result completeness',
            'Clearance status',
            'Final academic history review',
          ];
        case 'Corrections & Audit Trail':
          return const [
            'Correction reason',
            'Previous and new values',
            'Approval authority',
            'Supporting document',
            'Traceable audit log',
          ];
        case 'Reports':
          return const [
            'Student academic record report',
            'Course registration and result reports',
            'Missing result and carryover reports',
            'Probation and graduation eligibility',
            'Transcript request and department statistics',
          ];
      }
    }

    if (role == AdminRole.supportTeam) {
      return const [
        'Private support route',
        'Ticket triage',
        'Academic support routing',
        'Technical issue handling',
        'SLA activity audit',
      ];
    }

    if (role == AdminRole.reportsTeam) {
      return const [
        'Private reports route',
        'Management reports',
        'Analytics dashboards',
        'PDF, Excel, and CSV exports',
        'Report data quality checks',
      ];
    }

    switch (pageLabel) {
      case 'Overview':
        return const [
          'DLC-wide operational visibility',
          'Staff and lecturer supervision',
          'Course delivery tracking',
          'Student participation monitoring',
          'Exam and result readiness alerts',
        ];
      case 'Staff Management':
        return const [
          'Create staff accounts',
          'Assign roles and departments',
          'Assign programmes and levels',
          'Activate, deactivate, and reset access',
          'Review staff activity',
        ];
      case 'Lecturer Monitoring':
        return const [
          'Lecture notes upload tracking',
          'Video lecture tracking',
          'Assignments and quiz monitoring',
          'Student engagement review',
          'Delayed lecturer escalation',
        ];
      case 'Departments & Programmes':
        return const [
          'Faculty, department, and programme setup',
          'HoD assignment',
          'Programme coordinator assignment',
          'Level coordinator assignment',
          'Course and student mapping',
        ];
      case 'Course Management':
        return const [
          'Course upload supervision',
          'Lecturer and moderator allocation',
          'Assessment status tracking',
          'Exam status tracking',
          'Student enrolment visibility',
        ];
      case 'Student Management':
        return const [
          'Programme and level supervision',
          'Payment issue visibility',
          'Technical complaint history',
          'Exam eligibility review',
          'Special case approval coordination',
        ];
      case 'Exams & Assessments':
        return const [
          'Upcoming and completed exams',
          'Question submission tracking',
          'Moderation readiness',
          'AI proctoring and CBT reports',
          'Result submission status',
        ];
      case 'System Activity':
        return const [
          'Student login activity',
          'Lecturer login activity',
          'Live-class performance',
          'Server and system warnings',
          'Audit-ready operations log',
        ];
      case 'Settings':
        return const [
          'DLC policy settings',
          'Notification templates',
          'Operational notice controls',
          'Approval rules',
          'Management visibility preferences',
        ];
      case 'Department Overview':
        return const [
          'Department-only DLC visibility',
          'Course and lecturer supervision',
          'Level coordinator monitoring',
          'Academic quality alerts',
          'Departmental reporting',
        ];
      case 'Lecturers':
        return const [
          'View lecturer profiles',
          'Assign lecturers to courses',
          'Monitor last login',
          'Track uploaded materials',
          'Review pending lecturer tasks',
        ];
      case 'Courses':
        return const [
          'Department course catalogue',
          'Lecturer and coordinator allocation',
          'Moderator assignment visibility',
          'Student enrolment per course',
          'Approve or flag course readiness',
        ];
      case 'Level Coordinators':
        return const [
          '100L to 400L coordinator oversight',
          'Students per level',
          'Registration issues by level',
          'Exam eligibility issues',
          'Student progress reports',
        ];
      case 'Students':
        return const [
          'Department student profiles',
          'Academic progress monitoring',
          'Registered courses',
          'Assessment performance',
          'Students at risk',
        ];
      case 'Course Materials':
        return const [
          'Lecture notes upload checks',
          'Video lecture upload checks',
          'Assignments and quizzes',
          'Practical guides',
          'Course outline review',
        ];
      case 'Assessment & Exams':
        return const [
          'Submitted exam questions',
          'Assessment readiness',
          'Courses ready for exam',
          'Courses not ready for exam',
          'Result submission tracking',
        ];
      case 'Moderation Status':
        return const [
          'Lecturer to moderator handoff',
          'Moderator comments',
          'HoD academic review',
          'Exam officer handoff',
          'Quality assurance trail',
        ];
      case 'Results':
        return const [
          'Submitted scores',
          'Missing score checks',
          'Failed student review',
          'Pass-rate analysis',
          'Recommend result approval',
        ];
      case 'Notices':
        return const [
          'Lecturer notice publishing',
          'Exam office official notices',
          'Department/programme/level/cohort targeting',
          'Acknowledgement tracking',
          'Archive and audit logs',
        ];
      case 'Course Registration':
        return const [
          'Core course validation',
          'Elective selection review',
          'Carryover/repeat approval',
          'Overload waiver',
          'Registration lock/release',
        ];
      case 'Assignments':
        return const [
          'Lecturer grading',
          'Rubric review',
          'Late submission exceptions',
          'Peer review monitoring',
          'Academic integrity flags',
        ];
      case 'Exams':
        return const [
          'Question workflow',
          'Moderator review',
          'Exam officer approval',
          'Invigilation setup',
          'Incident escalation',
        ];
      case 'Records':
        return const [
          'Student profile records',
          'Cohort management',
          'CGPA and transcript preview',
          'Completed courses',
          'Programme curriculum mapping',
        ];
      case 'Approvals':
        return const [
          'Question approval',
          'Notice approval',
          'Carryover approval',
          'Result approval',
          'Special registration approval',
        ];
      case 'People':
        return const [
          'Staff roles',
          'Lecturer allocation',
          'Invigilator assignment',
          'Department/faculty admins',
          'Access control',
        ];
      default:
        return const [
          'Operational metrics',
          'Role-based work queues',
          'Live alerts',
          'Audit-ready actions',
          'Cross-portal supervision',
        ];
    }
  }

  List<ExamRoom> examRooms() {
    return const [
      ExamRoom(
        courseCode: 'CSC 204',
        room: 'ICT Lab A',
        time: '09:00 - 11:00',
        invigilator: 'Dr. A. Musa',
        candidateCount: 126,
        status: WorkStatus.normal,
      ),
      ExamRoom(
        courseCode: 'GST 102',
        room: 'Hall 2',
        time: '11:30 - 13:00',
        invigilator: 'Mrs. E. John',
        candidateCount: 214,
        status: WorkStatus.warning,
      ),
      ExamRoom(
        courseCode: 'MTH 112',
        room: 'CBT Centre 1',
        time: '14:00 - 16:00',
        invigilator: 'Mr. O. Bala',
        candidateCount: 188,
        status: WorkStatus.complete,
      ),
    ];
  }

  List<AdminAlert> alerts() {
    return const [
      AdminAlert(
        title: 'Candidate verification delay',
        message: 'Hall 2 has 14 candidates waiting for manual confirmation.',
        status: WorkStatus.warning,
        time: '8 min ago',
      ),
      AdminAlert(
        title: 'Remote proctoring escalation',
        message: 'Two sessions crossed the suspicious activity threshold.',
        status: WorkStatus.urgent,
        time: '19 min ago',
      ),
      AdminAlert(
        title: 'Results batch completed',
        message: 'CSC 312 scores are ready for HoD review.',
        status: WorkStatus.complete,
        time: '42 min ago',
      ),
    ];
  }
}
