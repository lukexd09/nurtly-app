# Data Safety preparation

This worksheet helps prepare the Google Play Data Safety answers for the first MVP release.

This document is not legal advice. Final answers must match the actual production behavior and Play Console configuration.

## Purpose

Use this page to collect the information needed for the Google Play Data Safety form before submission.

## Current known behavior from the repository

- Journal is local-only.
- Journal data is not synced to a backend or cloud service.
- Journal note content is not sent to a backend in the current implementation.
- The MVP does not require a child name or exact child birthdate.
- Billing is present for subscriptions.
- Ads are planned and partially wired through the app.
- MVP ad placement is currently planned to stay banner-only in passive browse areas, with no ads in Journal edit/create, active audio playback, Privacy / Settings, or startup flows. This is pending owner confirmation before it is treated as the final production behavior.
- Analytics is not currently enabled in the app.
- If analytics is added later, the proposed MVP scope is limited to app language, device locale, approximate country/region, app version, module usage, retention, ad events, and errors/crashes.
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

## TODO placeholders to finalize later

- [ ] Final ad behavior from the ads setup. Needs owner confirmation.
- [ ] Final ad personalization / Advertising ID decision. Needs owner confirmation.
- [ ] Final analytics provider, SDK, and consent decisions. Needs owner confirmation.
- [ ] Final analytics taxonomy and retention window. Needs owner confirmation.
- [ ] Final privacy policy URL.
- [ ] Final Billing data disclosure.

## Notes

- Keep the answer aligned with the production build, not the debug build.
- Recheck this worksheet whenever ad, analytics, billing, or privacy behavior changes.
