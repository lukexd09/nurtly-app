# Privacy policy publication handoff

This document records the approved public privacy URL and the live verification evidence for the public privacy SSOT.

It is a publication handoff only. It is not legal advice.

## Approved public SSOT

- Public privacy gateway: [https://nurtly.graylion.pl/privacy](https://nurtly.graylion.pl/privacy)
- English policy page: [https://nurtly.graylion.pl/privacy/en](https://nurtly.graylion.pl/privacy/en)
- Polish policy page: [https://nurtly.graylion.pl/privacy/pl](https://nurtly.graylion.pl/privacy/pl)
- Support pages used for adjacent owner contact evidence: [https://nurtly.graylion.pl/support/en](https://nurtly.graylion.pl/support/en) and [https://nurtly.graylion.pl/support/pl](https://nurtly.graylion.pl/support/pl)

## Source documents in this repository

- [English privacy policy mirror](privacy_policy_en.md)
- [Polish privacy policy mirror](privacy_policy_pl.md)
- [Owner decisions](../release/play_console_owner_decisions.md)
- [Data Safety preparation](../release/data_safety.md)
- [Google Play submission content pack](../release/google_play_submission_content_pack.md)

## Live verification evidence

Captured on July 13, 2026 with anonymous requests from the Codex workspace.

| Route | HTTP result | Redirects observed | Anonymous access | Canonical | Language metadata | Evidence notes |
| --- | --- | --- | --- | --- | --- | --- |
| `/privacy` | 200 OK | None observed with `curl -L` | Yes | `https://nurtly.graylion.pl/privacy` | `lang="en"`; `hreflang` for EN, PL, and x-default | Language gateway only; links to the EN and PL policy pages; no version/effective-date/contact block on the gateway page. |
| `/privacy/en` | 200 OK | None observed with `curl -L` | Yes | `https://nurtly.graylion.pl/privacy/en` | `lang="en"`; `hreflang` for EN, PL, and x-default | Shows version 1.0, effective date 25 June 2026, operator GRAY LION ŁUKASZ CHMIEL, and contact `nurtly@graylion.pl`; no placeholder fields remain. |
| `/privacy/pl` | 200 OK | None observed with `curl -L` | Yes | `https://nurtly.graylion.pl/privacy/pl` | `lang="pl"`; `hreflang` for EN, PL, and x-default | Shows version 1.0, effective date 25 czerwca 2026 r., operator GRAY LION ŁUKASZ CHMIEL, and contact `nurtly@graylion.pl`; no placeholder fields remain. |
| `/support/en` | 200 OK | None observed with `curl -L` | Yes | `https://nurtly.graylion.pl/support/en` | `lang="en"`; `hreflang` for EN and PL | Support page is anonymous, references privacy choices and local-data deletion, and repeats version 1.0 with effective date 25 June 2026. |
| `/support/pl` | 200 OK | None observed with `curl -L` | Yes | `https://nurtly.graylion.pl/support/pl` | `lang="pl"`; `hreflang` for EN and PL | Support page is anonymous, references privacy choices and local-data deletion, and repeats version 1.0 with effective date 25 czerwca 2026 r. |

## Live alignment notes

- EN and PL privacy pages share the same section structure and metadata; only language and localized copy differ.
- The public privacy pages are anonymous and do not require sign-in.
- The live pages do not contain `[DATE_TBD]`, `[CONTACT_EMAIL_TBD]`, `[PRIVACY_POLICY_URL_TBD]`, or other unpublished placeholders.
- The approved public privacy URL for Play Console and release docs is [https://nurtly.graylion.pl/privacy](https://nurtly.graylion.pl/privacy).
- The approved public policy lives at the root privacy gateway, not under `/legal/privacy`.

## Basic accessibility evidence

- The live pages expose `<html lang="en">` or `<html lang="pl">` as appropriate.
- The privacy and support language pages expose `<main>` landmarks.
- The privacy and support language pages expose visible `<h1>` headings.
- The privacy and support language pages expose a language-switcher `<nav aria-label="Language switcher">`.
- The live CSS includes `:focus-visible` styling for keyboard focus indication.

## What must stay aligned

- parent/caregiver positioning for adults 18+
- local-only Journal behavior
- no account and no cloud sync
- billing and Premium behavior
- passive banner-only ads for free users in the approved public wording
- Google UMP and Advertising ID wording
- no analytics SDK or crash-reporting SDK in the MVP wording
- operator/contact/effective-date/version metadata
- support guidance for local deletion and privacy choices

## What must not return

- `/legal/privacy` recommendations
- placeholder date or contact fields
- unpublished claims about final ad, analytics, or hosting decisions
- child-directed or Families-first wording unless explicitly approved

## Notes

- The repository copies in `docs/legal/` are mirrors only; the live public SSOT remains authoritative.
- Do not claim device visual QA here. This evidence is based on anonymous HTTP and HTML inspection only.
