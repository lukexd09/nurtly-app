# Android release privacy technical evidence

## Evidence status

| Field | Result |
| --- | --- |
| Candidate or provisional status | Candidate evidence: CONFIRMED |
| Repository | `lukexd09/nurtly-app` |
| Source SHA | `9a66925075e61a785af721191047f42c28875307` |
| Workflow SHA | `9a66925075e61a785af721191047f42c28875307` |
| Workflow run ID and attempt | `29698235374`, attempt 1 |
| Artifact name | `nurtly-android-0.1.0-9-9a66925` |
| Artifact ID | `8445767570` |
| Artifact SHA-256 | `d7adbad9e1f082a444036cec9adb2638f3fb21ad1d18de23c430d749d7e0f14d` |
| AAB signature verification | PASS; JDK `jarsigner` exit 0. Local certificate-chain trust was unavailable. |
| Version name | `0.1.0` |
| Version code | `9` |
| Android package ID | `com.graylion.nurtly` |
| Build type | Release |
| Ads profile | `closed-test-sample-banner` |
| Google Mobile Ads App ID metadata | externally configured non-sample value CONFIRMED; actual value intentionally not repeated |
| Manual QA status | NOT RUN |
| Store delivery status | NOT RUN |
| Evidence capture date | 2026-07-19 |
| Bundletool version and SHA-256 | `1.18.3`; `A099CFA1543F55593BC2ED16A70A7C67FE54B1747BB7301F37FDFD6D91028E29` |
| Raw evidence retention boundary | `C:\Projekty\Nurtly-evidence\247\9a66925075e61a785af721191047f42c28875307\29698235374` |

The artifact metadata, filename, source SHA, workflow run and attempt, version, build number, repository identity, AAB checksum, automated validation result, manual QA status, and store-delivery status all matched. The workflow reported automated validation `PASS`. The AAB was signed by the GitHub Android Release workflow; it was not processed by Google Play App Signing.

`0.1.0+8` remained valid technical evidence but was superseded for Play delivery because version code `8` already existed in Google Play Console.

## Manifest evidence

Bundletool `1.18.3` validated the candidate AAB and dumped the base-module manifest. The raw manifest is retained only outside the repository. It contains the Android package ID `com.graylion.nurtly`, version name `0.1.0`, and version code `9`.

The release merged manifest, manifest-merger blame report, and merger report were generated from the exact source SHA using `processReleaseMainManifest`. A temporary non-production signing shim was used only for manifest processing and was removed afterward. Candidate AAB signing source: GitHub Android Release workflow.

After comparing the AAB manifest and Gradle merged manifest, they matched for package, version, version code, permissions, privacy-relevant components, exported attributes, backup attributes, service declarations, provider declarations, metadata names, Billing declarations, and media/audio declarations.

| Raw evidence file | SHA-256 |
| --- | --- |
| `aab-base-manifest.xml` | `E6611C85CF0881B88BEE6A22D1AE241CFAB4DEC41575CB0FEC6D7B4E1E2F2D1C` |
| `gradle-merged-manifest.xml` | `E920EDF9BFFA9A14D839EB3764CC1F3E44E6F7106C86BC86F01C4773D7CD6287` |
| `gradle-manifest-blame.txt` | `F3E75F4BADF02AEF64EEA1FD4DEF397E570289951ED355B87AF42CA84B07A953` |
| `gradle-manifest-report.txt` | `9FA99246CC12683DB80051448A49D8CEF50592D261079314419CC75948620DE3` |

## Privacy-relevant component inventory

`27` final-AAB components were reviewed: `8` activities, `2` providers, `7` services, and `10` receivers.

Exported components: `4`.

Permission-protected components: `4`.

### Activities

