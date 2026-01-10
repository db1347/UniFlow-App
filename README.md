# UniFlow — Student Productivity Suite

UniFlow is a multi-platform Flutter app designed to help students plan, track, and stay on top of university life. It brings together a dashboard, todos, countdowns, calendar, and events—with personalization features, localization, and an optional Android home screen widget for quick actions.

## Overview

- **Platforms:** Android, iOS, Web, Windows, macOS, Linux (Flutter).
- **Focus:** Fast, local-first experience—no external services required.
- **Branding:** App header shows “UniFlow”; package name is `students_app`.

## Features

- **Dashboard:** At-a-glance overview with quick access to your main tools.
- **Todos:** Create, edit, and manage tasks with reminders and repeat options.
- **Countdowns:** Track days to exams, deadlines, and milestones.
- **Calendar:** Day/week/month views with localized dates and RTL support.
- **Events:** Plan semester activities and timelines.
- **Settings:** Theme selection, language (English/Hebrew), and display options.
- **Android Widget (optional):** Home screen widget for quick actions and settings.
- **Localization:** English and Hebrew with RTL-aware layouts.
- **Persistence:** Local storage via `SharedPreferences` for instant, offline access.

## Tech Stack

- **Flutter** UI with Material design components.
- **Riverpod** for state management across features.
- **GoRouter** for simple, declarative navigation (`/`, `/todo`, `/calendar`, `/settings`).
- **SharedPreferences** for local persistence, mirroring typical web localStorage.
- **Google Fonts (Work Sans)** for consistent typography.

## Project Structure

- `lib/core`: App routing, theme, localization, constants, and shared providers.
- `lib/features`: Feature modules (`dashboard`, `todos`, `calendar`, `countdowns`, `events`, `settings`).
- `lib/shared/widgets`: Common UI components (e.g., header, menus, controls).
- `assets/`: Icons and web assets consumed by the app.

## Getting Started

1. Install Flutter (3.9+ recommended) and set up an emulator or device.
2. Fetch dependencies:
   ```sh
   flutter pub get
   ```
3. Run on Android:
   ```sh
   flutter devices
   flutter run -d <android-device-id>
   ```
4. Run on iOS (requires Xcode/macOS):
   ```sh
   flutter devices
   flutter run -d <ios-device-id>
   ```
5. Run on web/desktop (where supported):
   ```sh
   flutter run -d chrome
   flutter run -d windows
   flutter run -d macos
   flutter run -d linux
   ```

### Hot Reload / Restart

- Use `r` (reload) and `R` (restart) in the Flutter CLI or your IDE.

## Android Home Screen Widget

- The project includes an AppWidget implementation that can trigger in-app actions.
- Add the widget from your launcher’s widget picker; actions may open the app and present a bottom sheet for quick settings.
- Behavior depends on your launcher/OS version; ensure the app has been opened at least once for stable widget-method channel communication.

## Configuration & Data

- No cloud services or API keys required—data is stored locally.
- To reset app data, clear storage for the app on your device/emulator.

## Localization

- Supported locales: English (`en`) and Hebrew (`he`).
- RTL is respected across screens and navigation.

## Development

- Code guidelines follow `flutter_lints`; see `analysis_options.yaml` for rules.
- Feature-first structure encourages modular additions and isolated testing.
- Tests run with:
  ```sh
  flutter test
  ```

## Roadmap

- Additional widget actions and configuration.
- Extended events planning and reminders.
- More theme variants and personalization options.

## Notes

- Minimum SDKs: Android 21+, iOS 13+.
- This repository is private (`publish_to: none`).
