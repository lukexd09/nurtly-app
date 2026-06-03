# Nurtly AI Delivery Workflow

Status: Working proposal  
Confidence: Medium-High  
Last updated: 2026-06-03

## Purpose

This document defines the recommended AI-assisted delivery workflow for Nurtly.

The goal is to turn broad product ideas into small, safe, reviewable implementation tasks while preserving the current Nurtly delivery rules:

- small, focused PRs,
- explicit scope only,
- no autonomous backlog selection by coding agents,
- privacy-first product decisions,
- calm and parent-focused UX,
- clear verification before merge,
- knowledge base updates when decisions change.

This document is intended for ChatGPT, Cline, Codex, local models, future RAG systems, and any orchestration workflow such as n8n.

## Source-of-truth relationship

This workflow does not replace existing project rules.

Use the following hierarchy when there is a conflict:

1. Implemented behavior in `app/lib` and tests in `app/test`.
2. Runtime content in `app/assets/content`.
3. Release and QA docs.
4. `AGENTS.md` for coding-agent behavior.
5. Knowledge base decision records and product principles.
6. This workflow document.

If this document conflicts with `AGENTS.md`, `AGENTS.md` wins for implementation behavior.

## Delivery model overview

Recommended workflow:

```text
Epic request
  ↓
Epic intake
  ↓
Product fit check
  ↓
Scope classification
  ↓
Risk assessment
  ↓
Task breakdown
  ↓
Model routing
  ↓
Implementation prompt generation
  ↓
Execution by coding agent
  ↓
Verification
  ↓
PR review
  ↓
Human merge decision
  ↓
Knowledge base update if needed
```

## 1. Epic request

An epic is a broad product or technical intent, for example:

- "Add dark mode to Nurtly."
- "Improve the Sounds player experience."
- "Prepare the app for closed testing."
- "Add a lightweight onboarding flow."

Epic requests should not be sent directly to implementation unless they are already narrow enough for one focused PR.

## 2. Epic intake

The intake step should summarize the request in a structured format:

```text
Epic title:
Requested outcome:
User value:
Affected product area:
Affected technical area:
Known constraints:
Open questions:
Initial risk level:
Recommended next step:
```

Local models are suitable for this step when they have access to the relevant repository docs.

## 3. Product fit check

Before implementation planning, evaluate the epic against Nurtly product principles.

Checklist:

1. Does it help parents or caregivers?
2. Does it reduce stress or mental load?
3. Does it preserve the calm premium direction?
4. Does it avoid child-facing design?
5. Does it avoid medical, diagnostic, or developmental claims?
6. Does it require unnecessary child data?
7. Does it keep MVP complexity under control?
8. Does it require a decision record?

Output:

```text
product_fit: strong | acceptable | weak | reject
reasoning:
decision_needed: yes | no
recommended_scope:
```

If product fit is weak or unclear, do not send the epic directly to coding.

## 4. Scope classification

Classify the epic by implementation type.

Suggested categories:

- documentation only,
- copy only,
- visual/UI polish,
- isolated widget/component,
- module-level feature,
- cross-module feature,
- persistence/storage,
- localization,
- monetization/billing,
- ads,
- analytics,
- platform Android/iOS,
- privacy/legal/compliance,
- architecture/refactor,
- release/QA.

Output:

```text
scope_type:
affected_modules:
likely_files_or_folders:
expected_pr_count:
should_split: yes | no
split_reason:
```

## 5. Risk assessment

Every epic and task should receive a practical risk score before execution.

Use this risk matrix:

```text
privacy_risk: low | medium | high
platform_risk: low | medium | high
dependency_risk: low | medium | high
scope_creep_risk: low | medium | high
release_risk: low | medium | high
ux_risk: low | medium | high
localization_risk: low | medium | high
verification_risk: low | medium | high
```

Also produce:

```text
overall_risk: low | medium | high
needs_human_decision: yes | no
needs_strong_model_review: yes | no
safe_for_local_model_execution: yes | no
```

High-risk items should not be implemented by a small local model without review.

## 6. Task breakdown

Break the epic into small, reviewable tasks.

A task should be suitable for one focused PR unless it is explicitly marked as a planning or research task.

