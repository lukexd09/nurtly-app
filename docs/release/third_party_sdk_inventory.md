# Nurtly third-party SDK inventory and Data Safety evidence draft

Status: evidence draft only. This is not a Play Console submission, approval, or legal advice.

## 1. Review identity

| Field | Value |
|---|---|
| Repository | `lukexd09/nurtly-app` |
| App evidence baseline | `9a1879cc02ca60f17e7377fdfe65412fb94de356` |
| Documentation PR head | New exact correction head is recorded in PR #243 and the final report |
| Review date | 15 July 2026 |
| App version | `0.1.0+8` from `app/pubspec.yaml` |
| Android application ID | `com.graylion.nurtly` |
| Evidence scope | Flutter/Dart source, final lockfile, Android manifest/build files, release/privacy documents, and first-party documentation listed in the source register |

The lockfile, not the version constraint alone, is the source of resolved package versions.

## 2. Direct dependency inventory

| Component / package | Constraint | Resolved version | Privacy-relevant role | Evidence | Confidence |
|---|---:|---:|---|---|---|
| Just Audio (`just_audio`) | `^0.10.5` | `0.10.5` | Audio playback and local file/asset source handling | `app/pubspec.yaml:14`, `app/pubspec.lock:224-231`; `app/lib/features/sounds/audio/looping_sound_loader.dart` | CONFIRMED |
| Google Mobile Ads Flutter plugin (`google_mobile_ads`) | `^5.1.0` | `5.3.1` | Android banner ads and the consent APIs used by the app | `app/pubspec.yaml:15`, `app/pubspec.lock:144-151`; `app/lib/core/ads/*` | CONFIRMED |
| Flutter in-app purchase (`in_app_purchase`) | `^3.2.0` | `3.2.3` | Google Play product lookup, purchase stream, purchase restore and completion | `app/pubspec.yaml:16`, `app/pubspec.lock:160-183`; `app/lib/core/monetization/*` | CONFIRMED |
| Shared Preferences (`shared_preferences`) | `^2.3.2` | `2.5.5` | Local journal, language, and reviewer-access persistence | `app/pubspec.yaml:17`, `app/pubspec.lock:432-471`; the three stores named in section 5 | CONFIRMED |
| URL Launcher (`url_launcher`) | `^6.3.2` | `6.3.2` | Opens the public privacy URL in the external browser | `app/pubspec.yaml:18`, `app/pubspec.lock:557-604`; `app/lib/core/platform/external_url_launcher.dart` | CONFIRMED |

## 3. Privacy-relevant transitive inventory

| Component / resolved version | Role in this build | Evidence | Confidence |
|---|---|---|---|
| `audio_session` 0.2.3; `just_audio_platform_interface` 4.5.0; `path_provider_android` 2.3.1; `path_provider_foundation` 2.6.0 | Audio platform integration and app-private file path support. No network source is selected by Nurtly. | `app/pubspec.lock:20-27`, `224-239`, `352-367`; bundled asset cache implementation | CONFIRMED |
| `in_app_purchase_android` 0.4.0+11; `in_app_purchase_platform_interface` 1.4.0; `in_app_purchase_storekit` 0.4.0+3 | Store-specific purchase bridge and platform-neutral purchase objects. Android runtime selects the Google Play provider. | `app/pubspec.lock:168-191`; `app/lib/main.dart`; billing client/provider | CONFIRMED |
| `shared_preferences_android` 2.4.23; `shared_preferences_foundation` 2.5.6; `shared_preferences_platform_interface` 2.4.2 | Platform persistence implementations for the local preference store. | `app/pubspec.lock:440-471`; journal/language/reviewer stores | CONFIRMED |
| `url_launcher_android` 6.3.30; `url_launcher_ios` 6.4.1; `url_launcher_platform_interface` 2.3.2 | Host-platform handoff for external URL launch. | `app/pubspec.lock:565-604`; external URL launcher | CONFIRMED |
| `com.google.android.gms:play-services-ads` 23.6.0; `play-services-ads-base` 23.6.0; `play-services-ads-lite` 23.6.0; `play-services-ads-identifier` 18.0.0 | Native Android Mobile Ads runtime and advertising identifier integration introduced by `google_mobile_ads` 5.3.1. | Gradle `:app:dependencyInsight --configuration debugRuntimeClasspath --dependency play-services-ads`; resolved from `project :google_mobile_ads` | CONFIRMED |
| `com.google.android.ump:user-messaging-platform` 3.1.0 | Native Android consent and privacy-options processing introduced by `google_mobile_ads` 5.3.1. Gradle selected 3.1.0 over the 3.0.0 request from `play-services-ads-lite`. | Gradle `:app:dependencyInsight --configuration debugRuntimeClasspath --dependency user-messaging-platform`; conflict resolution output | CONFIRMED |
| `com.android.billingclient:billing` 7.1.1 | Native Google Play Billing runtime introduced by `in_app_purchase_android` 0.4.0+11. | Gradle `:app:dependencyInsight --configuration debugRuntimeClasspath --dependency billing`; resolved from `project :in_app_purchase_android` | CONFIRMED |
| `plugin_platform_interface` 2.1.8 | Platform-plugin support library; no independent Nurtly data path found. | `app/pubspec.lock:400-407` | CONFIRMED |

