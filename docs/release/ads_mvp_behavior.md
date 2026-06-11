# MVP Ad Placement Contract

This document captures the proposed release-time ad behavior for the MVP. It is a contract note for QA, store readiness, and privacy review, not an implementation file.

## Allowed placements

- Passive banner-style ads are the proposed MVP behavior for non-sensitive, browse-style areas of the app.
- In the current MVP planning, the intended allowed placements are the Home feed, Play list, and Sounds list.
- Ads should only appear when the user is on a stable screen state and the entitlement allows free-user ads, pending owner confirmation of the final release model.

## Blocked flows

Ads must not interrupt or appear inside these flows:

- Journal entry creation or editing.
- Active audio playback.
- Privacy, Settings, legal, and release-readiness screens.
- Startup moments, splash transitions, or other aggressive first-run interruptions.
- Paywall and purchase confirmation flows.

## MVP ad formats

- Banner: proposed for the passive slots above, pending owner confirmation.
- Interstitial: proposed as not allowed in the MVP, pending owner confirmation.
- Rewarded: proposed as not allowed in the MVP, pending owner confirmation.

## Free vs Premium behavior

- Free users may see passive banner ads in the allowed browse areas if the MVP contract is confirmed.
- Premium users should not see ads.
- If ad loading fails, the screen should continue to behave calmly and remain usable.

## Store and policy notes

- Data Safety, privacy policy, and store listing copy should describe the same proposed MVP contract.
- If personalized ads, Advertising ID usage, or any future ad expansion is considered, mark it `Needs owner confirmation` before release.

## Needs owner confirmation

- Whether the MVP stays banner-only through release.
- Whether any future interstitial or rewarded placement is planned after MVP.
- Whether personalized ads or Advertising ID usage will be enabled in production.
