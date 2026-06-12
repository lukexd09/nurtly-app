# Release smoke test

Use this checklist on a real device or emulator before uploading a release build to Google Play.

Run it:

- before the AAB build if possible, to catch obvious UI or release-flow regressions early,
- after installing from the release artifact,
- after upload or in internal / closed testing when the Play Console flow is available.

## Test context

- [ ] Build type:
- [ ] Track:
- [ ] Tester group:
- [ ] Device:
- [ ] OS version:
- [ ] App version:
- [ ] Language:
- [ ] Tester:
- [ ] Date:

## Startup

- [ ] App installs successfully.
- [ ] App launches without crashing.
- [ ] Bottom navigation is visible.
- [ ] No debug-only UI is visible.
- [ ] Release package name and version match the closed-testing gate.
- [ ] No analytics provider UI or consent flow appears on launch.

## Localization

- [ ] Polish is available and renders correctly.
- [ ] English is available and renders correctly.
- [ ] Core tabs are localized.
- [ ] No obvious English strings appear in the Polish flow.
- [ ] Material pickers/dialogs are localized where applicable.

## Play / activities

- [ ] Activity list loads.
- [ ] Free and Premium chips are visible.
- [ ] Filters work.
- [ ] Free/Premium filter works.
- [ ] Activity detail opens.
- [ ] Ad placement does not break layout.
- [ ] Premium gating behaves as expected.
- [ ] No interstitial or rewarded ad surfaces appear.

## Sounds

- [ ] Sound list loads.
- [ ] Sound detail/player opens.
- [ ] Playback starts and stops.
- [ ] Only one sound plays at a time.
- [ ] Timer works.
- [ ] Fade-out works if present.
- [ ] Loop behavior works if present.
- [ ] Ads do not interrupt active playback.
- [ ] Premium gating behaves as expected.
- [ ] Sounds behavior matches the release contract document.

## Journal

- [ ] Journal tab opens.
- [ ] Selected day navigation works.
- [ ] Custom day picker opens.
- [ ] Start sleep works.
- [ ] Stop sleep creates an entry.
- [ ] Manual sleep can be added.
- [ ] Feeding can be added.
- [ ] Diaper can be added.
- [ ] Note can be added.
- [ ] Each entry type can be edited.
- [ ] Each entry type can be deleted.
- [ ] Entries persist after app restart.
- [ ] Journal create/edit flow stays calm and ad-free.
- [ ] Journal data stays local-only in the device flow.

## Premium / Billing

- [ ] Paywall opens.
- [ ] Monthly plan is visible.
- [ ] Yearly plan is visible.
- [ ] Restore purchases is visible.
- [ ] Purchase flow can be triggered on a test track.
- [ ] Cancelled or failed purchase does not unlock Premium.
- [ ] Premium hides ads.
- [ ] Billing behavior matches the closed-testing gate and does not prompt for analytics.

## Ads

- [ ] Free user ad placements render or fail gracefully.
- [ ] Premium user sees no ads.
- [ ] No ads appear in Journal create/edit.
- [ ] No ads appear during active sound playback.
- [ ] No layout crash occurs when an ad fails to load.
- [ ] No rewarded or interstitial ads appear anywhere.

## Privacy / Settings

- [ ] Privacy & Data screen opens.
- [ ] Local-only Journal copy is visible.
- [ ] Premium and Settings screens open.
- [ ] Language setting persists.
- [ ] Restore purchases is reachable.
- [ ] No product analytics provider prompt or consent flow appears.

## Offline / basic fallback

- [ ] App opens without network where possible.
- [ ] Bundled content still works.
- [ ] Failed ad load does not break the app.
- [ ] Basic Play, Sounds, and Journal flows remain usable.
- [ ] The app remains usable with the current closed-testing release configuration.

## Final result

| Result | Notes | Blockers | Screenshots / videos |
| --- | --- | --- | --- |
| PASS / FAIL |  |  |  |
