# UniMateX

Your academic companion — track attendance, manage your timetable, never miss an assignment, and keep your notes synced across devices.

## Features

- **Smart Attendance Tracking** — Mark present/absent per subject, see your percentage at a glance, get danger/warning zones, and know exactly how many classes you can safely skip (bunk calculator).
- **Weekly Timetable** — A timeline view of your schedule with live "Now / Next" indicators, per-day class counts, and tap-to-edit.
- **Assignments & Deadlines** — Track tasks with due dates, filter by status, and get reminders a day before they're due.
- **Quick Notes** — Jot down lecture highlights instantly, searchable and synced to the cloud.
- **Notifications** — Optional reminders 15 minutes before class and before assignment deadlines.
- **Cloud Sync** — All data is stored in Firebase and available on every device you sign in to.
- **Secure** — Per-user Firestore security rules ensure only you can access your data. Account deletion wipes everything.

## Screenshots

_Add your Play Store screenshots here._

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Backend / Database | Firebase (Auth, Cloud Firestore) |
| Local Cache | Hive |
| Navigation | GoRouter |
| Notifications | flutter_local_notifications + timezone |
| Fonts | Google Fonts (Inter) |
| Icons | Lucide Icons |

## Project Structure

```
lib/
├── core/           # Theme, colors, router, constants, services
├── data/           # Remote sources (Firestore), local cache, repository implementations
├── domain/         # Models, repository interfaces, use cases
├── presentation/   # Screens, providers, widgets
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.5.3)
- A Firebase project with Authentication and Cloud Firestore enabled
- Android Studio or VS Code with Flutter extension

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/YOUR_USERNAME/UniMateX.git
   cd UniMateX
   ```

2. **Firebase configuration**
   This project requires Firebase. The config files are gitignored for security.
   - Run `flutterfire configure` to generate `lib/firebase_options.dart`
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run**
   ```bash
   flutter run
   ```

### Release Build

1. Generate an upload keystore (see `android/key.properties` template).
2. Place the `.jks` file in `android/app/`.
3. Update `android/key.properties` with your credentials.
4. Build:
   ```bash
   flutter build appbundle
   ```

## Security

- Signing keys (`*.jks`, `key.properties`) are gitignored and never committed.
- Firebase config files are gitignored. Each developer generates their own via `flutterfire configure`.
- Firestore security rules restrict all data to the authenticated user's own subtree.

## Website

A landing page with Privacy Policy and Account Deletion instructions is in `docs/` and designed for GitHub Pages (Settings → Pages → Source: `/docs`).

## License

This project is proprietary. All rights reserved by Maadhu Apps.

---

Made with ❤️ by Maadhu
