# MVP manual QA checklist

Use this checklist before closed testing or production rollout. Keep notes short and practical.

## App shell / navigation

- [ ] Test: Open the app from a cold start. Expected result: App lands in the shell without errors. Notes:
- [ ] Test: Switch between the main tabs. Expected result: Navigation stays stable and state does not reset unexpectedly. Notes:
- [ ] Test: Open Home, Play, Sounds, Journal, and Settings from the shell. Expected result: Each module opens correctly. Notes:

## Localization

- [ ] Test: Switch to Polish. Expected result: Core UI copy is Polish and consistent. Notes:
- [ ] Test: Switch to English. Expected result: Core UI copy is English and consistent. Notes:
- [ ] Test: Open dialogs and pickers in both languages. Expected result: Material controls are localized. Notes:

## Play

- [ ] Test: Browse play ideas. Expected result: Content loads and cards render cleanly. Notes:
- [ ] Test: Filter by access and content. Expected result: Filters narrow results as expected. Notes:
- [ ] Test: Open a play detail page. Expected result: Detail content renders and back navigation works. Notes:
- [ ] Test: Free vs Premium gating. Expected result: Premium items respect the paywall or access state. Notes:

## Sounds

- [ ] Test: Open Sounds from the shell. Expected result: The Sounds tab opens without errors. Notes:
- [ ] Test: Browse sounds. Expected result: Sound list loads and artwork/text render correctly. Notes:
- [ ] Test: Start a sound. Expected result: Playback starts from the primary control. Notes:
- [ ] Test: Pause and resume a sound. Expected result: Playback toggles predictably from the primary control. Notes:
- [ ] Test: Stop behavior. Expected result: There is no dedicated stop control in the current MVP and the screen behavior matches the release contract. Notes:
- [ ] Test: Start a second sound while one is active. Expected result: Leaving the first sound detail and opening a second sound works cleanly. Notes:
- [ ] Test: Use timer controls. Expected result: 15, 30, 60, and continuous play states behave as documented. Notes:
- [ ] Test: Fade-out behavior. Expected result: Fade-out occurs near the end of a timed session and does not break playback. Notes:
- [ ] Test: Loop / continuous play. Expected result: Continuous play keeps looping in the current MVP behavior. Notes:
- [ ] Test: Loading and error states. Expected result: Calm loading and error states are visible when content or playback fails. Notes:
- [ ] Test: Audio license metadata expectations. Expected result: Bundled sound source/license provenance is documented or marked `Needs owner confirmation`. Notes:
- [ ] Test: Background audio expectation. Expected result: Background audio is explicitly treated as post-MVP and is not expected in release QA. Notes:
- [ ] Test: Premium sounds. Expected result: Premium gating behaves correctly. Notes:

## Journal

- [ ] Test: Open the Journal tab. Expected result: Journal dashboard renders without overflow. Notes:
- [ ] Test: Navigate between days. Expected result: Selected day updates consistently. Notes:
- [ ] Test: Add sleep, feeding, diaper, and note entries. Expected result: Each entry saves and appears on the timeline. Notes:
- [ ] Test: Edit each entry type. Expected result: Changes persist and the right type remains selected. Notes:
- [ ] Test: Delete each entry type. Expected result: Deleted entry disappears after confirmation. Notes:
- [ ] Test: Restart the app after saving entries. Expected result: Entries persist locally. Notes:

## Premium / Billing

- [ ] Test: Open the paywall. Expected result: Monthly and yearly plans are visible. Notes:
- [ ] Test: Restore purchases. Expected result: Premium entitlement restores when a valid purchase exists. Notes:
- [ ] Test: Cancel a purchase. Expected result: Premium is not unlocked. Notes:
- [ ] Test: Fail a purchase flow. Expected result: Premium is not unlocked and the app remains usable. Notes:

## Ads

- [ ] Test: Open Home as a free user. Expected result: A passive banner appears only in the allowed browse area. Notes:
- [ ] Test: Open Home as a Premium user. Expected result: No ad placeholder is shown. Notes:
- [ ] Test: Use the app as a free user. Expected result: Only passive banner-style ads appear in the allowed browse areas. Notes:
- [ ] Test: Use the app as a Premium user. Expected result: Ads are not shown anywhere. Notes:
- [ ] Test: Open Journal while ads are enabled. Expected result: No ads appear during create or edit flows. Notes:
- [ ] Test: Play a sound while ads are enabled. Expected result: No ads appear during active audio playback. Notes:
- [ ] Test: Open Settings or Privacy & Data while ads are enabled. Expected result: No ads appear in sensitive settings or legal flows. Notes:
- [ ] Test: Restart the app from a cold start. Expected result: No ad appears in the startup path before the main shell is stable. Notes:
- [ ] Test: Simulate ad load failure. Expected result: The screen stays usable and the ad area collapses gracefully without a crash. Notes:

## Privacy / Data

- [ ] Test: Open Privacy & Data in English. Expected result: Parent-first, local-only, ads, and analytics wording is visible. Notes:
- [ ] Test: Open Privacy & Data in Polish. Expected result: Polish copy matches the MVP behavior. Notes:
- [ ] Test: Verify Journal content stays local. Expected result: No backend or sync behavior appears in the flow. Notes:
- [ ] Test: Verify child name and exact birthdate are not required. Expected result: The screen does not imply those fields are required. Notes:
- [ ] Test: Verify ads wording. Expected result: Free-plan ad wording is calm and non-manipulative. Notes:
- [ ] Test: Verify analytics wording. Expected result: Any analytics wording stays limited to quality, module usage, retention, ads, and errors. Notes:
- [ ] Test: Check settings persistence. Expected result: Language and user preferences persist. Notes:

## Analytics

- [ ] Test: Review the analytics release note. Expected result: The allowed categories are limited to language, locale, approximate region, app version, module usage, retention, ad events, and errors/crashes. Notes:
- [ ] Test: Verify forbidden data boundaries. Expected result: Journal note content, child name, exact birthdate, health data, and child profiling are explicitly out of scope. Notes:
- [ ] Test: Review app start and module taxonomy. Expected result: Only session basics and module open events are described for Play, Sounds, Journal, and Settings. Notes:
- [ ] Test: Review ad analytics wording. Expected result: Ad events stay aligned with the proposed MVP ad contract and do not include Journal or child payloads. Notes:
- [ ] Test: Review provider decisions. Expected result: Provider, SDK, consent, and retention-window choices are marked `Needs owner confirmation` if not yet final. Notes:
- [ ] Test: Review the provider decision note. Expected result: MVP release recommendation is no product analytics provider or SDK, with implementation deferred unless owner approval changes the plan. Notes:
- [ ] Test: Verify no analytics SDK appears in the build scope. Expected result: Release notes and docs do not imply a hidden provider integration. Notes:

## Release build / install

- [ ] Test: Build and install the release artifact. Expected result: App installs and launches from the release build. Notes:
- [ ] Test: Re-open after install. Expected result: App resumes without startup regressions. Notes:
- [ ] Test: Run with no network. Expected result: Core offline-friendly flows still work. Notes:

## Store / Play Console

- [ ] Test: Verify listing assets are ready. Expected result: Screenshots, icon, feature graphic, and descriptions are complete. Notes:
- [ ] Test: Verify Data Safety answers. Expected result: Answers match actual app behavior. Notes:
- [ ] Test: Verify privacy policy URL. Expected result: Public privacy policy is reachable. Notes:
