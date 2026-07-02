# Nurtly Final MVP Release Readiness

## Executive Summary

Assessment date: `2026-06-14`

Assessed commit: `0b412e5a9c18a0b11af40da200c7cc87f6aef78d`

Assessed branch: `codex/issue-158-final-mvp-release-readiness`

Overall status: `BLOCKED`

Repo-side readiness status: `BLOCKED`

Owner-side readiness status: `BLOCKED`

Play Console readiness status: `BLOCKED`

Current status addendum:

- The 2026-06-14 audit below is historical and partially superseded by later release evidence.
- Signed AAB evidence and Internal Testing installation evidence are now recorded in `docs/release/internal_testing_0_1_0_1_evidence.md`.
- Manual reviewer QA for the signed Internal Testing build is documented in the evidence pack and checklist updates.
- Android signing and Android build/install evidence are resolved in the release evidence pack.
- `#212` and `#213` remain open and keep the release blocked.
- `#104` and `#125` remain open.

The repository-side MVP release shape is broadly coherent: Home, Play, Sounds, Journal, Privacy & Data, ads policy, localization, and the monetization flows all have code, tests, and release documentation aligned with the current MVP contract. The release pack is still blocked because release-critical evidence is incomplete for audio licensing BLK-002, store assets, privacy publication, Play Console setup, and the open issues tracked in `#212` and `#213`.

## Current Assessment

- App behavior is mostly in line with the release contract already documented in `docs/release/`.
- At the time of the 2026-06-14 audit, the repo did not contain a final release blocker register, so one was added in `docs/release/final_release_blockers.md`.
- At the time of the 2026-06-14 audit, the repo did not contain a final readiness summary, so this document became the single repo-side source of truth for closed-testing go/no-go.
- Background audio is explicitly deferred post-MVP.
- Interstitial ads, rewarded ads, cloud sync, accounts, backend validation, analytics SDKs, and production IDs remain out of scope.

## Scope

- Review the current repo-side MVP release readiness across code, tests, docs, and release assets.
- Consolidate the release-critical blockers into one authoritative register.
- Record evidence-based closure recommendations for #125, #127, and #131.
- Keep owner-only Play Console and hosting actions separate from repo-side evidence.

## Out of Scope

- Play Console submission.
- Production rollout.
- Creating or committing private release values, signing keys, `.aab`, `.apk`, `.jks`, `.keystore`, or `key.properties`.
- New SDKs, dependencies, analytics providers, backend services, or ad formats.
- Background audio architecture changes.
- Lock-screen or notification controls.
- Major UI redesign or broad refactoring.

## Changed Files / Affected Areas

- `docs/release/final_mvp_release_readiness.md`
- `docs/release/final_release_blockers.md`
- `docs/release/audio_asset_license_inventory.md`
- `docs/release/store_asset_inventory.md`
- `docs/release/store_screenshot_plan.md`
- `docs/release/README.md`
- Supporting release docs updated to link the authoritative final pack

## #104 Acceptance Traceability

