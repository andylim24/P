<!-- .github/copilot-instructions.md: Guidance for AI coding agents working in this repo -->
# PESO_APP — Copilot / AI Agent instructions

This file contains concise, actionable knowledge to help an AI coding agent be immediately productive in this Flutter repository.

- Quick context: PESO Makati mobile/web app (Flutter) with Firebase backend (Auth, Firestore, Storage). Entry: `lib/main.dart` and `lib/main_homepage.dart`.

1) Key files and places to read first
- `lib/main.dart` — Firebase initialization / app entry.
- `lib/main_homepage.dart` — shared app shell (`MainScaffold`), global UI layout, and `cachedUserName` usage.
- `lib/auth/main_page.dart` and `lib/auth/auth_page.dart` — auth flow; `auth/main_page.dart` uses `FirebaseAuth.instance.authStateChanges()` to decide routes.
- `lib/admin_page/` — admin dashboard (job posting, announcements, analytics).
- `lib/homepage parts/`, `lib/top navigations/`, `lib/widgets/` — UI sections and reusable widgets.
- `lib/widgets/jobseeker_form_data.dart` — primary domain model for jobseeker profiles; look for `toFirestore()` / `fromFirestore()` methods to see Firestore shape.
- `firebase_options.dart` and `android/app/google-services.json` — Firebase config locations.

2) Architecture and patterns (short)
- Frontend-only Flutter app using StatefulWidgets and local state. No Provider/Riverpod/Bloc is used — expect state to be passed through constructors or kept in StatefulWidgets.
- Navigation uses `PageRouteBuilder` with zero-duration transitions for instant switches (see `main_homepage.dart`).
- Responsive breakpoints: 800px (mobile vs desktop) and ~1000px for admin sidebar vs drawer. UI adapts by switching scaffold/drawer patterns.
- Firebase is the single backend: Auth (users), Cloud Firestore (primary data), Firebase Storage (file uploads). Expect Firestore collections for users and jobseeker profiles.

3) Developer workflows & useful commands
- Get dependencies: `flutter pub get` (or `flutter pub upgrade` when updating deps).
- Run app: `flutter run` (omit device for device chooser). Examples:
  - Web: `flutter run -d chrome`
  - Windows desktop: `flutter run -d windows`
- Build artifacts:
  - Web: `flutter build web` (output: `build/web/`)
  - Android APK: `flutter build apk`
  - Android App Bundle: `flutter build appbundle`
- Analysis & tests:
  - Static analysis: `flutter analyze`
  - Tests: `flutter test` (single file: `flutter test test/widget_test.dart`)

4) Repo-specific conventions and gotchas
- State: Most screens are `StatefulWidget`. When modifying UI/data flows, prefer following existing local-state patterns unless adding a project-wide state library and updating all callers.
- Caching: `cachedUserName` in `main_homepage.dart` is used globally; do not assume other global state managers exist.
- Data model serialization: Domain classes (e.g. `JobseekerFormData`) provide `toFirestore()` / `fromFirestore()` — use these when reading/writing Firestore to preserve schema.
- File uploads: Resumes/docs go through Firebase Storage integrations (see usages in jobseeker/admin pages).
- Navigation: Some pages expect near-instant transitions; preserve `PageRouteBuilder` zero-duration behavior where UX depends on it.

5) Integration and cross-component communication
- Authentication state is observed with `FirebaseAuth.instance.authStateChanges()` in `lib/auth/main_page.dart`; use this as the canonical source for routing decisions.
- Firestore reads/writes are the primary way UI components communicate server-side state. Inspect `toFirestore()` / `fromFirestore()` methods for exact field names and nested structures.
- Storage uploads are used for files; ensure security rules and paths match `firebase_options.dart` project id `makati-peso` and Android `google-services.json` placement.

6) Tests & verification
- There is a basic widget test at `test/widget_test.dart`. Run `flutter test` to validate changes quickly.
- After dependency or platform changes, run `flutter pub get` then `flutter analyze` and `flutter test` as a smoke-check.

7) When editing or adding features — checklist for PRs
- Keep local-state pattern consistent unless you propose a migration and update call sites.
- Update `JobseekerFormData` serialization if adding/removing profile fields; run/verify Firestore reads/writes.
- If adding native Firebase configuration, ensure `firebase_options.dart` and platform files (`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`) are updated.

8) Where to look for examples in the codebase
- Job profile serialization: `lib/widgets/jobseeker_form_data.dart`
- Auth-driven routing: `lib/auth/main_page.dart` and `lib/auth/auth_page.dart`
- Main scaffold & responsive patterns: `lib/main_homepage.dart`

If anything here is unclear or you want more detail (e.g., Firestore collection names, sample document shapes, or how admin analytics are computed), tell me which area to expand and I'll update this file.
