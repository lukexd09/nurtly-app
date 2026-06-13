# Final Release Blockers

This is the authoritative blocker register for the MVP release pack.

Resolved blockers should be removed from active lists or explicitly marked resolved in this file only.

## Blocker Register

| ID | Area | Description | Repo-side or owner-side | Closed testing or public release | Severity | Evidence | Resolution action | Responsible party | Current status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BLK-001 | Android signing | `app/android/key.properties` is not present in the repository checkout, so release AAB generation cannot complete safely on this machine. | Owner-side | Closed testing and public release | BLOCKER | `Test-Path app/android/key.properties` returned `False`; `app/android/app/build.gradle` throws on missing release signing. | Create the local signing file on the owner machine and keep it out of git. | Owner | Open |
| BLK-002 | Audio licensing | Bundled sound provenance is not documented in the repo for the six shipped sound assets. | Repo-side | Closed testing and public release | BLOCKER | `docs/release/sounds_mvp_behavior.md` requires provenance; repository search found no source/license record; no inventory existed before this task. | Record source, provider, license type, and attribution requirements for every bundled sound or replace the assets. | Owner / content owner | Open |
| BLK-003 | Store assets | Final icon/export assets are incomplete in the repo, and the feature graphic / screenshot exports are not yet committed. | Repo-side | Closed testing and public release | HIGH | `app/android/app/src/main/res` only contains a simple `drawable/ic_launcher.xml` placeholder; `docs/release/store_asset_inventory.md` shows the remaining assets as not exported. | Export the final app icon set, feature graphic, and screenshot set, then upload them in Play Console. | Owner / design / store ops | Open |
| BLK-004 | Privacy publication | The public privacy-policy URL is still not live, and the publication handoff still contains placeholder values. | Owner-side | Closed testing and public release | BLOCKER | `docs/legal/privacy_policy_publication_handoff.md` says publication is blocked until `[DATE_TBD]` and `[CONTACT_EMAIL_TBD]` are replaced. | Publish the EN/PL public pages, replace the placeholders, and confirm the live URL in Play Console. | Owner | Open |
| BLK-005 | Play Console setup | Final Play Console audience, content rating, Data Safety, tester group, invite flow, and billing configuration are not yet confirmed in the repo or console. | Owner-side | Closed testing and public release | HIGH | `docs/release/play_console_owner_decisions.md`, `docs/release/closed_testing_go_no_go.md`, and `docs/release/data_safety.md` all retain owner-confirmation items. | Complete the Play Console setup and align the final answers with the shipped build. | Owner | Open |

## Notes

- This register is the single source of truth for active blockers.
- Release docs outside this file should link here instead of repeating blocker lists.
- Background audio is intentionally not listed as a blocker because it is deferred post-MVP.
- Interstitial, rewarded, analytics-provider, cloud-sync, and account-system work remain out of scope rather than active blockers.
