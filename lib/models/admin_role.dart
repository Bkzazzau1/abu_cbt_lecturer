import 'package:flutter/material.dart';

enum AdminRole {
  lecturer,
  moderator,
  invigilator,
  examOfficer,
  recordsDepartment,
  departmentAdmin,
  facultyAdmin,
  dlcDirector,
  hod,
  levelAdviser,
  supportTeam,
  reportsTeam,
  superAdmin,
}

extension AdminRoleX on AdminRole {
  String get label {
    switch (this) {
      case AdminRole.lecturer:
        return 'Lecturer';
      case AdminRole.moderator:
        return 'Moderator';
      case AdminRole.invigilator:
        return 'Invigilator';
      case AdminRole.examOfficer:
        return 'Departmental Exam Officer';
      case AdminRole.recordsDepartment:
        return 'Academic Records';
      case AdminRole.departmentAdmin:
        return 'Department Admin';
      case AdminRole.facultyAdmin:
        return 'Faculty Admin';
      case AdminRole.dlcDirector:
        return 'DLC Director';
      case AdminRole.hod:
        return 'HoD';
      case AdminRole.levelAdviser:
        return 'Level Adviser';
      case AdminRole.supportTeam:
        return 'Support Team';
      case AdminRole.reportsTeam:
        return 'Reports Team';
      case AdminRole.superAdmin:
        return 'All Admins';
    }
  }

  String get scope {
    switch (this) {
      case AdminRole.lecturer:
        return 'Course content, assignments, question preparation, marking, and result recommendations';
      case AdminRole.moderator:
        return 'Question moderation, assessment quality review, grading policy checks, and moderation comments';
      case AdminRole.invigilator:
        return 'Exam rooms, candidate check-in, attendance, device flags, and incident reporting';
      case AdminRole.examOfficer:
        return 'Operational coordination of departmental exams under HoD supervision: timetables, question submission, moderation tracking, eligibility, invigilation, attendance, malpractice reports, result collection, verification, exam complaints, and exam reports';
      case AdminRole.recordsDepartment:
        return 'Official custodian of DLC student academic profiles, matriculation, course registration records, approved results, carryovers, academic standing, transcript records, graduation clearance, corrections, audit trails, and academic reports';
      case AdminRole.departmentAdmin:
        return 'Department courses, curriculum, lecturer allocation, student cohorts, and academic compliance';
      case AdminRole.facultyAdmin:
        return 'Faculty-wide academic operations, departments, programmes, approvals, and compliance reporting';
      case AdminRole.dlcDirector:
        return 'Central administration, staff enrolment, lecturer monitoring, programme supervision, course delivery, exams, support, approvals, and management reports';
      case AdminRole.hod:
        return 'Chief Departmental Exam Officer and academic supervisor for DLC courses, lecturers, level coordinators, students, materials, assessments, moderation, results, and departmental academic authority';
      case AdminRole.levelAdviser:
        return 'Assigned level student monitoring, registration checks, participation tracking, exam eligibility, academic complaints, announcements, escalation, and level reports';
      case AdminRole.supportTeam:
        return 'Dedicated student support, helpdesk ticket triage, academic support routing, SLA tracking, and private support activity handling';
      case AdminRole.reportsTeam:
        return 'Dedicated reporting and analytics workspace for operational reports, exports, dashboards, and management insights';
      case AdminRole.superAdmin:
        return 'Institution-wide administrative operations, configuration, audit, and role governance';
    }
  }

  IconData get icon {
    switch (this) {
      case AdminRole.lecturer:
        return Icons.school_outlined;
      case AdminRole.moderator:
        return Icons.rule_folder_outlined;
      case AdminRole.invigilator:
        return Icons.verified_user_outlined;
      case AdminRole.examOfficer:
        return Icons.assignment_turned_in_outlined;
      case AdminRole.recordsDepartment:
        return Icons.badge_outlined;
      case AdminRole.departmentAdmin:
        return Icons.account_tree_outlined;
      case AdminRole.facultyAdmin:
        return Icons.account_balance_outlined;
      case AdminRole.dlcDirector:
        return Icons.cast_for_education_outlined;
      case AdminRole.hod:
        return Icons.groups_2_outlined;
      case AdminRole.levelAdviser:
        return Icons.person_search_outlined;
      case AdminRole.supportTeam:
        return Icons.support_agent_outlined;
      case AdminRole.reportsTeam:
        return Icons.analytics_outlined;
      case AdminRole.superAdmin:
        return Icons.admin_panel_settings_outlined;
    }
  }
}
