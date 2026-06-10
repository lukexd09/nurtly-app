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

- [ ] Test: Use the app as a free user. Expected result: Ad placements load or fail gracefully. Notes:
- [ ] Test: Use the app as a Premium user. Expected result: Ads are not shown. Notes:
- [ ] Test: Open Journal while ads are enabled. Expected result: No ads interrupt create/edit flows. Notes:
- [ ] Test: Play a sound while ads are enabled. Expected result: Ads do not interrupt playback. Notes:

## Privacy / Data

- [ ] Test: Open Privacy & Data in English. Expected result: Parent-first, local-only, ads, and analytics wording is visible. Notes:
- [ ] Test: Open Privacy & Data in Polish. Expected result: Polish copy matches the MVP behavior. Notes:
- [ ] Test: Verify Journal content stays local. Expected result: No backend or sync behavior appears in the flow. Notes:
- [ ] Test: Verify child name and exact birthdate are not required. Expected result: The screen does not imply those fields are required. Notes:
- [ ] Test: Verify ads wording. Expected result: Free-plan ad wording is calm and non-manipulative. Notes:
- [ ] Test: Verify analytics wording. Expected result: Any analytics wording stays limited to quality, module usage, retention, ads, and errors. Notes:
- [ ] Test: Check settings persistence. Expected result: Language and user preferences persist. Notes:

## Release build / install

- [ ] Test: Build and install the release artifact. Expected result: App installs and launches from the release build. Notes:
- [ ] Test: Re-open after install. Expected result: App resumes without startup regressions. Notes:
- [ ] Test: Run with no network. Expected result: Core offline-friendly flows still work. Notes:

## Store / Play Console

- [ ] Test: Verify listing assets are ready. Expected result: Screenshots, icon, feature graphic, and descriptions are complete. Notes:
- [ ] Test: Verify Data Safety answers. Expected result: Answers match actual app behavior. Notes:
- [ ] Test: Verify privacy policy URL. Expected result: Public privacy policy is reachable. Notes:
