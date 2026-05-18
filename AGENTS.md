# AGENTS.md — Nurtly

## 1. Purpose

This file defines how Codex and other coding agents must work in the Nurtly repository.

These instructions are mandatory for agent work.

Nurtly is built through small, focused PRs. The agent must implement only the scope explicitly requested in the current prompt.

---

## 2. Product context

Nurtly is a mobile app for parents/caregivers 18+.

The app supports daily parenting through:

1. screen-free play ideas,
2. a local child journal,
3. calming sounds.

The app is for the parent/caregiver, not for the child.

Nurtly should feel calm, useful, trustworthy, privacy-conscious and parent-focused.

The MVP is Android + iOS using Flutter/Dart.

---

## 3. Current working model

We are not using a heavy GitHub Issues / Project fields workflow for the current implementation phase.

Current workflow:

1. Project owner and ChatGPT decide the next implementation step.
2. ChatGPT prepares a focused Codex prompt.
3. Codex implements only that prompt.
4. Codex creates a branch and opens a PR.
5. Project owner runs local Flutter verification when needed.
6. ChatGPT reviews the PR.
7. Project owner merges if accepted.

Codex must not select work independently.

Codex must not scan the backlog and decide what to implement.

Codex must not create or update GitHub Issues unless explicitly requested.

Codex must not update GitHub Project fields unless explicitly requested.

---

## 4. Core rule

Work only on the current prompt.

Do not expand scope.

Do not add “nice to have” changes.

Do not implement future features unless explicitly requested.

If the prompt is unclear or conflicts with this file, stop and ask for clarification.

Small, reviewable changes are preferred.

---

## 5. Repository structure

Current intended structure:

```text
app/
  lib/
    core/
    features/
content/
  source/
  published/
  licenses/
content-schema/
docs/
  ssot/
  architecture/
  decisions/
  qa/
  release/
  design/
tools/
.github/
README.md
AGENTS.md
```

Use the existing structure unless the current prompt explicitly asks to change it.

Do not reorganize folders as part of unrelated work.

---

## 6. Flutter rules

Flutter app work belongs under `app/`.

Use plain Flutter and Material unless the current prompt explicitly allows another dependency.

Do not add external packages unless explicitly requested.

Do not add platform SDKs unless explicitly requested.

Do not add Firebase, Supabase, AdMob, analytics, audio packages, or other SDKs unless the current prompt explicitly requires them.

Do not modify generated or platform files unless the prompt requires it.

If Flutter/Dart is not available in the Codex environment, do not claim that Flutter verification was completed.

When Flutter/Dart verification is unavailable, clearly state that the project owner must run local verification.

---

## 7. PR expectations

For implementation work, Codex should:

1. Create a focused branch.
2. Implement only the requested scope.
3. Keep the diff small and reviewable.
4. Run available lightweight checks.
5. Open a PR.
6. Describe what changed and what was intentionally not changed.

PR descriptions should include:

- summary,
- changed files or affected areas,
- what was not changed,
- verification,
- any relevant limitations.

Do not hide verification gaps.

Do not claim tests, formatting, analysis, builds, or app launches were run unless they were actually run.

---

## 8. Local verification for local Codex

If Codex is running locally and Flutter/Dart is available, Codex must run:

```powershell
powershell -ExecutionPolicy Bypass -File tools/verify_flutter.ps1
```

before opening or updating a PR that changes Flutter/Dart code.

After verification, Codex must run:

```powershell
git status --short
```

and ensure the PR includes only intentional files.

If local Flutter generated known iOS/Android ephemeral files, Codex may run:

```powershell
powershell -ExecutionPolicy Bypass -File tools/cleanup_flutter_local.ps1
```

and then check git status again.

Codex must include the verification result in the PR description.

---

## 9. Token Saver Mode

Codex should optimize for low token usage and high delivered value.

Default behavior:

- Prefer one focused module-level PR over many tiny PRs.
- Do not create unnecessary progress narration.
- Do not produce long PR descriptions.
- Do not restate AGENTS.md in responses.
- Do not scan unrelated files.
- Inspect only files required for the current task.
- Use deterministic shell commands and scripts instead of explaining manually.
- Use `tools/verify_flutter.ps1` for verification.
- Use `tools/cleanup_flutter_local.ps1` for known generated local noise.
- Before opening a PR, perform a concise self-review of the diff and fix obvious issues.

