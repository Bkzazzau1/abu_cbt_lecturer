# Backend connection

Configure the backend for Ahmadu Bello University, Zaria:

```sh
flutter run --dart-define=ABU_CBT_API_BASE_URL=https://YOUR-BACKEND-DOMAIN-OR-IP
flutter build web --release --dart-define=ABU_CBT_API_BASE_URL=https://YOUR-BACKEND-DOMAIN-OR-IP
```

Web defaults to its current origin; native apps default to `http://localhost:8080`. No inherited production server is configured.

Staff sign-in uses `/api/auth/login`. Lecturer question preparation uses `/api/lecturer/assessments`. Staff management uses `/api/staff`, `/api/departments`, and `/api/courses`.

The backend must support the five role codes documented in the README and enforce permissions on each request. This client update does not provision a university backend. Some panels still display demonstration data inherited from the original project.
