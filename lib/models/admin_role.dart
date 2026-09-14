import 'package:flutter/material.dart';

enum AdminRole { lecturer, moderator, examOfficer, hod, ictAdmin }

extension AdminRoleX on AdminRole {
  String get label {
    switch (this) {
      case AdminRole.lecturer:
        return 'Lecturer';
      case AdminRole.moderator:
        return 'Moderator';
      case AdminRole.examOfficer:
        return 'Exam Officer';
      case AdminRole.hod:
        return 'HoD';
      case AdminRole.ictAdmin:
        return 'General ICT Admin';
    }
  }

  String get scope {
    switch (this) {
      case AdminRole.lecturer:
        return 'Course content, assignments, question preparation, marking, and result recommendations';
      case AdminRole.moderator:
        return 'Question moderation, assessment quality review, grading policy checks, and moderation comments';
      case AdminRole.examOfficer:
        return 'Operational coordination of departmental exams under HoD supervision: timetables, question submission, moderation tracking, eligibility, invigilation, attendance, malpractice reports, result collection, verification, exam complaints, and exam reports';
      case AdminRole.hod:
        return 'Chief Exam Officer and academic supervisor for university courses, lecturers, students, materials, assessments, moderation, results, and departmental academic authority';
      case AdminRole.ictAdmin:
        return 'University-wide administrative operations, configuration, audit, and role governance';
    }
  }

  IconData get icon {
    switch (this) {
      case AdminRole.lecturer:
        return Icons.school_outlined;
      case AdminRole.moderator:
        return Icons.rule_folder_outlined;
      case AdminRole.examOfficer:
        return Icons.assignment_turned_in_outlined;
      case AdminRole.hod:
        return Icons.groups_2_outlined;
      case AdminRole.ictAdmin:
        return Icons.admin_panel_settings_outlined;
    }
  }
}

/// Backend role codes shared by sign-in routing and staff assignment.
const staffRoleOptions = [
  'lecturer',
  'moderator',
  'exam_officer',
  'hod',
  'ict_admin',
];

AdminRole? adminRoleFromCode(String? code) {
  switch (code?.toLowerCase().trim().replaceAll(' ', '_')) {
    case 'lecturer':
      return AdminRole.lecturer;
    case 'moderator':
      return AdminRole.moderator;
    case 'exam_officer':
    case 'departmental_exam_officer':
      return AdminRole.examOfficer;
    case 'hod':
    case 'head_of_department':
      return AdminRole.hod;
    case 'ict_admin':
    case 'general_ict_admin':
    case 'admin':
    case 'system_admin':
    case 'super_admin':
    case 'superadmin':
      return AdminRole.ictAdmin;
    default:
      return null;
  }
}