PR body should be short:

```text
Summary:
- ...

Verification:
- tools/verify_flutter.ps1 passed

Out of scope:
- no SDKs, no remote content, no ads, no analytics, no audio, no localization unless explicitly requested
```

When implementing features:

- Batch closely related work into one PR if it belongs to the same feature slice.
- Do not split trivial refactors into separate PRs when they are required for the same feature.
- Split only when the change affects architecture, dependencies, persistence, security, privacy, or multiple modules.

Self-review checklist before PR:

- Does the diff include only intentional files?
- Did verification pass?
- Did cleanup remove generated local files?
- Are there unnecessary abstractions?
- Are there trailing spacing hacks?
- Are Futures recreated unnecessarily in build methods?
- Did the change avoid new packages and SDKs unless requested?
- Is the PR body short?

If a task can be completed by editing fewer files, prefer that.

If a task requires broad repo exploration, explain why before doing it.

---

## 10. MVP guardrails

The MVP scope is intentionally limited.

Do not implement outside the current prompt:

- onboarding,
- account creation,
- backend sync,
- multiple child management,
- Play module functionality,
- Journal module functionality,
- Sounds module functionality,
- ads integration,
- analytics integration,
- audio playback,
- JSON content delivery,
- localization implementation,
- payments,
- subscriptions,
- social sharing,
- export features,
- CI.

Placeholders are allowed only when explicitly requested.

---

## 11. Product guardrails

Nurtly is for parents/caregivers, not children.

Avoid childlike, gamified, clinical, or judgmental product language.

Use calm, practical, parent-focused copy.

Do not make medical, diagnostic, or guaranteed developmental claims.

Prefer wording like:

- may support,
- can help,
- encourages,
- choose what fits your day,
- add a note when you are ready.

Avoid wording like:

- guarantees,
- diagnoses,
- boosts intelligence,
- complete your goal,
- you missed.

---

## 12. Design guardrails

The accepted design direction is:

Calm Premium Parenting / Modern Minimalist with Tactile Warmth.

Prefer:

- cream/off-white backgrounds,
- sage green primary accents,
- warm sand/beige secondary tones,
- dark green/charcoal primary text,
- muted secondary text,
- soft borders,
- soft rounded cards,
- generous spacing,
- simple parent-focused layouts.

Avoid:

- neon colors,
- childish visuals,
- heavy gamification,
- busy dashboards,
- medical/clinical styling,
- unrelated decorative complexity.

Use existing theme tokens and shared widgets when available.

---

## 13. Localization guardrails

Nurtly is expected to support English and Polish.

Do not implement localization unless explicitly requested.

Keep visible copy simple so it can be localized later.

Avoid scattering repeated product copy across many files when a central constant or future localization path is more appropriate.

---

## 14. Content guardrails

Content must stay outside app code where practical.

Future published content is expected to be JSON-based.

Do not implement JSON content delivery unless explicitly requested.

Do not add real content, audio files, licensed assets, or content validation scripts unless explicitly requested.

Do not mix source content, published content, and app code responsibilities.

---

## 15. Privacy guardrails

Privacy-by-design is mandatory.

MVP journal data is local-only.

Do not add cloud sync, accounts, analytics, or data collection unless explicitly requested.

Do not add secrets to the repository.

Do not hardcode API keys, tokens, credentials, or private configuration.

When adding privacy-related UI, keep it practical, calm, and transparent.

---

## 16. Ads and analytics guardrails

Ads may be considered later, but must not be added unless explicitly requested.

Analytics may be considered later, but must not be added unless explicitly requested.

Ads must not interrupt journal entry creation or active audio.

Do not add AdMob, Firebase Analytics, other analytics SDKs, or tracking code unless explicitly requested.

---

## 17. Product name guardrail

Do not hardcode the product name `Nurtly` in many places.

Use existing app configuration, constants, or future localization structures where practical.

Native platform display names may contain the product name where required by platform configuration.

---

## 18. When in doubt

Stop and ask for clarification if:

- the prompt conflicts with this file,
- the requested scope is ambiguous,
- a change would require a new dependency,
- a change would add SDKs or platform services,
- a change would affect privacy, analytics, ads, or content delivery,
- a change would require broad refactoring,
- a change would modify unrelated files.

Prefer a smaller PR over a larger PR.

Prefer explicit permission over guessing.

Do not continue by expanding scope silently.
