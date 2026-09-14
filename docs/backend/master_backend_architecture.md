# K-SLAS Master Backend Architecture and Database Model

## 1. Purpose

This document defines the backend architecture for the K-SLAS ecosystem covering:

- `k-slas-my-course`: student-facing app only.
- `kslas-admin-ui`: staff, academic, exam, records, support, reporting and operational administration only.

Finance and billing modules are intentionally excluded until the school contract approves that scope.

## 2. Application Boundary Rules

### Student app responsibilities

The student app may allow a student to:

- View personal dashboard, courses, academic record and graduation mapping.
- Register courses and track registration status.
- View notices targeted to the student, programme, level, cohort or general audience.
- Join live classes and view replays where permitted.
- Submit assignments and view submission receipts.
- Take CBT, theory and other permitted assessments.
- View personal results and unofficial transcript preview.
- Request official transcript dispatch.
- Submit internship/SIWES profile, placement letter request, acceptance letter and logbook entries.
- Create and track support tickets.

The student app must never perform staff/admin actions.

### Admin app responsibilities

The admin app may allow authorized staff to manage:

- Faculties, departments, programmes, courses, curriculum maps and cohorts.
- Staff roles, permissions and work allocations.
- Notice publishing and acknowledgement tracking.
- Course registration approval and carryover/repeat confirmation.
- Assignment creation, marking, feedback and mark release.
- Question submission, moderation and exam preparation workflow.
- Exam scheduling, readiness checks, room setup and invigilator assignment.
- Invigilation room operations, check-in review, workstation/app ID status and incident follow-up.
- Session overview, escalation review and sign-off.
- Results approval, records reconciliation and student publication.
- Student support/helpdesk assignment, escalation and resolution.
- Reports and analytics.

## 3. Recommended Backend Shape

A modular monolith is the best starting point. It is easier to build, secure, test and deploy than multiple microservices at this stage.

Recommended backend stack:

- API: Go using `net/http` or a lightweight router.
- Database: PostgreSQL.
- Cache/queues: Redis.
- File storage: S3-compatible object storage such as Wasabi for documents, submissions, evidence and learning materials.
- Background jobs: internal worker process for notifications, transcript queue, report generation and file processing.
- Authentication: JWT access token plus refresh token.
- Authorization: role-based access control with scoped permissions.
- Audit: central audit log table for every admin/staff action and sensitive student action.

## 4. API Route Structure

Use two clear API namespaces:

```text
/api/v1/student/*
/api/v1/admin/*
```

Student routes must always derive the student identity from the authenticated token. The backend must not trust `student_id` from the frontend for student-owned resources.

Admin routes must derive staff identity, role, permission scope and institution scope from the authenticated token.

## 5. Core Roles

| Role | App | Main Responsibility |
|---|---|---|
| Student | Student app | Learn, register, submit, take exams, view records, request services |
| Lecturer | Admin app | Course materials, assignments, grading, question submission |
| Moderator | Admin app | Question and result review |
| Exam Officer | Admin app | Exam scheduling, readiness, release control |
| Invigilator | Admin app | Room/group operations, check-in, incident reporting |
| Chief Invigilator | Admin app | Session overview, escalation review, sign-off |
| Records Department | Admin app | Academic records, CGPA, transcript, results reconciliation |
| Department Admin | Admin app | Programme/course/cohort operations within department |
| Faculty Admin | Admin app | Faculty-level oversight |
| DLC Director | Admin app | Distance learning oversight |
| HoD | Admin app | Department academic approvals |
| Level Adviser | Admin app | Student level/cohort follow-up |
| Super Admin | Admin app | System-wide configuration and high privilege access |

## 6. Database Model Overview

### Identity and access tables

| Table | Purpose |
|---|---|
| users | Shared login account for students and staff |
| students | Student profile linked to user account |
| staff_profiles | Staff profile linked to user account |
| roles | System roles such as student, lecturer, records, exam officer |
| user_roles | User-to-role assignments |
| permissions | Permission catalogue |
| role_permissions | Role-to-permission mapping |
| permission_scopes | Department, faculty, programme, cohort, course or exam scope |
| sessions | Refresh/session tracking |
| audit_logs | Central audit trail |

Suggested important fields:

```text
users: id, email, phone, password_hash, account_type, status, last_login_at, created_at
students: id, user_id, matric_no, jamb_no, nin_ref, programme_id, level, mode, cohort_id, status
staff_profiles: id, user_id, staff_no, department_id, faculty_id, title, status
user_roles: id, user_id, role_id, scope_type, scope_id, assigned_by, created_at
permission_scopes: id, user_id, role_id, scope_type, scope_id, starts_at, ends_at
sessions: id, user_id, refresh_token_hash, device_label, ip_address, expires_at
```

### Academic structure tables

