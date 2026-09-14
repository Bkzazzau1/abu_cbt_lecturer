class AdminNoticeBackendPath {
  static const listNotices = '/api/v1/admin/notices';
  static const createNotice = '/api/v1/admin/notices';
  static const publishNotice = '/api/v1/admin/notices/{noticeId}/publish';
  static const archiveNotice = '/api/v1/admin/notices/{noticeId}/archive';
  static const acknowledgements = '/api/v1/admin/notices/{noticeId}/acknowledgements';
  static const auditLogs = '/api/v1/admin/notices/{noticeId}/audit-logs';
}

class AdminSupportBackendPath {
  static const tickets = '/api/v1/admin/support/tickets';
  static const ticketDetail = '/api/v1/admin/support/tickets/{ticketId}';
  static const createTicket = '/api/v1/admin/support/tickets';
  static const assignTicket = '/api/v1/admin/support/tickets/{ticketId}/assign';
  static const escalateTicket = '/api/v1/admin/support/tickets/{ticketId}/escalate';
  static const resolveTicket = '/api/v1/admin/support/tickets/{ticketId}/resolve';
  static const reopenTicket = '/api/v1/admin/support/tickets/{ticketId}/reopen';
  static const ticketComments = '/api/v1/admin/support/tickets/{ticketId}/comments';
  static const missingResultFollowUp = '/api/v1/admin/support/tickets/{ticketId}/missing-result-follow-up';
  static const registrationIssueFollowUp = '/api/v1/admin/support/tickets/{ticketId}/registration-follow-up';
  static const examIncidentFollowUp = '/api/v1/admin/support/tickets/{ticketId}/exam-incident-follow-up';
  static const assignmentIssueFollowUp = '/api/v1/admin/support/tickets/{ticketId}/assignment-follow-up';
  static const supportAuditLogs = '/api/v1/admin/support/tickets/{ticketId}/audit-logs';
}

class AdminAcademicStructureBackendPath {
  static const faculties = '/api/v1/admin/academic/faculties';
  static const departments = '/api/v1/admin/academic/departments';
  static const programmes = '/api/v1/admin/academic/programmes';
  static const courses = '/api/v1/admin/academic/courses';
  static const curriculumMaps = '/api/v1/admin/academic/curriculum-maps';
  static const programmeLevels = '/api/v1/admin/academic/programmes/{programmeId}/levels';
  static const programmeSemesters = '/api/v1/admin/academic/programmes/{programmeId}/semesters';
  static const programmeCourses = '/api/v1/admin/academic/programmes/{programmeId}/courses';
  static const cohortMappings = '/api/v1/admin/academic/cohort-mappings';
  static const academicStructureAuditLogs = '/api/v1/admin/academic/audit-logs';
}

class AdminCourseRegistrationBackendPath {
  static const pendingRegistrations = '/api/v1/admin/course-registrations/pending';
  static const approveRegistration = '/api/v1/admin/course-registrations/{registrationId}/approve';
  static const rejectRegistration = '/api/v1/admin/course-registrations/{registrationId}/reject';
  static const confirmCarryover = '/api/v1/admin/course-registrations/{registrationId}/carryovers/confirm';
  static const lockRegistration = '/api/v1/admin/course-registrations/{registrationId}/lock';
}

class AdminAssignmentBackendPath {
  static const listAssignments = '/api/v1/admin/assignments';
  static const createAssignment = '/api/v1/admin/assignments';
  static const updateAssignment = '/api/v1/admin/assignments/{assignmentId}';
  static const publishAssignment = '/api/v1/admin/assignments/{assignmentId}/publish';
  static const listSubmissions = '/api/v1/admin/assignments/{assignmentId}/submissions';
  static const gradeSubmission = '/api/v1/admin/assignments/{assignmentId}/submissions/{submissionId}/grade';
  static const releaseMarks = '/api/v1/admin/assignments/{assignmentId}/release-marks';
  static const integrityFlags = '/api/v1/admin/assignments/{assignmentId}/integrity-flags';
  static const lateSubmissionDecisions = '/api/v1/admin/assignments/{assignmentId}/late-submissions';
}

