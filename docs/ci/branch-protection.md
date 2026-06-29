# Branch protection for `main`

Status: documented strategy only. No repository settings are changed by this file.

## CI identity

- Workflow file: `.github/workflows/mobile-ci.yml`
- Workflow name: `Mobile CI`
- Required check candidate: `PR CI gate`
- Trigger: pull requests targeting `main`
- Check source: the single `pr-ci-gate` job
- Merge remains an explicit owner decision

## Existing evidence

These repository records show how the gate behaves:

- Controlled formatting failure: run `28238812934`
- Scope-guard failure: run `28240331999`
- Final successful full gate: run `28242064366`
- Final successful head: `702d88ef63dd5a7b22af7e6cc69899be1d45436e`

What this evidence proves:

- Deterministic failures make `PR CI gate` fail.
- The known-good workflow passes formatting, analyze, tests, cleanup, scope guard, Android build, and repository integrity.
- These runs prove workflow behavior.
- They do not by themselves prove that branch protection is currently enabled.

## Recommended `main` protection

Recommended owner-facing GitHub UI policy:

- Require changes through a pull request.
- Require successful `PR CI gate` before merge.
- Disable force pushes.
- Disable branch deletion.
- Keep automatic merge disabled.
- Do not allow a bypass that would merge a failing required check unless the owner explicitly documents an emergency exception.

Do not require a review count that could deadlock a single-owner repository unless the repository governance already supports it.

Interpretation of the rule:

- A passing check permits an owner decision.
- It does not merge automatically.
- A failing required check must block merge.
- Manual QA remains independent.
- Branch protection does not authorize store publication.

## Verification after owner configuration

After the owner applies protection, verify it with these steps:

1. Inspect `main` protection or ruleset configuration.
2. Confirm the exact required context is `PR CI gate`.
3. Open or use a harmless test PR.
4. Confirm a failing check blocks merge.
5. Confirm a passing check still requires an explicit owner merge action.
6. Confirm auto-merge remains disabled.
7. Retain screenshots or command output as private, repository-safe evidence.

Safe read-only verification commands:

```powershell
gh api repos/lukexd09/nurtly-app/branches/main/protection
gh api repos/lukexd09/nurtly-app/rulesets
gh pr view <pr-number> --json state,mergeStateStatus,url
gh pr checks <pr-number>
```

Do not use mutating commands in this verification step unless the owner explicitly asked for a configuration change.

## Rollback

If the required-check selection is renamed or the workflow is accidentally broken, the owner should:

1. Update the required check to the current passing context, or restore the workflow name/job so `PR CI gate` remains stable.
2. Re-check merge blocking with a harmless PR.
3. Document any temporary exception separately.

Rollback must not disable all repository security without documenting why.

## Read-only audit result

Read-only repository access here returned insufficient permission for both classic branch protection and repository rulesets.

- Branch protection API result: HTTP 403
- Rulesets API result: HTTP 403

That means protection could not be confirmed from the API in this environment.