| Component | Type | Final AAB presence | Origin | Origin evidence | Exported | Protecting permission | Intent filters | Runtime purpose | Privacy relevance | Expected | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `com.graylion.nurtly.MainActivity` | Activity | CONFIRMED | `app/android/app/src/main/AndroidManifest.xml` | lines 81-99 | `true` | none | `MAIN`; `LAUNCHER` | App entrypoint and Flutter host | User-facing launch surface; no direct data capture by itself | YES | CONFIRMED |
| `io.flutter.plugins.urllauncher.WebViewActivity` | Activity | CONFIRMED | `url_launcher_android` | lines 105-108 | `false` | none | none | In-app web view for launched links | External-content surface; not externally callable | YES | CONFIRMED |
| `com.google.android.gms.ads.AdActivity` | Activity | CONFIRMED | Google Mobile Ads SDK `23.6.0` | lines 120-124 | `false` | none | none | Ad display and fullscreen ad host | Ad SDK runtime surface | YES | CONFIRMED |
| `com.google.android.gms.ads.OutOfContextTestingActivity` | Activity | CONFIRMED | Google Mobile Ads SDK `23.6.0` | lines 137-140 | `false` | none | none | Ad testing surface | Provider test surface only | REVIEW REQUIRED | CONFIRMED |
| `com.google.android.gms.ads.NotificationHandlerActivity` | Activity | CONFIRMED | Google Mobile Ads SDK `23.6.0` | lines 141-147 | `false` | none | none | Ad notification handling | Ad SDK runtime surface | YES | CONFIRMED |
| `com.android.billingclient.api.ProxyBillingActivity` | Activity | CONFIRMED | Play Billing `7.1.1` | lines 157-161 | `false` | none | none | Billing flow host | Purchase-flow surface | YES | CONFIRMED |
| `com.android.billingclient.api.ProxyBillingActivityV2` | Activity | CONFIRMED | Play Billing `7.1.1` | lines 162-166 | `false` | none | none | Billing flow host | Purchase-flow surface | YES | CONFIRMED |
| `com.google.android.gms.common.api.GoogleApiActivity` | Activity | CONFIRMED | Play services base `18.5.0` | lines 167-170 | `false` | none | none | Google Play services resolution flow | Provider resolution surface | YES | CONFIRMED |

### Providers

| Component | Type | Final AAB presence | Origin | Origin evidence | Exported | Protecting permission | Intent filters | Runtime purpose | Privacy relevance | Expected | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `com.google.android.gms.ads.MobileAdsInitProvider` | Provider | CONFIRMED | Google Mobile Ads SDK `23.6.0` | lines 126-130 | `false` | none | none | Mobile Ads startup initialization | Ad SDK initialization path | YES | CONFIRMED |
| `androidx.startup.InitializationProvider` | Provider | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 180-193 | `false` | none | none | Startup wiring for WorkManager, ProcessLifecycle, and ProfileInstaller | Background-startup coordination surface | YES | CONFIRMED |

### Services

| Component | Type | Final AAB presence | Origin | Origin evidence | Exported | Protecting permission | Intent filters | Runtime purpose | Privacy relevance | Expected | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `com.google.android.gms.ads.AdService` | Service | CONFIRMED | Google Mobile Ads SDK `23.6.0` | lines 132-135 | `false` | none | none | Ad SDK service | Ad SDK runtime surface | YES | CONFIRMED |
| `androidx.work.impl.background.systemalarm.SystemAlarmService` | Service | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 195-199 | `false` | none | none | WorkManager system-alarm scheduler | Local background-work coordination | YES | CONFIRMED |
| `androidx.work.impl.background.systemjob.SystemJobService` | Service | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 200-205 | `true` | `android.permission.BIND_JOB_SERVICE` | none | WorkManager job scheduler | System-bound background-work endpoint | YES | CONFIRMED |
| `androidx.work.impl.foreground.SystemForegroundService` | Service | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 206-210 | `false` | none | none | WorkManager foreground-work support | Foreground-work capability only | YES | CONFIRMED |
| `com.google.android.datatransport.runtime.backends.TransportBackendDiscovery` | Service | CONFIRMED | Transport backend CCT `3.1.8` | lines 306-312 | `false` | none | none | Backend discovery for transport runtime | Transport/provider backend wiring | YES | CONFIRMED |
| `com.google.android.datatransport.runtime.scheduling.jobscheduling.JobInfoSchedulerService` | Service | CONFIRMED | Transport runtime `3.1.8` | lines 313-317 | `false` | `android.permission.BIND_JOB_SERVICE` | none | Job scheduler for transport runtime | Background transport scheduling | YES | CONFIRMED |
| `androidx.room.MultiInstanceInvalidationService` | Service | CONFIRMED | Room runtime `2.2.5` | lines 323-326 | `false` | none | none | Room multi-instance invalidation | Local database coordination only | YES | CONFIRMED |

### Receivers