| Area | Implementation location | Test location | Documentation location | Result | Remaining owner action |
| --- | --- | --- | --- | --- | --- |
| Monetization, purchases, restore, Free/Premium gating | `app/lib/core/monetization/*`, `app/lib/core/navigation/app_shell.dart` | `app/test/core/monetization/*`, `app/test/core/navigation/*`, `app/test/app_shell_test.dart` | `docs/release/ads_mvp_behavior.md`, `docs/release/monetization_ads_config.md`, `docs/release/google_play_submission_content_pack.md` | `PASS WITH OWNER ACTION` | Confirm Play Console billing products, prices, and final production IDs. |
| Ads behavior and blocked-flow rules | `app/lib/core/ads/ad_widget_factory.dart`, `app/lib/core/monetization/ad_policy.dart`, screen placements in `app/lib/features/*` | `app/test/core/monetization/ad_policy_test.dart`, `app/test/features/home/home_screen_test.dart`, `app/test/features/play/play_screen_test.dart`, `app/test/features/sounds/sounds_screen_test.dart` | `docs/release/ads_mvp_behavior.md`, `docs/release/data_safety.md`, `docs/release/play_console_owner_decisions.md` | `PASS WITH OWNER ACTION` | Confirm Advertising ID and any final ad-disclosure decisions in Play Console. |
| Play, Sounds, Journal, startup, Settings, and Privacy & Data UX | `app/lib/core/navigation/app_shell.dart`, `app/lib/features/play/*`, `app/lib/features/sounds/*`, `app/lib/features/journal/*`, `app/lib/features/privacy/*`, `app/lib/features/home/*` | `app/test/app_shell_test.dart`, `app/test/features/play/play_screen_test.dart`, `app/test/features/sounds/sounds_screen_test.dart`, `app/test/features/journal/journal_screen_test.dart`, `app/test/features/privacy/privacy_data_screen_test.dart` | `docs/release/closed_testing_go_no_go.md`, `docs/release/closed_testing_release_gate.md`, `docs/qa/release_smoke_test.md`, `docs/qa/mvp_manual_qa_checklist.md` | `PASS WITH OWNER ACTION` | Complete the final device smoke test and closed-testing evidence capture; the reviewer-access shell coverage is now in place. |
| Localization EN/PL | `app/lib/core/localization/app_strings.dart` | `app/test/core/localization/privacy_strings_test.dart`, `app/test/app_shell_test.dart`, `app/test/content_loader_test.dart` | `docs/release/google_play_submission_content_pack.md`, `docs/release/store_listing.md`, `docs/legal/privacy_policy_en.md`, `docs/legal/privacy_policy_pl.md` | `PASS` | None in repo; keep final public copy aligned with the published policy URL. |
| Privacy and Data policy surfaces | `app/lib/features/privacy/privacy_data_screen.dart`, privacy string constants in `app/lib/core/localization/app_strings.dart` | `app/test/features/privacy/privacy_data_screen_test.dart`, `app/test/core/localization/privacy_strings_test.dart` | `docs/legal/privacy_policy_en.md`, `docs/legal/privacy_policy_pl.md`, `docs/legal/privacy_policy_publication_handoff.md`, `docs/legal/public/privacy_policy.md`, `docs/legal/public/privacy_policy_en.md`, `docs/legal/public/privacy_policy_pl.md`, `docs/release/data_safety.md` | `PASS WITH OWNER ACTION` | Publish the live privacy URL and replace all placeholders outside the repo. |
| Store listing, target audience, content rating, and Families posture | Store copy and submission handoff docs | `app/test/app_shell_test.dart`, `app/test/features/privacy/privacy_data_screen_test.dart` | `docs/release/store_listing.md`, `docs/release/google_play_submission_content_pack.md`, `docs/release/play_console_owner_decisions.md` | `PASS WITH OWNER ACTION` | Finish Play Console audience, content-rating, and Families posture decisions. |
| Store assets and screenshots | Current repo assets and release docs | N/A for exported store assets | `docs/release/store_asset_inventory.md`, `docs/release/store_screenshot_plan.md`, `docs/release/feature_graphic_brief.md`, `docs/release/store_assets_checklist.md` | `BLOCKED` | Export final icon, feature graphic, and screenshot set. |
| Android technical release config, permissions, signing, and release build | `app/pubspec.yaml`, `app/android/app/build.gradle`, `app/android/app/src/main/AndroidManifest.xml`, `app/android/app/src/debug/AndroidManifest.xml`, `app/android/app/src/profile/AndroidManifest.xml` | `docs/release/internal_testing_0_1_0_1_evidence.md`, `docs/release/README.md` | `docs/release/android_release_build.md`, `docs/release/android_signing.md`, `docs/release/internal_testing_0_1_0_1_evidence.md` | `PASS` | Historical signed AAB, upload, and tester-install evidence are captured in the evidence pack. |
| Content loading and validation | `app/assets/content/*`, `app/lib/core/content/*`, `content/*` | `app/test/content_loader_test.dart`, `app/test/content_repository_test.dart` | `docs/release/google_play_submission_content_pack.md`, `docs/release/store_listing_copy.md` | `PASS` | Keep source content and published content aligned if new content is added. |
| Performance, install sanity, and smoke coverage | Startup, release install, and content loading paths in the app shell | `app/test/app_shell_test.dart`, `app/test/features/home/home_screen_test.dart`, `app/test/features/play/play_screen_test.dart`, `app/test/features/sounds/sounds_screen_test.dart`, `app/test/features/journal/journal_screen_test.dart` | `docs/qa/release_smoke_test.md`, `docs/qa/mvp_manual_qa_checklist.md`, `docs/release/closed_testing_release_candidate_runbook.md` | `PASS WITH OWNER ACTION` | Run the real-device smoke pass and record the evidence outside git. |
## Sounds Readiness