class AdminQuestionReviewBackendPath {
  static const questionSets = '/api/v1/admin/question-sets';
  static const questionSetDetail = '/api/v1/admin/question-sets/{questionSetId}';
  static const addComment = '/api/v1/admin/question-sets/{questionSetId}/comments';
  static const approveQuestionSet = '/api/v1/admin/question-sets/{questionSetId}/approve';
  static const returnToLecturer = '/api/v1/admin/question-sets/{questionSetId}/return-to-lecturer';
  static const rubricReview = '/api/v1/admin/question-sets/{questionSetId}/rubric-review';
  static const difficultyReview = '/api/v1/admin/question-sets/{questionSetId}/difficulty-review';
  static const handoverToExamOffice = '/api/v1/admin/question-sets/{questionSetId}/handover-to-exam-office';
}

class AdminExamBackendPath {
  static const examPlans = '/api/v1/admin/exams';
  static const createExam = '/api/v1/admin/exams';
  static const updateExam = '/api/v1/admin/exams/{examId}';
  static const approveQuestions = '/api/v1/admin/exams/{examId}/questions/approve';
  static const packageQuestions = '/api/v1/admin/exams/{examId}/questions/package';
  static const hallSetup = '/api/v1/admin/exams/{examId}/hall-setup';
  static const assignInvigilators = '/api/v1/admin/exams/{examId}/invigilators';
  static const readinessChecklist = '/api/v1/admin/exams/{examId}/readiness';
  static const openExam = '/api/v1/admin/exams/{examId}/open';
  static const closeExam = '/api/v1/admin/exams/{examId}/close';
  static const incidents = '/api/v1/admin/exams/{examId}/incidents';
  static const escalateIncident = '/api/v1/admin/exams/{examId}/incidents/{incidentId}/escalate';
}

class AdminInvigilationBackendPath {
  static const rooms = '/api/v1/admin/invigilation/rooms';
  static const roomDetail = '/api/v1/admin/invigilation/rooms/{roomId}';
  static const candidateCheckIn = '/api/v1/admin/invigilation/rooms/{roomId}/check-in';
  static const candidateCheckOut = '/api/v1/admin/invigilation/rooms/{roomId}/check-out';
  static const workstationStatus = '/api/v1/admin/invigilation/rooms/{roomId}/workstations';
  static const appIdStatus = '/api/v1/admin/invigilation/rooms/{roomId}/app-ids';
  static const deviceStatus = '/api/v1/admin/invigilation/rooms/{roomId}/devices';
  static const reportIncident = '/api/v1/admin/invigilation/rooms/{roomId}/incidents';
  static const escalateIncident = '/api/v1/admin/invigilation/incidents/{incidentId}/escalate';
  static const resolveIncident = '/api/v1/admin/invigilation/incidents/{incidentId}/resolve';
  static const closeRoom = '/api/v1/admin/invigilation/rooms/{roomId}/close';
  static const sessionAuditLogs = '/api/v1/admin/invigilation/sessions/{sessionId}/audit-logs';
}

class AdminExamSessionOverviewBackendPath {
  static const overview = '/api/v1/admin/exam-sessions/overview';
  static const sessionDetail = '/api/v1/admin/exam-sessions/{sessionId}';
  static const riskSummary = '/api/v1/admin/exam-sessions/{sessionId}/risk-summary';
  static const reports = '/api/v1/admin/exam-sessions/{sessionId}/reports';
  static const escalationReviews = '/api/v1/admin/exam-sessions/{sessionId}/escalation-reviews';
  static const holdSignOff = '/api/v1/admin/exam-sessions/{sessionId}/hold-sign-off';
  static const approveSignOff = '/api/v1/admin/exam-sessions/{sessionId}/approve-sign-off';
  static const sessionAuditLogs = '/api/v1/admin/exam-sessions/{sessionId}/audit-logs';
}

class AdminPeopleBackendPath {
  static const staffAccounts = '/api/v1/admin/staff';
  static const createStaff = '/api/v1/admin/staff';
  static const updateStaff = '/api/v1/admin/staff/{staffId}';
  static const deactivateStaff = '/api/v1/admin/staff/{staffId}/deactivate';
  static const reactivateStaff = '/api/v1/admin/staff/{staffId}/reactivate';
  static const roleAssignments = '/api/v1/admin/staff/{staffId}/roles';
  static const permissionOverrides = '/api/v1/admin/staff/{staffId}/permissions';
  static const lecturerAllocations = '/api/v1/admin/staff/{staffId}/lecturer-allocations';
  static const moderatorAllocations = '/api/v1/admin/staff/{staffId}/moderator-allocations';
  static const invigilatorAllocations = '/api/v1/admin/staff/{staffId}/invigilator-allocations';
  static const accessAuditLogs = '/api/v1/admin/staff/{staffId}/access-audit-logs';
}