| Component | Type | Final AAB presence | Origin | Origin evidence | Exported | Protecting permission | Intent filters | Runtime purpose | Privacy relevance | Expected | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `androidx.work.impl.utils.ForceStopRunnable$BroadcastReceiver` | Receiver | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 212-216 | `false` | none | none | WorkManager force-stop recovery | Background-work recovery only | YES | CONFIRMED |
| `androidx.work.impl.background.systemalarm.ConstraintProxy$BatteryChargingProxy` | Receiver | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 217-226 | `false` | none | `ACTION_POWER_CONNECTED`; `ACTION_POWER_DISCONNECTED` | Battery-charging constraint proxy | Background-work constraint handling | YES | CONFIRMED |
| `androidx.work.impl.background.systemalarm.ConstraintProxy$BatteryNotLowProxy` | Receiver | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 227-236 | `false` | none | `BATTERY_OKAY`; `BATTERY_LOW` | Battery-level constraint proxy | Background-work constraint handling | YES | CONFIRMED |
| `androidx.work.impl.background.systemalarm.ConstraintProxy$StorageNotLowProxy` | Receiver | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 237-246 | `false` | none | `DEVICE_STORAGE_LOW`; `DEVICE_STORAGE_OK` | Storage-availability constraint proxy | Background-work constraint handling | YES | CONFIRMED |
| `androidx.work.impl.background.systemalarm.ConstraintProxy$NetworkStateProxy` | Receiver | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 247-255 | `false` | none | `CONNECTIVITY_CHANGE` | Network-state constraint proxy | Background-work constraint handling | YES | CONFIRMED |
| `androidx.work.impl.background.systemalarm.RescheduleReceiver` | Receiver | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 256-266 | `false` | none | `BOOT_COMPLETED`; `TIME_SET`; `TIMEZONE_CHANGED` | Job rescheduling after reboot/time changes | Background-work recovery only | YES | CONFIRMED |
| `androidx.work.impl.background.systemalarm.ConstraintProxyUpdateReceiver` | Receiver | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 267-275 | `false` | none | `UpdateProxies` | Constraint-proxy update hook | Background-work coordination only | YES | CONFIRMED |
| `androidx.work.impl.diagnostics.DiagnosticsReceiver` | Receiver | CONFIRMED | AndroidX Work runtime `2.7.0` | lines 276-285 | `true` | `android.permission.DUMP` | `REQUEST_DIAGNOSTICS` | Work diagnostics endpoint | Debug/diagnostic exposure only | OWNER DECISION | CONFIRMED |
| `androidx.profileinstaller.ProfileInstallReceiver` | Receiver | CONFIRMED | ProfileInstaller `1.3.1` | lines 286-304 | `true` | `android.permission.DUMP` | `INSTALL_PROFILE`; `SKIP_FILE`; `SAVE_PROFILE`; `BENCHMARK_OPERATION` | Profile installation and benchmark actions | Performance-maintenance surface only | REVIEW REQUIRED | CONFIRMED |
| `com.google.android.datatransport.runtime.scheduling.jobscheduling.AlarmManagerSchedulerBroadcastReceiver` | Receiver | CONFIRMED | Transport runtime `3.1.8` | lines 319-321 | `false` | none | none | Alarm-based transport scheduling | Background transport scheduling | YES | CONFIRMED |

## Backup and device-transfer evidence

| Item | Result | Evidence |
| --- | --- | --- |
| `android:allowBackup="true"` | CONFIRMED | App manifest and AAB manifest blame lines 68-74 |
| `@xml/backup_rules` | CONFIRMED | App manifest and AAB manifest blame lines 72-74 |
| `@xml/data_extraction_rules` | CONFIRMED | App manifest and AAB manifest blame lines 70-72 |
| `root`, `file`, `database`, `sharedpref`, `external` exclusions | CONFIRMED | `backup_rules.xml` and `data_extraction_rules.xml` |
| Cloud backup | CONFIRMED excluded | `data_extraction_rules.xml` `<cloud-backup>` block |
| Device transfer | CONFIRMED excluded | `data_extraction_rules.xml` `<device-transfer>` block |
| Manifest/configuration evidence | CONFIRMED | AAB and Gradle manifests match on backup attributes |
| Real-device backup/restore | NOT RUN | Owner-device QA not run |

