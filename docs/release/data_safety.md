# Data Safety preparation

For the current authoritative release status and blocker list, see [Final MVP release readiness](final_mvp_release_readiness.md) and [Final release blockers](final_release_blockers.md).

This worksheet helps prepare the Google Play Data Safety answers for the first MVP release.

This document is not legal advice. Final answers must match the actual production behavior and Play Console configuration.

## Purpose

Use this page to collect the information needed for the Google Play Data Safety form before submission.

For the current closed-testing pack, see [Google Play submission content pack](google_play_submission_content_pack.md).
For the owner-confirmation defaults around Advertising ID, ad personalization, and final release wording, see [Play Console owner decisions](play_console_owner_decisions.md).
For the public privacy policy publication flow, see [Privacy policy publication handoff](../legal/privacy_policy_publication_handoff.md).

## Current known behavior from the repository

- Journal is local-only.
- Journal data is not synced to a backend or cloud service.
- Journal note content is not sent to a backend in the current implementation.
- The MVP does not require a child name or exact child birthdate.
- Billing is present for subscriptions.
- Ads are planned and partially wired through the app.
- MVP ad placement is currently planned to stay banner-only in passive browse areas, with no ads in Journal edit/create, active audio playback, Privacy / Settings, or startup flows. This is pending owner confirmation before it is treated as the final production behavior.
- Android startup requests UMP consent info before banner loading, and banner requests remain blocked until the consent flow allows them.
- The app surfaces privacy choices in Privacy & Data only when the consent state requires it.
- The release build keeps the UMP consent flow separate from Nurtly-owned local data deletion.
- Analytics is not currently enabled in the app.
- The recommended MVP provider decision is no product analytics provider or SDK.
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

## Android merged-manifest notes

- `android.permission.INTERNET` is present in the merged Android manifest.
- `com.google.android.gms.permission.AD_ID` is present in the merged Android manifest.
- The manifest-merger blame report traces `AD_ID` to `com.google.android.gms:play-services-ads-lite:23.6.0`.
- `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_ATTRIBUTION`, and `ACCESS_ADSERVICES_TOPICS` are also introduced by the same ads dependency path.
- This finding should be reflected in the Data Safety draft and owner-confirmation notes before any public release decision.

## Questions to answer before submission

- [ ] What data is collected?
- [ ] What data is shared?
- [ ] Is data encrypted in transit?
- [ ] Can users request deletion?
- [ ] Is data optional or required?
- [ ] Are ads personalized?
- [ ] Is the Advertising ID used?

## TODO placeholders to finalize later

- [ ] Final ad behavior from the ads setup. Needs owner confirmation.
- [ ] Final ad personalization / Advertising ID decision. Needs owner confirmation.
- [ ] Final analytics provider, SDK, and consent decisions. Needs owner confirmation if a provider is ever approved.
- [ ] Final analytics taxonomy and retention window. Needs owner confirmation if analytics is ever approved.
- [ ] Final privacy policy URL and public hosting plan. Needs owner confirmation.
- [ ] Final Billing data disclosure.

## Notes

- Keep the answer aligned with the production build, not the debug build.
- Recheck this worksheet whenever ad, analytics, billing, or privacy behavior changes.