Generic Dart utilities in the lockfile are omitted because repository inspection found no independent privacy, network, storage, billing, consent, or media role for them.

## 4. Processing boundary

```text
Parent/caregiver
  ├─ Journal, language, local access setting ──> Nurtly local stores only
  │                                               (Android backup/transfer excluded)
  ├─ Consent choice ──> Google UMP state and consent form processing
  ├─ Passive banner request after canRequestAds() ──> Google Mobile Ads
  ├─ Product/purchase/restore actions ──> Google Play Billing
  ├─ Bundled sound asset ──> app-private local file + audio player
  └─ Privacy link ──> external browser and the public policy route
```

Nurtly has no account, backend, cloud sync, product analytics SDK, crash-reporting SDK, or Journal telemetry path in this commit. “No product analytics” does not mean that provider-side ad diagnostics or ad measurement are absent.

## 5. Component analysis and ownership boundary

### Nurtly-owned local data

Journal entries (`nurtly_journal_entries_v1`), saved language (`nurtly.selected_language`), and local app/reviewer access (`nurtly.reviewer_access_enabled`) are written through Shared Preferences. The repository has no code sending Journal content to a backend. Android `backup_rules.xml` and `data_extraction_rules.xml` exclude `root`, `file`, `database`, `sharedpref`, and `external` for backup and device transfer. Local deletion removes these Nurtly values; it does not clear Google-managed consent, advertising records, purchase history, entitlement state held by Google Play, or billing records.

Under Play’s definition, data processed only on-device is not collected. Therefore local Journal content, language, and local access settings are not Nurtly-collected Data Safety rows unless a later build adds off-device transmission.

### Google Mobile Ads and UMP

On Android, `GoogleConsentFlow` requests consent information, loads a required form, checks `canRequestAds()`, checks the privacy-options requirement status, and initializes Mobile Ads only after ads may be requested. The real banner widget uses a passive banner request only after that gate. The manifest contains the test application ID; production ID and merged-manifest evidence remain owner/release work.

Nurtly resolves native GMA Android 23.6.0 and UMP Android 3.1.0 through `google_mobile_ads` 5.3.1. The current Google Mobile Ads disclosure page describes the latest native SDK version, not necessarily Nurtly’s resolved older SDK. It is therefore current provider guidance, not exact-version proof for this build. The affected rows remain `LIKELY — VERIFY`; #182 and #185 must confirm final release applicability. Do not infer a final Advertising ID or personalized/non-personalized posture from this repository alone.

### Google Play Billing

The app queries two product IDs, listens to `purchaseStream`, starts non-consumable purchase flows for subscription products, restores purchases, maps purchase status to a local Premium entitlement, and completes pending purchases. The app receives product details, purchase status, and the purchase verification object exposed by the Flutter API; this repository does not send a purchase token to a Nurtly backend or expose payment-card details. Google Play remains responsible for the store checkout and payment credentials. A purchase token or transaction reference available to the app is not equivalent to payment-card information.

### Audio

The app loads declared bundled audio assets, materializes them into app-private storage, and plays local file URIs. No URL audio source, remote audio endpoint, or audio upload path was found. `just_audio` can support remote sources generally, but package capability alone is not evidence of a Nurtly data flow.

### URL Launcher

The only Nurtly call uses `launchUrl(uri, mode: LaunchMode.externalApplication)` for the verified public privacy route. The app hands the URL to the host platform; the browser, network request, and any browser-side processing are outside this app’s controlled code path. This is not evidence that Journal data is sent to the policy site.

## 6. Data Safety evidence matrix

Play meaning used here: collected means transmitted off-device; shared is a transfer to a third party where Play’s sharing rules apply; ephemeral is real-time off-device processing not retained beyond the request and not used to build a profile; required/optional describes whether the data collection is required for the app or user can opt out. These are draft classifications, not submitted answers.