- Playback: `FAIL`
- Timer: `PASS WITH OWNER ACTION`
- Loop: `PASS WITH OWNER ACTION`
- Fade-out: `PASS WITH OWNER ACTION`
- Lifecycle: `BLOCKED`
- Background audio decision: `DEFERRED POST-MVP`
- Licensing: `BLOCKED`
- #125 recommendation: `keep open` until bundled sound provenance is documented or assets are replaced

Evidence:

- `app/lib/features/sounds/sounds_screen.dart`
- `app/lib/features/sounds/audio/looping_sound_loader.dart`
- `app/test/features/sounds/sounds_screen_test.dart`
- `docs/release/sounds_mvp_behavior.md`
- `docs/release/audio_asset_license_inventory.md`

Release notes:

- The implementation exists for the in-screen audio player, timer presets, looping, and fade-out.
- `sounds_screen_test.dart` covers rendering, navigation, premium gating, and ad placement, but it does not exercise the real audio-player runtime, countdown behavior, fade-volume transition, or app lifecycle transitions on a device.
- Real-device verification still failed in the Play-installed Android release build tracked by `#212`.
- Background audio remains a post-MVP decision rather than a closed-testing requirement.
- Missing or unclear sound provenance remains recorded separately in the release register, but it is not the current blocker addressed by this addendum.

## Privacy and Data Readiness

- In-app screen: `PASS`
- EN/PL: `PASS`
- Journal local-only alignment: `PASS`
- Ads / purchases / analytics alignment: `PASS WITH OWNER ACTION`
- Privacy URL status: `BLOCKED`
- #127 recommendation: `close after owner confirmation`

Evidence:

- `app/lib/features/privacy/privacy_data_screen.dart`
- `app/test/features/privacy/privacy_data_screen_test.dart`
- `app/test/core/localization/privacy_strings_test.dart`
- `docs/legal/privacy_policy_en.md`
- `docs/legal/privacy_policy_pl.md`
- `docs/legal/privacy_policy_publication_handoff.md`
- `docs/legal/public/privacy_policy.md`
- `docs/legal/public/privacy_policy_en.md`
- `docs/legal/public/privacy_policy_pl.md`
- `docs/release/data_safety.md`

Release notes:

- The app is parent/caregiver-facing and not child-directed.
- Journal remains local-only in the current implementation.
- The public policy body matches the shipped MVP behavior described in the repo.
- The live policy URL and publication timestamp are still owner-side actions.

## Ads Readiness

- Free placements: `PASS`
- Premium suppression: `PASS`
- Blocked flows: `PASS`
- Failure behavior: `PASS`
- Manifest/config: `PASS WITH OWNER ACTION`
- #131 recommendation: `close after owner confirmation`

Evidence:

- `app/lib/core/ads/ad_widget_factory.dart`
- `app/lib/core/monetization/ad_policy.dart`
- `app/test/core/monetization/ad_policy_test.dart`
- `app/test/features/home/home_screen_test.dart`
- `app/test/features/play/play_screen_test.dart`
- `app/test/features/sounds/sounds_screen_test.dart`
- `docs/release/ads_mvp_behavior.md`
- `docs/release/data_safety.md`
- `docs/release/play_console_owner_decisions.md`

Release notes:

- Free users only see passive banner placements in approved browse areas.
- Premium users do not construct or display banner placeholders in the blocked flows.
- No interstitial, rewarded, or startup ad expansion is in the MVP contract.
- Final ad IDs and ad-disclosure decisions remain owner-confirmed Play Console work.

## Store Listing Readiness

- EN copy: `PASS WITH OWNER ACTION`
- PL copy: `PASS WITH OWNER ACTION`
- Target audience: `PASS WITH OWNER ACTION`
- Families posture: `PASS WITH OWNER ACTION`
- Content rating: `PASS WITH OWNER ACTION`
- Ads declaration: `PASS WITH OWNER ACTION`
- Subscriptions: `PASS WITH OWNER ACTION`
- Privacy URL: `BLOCKED`

Evidence:

- `docs/release/store_listing.md`
- `docs/release/store_listing_copy.md`
- `docs/release/google_play_submission_content_pack.md`
- `docs/release/play_console_owner_decisions.md`
- `docs/legal/privacy_policy_publication_handoff.md`

## Store Asset Inventory

