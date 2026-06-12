# Closed Testing Release Gate

This document is the operational release gate for inviting closed-test users to the Nurtly MVP. It consolidates the current release posture, the remaining owner decisions, and the documents that must stay aligned before testers are invited.

## Current release posture

- App identity is set in the repo as `com.nurtly.app` with app label `Nurtly`.
- The current app version in `app/pubspec.yaml` is `0.1.0+1`.
- Android release signing expects a local `app/android/key.properties` file and keeps private release credentials out of git.
- The MVP is parent-facing, privacy-first, and local-only for Journal data.
- The current MVP release path is banner-only in passive browse areas, Premium users are ad-free, Sounds behavior is documented, and no product analytics provider is selected for MVP.
- The remaining owner-confirmation items and recommended defaults are documented in [Play Console owner decisions](play_console_owner_decisions.md) and [Closed-testing go/no-go](closed_testing_go_no_go.md).

## Location

- Primary gate: [docs/release/closed_testing_release_gate.md](closed_testing_release_gate.md)
- Supporting release docs: [Google Play checklist](google_play_checklist.md), [Android release build](android_release_build.md), [Android signing](android_signing.md), [Store listing preparation](store_listing.md), [Data Safety preparation](data_safety.md), [Monetization and ads release config](monetization_ads_config.md), [Play Console owner decisions](play_console_owner_decisions.md), [Closed-testing go/no-go](closed_testing_go_no_go.md), [Closed-testing release candidate runbook](closed_testing_release_candidate_runbook.md), [Closed-testing release candidate evidence](closed_testing_release_candidate_evidence.md), [MVP ad placement contract](ads_mvp_behavior.md), [Sounds MVP behavior](sounds_mvp_behavior.md)
- Supporting QA docs: [Release smoke test](../qa/release_smoke_test.md), [MVP manual QA checklist](../qa/mvp_manual_qa_checklist.md)

## Release build readiness

- Release signing is documented and should be kept outside version control.
- `flutter test` and `tools/pre_pr_check.ps1` are the expected local verification steps before a release build.
- A closed-testing AAB should be produced from the current branch and checked on a real device before testers are invited.
- No private release configuration should be committed to the repository.

## Google Play closed-testing setup steps

1. Confirm the developer account, app entry, and closed-testing track exist in Google Play Console.
2. Confirm the release signing setup is ready for the AAB upload flow.
3. Confirm the tester group and invite link are prepared.
4. Upload the signed release build and attach release notes.
5. Complete or verify the store listing, privacy policy URL, content rating, target audience, and Data Safety answers.
6. Confirm Premium purchase products and restore flow are ready in Play Console if they are being exercised in closed testing.

## Store listing readiness

- App name, short description, full description, screenshots, icon, and feature graphic still need final Play Console readiness checks.
- The store listing copy should stay calm, parent-facing, and non-medical.
- No ad overlays should appear in Journal, Settings, Privacy, or active audio screenshots.

## Data Safety readiness

- Journal data is local-only and not synced to a backend or cloud service.
- The app does not require a child name or exact birthdate for MVP use.
- Ads are currently banner-only in passive areas and should not appear in Journal, active audio, Privacy/Settings, or startup flows.
- No product analytics provider is selected for the MVP.
- Final Data Safety answers must still match the actual Play Console configuration.

## Privacy policy readiness

- Draft privacy policies exist in English and Polish.
- The privacy policy URL is still an owner decision before publication.
- The policy text must continue to match the current MVP behavior: local-only Journal, banner-only passive ads, Premium ad-free, and no product analytics provider for MVP.

## Ads / Premium readiness

- Banner-only passive ads are the current MVP contract.
- Premium users should not see ads.
- Interstitial and rewarded ads are not part of the MVP contract.
- Production ad app and unit IDs remain an owner decision before public release.
- The current repository should not contain production ad IDs or secrets.

## Analytics readiness

- No analytics provider is configured for the MVP.
- No analytics SDK is committed in the current release slice.
- Any future analytics provider decision must remain separate from closed-testing launch readiness unless owner confirmation changes the scope.

## Sounds readiness

- Sounds MVP behavior is documented and should stay aligned with the release smoke test.
- The release gate assumes bundled audio content, timer behavior, fade-out, and loop behavior follow the current documented contract.

## Journal / local-only readiness

- Journal data remains local-only in the current implementation.
- The release gate does not assume cloud sync, account sync, or backend storage.
- Journal content should stay out of analytics and ad targeting.

## Localization readiness

- English and Polish content exist for the app and the privacy policy drafts.
- Closed-testing smoke checks should cover both languages before testers are invited.

## Manual QA / smoke-test readiness

- Use [Release smoke test](../qa/release_smoke_test.md) for the closed-testing device pass.
- Use [MVP manual QA checklist](../qa/mvp_manual_qa_checklist.md) for module-level checks.
- The smoke checklist should cover startup, localization, Play, Sounds, Journal, Premium, ads, privacy, offline fallback, and release install behavior.
- Record the release-candidate preflight and smoke-test results in the release-candidate evidence template.

## Launch blockers found

- Privacy policy URL is still a placeholder.
- Store assets and listing copy still need final Play Console publication values.
- Data Safety answers still need final confirmation.
- Content rating and target audience setup still need Play Console confirmation.
- Closed-testing track, tester group, and invite flow still need final Play Console setup.
- The remaining blocker decisions are tracked in [Play Console owner decisions](play_console_owner_decisions.md).

## Non-blockers

- Banner-only passive ads are already documented for the MVP.
- Premium ad-free behavior is already documented.
- Journal local-only behavior is already documented.
- Sounds MVP behavior is already documented.
- No product analytics provider is selected for MVP.

## Owner decisions needed

- See [Play Console owner decisions](play_console_owner_decisions.md) for the current recommended defaults and remaining confirmations.

## Notes

- This document is a gate, not a product feature spec.
- Confirm no private release configuration was committed.
- Confirm #104 was not closed.