| Table | Purpose |
|---|---|
| faculties | Faculty registry |
| departments | Department registry |
| programmes | Degree/diploma programme registry |
| courses | Course catalogue |
| programme_courses | Curriculum mapping |
| cohorts | Student academic cohorts |
| cohort_students | Student-to-cohort mapping |
| academic_sessions | Academic year/session |
| semesters | Semester/calendar definition |

Suggested important fields:

```text
programmes: id, department_id, name, code, award, mode, duration_years, status
courses: id, department_id, code, title, credit_units, level, semester, course_type, status
programme_courses: id, programme_id, course_id, level, semester, requirement_type, min_grade, active_from_session_id
cohorts: id, programme_id, name, intake_year, mode, level, semester, status
cohort_students: id, cohort_id, student_id, status, joined_at, left_at
```

### Student course registration tables

| Table | Purpose |
|---|---|
| course_registration_windows | Registration open/close rules |
| course_registrations | Student registration batch |
| course_registration_items | Individual selected courses |
| carryover_confirmations | Records confirmation for repeat/carryover courses |
| registration_approvals | Department/records approval trail |

Suggested important fields:

```text
course_registrations: id, student_id, session_id, semester_id, status, total_credits, submitted_at
course_registration_items: id, registration_id, course_id, item_type, status, previous_grade, requires_approval
registration_approvals: id, registration_id, approver_id, action, note, created_at
```

### Learning, live class and notice tables

| Table | Purpose |
|---|---|
| course_materials | Lecture notes, videos, links, files |
| live_sessions | Scheduled live classes |
| live_session_attendance | Student attendance and participation |
| live_session_replays | Replay metadata |
| notices | Published notices |
| notice_targets | Audience targeting rules |
| notice_acknowledgements | Student acknowledgement tracking |

Suggested important fields:

```text
course_materials: id, course_id, title, material_type, file_url, created_by, published_at
live_sessions: id, course_id, title, starts_at, ends_at, room_url, status
notices: id, title, body, author_id, scope_type, priority, requires_ack, status, published_at
notice_targets: id, notice_id, target_type, target_id
```

### Assignment tables

| Table | Purpose |
|---|---|
| assignments | Assignment setup |
| assignment_rubrics | Marking rubric |
| assignment_submissions | Student submissions |
| submission_files | Uploaded files |
| assignment_grades | Lecturer grading and feedback |
| assignment_integrity_flags | Late, duplicate or review flags |

Suggested important fields:

```text
assignments: id, course_id, title, instructions, due_at, max_score, status, created_by
assignment_submissions: id, assignment_id, student_id, status, submitted_at, receipt_no
assignment_grades: id, submission_id, score, feedback, graded_by, released_at
```

### Exam and assessment tables

| Table | Purpose |
|---|---|
| question_banks | Question repository grouping |
| questions | Individual questions |
| question_options | Options for objective questions |
| question_assets | Images/files used in questions |
| question_sets | Lecturer-submitted exam set |
| question_set_reviews | Moderator review trail |
| exams | Exam schedule/setup |
| exam_candidates | Student mapping to exam |
| exam_attempts | Student attempt session |
| exam_responses | Student answers |
| exam_submission_receipts | Submission proof |

Supported question types should include:

- Objective/multiple choice.
- Essay/theory.
- Fill in the blank.
- Drag and drop.
- Image-based question.
- Whiteboard/drawing response.

Suggested important fields:

```text
questions: id, course_id, question_type, prompt, marks, difficulty, created_by, status
question_sets: id, course_id, title, submitted_by, review_status, total_marks
exams: id, course_id, title, mode, starts_at, ends_at, status, created_by
exam_attempts: id, exam_id, student_id, workstation_id, started_at, submitted_at, status, score
exam_responses: id, attempt_id, question_id, answer_text, answer_payload_json, score, marked_by
```

### Invigilation and exam operations tables

| Table | Purpose |
|---|---|
| exam_rooms | Physical/online exam room or group |
| exam_room_candidates | Candidate room/seat mapping |
| workstations | Registered CBT device/workstation |
| workstation_whitelist | Whitelisted app/device IDs |
| candidate_checkins | Candidate check-in events |
| exam_incidents | Incidents reported during exam |
| incident_actions | Escalation and resolution trail |
| exam_session_signoffs | Room/session closure sign-off |

Suggested important fields:

```text
workstations: id, app_id, hall_id, seat_no, status, registered_by, registered_at
workstation_whitelist: id, workstation_id, exam_id, active, approved_by, approved_at
candidate_checkins: id, exam_id, student_id, room_id, workstation_id, identity_status, checked_in_by, checked_in_at
exam_incidents: id, exam_id, student_id, room_id, incident_type, severity, status, reported_by, reported_at
exam_session_signoffs: id, exam_id, room_id, signed_by, candidate_count_ok, submissions_synced, unresolved_incidents, status
```

### Results and academic records tables

