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

- [ ] Test: Browse sounds. Expected result: Sound list loads and artwork/text render correctly. Notes:
- [ ] Test: Start and stop a sound. Expected result: Playback behaves predictably. Notes:
- [ ] Test: Start a second sound while one is active. Expected result: Only one sound remains active. Notes:
- [ ] Test: Use timer and fade-out controls if present. Expected result: Controls work and do not break playback. Notes:
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

- [ ] Test: Open Privacy & Data. Expected result: Local-only and privacy copy is visible. Notes:
- [ ] Test: Verify Journal content stays local. Expected result: No backend or sync behavior appears in the flow. Notes:
- [ ] Test: Check settings persistence. Expected result: Language and user preferences persist. Notes:

## Release build / install

- [ ] Test: Build and install the release artifact. Expected result: App installs and launches from the release build. Notes:
- [ ] Test: Re-open after install. Expected result: App resumes without startup regressions. Notes:
- [ ] Test: Run with no network. Expected result: Core offline-friendly flows still work. Notes:

## Store / Play Console

- [ ] Test: Verify listing assets are ready. Expected result: Screenshots, icon, feature graphic, and descriptions are complete. Notes:
- [ ] Test: Verify Data Safety answers. Expected result: Answers match actual app behavior. Notes:
- [ ] Test: Verify privacy policy URL. Expected result: Public privacy policy is reachable. Notes:

