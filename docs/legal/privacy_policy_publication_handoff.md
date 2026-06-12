# Privacy policy publication handoff

This document prepares the public privacy-policy publication flow for Nurtly.

It is a publication handoff only. It is not legal advice.

## Purpose

- Prepare a publishable privacy-policy URL structure for the MVP release.
- Keep the public policy aligned with the shipped app behavior and Play Console answers.
- Separate the source drafts from the publication copy and owner-side hosting decisions.
- Publication is blocked until `[DATE_TBD]` and `[CONTACT_EMAIL_TBD]` are replaced with final values.

## Source documents

- [English privacy policy draft](privacy_policy_en.md)
- [Polish privacy policy draft](privacy_policy_pl.md)
- [Owner decisions](../release/play_console_owner_decisions.md)
- [Data Safety preparation](../release/data_safety.md)
- [Google Play submission content pack](../release/google_play_submission_content_pack.md)

## Recommended URL structure

Recommended public structure:

- `/legal/privacy` for the single public landing page
- `/legal/privacy/en` for the English policy page
- `/legal/privacy/pl` for the Polish policy page

Why this structure:

- it gives Play Console one stable URL,
- it avoids choosing one language as the only visible entry point,
- it keeps the public policy easy to maintain,
- it makes the EN and PL versions explicit.

## EN URL recommendation

- Recommended public page: `/legal/privacy/en`
- Use this as the English policy destination and keep it synchronized with the shipped behavior.

## PL URL recommendation

- Recommended public page: `/legal/privacy/pl`
- Use this as the Polish policy destination and keep it synchronized with the shipped behavior.

## Google Play privacy URL strategy

- Recommended single Play Console URL: `/legal/privacy`
- That landing page should link clearly to the EN and PL policy pages.
- The Play Console URL should not be treated as final until the owner has published the pages on a live host.

## Owner-side publication steps

1. Choose the live host or static publication method already available to the owner.
2. Publish the landing page at `/legal/privacy`.
3. Publish the EN page at `/legal/privacy/en`.
4. Publish the PL page at `/legal/privacy/pl`.
5. Replace placeholder date and contact values with the final owner-approved values.
6. Confirm the landing page links to both language pages.
7. Confirm the live pages match the shipped app behavior and Play Console answers.
8. Copy the final live URL into Play Console and the app privacy references if needed.

## Validation checklist

- [ ] The public landing page is reachable.
- [ ] The EN and PL pages are reachable.
- [ ] The text matches the shipped app behavior.
- [ ] The text says Journal is local-only.
- [ ] The text says no product analytics provider is planned for MVP.
- [ ] The text says free users may see passive banner ads only in the current MVP contract.
- [ ] The text says Premium removes ads.
- [ ] The text does not claim cloud sync, child profiling, or a finalized Advertising ID decision unless the owner has confirmed it.
- [ ] The live URL matches the published Play Console URL.
- [ ] The in-app Privacy & Data wording still matches the live policy.

## What must match the shipped app

- parent/caregiver positioning
- adults 18+ posture
- local-only Journal behavior
- billing and Premium behavior
- banner-only passive ads in the current MVP contract
- no product analytics provider for MVP
- no Journal note content in backend collection

## What must not be claimed

- a live URL that has not been published yet
- cloud sync or account sync
- child-directed or Families-first positioning unless explicitly confirmed
- analytics provider usage for MVP
- final Advertising ID or ad-personalization decisions unless owner-confirmed
- legal advice

## Remaining owner confirmations

- final live URL and host
- final contact email
- final publication date
- final EN/PL landing-page wording if the owner wants additional branding or routing text
- whether the app should link directly to the public landing page or continue using in-app privacy copy only

## Notes

- Keep this handoff aligned with the release checklist, Data Safety notes, and owner decisions.
- Do not publish a live URL until the owner has reviewed the final pages.
