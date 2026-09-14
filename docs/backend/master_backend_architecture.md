# ABU CBT Admin backend scope

Ahmadu Bello University, Zaria.

The supported staff roles are Lecturer (`lecturer`), Moderator (`moderator`), Exam Officer (`exam_officer`), HoD (`hod`), and General ICT Admin (`ict_admin`).

The backend must validate tokens, role assignments, departmental/course scope, and permissions on every endpoint. Unsupported roles must not receive portal access. The client rejects unsupported sign-in roles and prevents assigning roles outside this list.

Preserve the existing lecturer, moderator, exam-officer, academic-setup, and staff API contracts during integration. The General ICT Admin manages staff accounts and system configuration. Backend changes and production deployment are separate integration work; this repository contains the Flutter client.
