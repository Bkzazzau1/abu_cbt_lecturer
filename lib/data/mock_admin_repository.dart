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
          detail: 'Courses assigned by HoD or General ICT Admin',
          icon: Icons.menu_book_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Course Students',
          value: '804',
          detail: 'Students enrolled across assigned ABU courses',
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

    if (role == AdminRole.hod) {
      return const [
        AdminMetric(
          label: 'ABU Students',
          value: '1,250',
          detail: 'Computer Science students across 100L to 400L',
          icon: Icons.groups_2_outlined,
          status: WorkStatus.normal,
        ),
        AdminMetric(
          label: 'Department Lecturers',
          value: '18',
          detail: 'Lecturers assigned to ABU departmental courses',
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
                  'Course is active but still missing a confirmed lecturer.',
            ),
            AdminTask(
              title: 'Follow up delayed lecturer uploads',
              ownerRole: AdminRole.lecturer,
              due: 'Today',
              status: WorkStatus.urgent,
              description:
                  'Three lecturers have pending notes, videos, or quizzes for active ABU courses.',
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
                  'HoD remains Chief Exam Officer for final academic supervision.',
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
                  'Exam officer prepares completeness checks; HoD remains Chief Exam Officer.',
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
      return const [];
    }

    if (pageLabel == 'Records') {
      return const [];
    }

    return [
      AdminTask(
        title: role == AdminRole.lecturer
            ? 'Upload CSC 204 answer guide'
            : 'Approve CSC 204 question paper',
        ownerRole: role == AdminRole.ictAdmin ? AdminRole.examOfficer : role,
        due: 'Today, 2:00 PM',
        status: WorkStatus.warning,
        description:
            'Final moderation is waiting for an administrative sign-off.',
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

    switch (pageLabel) {
      case 'Overview':
        return const [
          'ABU-wide operational visibility',
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
          'HoD assignment',
          'Exam Officer assignment',
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
          'ABU policy settings',
          'Notification templates',
          'Operational notice controls',
          'Approval rules',
          'Management visibility preferences',
        ];
      case 'Department Overview':
        return const [
          'Department-only ABU visibility',
          'Course and lecturer supervision',
          'Lecturer monitoring',
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
          'Lecturer allocation',
          'Moderator assignment visibility',
          'Student enrolment per course',
          'Approve or flag course readiness',
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
          'General ICT Admin',
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
