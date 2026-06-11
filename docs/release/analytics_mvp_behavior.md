# MVP Analytics Event Taxonomy

This document captures the proposed MVP analytics boundary. It is for QA, release readiness, and privacy review, not implementation.

## Allowed data categories

The proposed MVP analytics scope is limited to:

- app language
- device locale
- approximate country/region
- app version
- module usage
- retention signals
- ad events
- errors/crashes

## Forbidden data

The proposed MVP analytics scope must not collect:

- journal note content
- child name
- exact birthdate
- health data
- child profiling
- precise location
- stable user identifiers
- device fingerprints

## Proposed MVP event taxonomy

### App start and session basics

- `app_start`
- `session_start`
- `app_resume`

Recommended properties:

- `app_version`
- `app_language`
- `device_locale`
- `approximate_country_or_region`
- `session_type`

### Module open events

- `module_opened`

Recommended properties:

- `module`: `Home`, `Play`, `Sounds`, `Journal`, or `Settings`
- `entry_point`: optional, if needed for release learning

### Basic content interaction

- `content_interaction`

Use this only for non-sensitive interaction counts and screen-level usage.

Recommended properties:

- `module`
- `surface`
- `action`

Do not include content text, child attributes, journal note payloads, or exact care details.

### Ads events

Ads analytics should align with the proposed MVP ad contract in `ads_mvp_behavior.md`.

- `ad_viewed`
- `ad_impression`
- `ad_click`
- `ad_failed_to_load`

Recommended properties:

- `placement`
- `format`
- `result`
- `premium_state`

Ad events must not include Journal content or child-related payloads.

### Errors and crashes

- `error_event`
- `crash_event`

Recommended properties:

- `module`
- `error_type`
- `severity`
- `app_version`
- `device_locale`

Errors and crashes should stay free of user-entered content and child data.

## Store and policy notes

- The analytics provider, SDK, consent, and retention-window decisions are not yet final.
- If Advertising ID, crash provider enrichment, or any remote analytics provider is considered, mark it `Needs owner confirmation` before release.
- Data Safety, privacy policy, and store listing copy should describe the same strict boundary.

## Needs owner confirmation

- Which analytics provider or SDK, if any, will be used.
- Whether analytics is opt-in, opt-out, or always-on in the MVP.
- Whether Advertising ID or other advertising-linked identifiers are needed.
- Whether crash reporting is separate from product analytics.
- Whether any retention window or data deletion policy needs to be documented before release.
