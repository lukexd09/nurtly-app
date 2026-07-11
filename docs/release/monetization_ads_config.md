# Monetization and ads release config

This note summarizes the current release-readiness state for monetization and ads in the MVP-2 release path.

## 1. Current repo state

### Billing

- Google Play Billing integration is present in the app.
- Current product IDs expected by the app:
  - `nurtly_premium_monthly`
  - `nurtly_premium_yearly`
- Premium entitlement supports monthly and yearly active states.
- Restore purchases is wired through the premium access flow.
- Premium gating is applied through entitlement and ad policy checks.

### Ads

- Ads are wired through the app.
- The merged Android manifest contains `INTERNET`.
- The merged Android manifest contains `AD_ID`.
- `AD_ID` is introduced by the Google Mobile Ads dependency through `play-services-ads-lite`.
- Current Android manifest uses the Google test ads app id for development.
- Banner ads are the current ad format.
- The committed banner ad unit IDs use Google test values for development and closed-test validation.
- Production app and ad unit IDs should be delivered through a secure release process before public release and should not be committed as sensitive release values.
- Premium users should not load or see ads.

### UMP consent flow

- Android startup requests UMP consent info before banner loading.
- Banner ads are only initialized after `canRequestAds()` becomes true.
- If privacy options are required, the app surfaces a privacy choices action in Privacy & Data.
- Privacy choices appears only when required.
- Debug EEA testing is enabled only in debug builds.
- Local debug test device IDs can be supplied with `--dart-define=UMP_TEST_DEVICE_IDS=ID1,ID2`.

## 2. Required Google Play Console setup

- [ ] Create the monthly subscription product.
- [ ] Create the yearly subscription product.
- [ ] Verify the product IDs match the app config exactly.
- [ ] Configure introductory or early pricing in Play Console if the launch offer is intended.
- [ ] Test purchases on internal or closed track before production.
- [ ] Confirm restore purchases works on a real device.
- [ ] Confirm premium users do not see ads.

## 3. Required ads setup

- [ ] Create the production ads app.
- [ ] Replace the test ads app id with the production ads app id before public release.
- [ ] Create production banner ad units.
- [ ] Map the production ad unit ids into the release setup.
- [ ] Keep rewarded ads out of this MVP release.

## 4. Premium behavior

- Premium users must not see ads.
- Restore purchases should recover Premium when a valid purchase exists.
- Failed, expired, or cancelled purchase states should be smoke-tested where practical.
- The app uses the entitlement state, not hardcoded paid/free UI assumptions, to control ad visibility.

## 5. Local data deletion

- Privacy & Data includes a delete-all-local-data action.
- The action clears local journal entries, the saved language preference, and reviewer-access state.
- The action is separate from UMP consent and does not delete UMP-managed consent.
- It does not delete Google Play purchase history.
- The UI should land back on an empty journal state after success.

## 6. Release checklist

- [ ] Test IDs are not used in public production release.
- [ ] Production IDs are not committed as sensitive values if avoidable.
- [ ] Data Safety is updated after final ads behavior is confirmed.
- [ ] Privacy policy is updated after final ads behavior is confirmed.
- [ ] Play Console billing and ads configuration matches the release build.
- [ ] Debug geography is not forced in release builds.

## Notes

- This document is a release checklist, not a production configuration file.
- Real production ads IDs should live in the store console or a secure release process, not in this repo.
