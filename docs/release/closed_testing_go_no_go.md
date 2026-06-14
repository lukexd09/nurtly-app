# Closed-testing go/no-go

For the current authoritative release status and blocker list, see [Final MVP release readiness](final_mvp_release_readiness.md) and [Final release blockers](final_release_blockers.md).

This checklist turns the owner decisions into a simple release gate for the Nurtly closed-testing build.

Use it alongside [Play Console owner decisions](play_console_owner_decisions.md) and the [Closed-testing release candidate runbook](closed_testing_release_candidate_runbook.md).

## Ready for closed testing

- [ ] App is on the intended closed-testing branch and build version.
- [ ] Target audience is confirmed as adults 18+, parents/caregivers.
- [ ] App is not directed to children and is not placed in Families Program by default.
- [ ] Content rating questionnaire has been answered truthfully and reviewed.
- [ ] Privacy policy draft matches the current app behavior.
- [ ] Privacy policy publication handoff has been reviewed.
- [ ] Data Safety draft matches the current app behavior.
- [ ] Banner-only passive ads are the confirmed MVP closed-testing model.
- [ ] Premium users are ad-free.
- [ ] Monthly and yearly Premium products are the only billing products in scope.
- [ ] Closed-testing track and tester group are ready.
- [ ] Invite flow is ready.

## Blocked for closed testing

- [ ] Privacy policy URL is still a placeholder.
- [ ] Privacy policy publication handoff has not been reviewed or the live URL has not been chosen.
- [ ] Data Safety answers contradict the current app behavior.
- [ ] The app is being positioned as child-directed or Families-Program-first without explicit owner approval.
- [ ] Interstitial or rewarded ads are treated as part of the MVP closed-testing model.
- [ ] Journal note content is described as analytics data.
- [ ] Production ad IDs or private release configuration have been committed.
- [ ] The intended closed-testing track or tester group is not set up.

## Allowed to defer until public release

- [ ] Production ad IDs.
- [ ] Public-release ad unit IDs.
- [ ] Public-release rollout settings.
- [ ] Final public marketing copy refinements, if the closed-testing text already matches the build.
- [ ] Any future analytics provider decision, if analytics is still out of scope for MVP.
- [ ] Final release-candidate evidence upload, if the evidence is only needed locally and not committed.

## Owner must confirm manually in Play Console

- [ ] Target audience and families posture.
- [ ] Content rating questionnaire.
- [ ] Privacy policy URL.
- [ ] Privacy policy publication handoff and live URL.
- [ ] Data Safety answers.
- [ ] Billing products and pricing.
- [ ] Closed-testing tester group and invite flow.
- [ ] Ads model and whether banner-only remains the public release contract.

## Go / no-go summary

- Go for closed testing when all items in the "Ready for closed testing" section are checked and no blockers remain.
- No-go for closed testing when any item in the "Blocked for closed testing" section is unresolved.
- Public-release items can remain open if they are listed in "Allowed to defer until public release".

## Notes

- This checklist does not change app code.
- Keep it aligned with the owner decision pack, Data Safety notes, release gate, and release-candidate evidence template.
