# Play Console owner decisions

For the current authoritative release status and blocker list, see [Final MVP release readiness](final_mvp_release_readiness.md) and [Final release blockers](final_release_blockers.md).

This document turns the remaining Play Console and release-blocker questions into recommended MVP defaults for the Nurtly closed-testing path.

It is a decision pack for release readiness only. It does not change app behavior or commit production configuration.

## Decision matrix

| Decision area | Recommended default | Rationale | Play Console impact | Risk if wrong | Owner confirmation needed | Blocks closed testing | Blocks public release |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Target audience | Adults 18+, parents/caregivers | Matches the product's parent-focused positioning and keeps the app out of child-directed framing. | Sets the store audience, families posture, and rating questionnaire tone. | Misstated audience could create policy mismatch or review delay. | Yes | Yes | Yes |
| Child-directed / Families Program posture | Not directed to children; do not opt into Families Program unless explicitly approved later | The app is a calm support tool for adults, with local Journal and parent-facing content. | Influences families compliance, listing language, and content review. | Incorrect Families posture could trigger policy issues or the wrong audience labeling. | Yes | Yes | Yes |
| Content rating posture | Use the lowest truthful rating from Play Console; keep the app non-medical, non-violent, non-sexual, and not child-directed | Conservative truthfulness keeps the review aligned with the app's actual calm parenting scope. | Affects the content rating questionnaire and final badge shown in Play Console. | Wrong answers can raise the rating or create compliance risk. | Yes | Yes | Yes |
| Privacy policy URL handoff | Publish the live policy only after the publication handoff is reviewed and the final text matches the shipped behavior | The URL should point to the final policy, not a placeholder. | Required for public release and expected for closed-testing readiness planning. | A placeholder URL breaks trust and can block publication. | Yes | Yes | Yes |
| Data Safety draft posture | Local-only Journal, no product analytics provider for MVP, no Journal note content in analytics or Data Safety narratives, billing disclosed, ads described as passive banner-only in allowed browse areas | Keeps the Data Safety answers conservative and aligned with the current repo posture. | Drives Data Safety disclosure categories and free-text answers. | Wrong disclosure can block review or require a resubmission. | Yes | Yes | Yes |
| Advertising ID | Do not claim Advertising ID is in use unless the final ad setup explicitly requires it | Keeps ad disclosures cautious while the final ad setup remains owner-confirmed. | May affect Data Safety and ads declarations. | Over-claiming use can create privacy mismatch; under-claiming if used is also risky. | Yes | No | Yes |
| Ad personalization | Default to no personalized ads in the MVP decision pack; keep personalization as owner-confirmed if it is ever introduced | The calm parenting position is stronger with the simplest ad model. | Affects Data Safety, privacy wording, and ads policy language. | Wrong choice can change disclosure obligations and user trust. | Yes | No | Yes |
| Ads setup for closed testing | Banner-only passive ads in allowed browse areas, with no ads in Journal create/edit, active audio, privacy/settings, startup, or paywall flows | This matches the current MVP ad contract and keeps testing calm and reviewable. | Guides release notes, QA, and Data Safety copy. | A more aggressive setup would damage UX and trigger review issues. | Yes | Yes | Yes |
| Ads setup for public release | Keep banner-only passive ads unless the owner explicitly approves a broader model later | The MVP should remain simple and non-intrusive at launch. | Must match store copy, privacy policy, and ads configuration. | Changing ad format later creates store and privacy mismatches. | Yes | No | Yes |
| Premium billing products | Keep monthly and yearly Premium products as the current release model; do not add new products in this task | Preserves the existing monetization structure without expanding scope. | Affects Billing setup, paywall wording, and test-track preparation. | Wrong or unstable product IDs can break purchases. | Yes | Yes | Yes |
| Closed-testing track | Use the intended closed-testing track only; keep production rollout separate | Keeps release control tight for tester validation. | Determines the track, tester access, and upload flow in Play Console. | Wrong track can expose an unstable build. | Yes | Yes | Yes |
| Tester group and invite flow | Use a small internal tester group with a single controlled invite flow | Safer for the first release-readiness pass and easier to validate. | Affects who can install the closed test build. | Too broad a group can increase support and privacy risk. | Yes | Yes | Yes |

## Recommended MVP defaults

- Audience: adults 18+, parents/caregivers.
- Child posture: not directed to children; do not opt into Families Program unless owner-approved later.
- Content rating posture: answer conservatively and truthfully; keep the app non-medical and not child-directed.
- Privacy policy: publish only when the final text and URL match the shipped build.
- Privacy policy publication: use the handoff in `docs/legal/privacy_policy_publication_handoff.md` and keep Play Console aligned with the approved live URL.
- Data Safety: keep the MVP disclosure limited to local-only Journal, billing, passive ads, and no product analytics provider.
- Advertising ID: treat as owner-confirmed and do not assume it is required.
- Ad personalization: default to no personalization for MVP.
- Closed testing ads: banner-only passive ads in allowed browse areas only.
- Public release ads: keep the same banner-only model unless a later owner decision changes it.
- Premium billing: keep monthly and yearly products only.
- Closed-testing track: use a controlled closed-testing track with a small invite group.

## Notes

- Production ad IDs and billing products remain outside the repository.
- The approved public privacy URL is live at https://nurtly.graylion.pl/privacy; keep Play Console aligned with the live SSOT and use the privacy publication handoff as the mirror of record.
- If any of the above defaults change, update the Data Safety, privacy, store listing, and QA docs together.
- For a concise go/no-go view, see [Closed-testing go/no-go](closed_testing_go_no_go.md).
