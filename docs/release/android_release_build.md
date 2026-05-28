# Android release build

This note covers the Android MVP release build path for Nurtly.

## Prerequisites

- `flutter test` passes locally.
- `tools/pre_pr_check.ps1` passes locally.
- Android release signing is set up through `app/android/key.properties`.
- Google Play App Signing is enabled in Play Console.
- Production ad IDs, billing products, privacy URL, and Data Safety answers are ready before public release.

## Commands

Run the quality and release checks from the repository root `C:\Projekty\Nurtly`:

```powershell
powershell -ExecutionPolicy Bypass -File tools/pre_pr_check.ps1
cd app
flutter build appbundle --release
```

If you prefer to run Flutter checks directly inside `app`, the equivalent bundle command is:

```powershell
cd app
flutter build appbundle --release
```

## Expected output

- From `C:\Projekty\Nurtly`: `app/build/app/outputs/bundle/release/app-release.aab`
- From `C:\Projekty\Nurtly\app`: `build/app/outputs/bundle/release/app-release.aab`

## Manual smoke before upload

Before uploading the bundle, verify on a real device or emulator:

- app starts cleanly
- language switching works
- Play screens load
- Premium paywall opens and restore is reachable
- free users see ads where expected
- premium users do not see ads
- Journal entries can be added and restored locally
- Sounds playback still works

## Release checklist reminders

Before public release, make sure these are ready outside the repo:

- production ad IDs
- Google Play Billing products and prices
- privacy policy URL
- Data Safety answers in Play Console
- store listing assets and copy