| Table | Purpose |
|---|---|
| result_batches | Lecturer course result submission batch |
| result_items | Student score/grade per course |
| result_reviews | Moderator/HoD/records review trail |
| academic_records | Final student academic record rows |
| cgpa_snapshots | CGPA by session/semester |
| transcript_requests | Official transcript request |
| transcript_request_events | Transcript review/dispatch trail |
| unofficial_transcript_views | Optional record of generated student copies |
| graduation_maps | Cached graduation progress summary |
| graduation_map_items | Remaining/completed requirement rows |

Suggested important fields:

```text
result_batches: id, course_id, session_id, semester_id, submitted_by, status, submitted_at
result_items: id, batch_id, student_id, ca_score, exam_score, total_score, grade, grade_point, status
academic_records: id, student_id, course_id, session_id, semester_id, credit_units, grade, grade_point, status
transcript_requests: id, student_id, request_no, delivery_method, recipient_name, recipient_contact, purpose, status
```

### Internship/SIWES tables

| Table | Purpose |
|---|---|
| internship_profiles | Student placement profile |
| internship_letters | Placement letter requests |
| internship_acceptance_letters | Employer acceptance upload |
| internship_logbooks | Weekly logbook entries |
| internship_supervisor_reviews | Institution/employer review status |

Suggested important fields:

```text
internship_profiles: id, student_id, programme_id, preferred_industry, organization_name, status
internship_letters: id, student_id, request_no, status, issued_file_url, requested_at
internship_logbooks: id, student_id, week_no, activity_summary, file_url, status, submitted_at
```

### Support/helpdesk tables

| Table | Purpose |
|---|---|
| support_tickets | Student support ticket |
| support_ticket_messages | Student/staff replies |
| support_ticket_files | Evidence attachments |
| support_ticket_assignments | Staff ownership history |
| support_ticket_events | Ticket lifecycle events |

Suggested important fields:

```text
support_tickets: id, ticket_no, student_id, category, subject, description, priority, status, current_owner_id, created_at
support_ticket_messages: id, ticket_id, sender_id, sender_type, message, created_at
support_ticket_events: id, ticket_id, event_type, actor_id, note, created_at
```

### File storage tables

| Table | Purpose |
|---|---|
| files | Stored file metadata |
| file_links | Link a file to a domain object |

Suggested important fields:

```text
files: id, owner_id, bucket, object_key, file_name, mime_type, size_bytes, checksum, created_at
file_links: id, file_id, entity_type, entity_id, purpose
```

## 7. Authorization and Scope Model

Every request must pass through:

1. Authentication middleware.
2. Role loading.
3. Scope validation.
4. Permission validation.
5. Audit decision.

Examples:

- Student reading transcript preview: token user must match transcript student.
- Lecturer grading assignment: lecturer must be assigned to the course.
- Moderator reviewing questions: moderator must be assigned to course/department/review batch.
- Invigilator handling check-in: invigilator must be assigned to the exam room/session.
- Records officer editing academic record: user must have records permission and action must be audited.

## 8. Audit Log Model

Every sensitive action should write to `audit_logs`.

Audit fields:

```text
audit_logs: id, actor_user_id, actor_role, action, entity_type, entity_id, before_json, after_json, ip_address, user_agent, created_at
```

Audit required for:

- Role/permission changes.
- Academic structure changes.
- Cohort assignment or promotion.
- Course registration approval/rejection.
- Result edit/reconciliation/release.
- Transcript request review and dispatch.
- Exam setup and closure.
- Incident escalation/resolution.
- Support ticket assignment, escalation and resolution.

## 9. Backend Build Order

### Phase 1: Foundation

1. Auth and JWT.
2. Users, students, staff, roles and permissions.
3. Audit log middleware.
4. Academic structure tables.
5. Student profile and dashboard summary.

### Phase 2: Student academic services

1. Courses and curriculum.
2. Course registration.
3. Academic record.
4. Graduation mapping.
5. Transcript request and unofficial preview.
6. Internship/SIWES.
7. Student support tickets.

### Phase 3: Learning and assessment

1. Course materials.
2. Live sessions and replays.
3. Assignments and submissions.
4. Question bank and question review.
5. Exam setup, attempts and responses.

### Phase 4: Operations and records

1. Invigilation rooms and check-in.
2. Workstation/app ID whitelist.
3. Exam incidents and sign-off.
4. Results batching and approval.
5. Records reconciliation and CGPA.
6. Notices and acknowledgements.

### Phase 5: Reporting

1. Management summary.
2. Student progress reports.
3. Exam operations reports.
4. Support SLA reports.
5. Attendance and live-class reports.

## 10. Non-Negotiable Rules

- No Finance/Billing until contract approval.
- Student app must not contain admin actions.
- Admin app must not impersonate student actions except through approved support/records workflows.
- Every admin action must be scoped, permission-checked and audited.
- Every student query must be filtered by authenticated student ID.
- Every file upload must be virus-scanned or marked pending scan before staff use.
- Every generated official document must have a request number and audit trail.
- Every exam attempt must have a submission receipt or offline recovery record.
