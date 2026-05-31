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

From the repo root:

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File tools/pre_pr_check.ps1
```
