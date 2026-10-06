# Athletica

Athletica is a Flutter fitness and coaching app with client and coach workflows for workouts, nutrition, progress check-ins, and communication.

## Features

- Authentication, onboarding, and profile setup.
- Coach and client management, assigned plans, and workout sessions.
- Nutrition plans and templates.
- Progress check-ins, streaks, and achievements.
- Chat with media support and push notifications.
- Profile and account settings.

## Getting started

Use a Flutter SDK with Dart **3.11.4 or a compatible 3.x version**, as required by `pubspec.yaml`. Android development requires the Android SDK (compile SDK 36), Java 17, and an emulator or connected device. The Android app requires API 24 or newer.

From the repository root, create local environment files from [.env.example](.env.example). In PowerShell:

```powershell
Copy-Item .env.example .env.dev
Copy-Item .env.example .env.prod
```

Configure each file for its environment:

| Variable | Purpose |
| --- | --- |
| `BASE_URL` | Backend API base URL, including the API path and trailing slash. |
| `APP_NAME` | Name used by `AppConfig`; Android launcher names are configured separately in Gradle. |
| `SENTRY_DSN` | Sentry project DSN for error reporting; defaults to an empty string. |

Blank values use the defaults in [app_config.dart](lib/core/config/app_config.dart). Both environment files must exist because they are declared as Flutter assets. They are ignored by Git but bundled into the app: use only public client configuration, never secrets or private API keys.

Install dependencies and check the local toolchain:

```sh
flutter pub get
flutter doctor
```

The app integrates with a backend, Firebase Messaging, Google Sign-In, Ably, and Sentry. Use the project's service configuration when testing these integrations. Android uses the Google Services Gradle plugin; Firebase configuration must match the flavor's application ID.

## Run the app

Keep the Android flavor, Dart entry point, and environment file matched:

| Flavor | Entry point | Environment file | Android application ID |
| --- | --- | --- | --- |
| `dev` | `lib/main_dev.dart` | `.env.dev` | `com.example.athletica.dev` |
| `prod` | `lib/main_prod.dart` | `.env.prod` | `com.example.athletica` |

```sh
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor prod -t lib/main_prod.dart
```

VS Code provides equivalent **Athletica (dev)** and **Athletica (prod)** launch configurations. These commands target the configured Android flavors; platform folders alone do not establish equivalent flavor or integration support on other platforms.

## Project structure

```text
lib/
  athletica_app.dart        App root, theme, routing, and ScreenUtil
  main_dev.dart            Development bootstrap
  main_prod.dart           Production bootstrap
  core/                    Shared configuration, DI, errors, networking,
                           services, utilities, helpers, and widgets
  features/
    <feature>/
      data/                Data sources, models, repository implementations
      domain/              Entities, repository interfaces, use cases
      presentation/        Screens, widgets, Cubits/Blocs, and states
assets/                    Fonts, icons, images, and animations
scripts/                   Release and Firebase distribution scripts
test/                      Flutter tests
```

The project follows Clean Architecture: screens call Cubits, Cubits call use cases, and use cases depend on repository interfaces implemented by the data layer. Presentation and data depend on domain; domain stays independent of Flutter and data implementations.

- State management: `flutter_bloc`, with sealed-class states.
- Dependency injection: `get_it`, registered in [injection_container.dart](lib/core/di/injection_container.dart).
- Networking: Dio; JSON serialization is manual.
- Error handling: data boundaries map exceptions to typed failures; repositories and use cases return `ApiResult<T>`; presentation maps failures to UI messages.
- Responsive layout: `flutter_screenutil`.
- Shared code used in two or more places belongs in `core/`.
- Freezed, `build_runner`, and Retrofit must not be introduced.

## Development checks

Read [CLAUDE.md](CLAUDE.md) and [AGENTS.MD](AGENTS.MD) before contributing. Run static analysis for Dart changes:

```sh
flutter analyze
```

Run tests when test files are available:

```sh
flutter test
flutter test test/path/to/file_test.dart
flutter test --plain-name "test name"
```

The `test/` directory currently contains no test files. New tests should mirror `lib/` paths, use the installed `flutter_test` package and hand-written fakes, and initialize `ScreenUtil` for widgets that depend on it. Bug fixes require a deterministic reproducing test. There is no configured CI or pre-commit pipeline; analysis and tests are local checks.

## Android release builds

Build an APK without running the distribution scripts:

```sh
flutter build apk --flavor dev --target lib/main_dev.dart --release
flutter build apk --flavor prod --target lib/main_prod.dart --release
```

The current Android release configuration uses debug signing. Configure release signing before a store release.

For authorized Firebase App Distribution releases, the repository provides:

- `scripts/distribute_dev.ps1` for development on Windows.
- `scripts/distribute_dev.sh` for development on macOS.
- `scripts/distribute_prod.ps1` for production on Windows.

These scripts increment the patch version and build number in `pubspec.yaml`, clean the build, fetch dependencies, build the matching release APK, and distribute it to the Firebase `testers` group. They require an authenticated Firebase CLI with access to the configured project. Run them only for an intended distribution, not as a development check.
