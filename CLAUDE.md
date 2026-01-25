# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PESO Makati Website Application - A Flutter web/mobile application for the Public Employment Service Office (PESO) of Makati City, Philippines. The app serves jobseekers who can browse jobs, register profiles, and track applications, as well as admins who manage job postings and announcements.

## Common Commands

```bash
# Run the application
flutter run

# Run on specific device/platform
flutter run -d chrome          # Web
flutter run -d windows         # Windows desktop

# Build for deployment
flutter build web              # Web build (output: build/web/)
flutter build apk              # Android APK
flutter build appbundle        # Android App Bundle

# Static analysis (linting)
flutter analyze

# Run tests
flutter test                   # All tests
flutter test test/widget_test.dart  # Single test file

# Get dependencies
flutter pub get
```

## Architecture

### Entry Point and Navigation Flow
- `main.dart` initializes Firebase and launches `HomePage`
- `main_homepage.dart` contains `MainScaffold` (shared app shell with AppBar/Drawer) and `HomePage` (landing page)
- Navigation uses `PageRouteBuilder` with zero transition duration for instant page switches

### Authentication
- `auth/auth_page.dart` - Toggles between `LoginPage` and `RegisterPage`
- `auth/main_page.dart` - StreamBuilder on `FirebaseAuth.instance.authStateChanges()` for auth state
- Admin users are redirected to `AdminHomepage` after login

### Key Directories
- `lib/admin_page/` - Admin dashboard: job posting, job management, analytics, announcements
- `lib/homepage parts/` - Homepage sections: home, announcements, about us, footer
- `lib/top navigations/` - Main navigation pages: job listings, services, contacts, profile
- `lib/widgets/` - Reusable components and data models (e.g., `JobseekerFormData`)

### Data Models
- `JobseekerFormData` (`widgets/jobseeker_form_data.dart`) - Comprehensive jobseeker profile with personal info, employment history, education, skills. Includes `toFirestore()` and `fromFirestore()` methods.
- Supporting models: `TrainingEntry`, `EligibilityEntry`, `LicenseEntry`, `WorkExperienceEntry`

### Firebase Integration
- **Firebase Auth** - User authentication
- **Cloud Firestore** - Data storage (users collection, jobseeker profiles)
- **Firebase Storage** - File uploads (resumes, documents)
- Configuration in `firebase_options.dart`, project ID: `makati-peso`

### Responsive Design
- Desktop/Mobile breakpoint at 800px width
- `MainScaffold` shows drawer navigation on mobile, horizontal nav on desktop
- Admin dashboard uses 1000px breakpoint for sidebar vs drawer

## State Management

- Uses StatefulWidget with local state
- Global `cachedUserName` variable in `main_homepage.dart` for username caching
- No external state management library (Provider, Riverpod, etc.)

## Key Dependencies

- `firebase_auth`, `cloud_firestore`, `firebase_storage` - Firebase services
- `google_fonts` - Typography
- `cached_network_image` - Image caching
- `file_picker`, `image_picker` - File/image selection
- `syncfusion_flutter_pdfviewer` - PDF viewing
- `fl_chart` - Charts for analytics
- `flutter_map`, `google_maps_flutter` - Maps integration
