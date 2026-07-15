# Mobile Ads, UMP and Billing Release Configuration

Status: repository implementation complete; owner and device checks remain blocked or not run.

## Baseline

- Tested source commit: `50ab206b250ae922117e8b442b98f13cdef31583`.
- App version: `0.1.0+8`.
- Android package ID: `com.graylion.nurtly`.
- Resolved Flutter package versions are recorded in `app/pubspec.lock`; this checkout uses `google_mobile_ads` 5.1.0 and Android Billing 7.1.1.

## Release configuration

Debug uses Google sample application and banner IDs, with UMP debug settings only in debug mode. Release Gradle builds require `NURTLY_MOBILE_ADS_ANDROID_APP_ID` and reject missing, sample, or malformed application IDs. The workflow requires `ads_profile`:

- `closed-test-sample-banner`: external Nurtly application ID plus the official sample banner.
- `production-banner`: external Nurtly application and banner IDs; sample banner IDs are rejected.

The workflow passes `NURTLY_MOBILE_ADS_PROFILE` and `NURTLY_MOBILE_ADS_ANDROID_BANNER_ID` through `--dart-define`. No production identifier is committed.

## UMP and ads gates

`requestConsentInfoUpdate()` precedes consent-state reads. A consent-update error rechecks provider state so a valid previous session can remain requestable; ads still require UMP `canRequestAds() == true`. Mobile Ads initialization and banner loading are gated by that value. Release builds contain no debug geography or test-device IDs. Privacy choices errors are propagated to the existing localized UI failure path.

Automated code-path checks: Flutter tests cover consent/banner UI behavior and `BannerLoadGate`; configuration resolution is covered by Dart tests and the PowerShell regression script. Real-device UMP form, Privacy choices, ad-request, and banner checks are `NOT RUN` here.

## Billing

The repository preserves `nurtly_premium_monthly` and `nurtly_premium_yearly`. Product querying, purchase stream handling, pending/purchased/restored mapping, completion, restore, unavailable service, unknown products, and Premium precedence are covered by the existing provider tests. Play Console evidence is not available to this task.

| Check | Expected value | Evidence source | Status | Owner action |
| --- | --- | --- | --- | --- |
| Monthly product ID exists | `nurtly_premium_monthly` | `billing_product_ids.dart` | PASS | Confirm in Play Console |
| Yearly product ID exists | `nurtly_premium_yearly` | `billing_product_ids.dart` | PASS | Confirm in Play Console |
| Both are subscriptions | Active subscription products | Play Console | BLOCKED — OWNER CONSOLE CONFIRMATION REQUIRED | Verify |
| Base plans, regions and prices | Active and configured | Play Console | BLOCKED — OWNER CONSOLE CONFIRMATION REQUIRED | Verify |
| Test account eligible | Eligible tester | Play Console | BLOCKED — OWNER CONSOLE CONFIRMATION REQUIRED | Verify |
| Query, purchase, restore and cancellation | Expected store behavior | Device/store test | NOT RUN | Run on closed track |

## Advertising ID and personalization boundary

No direct Nurtly Advertising ID API call was found. Google Mobile Ads is present and may contribute native behavior. The source manifest does not directly declare `AD_ID`; merged release-manifest origin remains follow-up #185. No-personalized-ads posture is recommended but is not technically confirmed by this repository; AdMob and UMP console confirmation is required. This document is not legal advice and does not submit console declarations.

## Manual and owner status

| Check | Status |
| --- | --- |
| Repository variables configured | BLOCKED |
| AdMob application configured | BLOCKED |
| UMP European-regulation message configured | BLOCKED |
| Personalization posture confirmed | BLOCKED |
| Advertising ID declaration approved | BLOCKED |
| Real-device verification | NOT RUN |
| Billing console confirmation | BLOCKED |

## Commands

```powershell
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\tools\test_mobile_ads_release_config.ps1
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\tools\check_mobile_ads_release_config.ps1 -ValidateRepository
```

Official sources, accessed 15 July 2026: [AdMob Flutter quick start](https://developers.google.com/admob/flutter/quick-start), [banner ads](https://developers.google.com/admob/flutter/banner), [test ads](https://developers.google.com/admob/flutter/test-ads), [privacy](https://developers.google.com/admob/flutter/privacy), [GDPR](https://developers.google.com/admob/flutter/privacy/gdpr), [ad serving modes](https://developers.google.com/admob/flutter/privacy/ad-serving-modes), [Google Play Billing integration](https://developer.android.com/google/play/billing/integrate), and [Advertising ID policy](https://support.google.com/googleplay/android-developer/answer/10787469).