| Data category / specific type | Component/provider | Nurtly/provider control | Collected | Shared | Ephemeral | Required / optional | Purpose | Encrypted in transit | Deletion behavior | Code/build evidence | Official external source | Confidence | Owner decision / follow-up |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| User-provided content: Journal entries | Nurtly local store | Nurtly-controlled | No; local-only | No | N/A | Optional user-created feature | App functionality | N/A for local storage | In-app local deletion; excluded from Android backup/transfer | Journal store; deletion coordinator; backup XML | Play Data Safety local-only guidance; Android Auto Backup | CONFIRMED | Recheck in #186 device QA |
| App activity: ad/product interactions | Google Mobile Ads | Provider-controlled processing | Likely yes when an ad is requested or interacted with | Likely yes under provider processing | No if used for measurement/profile purposes | Configuration/consent-dependent | Advertising, analytics, fraud prevention | Google says TLS | Provider retention/deletion not controlled by Nurtly; local deletion does not clear it | Banner request and passive placements; consent gate | Google Mobile Ads Play data disclosure; UMP setup | LIKELY — VERIFY | Final row and purpose selection in #182; real-device checks #186 |
| Device or other identifiers: Android advertising ID, app set ID, and other applicable device/account identifiers | Google Mobile Ads | Provider-controlled processing | Likely yes, provider/configuration-dependent | Likely yes | No where used beyond real-time service or profiling | Configuration/consent/device-dependent | Advertising, analytics, fraud prevention | Google says TLS | Android Advertising ID is user-resettable/deletable; provider records are not deleted by local app action | No direct Nurtly identifier code; native SDK resolution and manifest require release evidence | Current Google Mobile Ads provider guidance; exact-version applicability remains open | LIKELY — VERIFY | Advertising ID declaration and permission origin in #185; final posture #182 |
| Approximate location/region inferred from IP | Google Mobile Ads | Provider-controlled processing | Likely; provider may infer a general device location from IP | Likely | No if retained or used for profiles | Provider/configuration-dependent | Advertising, analytics, fraud prevention | Google says TLS | Not controlled by local deletion | No Android coarse or precise location permission is requested in the app manifest; provider behavior is external | Current Google Mobile Ads provider guidance; exact-version applicability remains open | LIKELY — VERIFY | Confirm applicability and row selection in #182/#185 |
| Diagnostics: SDK/app performance data | Google Mobile Ads | Provider-controlled processing | Likely yes for ad SDK diagnostics | Likely | No if retained for diagnostics | Provider-controlled | Diagnostics, fraud prevention | Google says TLS | Provider-managed; local deletion does not clear it | No Nurtly crash SDK; Mobile Ads SDK is initialized after consent gate | Google Mobile Ads Play data disclosure | LIKELY — VERIFY | Verify release behavior in #182 and #186 |
| Purchase history / purchase status / product details | Google Play Billing | Provider-controlled store, with purchase state exposed to app | Store processing occurs; Nurtly receives status/product state via API | Store/provider-controlled; no Nurtly backend sharing found | Not classified as ephemeral | Required for Premium purchase/restore; optional feature | App functionality | Store transport; exact Play declaration needs owner confirmation | Nurtly local-data deletion does not remove Google Play purchase history, subscriptions, Google-managed billing records, or the real Premium entitlement managed through Google Play. It removes only Nurtly-owned local data, including the local app/reviewer access setting. | Billing client/provider; purchase stream, query, restore, complete | Flutter in-app purchase docs; Android Play Billing guide | CONFIRMED for boundary; LIKELY — VERIFY for final Play row | Final Billing disclosure in #182; merged release evidence #185 |
| Purchase token / transaction reference if present in store object | Google Play Billing | Provider-controlled store; exposed to app API | Store processing; no Nurtly persistence/backend path found | No Nurtly sharing path found; Google-controlled processing | No assumption | Required for transaction handling if supplied by store | App functionality, fraud/payment processing by store | Store transport | Google-managed; no local deletion claim | Repository does not read or transmit token fields | Android Play Billing guide; Flutter purchase API | CONFIRMED boundary; UNKNOWN for exact provider retention | Confirm exact object fields in #182/#186 |
| Consent signals / privacy choices | Google UMP | Provider-controlled consent state | Likely yes to UMP/Google services when consent flow runs | Provider-controlled | No assumption | Required to determine ad request eligibility; user choice is optional | Consent, compliance | Provider transport | Local deletion does not clear UMP state; Privacy options form is separate | Consent controller uses request/update, form, privacy options, `canRequestAds` | UMP Flutter setup | CONFIRMED code path; LIKELY — VERIFY provider disclosure | Confirm final consent message/configuration in #182 |

No Nurtly-controlled row is marked as shared merely because a third-party package is present. No final Play Console yes/no answer is asserted for configuration-dependent provider rows.

## 7. Confidence legend

- **CONFIRMED** — directly supported by repository code, final lockfile, manifest/build evidence, merged behavior, or current official documentation.
- **LIKELY — VERIFY** — official provider behavior applies conditionally and final release evidence is still required.
- **OWNER DECISION** — product/configuration choice such as personalized ads, Advertising ID declaration, optional/required selection, or final Play answer.
- **UNKNOWN** — evidence genuinely cannot establish the answer; the missing evidence and follow-up are named.

