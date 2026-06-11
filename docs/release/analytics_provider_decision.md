# MVP Analytics Provider Decision

This document records the recommended MVP approach for analytics providers and crash reporting. It is a release-readiness note only and does not implement analytics.

## Repository assumptions

- The app currently has no analytics SDK implementation.
- The app privacy screen already describes analytics as not currently enabled.
- The analytics taxonomy for the proposed MVP was defined in `analytics_mvp_behavior.md`.
- The release train must stay privacy-first, calm, and child-data safe.

## Options considered

| Option | Privacy / Data Safety impact | Consent / opt-in impact | Advertising ID risk | Complexity | MVP value | Parent trust | Outcome |
|---|---|---|---|---|---|---|---|
| No product analytics for closed testing | Lowest. No new app-level analytics collection. | No analytics consent flow needed. | None for analytics. | Lowest. | Lower release learning, but enough for a small MVP. | Strongest. | Recommended default |
| No remote analytics, manual release QA only | Lowest. Same as above. | No analytics consent flow needed. | None for analytics. | Lowest. | Good for a privacy-first MVP; feedback comes from QA and Play Console. | Strongest. | Recommended default |
| Firebase Analytics | Higher. Adds app-level collection and disclosure burden. | Consent and disclosure become more complex. | Higher if advertising-linked identifiers are in scope. | Medium to high. | Useful later, but not necessary for MVP release readiness. | Weaker. | Not recommended for MVP |
| Firebase Crashlytics only | Moderate. Crash data still needs disclosure and review. | Usually no interactive consent, but disclosure still changes. | Lower than full analytics, but still review needed. | Medium. | Helpful, but still adds provider complexity for a small MVP. | Mixed. | Not recommended for MVP |
| Sentry or another crash-only provider | Moderate. Similar disclosure and retention review. | Usually no interactive consent, but disclosure still changes. | Lower than full analytics, but still review needed. | Medium. | Useful later if crash visibility is a release blocker. | Mixed. | Not recommended for MVP |
| Custom/local-only/no remote tracking | Lowest, but usually overlaps with the recommended no-provider approach. | No analytics consent flow needed. | None for analytics. | Lowest. | Good for MVP release readiness and preserves calm positioning. | Strongest. | Recommended default |

## Recommended MVP approach

- Recommended default: no product analytics provider or SDK for the MVP release.
- Recommended release practice: use manual QA, user feedback, and existing store/release review signals instead of a remote analytics provider.
- Recommended crash posture: do not add a crash-only provider in the MVP release slice unless a later owner decision explicitly approves it.

## Why this is the default

- It keeps Journal and child-data boundaries simplest.
- It avoids introducing new consent, retention, or Advertising ID questions for analytics.
- It preserves the calm, privacy-first parent trust position of Nurtly.
- It keeps the MVP release slice reviewable without SDK or platform-service work.

## Privacy / Data Safety / Store impact

- No app-level analytics SDK means no new analytics event collection inside the app for the MVP release.
- Data Safety disclosures stay simpler because the release does not add a product analytics provider.
- Privacy policy language can stay future-facing for analytics without claiming an active provider.
- Store copy does not need to promise analytics functionality for MVP.
- Advertising ID is not needed for the recommended MVP analytics approach.

## QA / release checklist updates

- Verify that no analytics SDK or provider config has been added to the app.
- Verify that Data Safety and privacy text remain consistent with a no-provider MVP.
- Verify that the analytics taxonomy document is treated as a future implementation contract, not as active telemetry.
- Verify that any later provider decision is clearly marked `Needs owner confirmation`.

## Implementation readiness

If a provider is approved later, a future implementation PR should:

1. Add the selected analytics or crash-reporting SDK through an explicit owner-approved dependency change.
2. Add the provider abstraction or wrapper in app code.
3. Implement only the approved events from `analytics_mvp_behavior.md`.
4. Keep all forbidden data out of event payloads.
5. Revisit consent, retention, and Advertising ID decisions before release.
6. Update Data Safety, privacy policy, store copy, and QA checks to match the approved provider.
7. Add verification that the app still behaves correctly without tracking Journal or child data.

## Needs owner confirmation

- Whether the MVP should remain with no product analytics provider.
- Whether a crash-only provider should be approved later.
- Whether any future provider would require consent or retention-window documentation.
- Whether any future provider would use Advertising ID or other advertising-linked identifiers.
- Whether the release should rely on Play Console and manual QA only for MVP analytics learning.
