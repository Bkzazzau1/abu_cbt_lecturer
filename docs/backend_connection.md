# Backend connection

The admin UI now has a backend connection layer for the live K-SLAS Go API.

## Build with live VPS URL

Use Flutter dart-define when building the web app:

```bash
flutter build web --release --dart-define=KSLAS_API_BASE_URL=https://YOUR-BACKEND-DOMAIN-OR-IP
```

If the admin UI and backend are served from the same domain, the app automatically uses the current web origin.

## Connected endpoints

The first connected screen reads lecturer assessments from:

```txt
GET /api/lecturer/assessments
```

The API service also supports:

```txt
POST /api/lecturer/assessments
POST /api/lecturer/assessments/{id}/publish
POST /api/lecturer/assessments/{id}/close
```

## Current UI entry

A floating `Live backend` button appears on the admin dashboard. It opens the live lecturer assessment panel and displays records returned from the backend.

Next step: move this panel directly into the Lecturer workspace under `Exam Questions` after the backend authentication and course ID flow are finalized.
