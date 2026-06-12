# Closed-testing release candidate runbook

This runbook describes the local release-candidate preflight and handoff flow for the Nurtly closed-testing build.

It is a local execution guide only. It does not commit private release values, build artifacts, screenshots, or Play Console exports.

## Purpose

- Prepare a safe closed-testing release candidate from the current branch.
- Validate signing-file presence without exposing private values.
- Record the AAB build and smoke-test handoff steps.
- Keep the repo clean and separate from local release evidence.

## Prerequisites

- Current local repo path: `C:\Serwer\Projekty\Nurtly`
- The current branch is the intended release-candidate branch.
- Flutter/Dart are available on the local machine when app verification is needed.
- Local signing files exist outside git and are ready for release use.
- No private Play Console exports, screenshots, or production IDs are committed.

## Exact preflight commands

Run these commands from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File tools/release_preflight_check.ps1
git diff --check
git status --short
```

If app code or Flutter config changes unexpectedly, also run:

```powershell
powershell -ExecutionPolicy Bypass -File tools/pre_pr_check.ps1
```

## Signing-file existence checks

Check the local release signing files without printing private contents:

```powershell
Test-Path app\android\key.properties
Test-Path app\android\upload-keystore.jks
```

If a different local keystore file is used, verify its existence only. Do not print passwords or file contents.

## AAB build command

From the repository root:

```powershell
cd app
flutter build appbundle --release
```

## Expected output path

- From `C:\Serwer\Projekty\Nurtly`: `app/build/app/outputs/bundle/release/app-release.aab`
- From `C:\Serwer\Projekty\Nurtly\app`: `build/app/outputs/bundle/release/app-release.aab`

## What must not be committed

- `app/android/key.properties`
- `app/android/*.jks`
- `app/android/*.keystore`
- `*.aab`
- `*.apk`
- local Play Console exports or notes with private data
- passwords, tokens, or other private release values

## How to verify `git status`

After preflight and build steps, run:

```powershell
git status --short
```

The working tree should stay clean except for intentional docs or code changes that belong to the release task.
Any generated release artifact or signing file must stay outside git.

## Smoke-test order

1. Install the release AAB on a real device.
2. Confirm startup and navigation.
3. Confirm localization in English and Polish.
4. Confirm Play, Sounds, Journal, Premium, ads, and Privacy / Data flows.
5. Confirm the release smoke test notes are written down in the evidence template.

## Monetization runtime matrix

Record the following cases in the evidence notes and keep them aligned with the QA checklist:

- monthly purchase
- yearly purchase
- pending purchase
- canceled purchase
- failed purchase
- restore success
- restore with no purchase
- restore after reinstall
- Premium after restart
- Premium ad suppression
- Free banner behavior in allowed areas only
- blocked Journal, active audio, Settings, Privacy, legal, paywall, and startup flows
- ad failure remains non-blocking

Relevant automated coverage lives in:

- `app/test/core/monetization/google_play_billing_entitlement_provider_test.dart`
- `app/test/core/monetization/ad_policy_test.dart`
- `app/test/features/home/home_screen_test.dart`
- `app/test/features/play/play_screen_test.dart`
- `app/test/features/sounds/sounds_screen_test.dart`
- `app/test/features/journal/journal_screen_test.dart`
- `app/test/features/privacy/privacy_data_screen_test.dart`
- `app/test/app_shell_test.dart`
- `app/test/core/monetization/premium_paywall_sheet_test.dart`

Use these docs as the test references:

- [Release smoke test](../qa/release_smoke_test.md)
- [MVP manual QA checklist](../qa/mvp_manual_qa_checklist.md)

## Artifact handoff notes

- Keep the AAB local until it is uploaded by the owner in Play Console.
- Copy only the artifact path and non-sensitive results into the evidence template.
- Keep Play Console exports and screenshots outside git.
- Do not store release artifacts in the repository.

## Failure handling

- If signing files are missing, stop and resolve them locally before building.
- If `git diff --check` fails, fix whitespace or line-ending issues before proceeding.
- If `git status --short` shows release artifacts or signing files, remove them from git tracking or move them outside the repo.
- If the release smoke test fails, do not upload the build until the issue is understood.

## Final owner checklist

- [ ] Local signing files exist and stay out of git.
- [ ] Preflight checks passed.
- [ ] AAB built successfully at the expected path.
- [ ] Smoke-test evidence was recorded.
- [ ] `git status --short` is clean of release artifacts and private release values.
- [ ] No Google Play submission was performed from the repository.
- [ ] No private release configuration was committed.
- [ ] No production IDs were committed.
