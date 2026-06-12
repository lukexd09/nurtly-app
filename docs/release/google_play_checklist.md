# Google Play launch checklist

Use this checklist to prepare the first MVP release in Google Play Console.

## 0. Closed-testing gate

- [ ] [Closed-testing release gate](closed_testing_release_gate.md) has been reviewed.
- [ ] [Closed-testing upload handoff](closed_testing_upload_handoff.md) has been reviewed.
- [ ] [Google Play submission content pack](google_play_submission_content_pack.md) has been reviewed.
- [ ] App package name is `com.nurtly.app`.
- [ ] App label is `Nurtly`.
- [ ] Current release version is confirmed in the release gate.

## 1. Repository / build readiness

- [ ] `tools/pre_pr_check.ps1` passes.
- [ ] `git diff --check` passes.
- [ ] `git status --short` is clean.
- [ ] The release AAB path matches the handoff doc.
- [ ] No private release configuration is committed in the repository.

## 2. Local owner machine readiness

- [ ] `app/android/key.properties` exists locally.
- [ ] The local upload keystore exists locally if required.
- [ ] The release build command works on the owner machine.
- [ ] The AAB can be produced from the current branch without adding secrets to git.
- [ ] The release smoke test can be run on a real device.

## 3. Play Console account and app setup

- [ ] Developer account is ready.
- [ ] App exists in Google Play Console.
- [ ] Package name is verified.
- [ ] App category is selected.
- [ ] Contact details are completed.
- [ ] Financial or payment profile is completed if required for paid products.

## 4. Release track

- [ ] Internal testing track is ready.
- [ ] Closed testing track is ready.
- [ ] Production release path is understood.
- [ ] Closed testing tester requirements are reviewed if applicable.
- [ ] Tester groups and invite links are organized.
- [ ] Release notes are prepared.

## 5. Android build upload

- [ ] AAB is generated.
- [ ] Signing and upload key are ready.
- [ ] Google Play App Signing is enabled.
- [ ] versionCode is checked.
- [ ] versionName is checked.
- [ ] Release artifact is uploaded.

## 6. Store listing

- [ ] App name is finalized.
- [ ] Short description is finalized.
- [ ] Full description is finalized.
- [ ] Closed-testing release notes are finalized.
- [ ] App icon is ready.
- [ ] Feature graphic is ready.
- [ ] Phone screenshots are ready.
- [ ] Tablet screenshots are ready if needed.
- [ ] Default language is chosen.
- [ ] EN and PL translations are reviewed where applicable.

## 7. Monetization

- [ ] Subscriptions and products are created.
- [ ] Monthly and yearly products are configured.
- [ ] Introductory or early pricing is configured if applicable.
- [ ] Restore purchases is tested manually.
- [ ] Premium users do not see ads.

## 8. Ads

- [ ] Ads app is created.
- [ ] Production ad app id is ready.
- [ ] Production ad unit ids are ready.
- [ ] Ad policy is reviewed.
- [ ] Ads follow the MVP contract: banner-only in passive browse areas.
- [ ] Ads do not interrupt Journal create or edit flows.
- [ ] Ads do not interrupt sound playback.
- [ ] Ads do not appear in Settings, Privacy, or other sensitive flows.
- [ ] Ads do not appear during startup or aggressive first-run moments.
- [ ] Premium disables ads.
- [ ] Production ads app and ad unit ids are ready.
- [ ] Rewarded and interstitial ads are not part of the MVP contract.

## 9. Privacy and compliance

- [ ] Privacy policy URL is published.
- [ ] Data Safety is completed.
- [ ] Privacy & Data screen in the app matches the published policy.
- [ ] Analytics provider decision is documented and points to no product analytics provider for MVP.
- [ ] Analytics taxonomy is reviewed and excludes Journal content and child-related data.
- [ ] If analytics is ever approved, provider, SDK, and consent decisions are confirmed or marked `Needs owner confirmation`.
- [ ] Content rating is completed.
- [ ] Target audience and families policy are checked.
- [ ] Ads disclosure is checked.
- [ ] In-app purchases disclosure is checked.

## 10. Upload-ready blockers

- [ ] Missing or invalid local signing files are resolved.
- [ ] `tools/pre_pr_check.ps1` passes.
- [ ] `git diff --check` passes.
- [ ] The release AAB builds successfully.
- [ ] The release AAB path exists.
- [ ] Package name, version, and signing expectations match the handoff doc.
- [ ] Required closed-testing track fields are complete.
- [ ] Tester group and invite flow are ready.

## 11. Public-release blockers

- [ ] Privacy policy URL is published.
- [ ] Store screenshots, icon, feature graphic, and listing copy are final.
- [ ] Data Safety answers are final.
- [ ] Content rating is complete.
- [ ] Target audience and families policy are complete.
- [ ] Production ad IDs are ready.
- [ ] Billing products and pricing are final.

## 12. Final QA

- [ ] Startup works.
- [ ] Localization works in EN and PL.
- [ ] Play flow works.
- [ ] Sounds flow works.
- [ ] Journal flow works.
- [ ] Premium and paywall work.
- [ ] Restore purchases works.
- [ ] Ads behave correctly.
- [ ] Settings work.
- [ ] Privacy screen works.
- [ ] Privacy & Data wording is clear in EN and PL.
- [ ] Offline and basic fallback behavior is acceptable.
- [ ] Release build smoke test passed on a real device.
