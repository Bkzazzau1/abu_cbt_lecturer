# ABU CBT Admin

CBT administration for **Ahmadu Bello University, Zaria**. Built with Flutter for web, Android, iOS, Windows, macOS, and Linux.

## Staff portals

- Lecturer: course delivery, assessment and question preparation, marking, and result submission.
- Moderator: question review, moderation feedback, and assessment quality checks.
- Exam Officer: examination readiness, timetables, moderation tracking, eligibility, and result verification.
- HoD: departmental academic supervision, lecturers, courses, moderation, and results.
- General ICT Admin: university-wide staff access, academic setup, examination operations, and system oversight.

These are the only supported portal roles. Unknown and removed roles are denied portal access. Staff assignment uses `lecturer`, `moderator`, `exam_officer`, `hod`, and `ict_admin`. Existing `admin`, `system_admin`, and `super_admin` codes are accepted as aliases for General ICT Admin.

## Development

```sh
flutter pub get
flutter run --dart-define=ABU_CBT_API_BASE_URL=https://YOUR-BACKEND-DOMAIN-OR-IP
flutter analyze
flutter test
```

The backend URL must be configured for the university deployment. Web otherwise uses the current origin; native apps use localhost:8080. Backend authorisation must enforce the same five-role scope. Some inherited dashboards use demonstration data.

Local folder: `abu cbt admin`. Dart package: `abu_cbt_admin`.
