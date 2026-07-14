# Closed Testing Upload Handoff

This document is the practical handoff for producing and uploading the closed-testing Android `aab` for the Nurtly MVP.

It is intentionally release-only. It does not include private signing values, production IDs, or Google Play submission steps.

For the local release-candidate execution flow, use the [Closed-testing release candidate runbook](closed_testing_release_candidate_runbook.md) and record evidence in [Closed-testing release candidate evidence](closed_testing_release_candidate_evidence.md).
For privacy URL handoff, use [Privacy policy publication handoff](../legal/privacy_policy_publication_handoff.md).

## Exact local pre-check commands

Run these commands from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File tools/pre_pr_check.ps1
git diff --check
git status --short
```

## Exact AAB build command

From the repository root:

```powershell
cd app
flutter build appbundle --release
```

## Expected output path

- From `C:\Serwer\Projekty\Nurtly`: `app/build/app/outputs/bundle/release/app-release.aab`
- From `C:\Serwer\Projekty\Nurtly\app`: `build/app/outputs/bundle/release/app-release.aab`

## Local files that must exist but stay outside git

- `app/android/key.properties`
- `app/android/upload-keystore.jks` or the locally chosen upload keystore file
- any local Play Console export or notes file that contains private release data
- any local evidence file that contains private release data

## What to verify before uploading

- `tools/pre_pr_check.ps1` passes.
- `git diff --check` is clean.
- `git status --short` is clean.
- the release AAB was built from the intended branch on current `main`.
- the AAB path above exists.
- the app opens, shows the correct language, and reaches the shell cleanly on a real device.
- the release smoke test passes for the relevant device and install state.
- the release-candidate evidence template is ready to be filled locally.

## What to check in Google Play Console

- app entry exists and package name matches `com.graylion.nurtly`
- release track is the intended closed-testing track
- tester group and invite link are prepared
- signing and upload flow are ready
- store listing fields are complete enough for closed testing
- privacy policy URL is approved and live, and the live SSOT is kept aligned
- privacy policy publication handoff is reviewed and the approved live URL is known
- Data Safety answers match the actual app behavior
- content rating and target audience are ready
- billing products are ready if Premium is being exercised in testing

## Owner decisions still required

- public privacy URL remains https://nurtly.graylion.pl/privacy and must stay aligned with the live SSOT
- final privacy policy publication handoff remains aligned with the approved live URL
- final store listing copy and assets
- final Data Safety answers
- final content rating and target audience settings
- final closed-testing tester group and invite flow
- final Google Play Billing products and pricing confirmation
- final production ad app and ad unit IDs for public release

## What blocks upload

- missing or invalid local signing files
- failing `tools/pre_pr_check.ps1`
- failing `git diff --check`
- missing release AAB
- mismatched package name, version, or signing expectations
- critical Play Console fields missing for the closed-testing track

## What blocks public release

- unapproved privacy policy URL or drift from the live SSOT
- privacy policy publication handoff not reviewed
- incomplete store assets or listing copy
- incomplete Data Safety answers
- incomplete content rating or target audience setup
- missing production ad IDs
- missing public release billing confirmation

## Notes

- This handoff is safe to share because it contains no private release values.
- It should be used together with the closed-testing release gate and the Google Play checklist.