Both Android backup paths exclude the same local-data domains. That covers cloud backup and device transfer for the app's local storage surface.

## Permission inventory

The final AAB contains 10 permissions. Origins below are from the manifest-merger blame report; runtime use is not inferred from presence alone.

| Permission | Final AAB presence | Origin | Origin evidence | Runtime request in Nurtly code | Runtime purpose | Control | Data Safety relevance | Expected for closed testing | Confidence | Follow-up |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `android.permission.INTERNET` | CONFIRMED | Google Mobile Ads Flutter plugin | blame lines 11-13 | NO | Provider network access | Provider-contributed | Provider ad/consent transport may process provider-controlled data | YES | CONFIRMED | Owner review in #182/#186 |
| `android.permission.ACCESS_NETWORK_STATE` | CONFIRMED | AndroidX Media3 common 1.4.1 | blame lines 14-16 | NO | Provider/library network-state checks | Provider-contributed | Supports provider/library connectivity decisions | YES | CONFIRMED | None |
| `com.google.android.gms.permission.AD_ID` | CONFIRMED | Google Mobile Ads Android SDK 23.6.0 | blame lines 17-20 | NO | Provider advertising identifier access | Provider-contributed | Identifier processing may apply when ads/provider services run | OWNER DECISION | CONFIRMED | Advertising ID declaration in #182 |
| `android.permission.ACCESS_ADSERVICES_AD_ID` | CONFIRMED | Google Mobile Ads Android SDK 23.6.0 | blame lines 21-24 | NO | Android Privacy Sandbox advertising services access | Provider-contributed | Provider advertising and measurement processing may apply | OWNER DECISION | CONFIRMED | Confirm final provider posture in #182 |
| `android.permission.ACCESS_ADSERVICES_ATTRIBUTION` | CONFIRMED | Google Mobile Ads Android SDK 23.6.0 | blame lines 25-28 | NO | Android Privacy Sandbox attribution access | Provider-contributed | Provider attribution processing may apply | OWNER DECISION | CONFIRMED | Confirm final provider posture in #182 |
| `android.permission.ACCESS_ADSERVICES_TOPICS` | CONFIRMED | Google Mobile Ads Android SDK 23.6.0 | blame lines 29-32 | NO | Android Privacy Sandbox topics access | Provider-contributed | Provider interest/advertising processing may apply | OWNER DECISION | CONFIRMED | Confirm final provider posture in #182 |
| `com.android.vending.BILLING` | CONFIRMED | Google Play Billing Library 7.1.1 | blame lines 100-102 | NO | Product and purchase operations | Provider-contributed | Billing and purchase-status processing is provider-controlled | YES | CONFIRMED | Billing console confirmation in #182 |
| `android.permission.WAKE_LOCK` | CONFIRMED | Google Play measurement transitives 20.1.2 | blame lines 103-105 | NO | Provider/library scheduled work | Provider-contributed | Provider/library background work capability | YES | CONFIRMED | None |
| `android.permission.FOREGROUND_SERVICE` | CONFIRMED | AndroidX Work runtime 2.7.0 | blame lines 106-108 | NO | Library foreground work support | Provider-contributed | Capability declaration; no Nurtly runtime request found | YES | CONFIRMED | Real-device check in #186 |
| `com.graylion.nurtly.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | CONFIRMED | AndroidX Core 1.17.0 | blame lines 112-119 | NOT APPLICABLE | Protects non-exported dynamic receivers | Provider-contributed | Internal component boundary; not user data collection | YES | CONFIRMED | None |

Explicitly absent from the final AAB: `android.permission.POST_NOTIFICATIONS`, `android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK`, storage permissions, media permissions, audio-recording permissions, location permissions, and camera permissions.

No Android feature declaration relevant to storage, media capture, recording, location, or camera was found. No runtime permission request for those areas was found in Nurtly code.

## Advertising ID and provider metadata

- Final AAB `AD_ID` presence: CONFIRMED.
- Exact origin: Google Mobile Ads Android SDK 23.6.0, blame lines 17-20.
- Direct Nurtly Advertising ID API usage: NOT FOUND in source inspection.
- Provider dependency contribution: CONFIRMED through the release dependency graph and manifest blame.
- Google Mobile Ads App ID metadata: externally configured non-sample value CONFIRMED; actual value intentionally not repeated.
- Closed-test profile: `closed-test-sample-banner`.
- Personalization enforcement status: OWNER DECISION / NOT CONFIRMED by this evidence.
- Final Play Console declaration status: BLOCKED — OWNER CONFIRMATION REQUIRED.
- Non-personalized ads do not establish that identifier processing is absent. This task did not remove `AD_ID`.

The AAB application metadata includes the Google Mobile Ads App ID metadata name. Its configured value is withheld. Billing metadata reports Google Play Billing Library `7.1.1`. No audio-session component, exported Nurtly provider, or exported Nurtly service was found. The launcher activity is `com.graylion.nurtly.MainActivity` with `exported="true"`; the URL launcher activity is `exported="false"`. Provider and service declarations from Google Mobile Ads, Billing, AndroidX startup/work, and transport libraries are non-exported except for provider-declared diagnostics receivers protected by `DUMP`.

## Dependency evidence

Release configuration: `releaseRuntimeClasspath`.

- Google Mobile Ads Android SDK: `23.6.0`.
- UMP Android SDK: `3.1.0`.
- Google Play Billing Library: `7.1.1`.
- Google Mobile Ads Flutter plugin: `5.3.1`.
- Shared Preferences implementation: `2.4.23` on Android; canonical inventory package resolution remains `2.5.5` for the Dart package.
- Audio playback implementation: `0.10.5`.
- AndroidX / Media3 privacy-relevant transitive: Media3 common `1.4.1`; AndroidX Work runtime `2.7.0`; AndroidX Core `1.17.0`.
- Dependency drift from #181 inventory: NO.

| Report | SHA-256 |
| --- | --- |
| Ads dependency insight | `5AD63C2D13C51948C850437F336646789094A7D0CD19D28B37DC5EA30E00E66F` |
| UMP dependency insight | `40A33C13B94A6C448EAF8BA8776925F110083B760F82565A7C044C053B785D10` |
| Billing dependency insight | `55B84A0BCA23832E37D5F713180BF2AE046C24091D4C117B6C5A50F9EF0773D6` |
| Full release runtime graph | `70A057BC8BDADF6F7A1415FCFEAD2A4ED64F17080FAF4E92F42FD8DFC2AFA3FA` |

## UMP and release configuration

Build-input and code-path evidence: CONFIRMED.

- The workflow input was `closed-test-sample-banner`.
- No production banner value was passed for this profile.
- The release workflow passed the selected profile through Dart configuration and passed an empty banner value for the sample-banner profile.
- Release Dart configuration uses `kReleaseMode`.
- UMP debug geography and test-device IDs are gated by `kDebugMode`.
- No `UMP_TEST_DEVICE_IDS` release define was supplied.
- Candidate workflow logs contained no debug geography or test-device value.
- Banner loading remains gated by provider `canRequestAds()`.
- Mobile Ads initialization failure remains fail-closed.

Real-device runtime evidence: NOT RUN — #186.

## Journal and unintended data-flow boundary

Static source/config evidence:

- Journal content sent to Ads: NOT FOUND.
- Journal content sent to Billing: NOT FOUND.
- Journal content sent to network/backend: NOT FOUND.
- Journal-content logging path: NOT FOUND.
- Journal storage is local-only through the local preference implementation; the Journal model/repository was reviewed at `app/lib/features/journal/journal_entry.dart`, `journal_store.dart`, and `journal_controller.dart`.
- The only source logging path found is Sounds playback diagnostics; it is not passed Journal fields.

Candidate build/workflow logs:

- Journal content found: NO.
- Workflow output contained no child name, birth date, or note body values.

Runtime device/network observation: NOT RUN — #186.

Static inspection does not prove every possible runtime payload. No real user Journal content was included in this evidence package.

## Owner and manual blockers

- Repository application-ID variable: PASS.
- Signed candidate artifact: PASS.
- Merged release manifest: PASS.
- Permission-origin inventory: PASS.
- UMP console configuration: BLOCKED.
- Billing console confirmation: BLOCKED.
- Advertising ID declaration: BLOCKED.
- Personalization posture: BLOCKED.
- Real-device privacy QA: NOT RUN.
- Store delivery: NOT RUN.

No Play Console submission, store promotion, provider-console mutation, permission removal, manual-QA claim, production identifier commit, or merge was performed.
