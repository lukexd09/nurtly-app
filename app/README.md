# Nurtly Flutter App

Flutter mobile app for parents and caregivers.

## Current modules

- `lib/core/navigation`
- `lib/core/theme`
- `lib/core/localization`
- `lib/core/content`
- `lib/core/monetization`
- `lib/core/ads`
- `lib/features/home`
- `lib/features/play`
- `lib/features/sounds`
- `lib/features/journal`

## Runtime content

The MVP uses bundled JSON content from:

- `app/assets/content/nurtly_content_en_v1.json`
- `app/assets/content/nurtly_content_pl_v1.json`

## Journal note

Journal data is local-only in the current MVP implementation.

## Premium / Billing / Ads

Current MVP monetization uses monthly and yearly product IDs, premium entitlement, and test/placeholder ad configuration. Premium users are expected to see no ads.

### UMP consent flow

- On Android, the app requests UMP consent info during startup.
- The app only allows banner requests after `canRequestAds()` becomes true.
- If privacy options are required, the Privacy & Data screen shows `Privacy choices` / `Ustawienia prywatności reklam`.
- Banner ads are not initialized before consent allows requests.
- Debug EEA testing is enabled only in debug builds.
- Local debug test device IDs can be passed with `--dart-define=UMP_TEST_DEVICE_IDS=ID1,ID2`.

### Local data deletion

- The Privacy & Data screen includes `Delete all local data` / `Usuń wszystkie dane lokalne`.
- The action deletes local journal entries and safe resettable preferences.
- It does not touch Google Play purchase history.
- The UI returns to the empty journal state after deletion succeeds.

## Run locally

From the repo root:

```powershell
cd app
flutter pub get
flutter run
```

From `app/`:

```powershell
flutter pub get
flutter run
```

## Verify

From `app/`:

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
```

From the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File tools/pre_pr_check.ps1
```