## 8. Owner-decision and follow-up register

| Item | Status | Follow-up |
|---|---|---|
| Personalized versus non-personalized ads | OWNER DECISION | #182 |
| Advertising ID declaration and production permission origin | OWNER DECISION / LIKELY — VERIFY | #182 and #185 |
| Exact provider Data Safety rows by release geography/consent/configuration | LIKELY — VERIFY | #182 and #186 |
| Final Billing purchase-history/token wording | OWNER DECISION / UNKNOWN for provider retention | #182 and #186 |
| Final merged manifest and release ad application ID | UNKNOWN in this documentation-only review | #185 |
| Real-device consent, ad request, deletion-boundary and purchase checks | UNKNOWN until performed | #186 |
| Target audience and Families confirmation | OWNER DECISION | Existing owner decision register; not decided by this document |

This inventory does not close #176, #172, #127, #131, or #104, and does not submit anything to Play Console.

## 9. Source register

All external sources below were accessed on 15 July 2026.

| Source title / publisher | URL | Evidence class | Relevant paraphrase | Supported rows |
|---|---|---|---|---|
| Provide information for Google Play’s Data safety section — Google Play Help | https://support.google.com/googleplay/android-developer/answer/10787469?hl=en | Current provider guidance | Collection is off-device transmission; local-only processing is out of scope; ephemeral processing has a defined narrow meaning; developers must account for third-party SDK behavior and choose optional/required classifications. | Matrix semantics; local rows; provider rows |
| Google Play data disclosure — Google for Developers | https://developers.google.com/admob/android/privacy/play-data-disclosure | Current provider guidance; not exact-version evidence | Current provider guidance for the latest native SDK: Google Mobile Ads automatically collects/shares IP, product interactions, diagnostics, and device/account identifiers for advertising, analytics, and fraud prevention; TLS is used; Advertising ID collection is optional/configurable. It is not exact-version proof for Nurtly’s resolved 23.6.0 SDK. | Ads, identifiers, region, diagnostics |
| Set up UMP SDK — Google for Developers | https://developers.google.com/admob/flutter/privacy?hl=en | Current provider guidance | Request consent information at app launch, show required forms, expose privacy options when required, and check `canRequestAds()` before requesting ads. | Consent and ads gate |
| Set up Google Mobile Ads Flutter Plugin — Google for Developers | https://developers.google.com/admob/flutter/quick-start?hl=en | Current provider guidance | The plugin requires the app ID in the Android manifest and Mobile Ads initialization before loading ads. | Ads manifest/build evidence |
| Integrate the Google Play Billing Library — Android Developers | https://developer.android.com/google/play/billing/integrate?hl=en | Current provider guidance | The purchase lifecycle includes product display, purchase, entitlement delivery, verification, and completion; purchase tokens may be stored locally or sent to a secure backend. | Billing boundary and token limitation |
| `in_app_purchase` package — Flutter team / pub.dev | https://pub.dev/packages/in_app_purchase | Current package documentation | The plugin delegates purchases to Google Play/App Store and exposes product details, purchase updates, restore, and completion APIs. | Billing code and resolved package |
| `shared_preferences` package — Flutter team / pub.dev | https://pub.dev/packages/shared_preferences | Current package documentation | The plugin wraps Android Shared Preferences and iOS NSUserDefaults for simple persistent key/value data. | Local persistence |
| `just_audio` package — pub.dev | https://pub.dev/packages/just_audio | Current package documentation | The player supports asset/file/URL sources; the repository’s selected source is a bundled asset materialized locally. | Audio boundary |
| `url_launcher` 6.3.2 — Flutter team / pub.dev | https://pub.dev/packages/url_launcher/versions/6.3.2 | Current package documentation | `launchUrl` hands a URL to the host platform; HTTPS commonly opens the default browser. | External browser boundary |
| Back up user data with Auto Backup — Android Developers | https://developer.android.com/identity/data/autobackup?hl=en | Current platform guidance | Backup and device-transfer XML can exclude shared preferences and other domains. | Local deletion/backup boundary |
| `google_mobile_ads` 5.3.1 changelog — Flutter team / pub.dev | https://pub.dev/packages/google_mobile_ads/versions/5.3.1/changelog | Exact package-version corroboration | The 5.3.0 entry records Android GMA 23.6.0 and UMP 3.1.0 dependencies; Gradle output is the exact-version evidence for this build. | Native dependency corroboration; exact-version evidence remains Gradle |

## 10. Limitations

This is a repository and documentation evidence draft, not a legal opinion and not a submitted or approved Data Safety response. It does not replace release-build merged-manifest inspection, provider-console configuration inspection, real-device testing, or owner confirmation. Provider behavior can vary by SDK version, device, geography, consent, account state, and configuration. The final answers must be made by the app owner against the exact distributed artifact.
