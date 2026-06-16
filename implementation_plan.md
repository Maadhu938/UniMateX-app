# UniMateX Complete Polish & Feature Upgrade Plan

## Goal
Implement a fully functional profile screen, adjust the timetable layout, and introduce major new features requested: Firestore Cloud Sync, AdMob monetization, real Local Notifications, functional Account Deletion, and Play Store ready legal texts.

## Phase 1: Core UX Improvements (Previous Requests)
### 1. Global Attendance Target
- Create a `SettingsService` backed by Hive to manage the global attendance target and read this value instead of the hardcoded `0.75` in the Attendance screen.
### 2. Functional Profile Screen
- Add an "Edit Name" dialog to update Firebase Auth profile name.
- Remove "demo" look and implement a premium, functional profile UI.
### 3. Vertical Timetable Layout
- Stack the Timetable day labels vertically (`M\nO\nN`, etc.) so all 6 days comfortably fit horizontally.
### 4. Empty State & Quick Actions Adjustments
- **Tasks Empty State**: Use `LucideIcons.listTodo` instead of the same icon as Notes.
- **Attendance Empty State**: Hide the "Danger Zone" circle if there are 0 subjects.
- **Home Screen**: Remove the redundant "Quick Actions" card.
- **Notes Screen**: Show the "Saved!" snackbar instantly before the async save.
- **Login/Signup**: Remove the confusing top-right decorative circle from `WavePainter`.

## Phase 2: Major New Features
### 5. AdMob Monetization
- **Dependency**: Add `google_mobile_ads` to `pubspec.yaml`.
- **Implementation**: Initialize AdMob in `main.dart`. Create an `AdService` to load and show a 5-second Interstitial Ad. We will trigger this ad either on app launch (AppOpenAd style) or at a specific logical interval.

### 6. Firestore Cloud Sync
- **Implementation**: Create a `CloudSyncService` that listens to local Hive changes and mirrors them to a Firestore collection (`users/{userId}/data`).
- When the user logs in on a new device, the sync service will pull the data from Firestore and populate the local `AcademicLocalStore` so their attendance, timetable, and assignments are restored.

### 7. Functional Account Deletion
- Update the "Delete Account" button in `profile_screen.dart` to trigger a thorough deletion sequence:
  1. Wipe all cloud data from Firestore (`users/{userId}`).
  2. Delete the user from Firebase Auth.
  3. Wipe the local Hive cache (`HiveService.clearAll()`).

### 8. Real Local Notifications
- **Dependency**: Add `flutter_local_notifications` to `pubspec.yaml`.
- **Implementation**: Replace the demo "Notifications" switches in the Profile screen with real logic that uses the local notifications plugin. When enabled, it will schedule reminders for Assignments (e.g., due tomorrow) and upcoming Timetable classes.

### 9. Play Store Ready Legal Texts
- Replace the dummy Help Center and Privacy Policy texts in `policy_screen.dart` with comprehensive, professionally formatted legal documentation suitable for Google Play Console review.

---
## User Review Required
> [!IMPORTANT]
> Since we are adding **Cloud Sync** and **AdMob Ads**, this will require adding new dependencies and slightly altering how the app starts up. Are you okay with the plan to use an Interstitial Ad that shows occasionally to generate revenue, and using `flutter_local_notifications` for the reminders?
