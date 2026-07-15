# Data Safety preparation

The canonical evidence draft is [Third-party SDK inventory and Data Safety evidence draft](third_party_sdk_inventory.md). This worksheet is retained as a short release pointer; do not treat it as a submitted or approved Play Console response.

For the current authoritative release status and blocker list, see [Final MVP release readiness](final_mvp_release_readiness.md) and [Final release blockers](final_release_blockers.md).

This worksheet helps prepare the Google Play Data Safety answers for the first MVP release.

This document is not legal advice. Final answers must match the actual production behavior and Play Console configuration.

## Purpose

Use this page to collect the information needed for the Google Play Data Safety form before submission.

For the current closed-testing pack, see [Google Play submission content pack](google_play_submission_content_pack.md).
For the owner-confirmation defaults around Advertising ID, ad personalization, and final release wording, see [Play Console owner decisions](play_console_owner_decisions.md).
For the live public privacy SSOT, see [Privacy policy publication handoff](../legal/privacy_policy_publication_handoff.md).

## Current known behavior from the repository

- Journal is local-only.
- Journal entries, the saved language, and the local app access setting live only on the device.
- Journal data is not synced to a backend or cloud service.
- Journal note content is not sent to a backend in the current implementation.
- Local data deletion is separate from UMP-managed consent.
- Local data deletion removes Journal entries, the saved language, and the local app access setting.
- Local data deletion does not affect Google Play purchase history, Google Play subscriptions, real Premium entitlement managed through Google Play, Google UMP consent state, Google-managed advertising records, or Google-managed billing records.
- The MVP does not require a child name or exact child birthdate.
- Billing is present for subscriptions.
- Ads are banner-only in passive browse areas once UMP confirms ads may be requested.
- Ads do not belong in Journal edit/create, active audio playback, Privacy / Settings, or startup flows.
- Analytics is not currently enabled in the app.
- The recommended MVP provider decision is no product analytics provider or SDK.
- There is no crash-reporting SDK and no Journal telemetry in the MVP.
- If analytics is approved later, the proposed MVP scope is limited to app language, device locale, approximate country/region, app version, module usage, retention, ad events, and errors/crashes.
- Journal note content, child name, exact birthdate, health data, child profiling, precise location, and stable identifiers are out of scope.

## Data categories to review

- App activity
- Device or app info
- Purchase history
- Advertising ID
- Diagnostics or crash logs
- User-provided content, including Journal data
- Child profile fields, if any are added later

## Questions to answer before submission

- [ ] What data is collected?
- [ ] What data is shared?
- [ ] Is data encrypted in transit?
- [ ] Can users request deletion?
- [ ] Is data optional or required?
- [ ] Are ads personalized?
- [ ] Is the Advertising ID used?

## Open owner/release decisions

- Final ad personalization and Advertising ID declaration: #182 and #185.
- Final provider-specific rows and release-build evidence: #182, #185, and #186.
- Final Billing wording for purchase status/token handling: #182 and #186.

The canonical inventory records the evidence, confidence, source register, and deletion boundaries for these decisions.

## Notes

- Keep the answer aligned with the production build, not the debug build.
- Recheck this worksheet whenever ad, analytics, billing, or privacy behavior changes.