- Icon: `BLOCKED`
- Adaptive icon: `BLOCKED`
- Feature graphic: `BLOCKED`
- Phone screenshots: `BLOCKED`
- EN assets: `BLOCKED`
- PL assets: `BLOCKED`
- Remaining owner exports: final icon set, feature graphic, screenshot exports, and any Play Console asset uploads

Evidence:

- `docs/release/store_asset_inventory.md`
- `docs/release/store_screenshot_plan.md`
- `docs/release/feature_graphic_brief.md`
- `docs/release/store_assets_checklist.md`
- `app/android/app/src/main/res/drawable/ic_launcher.xml`

## Android Technical Release Audit

- Application ID: `PASS`
- Version: `PASS`
- SDK configuration: `PASS`
- Permissions: `PASS`
- Signing: `PASS`
- Android build environment / install sanity: `PASS`
- Debug/release separation: `PASS`
- Production ID separation: `PASS WITH OWNER ACTION`

Evidence:

- `app/pubspec.yaml`
- `app/android/app/build.gradle`
- `app/android/app/src/main/AndroidManifest.xml`
- `app/android/app/src/debug/AndroidManifest.xml`
- `app/android/app/src/profile/AndroidManifest.xml`
- `docs/release/android_release_build.md`
- `docs/release/android_signing.md`

Notes:

- Signed AAB generation and install evidence are recorded in `docs/release/internal_testing_0_1_0_1_evidence.md`.
- Historical build-environment issues are now archived as resolved evidence rather than current blockers.

## Content and Localization Validation

- JSON parsing and bundled content validation: `PASS`
- Required EN/PL fields: `PASS`
- Draft-only content exposure: `PASS`
- Premium/free flags: `PASS`
- App UI and bundled user content contain no release placeholder copy: `PASS`
- Legal publication templates still contain tracked owner placeholders: `BLOCKED under BLK-004`

Evidence:

- `app/test/content_loader_test.dart`
- `app/test/content_repository_test.dart`
- `app/test/core/localization/privacy_strings_test.dart`
- `app/test/app_shell_test.dart`

## Manual Verification Still Required

- Real-device Sounds verification.
- Final Play Console entry, audience, rating, billing, and tester-group setup.
- Privacy policy publication and live URL confirmation.
- Final store asset export and upload.

## Remaining Blockers

See the authoritative register in `docs/release/final_release_blockers.md`.

## Deferred Post-MVP Items

- Background audio.
- Lock-screen controls.
- Notification controls.
- Interstitial ads.
- Rewarded ads.
- Startup ads.
- Personalized ad expansion.
- Analytics SDK/provider integration.
- Cloud sync and accounts.

## Issue Closure Recommendations

- `#125`: keep open until bundled audio provenance is documented or the bundled assets are replaced.
- `#127`: close after owner confirmation for the live privacy URL and Play Console publication steps.
- `#131`: close after owner confirmation for the final Play Console ad configuration and disclosures.
- `#104 remains open`: do not close automatically.
- `#212`: keep open until bundled Sounds playback succeeds in the Google Play Android release build.
- `#213`: keep open until Home daily idea Premium gating is fixed and verified.

## Automated Verification

| Command | Result | Notes |
| --- | --- | --- |
| `tools/pre_pr_check.ps1` | `NOT RUN IN THIS TASK` | Covered by historical release evidence; not rerun in this correction-only task. |
| `tools/release_preflight_check.ps1` | `NOT RUN IN THIS TASK` | Covered by historical release evidence; not rerun in this correction-only task. |
| `git diff --check` | `PASS` | Clean diff format. |
| `git status --short` | `PASS` | Clean before and after the verification rerun. |
| `flutter pub get` | `PASS` | Ran from `app/` with `C:\src\flutter\bin` on `PATH`. |
| `dart format --output=none --set-exit-if-changed .` | `PASS` | No formatting changes required on the final checked state. |
| `flutter analyze` | `PASS` | No issues found. |
| `flutter test` | `PASS` | All app tests passed. |
| `flutter build apk --debug` | `NOT RUN IN THIS TASK` | Covered by historical release evidence; not rerun in this correction-only task. |
| `flutter build appbundle --release` | `NOT RUN IN THIS TASK` | Covered by historical release evidence; not rerun in this correction-only task. |

## Final Go / No-Go Recommendation

No-go for closed testing until the blockers in `docs/release/final_release_blockers.md` are resolved.

Public release is deferred until the same blockers and the Play Console owner actions are completed.