class AdminCohortBackendPath {
  static const listCohorts = '/api/v1/admin/cohorts';
  static const createCohort = '/api/v1/admin/cohorts';
  static const updateCohort = '/api/v1/admin/cohorts/{cohortId}';
  static const archiveCohort = '/api/v1/admin/cohorts/{cohortId}/archive';
  static const assignStudents = '/api/v1/admin/cohorts/{cohortId}/students';
  static const removeStudents = '/api/v1/admin/cohorts/{cohortId}/students/remove';
  static const registrationRules = '/api/v1/admin/cohorts/{cohortId}/course-registration-rules';
  static const noticeTargeting = '/api/v1/admin/cohorts/{cohortId}/notice-targeting';
  static const resultMapping = '/api/v1/admin/cohorts/{cohortId}/result-mapping';
  static const recordsMapping = '/api/v1/admin/cohorts/{cohortId}/records-mapping';
  static const promoteCohort = '/api/v1/admin/cohorts/{cohortId}/promote';
  static const cohortAuditLogs = '/api/v1/admin/cohorts/{cohortId}/audit-logs';
}

class AdminResultBackendPath {
  static const resultBatches = '/api/v1/admin/results/batches';
  static const lecturerSubmissions = '/api/v1/admin/results/lecturer-submissions';
  static const submitBatch = '/api/v1/admin/results/{batchId}/submit';
  static const moderatorQuery = '/api/v1/admin/results/{batchId}/moderator-query';
  static const hodReview = '/api/v1/admin/results/{batchId}/hod-review';
  static const recordsReconcile = '/api/v1/admin/results/{batchId}/records-reconcile';
  static const examOfficeRelease = '/api/v1/admin/results/{batchId}/release';
  static const studentPublication = '/api/v1/admin/results/{batchId}/publish-to-students';
  static const auditTrail = '/api/v1/admin/results/{batchId}/audit-trail';
}

class AdminWorkflowContract {
  const AdminWorkflowContract._();

  static const ownershipRules = [
    'Lecturer, moderator, invigilator, exam officer, records, department, faculty, HoD, level adviser and super admin workflows belong in kslas-admin-ui.',
    'The student app must only read student-visible data and submit student actions such as course registration, assignment submissions, exam attempts, acknowledgements and live-class participation.',
    'Admin APIs must derive staff role and permission from the authenticated token before exposing admin data.',
    'Notice publishing, support ticket handling, academic structure management, assignment creation, grading, question moderation, exam scheduling, question approval, invigilator assignment, invigilation operations, exam session overview, staff role assignment, cohort creation, cohort promotion, carryover confirmation, result release, and registration approval must never be performed by the student app.',
  ];

  static const supportHelpdeskRules = [
    'Students may create support tickets from the student app, but ticket assignment, escalation, resolution and audit review belong in kslas-admin-ui.',
    'Missing-result tickets must be linked to records, result batches and course attempts before resolution.',
    'Course-registration tickets must be linked to cohort rules, curriculum maps and approval history.',
    'Exam-incident follow-up must be linked to exam session reports and invigilation logs where applicable.',
    'Assignment support must be linked to assignment submissions, grading status and lecturer feedback.',
    'Every assignment, escalation, comment, resolution and reopen action must be audit logged.',
  ];

  static const academicStructureRules = [
    'Faculties, departments, programmes, courses, curriculum maps, levels, semesters and cohorts are admin-only records.',
    'Programme curriculum must define core, elective and shared courses before student course registration is opened.',
    'Level, semester, credit load, course type and cohort mappings must be versioned by academic session where policy requires it.',
    'Shared courses such as GST must be mapped without duplicating student academic records.',
    'Every structural change must be audit logged because it affects registration, records, results and transcripts.',
  ];

  static const cohortManagementRules = [
    'Cohorts connect students to programme, intake year, study mode, level, semester, course registration, notices, records and results.',
    'A student may belong to an academic programme cohort and also shared course cohorts such as GST or institution-wide groups.',
    'Course registration rules must derive from programme curriculum and cohort-specific calendar or mode rules.',
    'Notice targeting may use cohort IDs, but the student app must only receive notices matching the authenticated student cohort membership.',
    'Cohort promotion must update level, semester and academic session carefully and must not overwrite historical academic records.',
    'Every cohort creation, student assignment, removal, promotion, registration-rule update and result mapping change must be audit logged.',
  ];

