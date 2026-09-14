# KSLAS Admin UI

Flutter admin console for KSLAS academic operations across Android, iOS, web, desktop, and PWA.

## Current Scope

This repository owns all non-student portals and administrative workflows.

- Lecturer Portal
- Moderator Portal
- Invigilator Portal
- Exam Officer Portal
- Records Department Portal
- Department Admin Portal
- Faculty Admin Portal
- HoD Portal
- Level Adviser Portal
- DLC Director Portal
- Super Admin Portal

## Workflows Owned Here

- Lecturer course notices, assignments, marking, question preparation, and result recommendations.
- Moderator question review, rubric checks, and moderation feedback.
- Exam officer exam scheduling, notice publishing, question approval, invigilation oversight, and result release.
- Records department student records, cohorts, course registration audit, carryover/repeat approval, CGPA and transcript preview.
- Department/faculty curriculum, programme, staff allocation, course registration rules, and academic compliance.
- Invigilator candidate check-in, hall monitoring, malpractice reports, and incident escalation.

## Student App Separation

The student-only app is `k-slas-my-course`.

That app should contain only student-facing screens such as:

- student courses
- student course registration
- student academic record and CGPA view
- student assignment submission
- student exams
- student live classes
- student results
- student noticeboard
- student notifications

Any lecturer, exam officer, records, invigilator, moderator, HoD, department, faculty, or admin workflow belongs in this repository.

## Run

```sh
flutter pub get
flutter run -d chrome
flutter run -d windows
```

## Build Targets

```sh
flutter build web --pwa-strategy offline-first
flutter build apk
flutter build windows
```
