# Privacy policy publication handoff

This document records the approved public privacy URL and the live verification evidence for the public privacy SSOT.

It is a publication handoff only. It is not legal advice.

## Approved public SSOT

- Public privacy gateway: [https://nurtly.graylion.pl/privacy](https://nurtly.graylion.pl/privacy)
- English policy page: [https://nurtly.graylion.pl/privacy/en](https://nurtly.graylion.pl/privacy/en)
- Polish policy page: [https://nurtly.graylion.pl/privacy/pl](https://nurtly.graylion.pl/privacy/pl)
- Support pages used for adjacent owner contact evidence: [https://nurtly.graylion.pl/support/en](https://nurtly.graylion.pl/support/en) and [https://nurtly.graylion.pl/support/pl](https://nurtly.graylion.pl/support/pl)
- Canonical host: `nurtly.graylion.pl`
- The public deployment URL is not the canonical public address and must not be used in Play Console or repo SSOT docs.

## Source documents in this repository

- [English privacy policy pointer](privacy_policy_en.md)
- [Polish privacy policy pointer](privacy_policy_pl.md)
- [Owner decisions](../release/play_console_owner_decisions.md)
- [Data Safety preparation](../release/data_safety.md)
- [Google Play submission content pack](../release/google_play_submission_content_pack.md)

## Live verification evidence

Captured on 14 July 2026 with anonymous requests from the Codex workspace.

| Route | HTTP result | Language / behavior | Canonical | Evidence notes |
| --- | --- | --- | --- | --- |
| `/privacy` | 200 OK | EN/PL browser-language gateway with manual links and redirect behavior | `https://nurtly.graylion.pl/privacy` | Single gateway document with `<html lang="en">`, EN/PL `hreflang` alternates, and manual links to the language-specific policy pages; browser language can route the user to the matching localized page. |
| `/privacy/en` | 200 OK | `lang=en`, version 1.1, effective 14 July 2026 | `https://nurtly.graylion.pl/privacy/en` | Shows operator `GRAY LION ŁUKASZ CHMIEL`, contact `nurtly@graylion.pl`, and EN/PL/x-default `hreflang` alternates. |
| `/privacy/pl` | 200 OK | `lang=pl`, version 1.1, effective 14 lipca 2026 r. | `https://nurtly.graylion.pl/privacy/pl` | Shows operator `GRAY LION ŁUKASZ CHMIEL`, contact `nurtly@graylion.pl`, and EN/PL/x-default `hreflang` alternates. |
| `/support/en` | 200 OK | `lang=en`, version 1.1, effective 14 July 2026 | `https://nurtly.graylion.pl/support/en` | Support page is anonymous, exposes the language switcher, and repeats the live operator/contact metadata. |
| `/support/pl` | 200 OK | `lang=pl`, version 1.1, effective 14 lipca 2026 r. | `https://nurtly.graylion.pl/support/pl` | Support page is anonymous, exposes the language switcher, and repeats the live operator/contact metadata. |

## Live alignment notes

- EN and PL privacy pages share the same section structure and metadata; only language and localized copy differ.
- The public privacy pages are anonymous and do not require sign-in.
- The live pages do not contain `[DATE_TBD]`, `[CONTACT_EMAIL_TBD]`, `[PRIVACY_POLICY_URL_TBD]`, or other unpublished placeholders.
- The approved public privacy URL for Play Console and release docs is [https://nurtly.graylion.pl/privacy](https://nurtly.graylion.pl/privacy).
- The public policy lives at the root privacy gateway, not under `/legal/privacy`.
- The public privacy publication and reachability work is complete.
- Play Console and release-compliance work remains open in BLK-005.

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
- banner-only passive ads in the approved public wording
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

- The `docs/legal/public/` files are the repo mirror pair; the top-level `docs/legal/privacy_policy_en.md` and `docs/legal/privacy_policy_pl.md` files are internal pointers only.
- Do not claim device visual QA here. This evidence is based on anonymous HTTP and HTML inspection only.
- Keep BLK-004 resolved specifically for public publication, anonymous reachability, canonical public URL, and EN/PL route availability.
- Do not imply that every privacy, Data Safety, Play Console, or release-readiness task is complete.