  static const courseRegistrationApprovalRules = [
    'Core courses are validated from programme curriculum.',
    'Electives must match programme, level, semester and cohort rules.',
    'Carryover/repeat courses must be confirmed against released records before approval.',
    'Overload or late registration must require authorized override with audit log.',
  ];

  static const assignmentMarkingRules = [
    'Lecturers may create and publish assignments only for assigned courses.',
    'Students submit assignments in the student app, while staff review and grade submissions in kslas-admin-ui.',
    'Rubric scores, feedback, late decisions, integrity flags, and released marks must be audit logged.',
    'Assignment marks should move to result workflow only after lecturer release or department policy approval.',
  ];

  static const questionReviewRules = [
    'Lecturers submit question sets for assigned courses only.',
    'Moderators review question clarity, coverage, difficulty balance, marking guide, answer key, and rubric completeness.',
    'Moderators may approve, return to lecturer, or add issue comments before exam office packaging.',
    'Approved question sets may be handed over to the exam office for secure packaging and scheduling.',
    'Every moderation comment, approval, return, rubric change, and handover must be audit logged.',
  ];

  static const examManagementRules = [
    'Exam officers create and schedule exams only after the lecturer and moderator question workflow is complete.',
    'Question approval, packaging, hall setup, proctoring mode, exam window and security rules are admin-only operations.',
    'Invigilator assignment must be tracked per hall, session, mode and candidate population.',
    'An exam should open only when readiness checks pass: questions approved, venue configured, candidates mapped, invigilators assigned and security settings confirmed.',
    'Incidents from invigilators, proctoring alerts or candidate verification must be reviewable and escalatable inside the admin UI.',
    'Every schedule change, approval, open/close action and incident escalation must be audit logged.',
  ];

  static const invigilationRules = [
    'Invigilators may operate only assigned rooms, halls or online proctoring groups for the current exam session.',
    'Candidate check-in must verify the exam, room, seat, identity status and whitelisted workstation or app ID before admission.',
    'Workstation, device, app ID and network status are monitoring signals for operations and must not be controlled by the student app.',
    'Incidents and malpractice reports must be created, escalated, resolved and audited inside the admin UI.',
    'Room closure should require candidate count reconciliation, submission sync status, incident review and invigilator sign-off.',
  ];

  static const examSessionOverviewRules = [
    'Chief invigilators and authorized exam officers may view all active rooms, online groups, open reports, escalations and pending sign-offs for an exam session.',
    'Session overview should aggregate data from invigilation rooms without allowing student-side control operations.',
    'Sign-off should require candidate reconciliation, submission sync status, unresolved-report review and room-level invigilator sign-off.',
    'High-risk sessions should not be signed off until escalated reports are reviewed by the authorized role.',
    'Every overview review, escalation review, sign-off hold and sign-off approval must be audit logged.',
  ];

  static const peopleAccessRules = [
    'Staff role assignment must be performed only by authorized department, faculty or super admin users.',
    'Lecturer permissions must be restricted to assigned courses unless an explicit override is approved.',
    'Moderator permissions must be restricted to assigned moderation batches or departments.',
    'Invigilator permissions must be restricted to assigned halls, exam sessions and incidents.',
    'Records department permissions are high-risk and must be audit logged for CGPA, transcript, cohort and student-record changes.',
    'Every role grant, permission override, deactivation, reactivation and work allocation must be audit logged.',
  ];

  static const resultApprovalRules = [
    'Lecturers submit result batches only for assigned courses.',
    'Moderator or HoD review must happen before exam office release where institution policy requires it.',
    'Records department must reconcile repeated courses, missing scores, carryovers and student academic history before final publication.',
    'Exam office controls final release and student publication.',
    'Every score edit, query, review, reconciliation and release action must be audit logged.',
  ];

  static const recordsDepartmentRules = [
    'Maintain student profile, programme, department, level, semester and cohort records.',
    'Reconcile completed courses, repeated courses, missing results, CGPA and transcript preview.',
    'Lock approved academic records according to institution policy.',
  ];
}