Task template:

```text
Task ID:
Title:
Goal:
Scope:
Out of scope:
Affected files/folders:
Risk level:
Recommended model:
Verification:
PR notes:
Knowledge base update needed:
```

Preferred task size:

- small enough to review quickly,
- large enough to avoid meaningless micro-PRs,
- focused on one feature slice,
- no unrelated refactors,
- no new dependency unless explicitly approved.

## 7. Model routing

After risk assessment, route each step to the appropriate model or tool.

General rule:

- use local models for structured analysis, classification, draft planning, and low-risk documentation work,
- use stronger coding models for implementation, architecture, broad refactors, and PR review,
- keep human approval for product decisions, merge decisions, and risky scope changes.

Detailed routing rules live in:

- `docs/architecture/model-routing.md`

## 8. Implementation prompt generation

Implementation prompts should be narrow and explicit.

Prompt template:

```text
Read AGENTS.md first.

Task:
...

Context:
...

Allowed changes:
...

Out of scope:
...

Constraints:
- Do not expand scope.
- Do not add dependencies unless explicitly requested.
- Do not modify platform files unless explicitly requested.
- Preserve calm, parent-focused Nurtly UX.
- Preserve privacy-first behavior.

Verification:
- Run the relevant project verification.
- For app code, use tools/pre_pr_check.ps1 when available.

PR expectations:
- Short summary.
- Changed files or affected areas.
- Verification result.
- Explicit out-of-scope notes.
- Any limitations.
```

## 9. Execution

Execution should follow `AGENTS.md`.

Coding agents must:

- implement only the current prompt,
- keep the diff focused,
- avoid unrelated files,
- avoid unnecessary abstractions,
- avoid new SDKs or packages unless explicitly requested,
- run available verification,
- clearly state verification gaps.

Local model execution may be tested only for low-risk tasks.

## 10. Verification

Use repository verification scripts where applicable.

For Flutter/app changes, preferred verification is:

```powershell
powershell -ExecutionPolicy Bypass -File tools/pre_pr_check.ps1
```

For smaller direct checks, use the scripts documented in `app/README.md` and `AGENTS.md`.

Verification results must not be invented. If a tool was unavailable, the PR or summary must say so.

## 11. PR review

PR review should be performed by a stronger model or by the project owner for any non-trivial implementation.

Review checklist:

1. Does the PR match the requested scope?
2. Did it avoid unrelated changes?
3. Did it follow `AGENTS.md`?
4. Did it avoid forbidden dependencies and SDKs?
5. Did it preserve privacy-first assumptions?
6. Did it preserve calm premium UX?
7. Did verification pass?
8. Are verification gaps clearly stated?
9. Is a knowledge base update needed?

## 12. Human merge decision

The project owner remains responsible for merging.

Automation may recommend merge readiness, but should not silently merge risky changes.

Suggested merge states:

```text
ready_for_owner_review
needs_changes
blocked_by_verification
blocked_by_product_decision
blocked_by_privacy_or_release_risk
```

## 13. Knowledge base update

After meaningful product, architecture, privacy, monetization, or workflow decisions, update the relevant docs.

Common update targets:

- `docs/knowledge-base/07-decisions.md`
- `docs/knowledge-base/99-chatgpt-project-context.md`
- relevant knowledge-base topic document,
- release or QA docs if release behavior changed,
- this workflow document if AI delivery rules changed.

Do not treat exploratory ideas as accepted decisions.

## Recommended n8n orchestration shape

A future n8n workflow can use this structure:

```text
Manual trigger / issue / form input
  ↓
Load repository context
  ↓
Local model: epic intake
  ↓
Local model: product fit + risk scoring
  ↓
Strong model: validate plan for medium/high risk
  ↓
Create task records
  ↓
Generate implementation prompt
  ↓
Run Cline/Codex with selected provider/model
  ↓
Run verification
  ↓
Strong model PR review
  ↓
Owner approval
```

## Key principle

Use cheap/local intelligence where mistakes are cheap.

Use stronger models where mistakes are expensive.

Use the human owner where decisions affect product direction, privacy, release readiness, or long-term architecture.
