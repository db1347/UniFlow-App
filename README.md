# ChronoStyle Flutter

ChronoStyle is a faithful Flutter recreation of the original Loveable web experience. It ships with the complete countdown dashboard, todo manager, multi-view calendar, and personalization settings so that every interaction, animation, and data flow mirrors the source project on both iOS and Android.

## Highlights

- **Riverpod state management** keeps countdowns, todos, calendar events, and user settings in sync with persisted data via `SharedPreferences`.
- **GoRouter navigation** mirrors the web routes (`/`, `/todo`, `/calendar`, `/settings`) with shared header and bottom navigation for parity.
- **Custom theming & localization** match the original theme palette (10 variants) and English/Hebrew copy, including RTL handling.
- **Feature parity** covers mini countdown editing, todo reminders with repetition, calendar day/week/month layouts, semester planning, and localized dialogs/toasts.

## Project Structure

- `lib/core`: routing, localization, theming, shared providers, and constants.
- `lib/features`: feature-specific models, controllers, and screens (dashboard, todos, calendar, settings, events).
- `lib/shared/widgets`: reusable UI elements like the header, bottom navigation, and countdown displays.
- `assets/web`: original static assets (favicon, placeholder, robots) referenced from the Flutter app.

## Running the App

1. **Install Flutter 3.19+** and set up at least one iOS simulator or Android emulator/device.
2. Fetch dependencies:
   ```sh
   flutter pub get
   ```
3. **Android**: launch an emulator (or connect a device) and run
   ```sh
   flutter run -d <android-device-id>
   ```
4. **iOS**: open an iOS Simulator (or connect a device with Xcode configured) and run
   ```sh
   flutter run -d <ios-device-id>
   ```
5. For hot reload/hot restart use `r` / `R` in the Flutter CLI or your IDE tooling.

## Environment & Configuration

- No external services or secrets are required. All data persists locally via `SharedPreferences` to mirror the browser `localStorage` usage from the web project.
- To reset sample data, clear the app storage on your device/simulator.

## Notes

- Minimum SDKs: **Android SDK 21**, **iOS 13.0**.
- The app uses Google Fonts (Work Sans) and the provided assets to ensure pixel-parity with the web design.
