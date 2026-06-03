# Nurtly AI Model Routing

Status: Working proposal  
Confidence: Medium-High  
Last updated: 2026-06-03

## Purpose

This document defines how Nurtly should route AI-assisted work between local models, stronger coding models, automation tools, and the project owner.

The goal is to reduce cost and speed up routine work without increasing implementation, privacy, product, or release risk.

## Core idea

Use cheap or local models where mistakes are easy to catch and cheap to fix.

Use stronger models where mistakes are expensive, subtle, or likely to create technical debt.

Use human approval where decisions affect product direction, privacy, release readiness, monetization, or long-term architecture.

## Current recommended roles

### Local model: Qwen3 8B or equivalent

Recommended role:

- intake analyst,
- task classifier,
- risk scorer,
- documentation drafter,
- QA checklist drafter,
- implementation prompt drafter,
- low-risk reviewer for docs-only changes,
- optional experimental executor for very small low-risk code changes.

Do not treat the local model as the main autonomous developer.

### Strong coding model through Cline/Codex

Recommended role:

- implementation of app changes,
- architecture-sensitive changes,
- cross-module changes,
- Flutter/Dart refactoring,
- monetization-related changes,
- ads-related changes,
- platform Android/iOS changes,
- persistence/storage changes,
- privacy-sensitive changes,
- PR review.

### ChatGPT / strong reasoning model

Recommended role:

- product decision support,
- plan validation,
- risk validation,
- PR review,
- architecture review,
- documentation review,
- deciding whether a task is safe for local execution.

### n8n or other orchestrator

Recommended role:

- trigger workflows,
- pass context to models,
- store epic/task/risk records,
- choose model/provider based on routing rules,
- call Cline/Codex CLI where available,
- run verification commands where environment allows,
- collect outputs and status.

The orchestrator should not silently override `AGENTS.md` or merge risky work.

### Project owner

Recommended role:

- final product decisions,
- approving ambiguous scope,
- approving new dependencies or SDKs,
- approving privacy-sensitive changes,
- approving release decisions,
- merge decisions.

## Routing by workflow stage

| Stage | Recommended model/tool | Notes |
|---|---|---|
| Epic intake | Local model | Good fit for Qwen3 8B when repository docs are provided. |
| Product fit check | Local model, then strong model if unclear | Use Nurtly product principles and MVP guardrails. |
| Scope classification | Local model | Mostly rule-based. |
| Risk scoring | Local model | Strong fit for Qwen3 8B with structured output. |
| Task breakdown | Local model draft, strong model validation | Qwen can draft; strong model should validate medium/high risk plans. |
| Prompt generation | Local model draft | Use strict templates and `AGENTS.md`. |
| Docs-only implementation | Local model or strong model | Local is acceptable for low-risk docs. |
| Small UI copy/styling change | Strong model preferred; local model optional experiment | Use local only if scope is tiny and easily reviewable. |
| Flutter feature implementation | Strong coding model | Default to Codex/Cline strong model. |
| Cross-module implementation | Strong coding model | Do not route to local model. |
| Architecture/refactor | Strong model + human decision | High technical-debt risk. |
| Privacy/data changes | Strong model + human decision | High trust/compliance risk. |
| Billing/ads changes | Strong model + human decision | High release/business risk. |
| Platform Android/iOS changes | Strong model + human decision | High breakage risk. |
| Verification interpretation | Strong model or deterministic scripts | Scripts are source of truth when available. |
| PR review | Strong model | Do not rely only on local model for non-trivial PRs. |
| Knowledge base update | Local model draft, human/strong model review | Keep docs aligned with actual decisions. |

## Routing by risk level

### Low risk

Examples:

- documentation wording,
- QA checklist draft,
- release note draft,
- issue/task formatting,
- prompt generation,
- product fit classification,
- risk scoring,
- simple copy proposal.

Recommended routing:

```text
Qwen3 8B allowed
Strong model optional
Human review light
```

### Medium risk

Examples:

- feature task breakdown,
- user-facing copy that affects positioning,
- UI polish across multiple screens,
- small Flutter widget change,
- updating knowledge base decisions,
- release checklist changes.

Recommended routing:

```text
Qwen3 8B draft allowed
Strong model validation recommended
Human review before merge/change acceptance
```

### High risk

Examples:

- privacy model changes,
- child data handling,
- Journal storage behavior,
- subscriptions,
- ads behavior,
- analytics,
- platform files,
- new dependencies,
- app architecture,
- release build/signing,
- medical or parenting-claim copy,
- broad refactors,
- cross-module feature implementation.

Recommended routing:

```text
Qwen3 8B may classify only
Strong model required
Human approval required
Local model execution not allowed
```

## Safe use cases for Qwen3 8B

Qwen3 8B is a good fit for:

1. Reading an epic and producing structured intake.
2. Checking whether a request fits Nurtly principles.
3. Identifying affected areas from documentation.
4. Producing a first task breakdown.
5. Scoring risk using a fixed schema.
6. Drafting Cline/Codex prompts from templates.
7. Drafting QA checklist items.
8. Drafting documentation updates.
9. Summarizing PR descriptions.
10. Finding whether a knowledge base update may be needed.

Expected output should be structured, for example JSON or a fixed Markdown template.

## Unsafe use cases for Qwen3 8B

Do not use Qwen3 8B as the only agent for:

1. Billing or subscription implementation.
2. Ads integration or ad behavior changes.
3. Analytics or tracking implementation.
4. Privacy-sensitive user data changes.
5. Journal persistence/storage changes beyond trivial local-only behavior.
6. Platform Android/iOS file changes.
7. New dependencies or SDKs.
8. Broad refactors.
9. Cross-module architecture changes.
10. PR review for non-trivial code changes.
11. Medical, diagnostic, or developmental user-facing advice.
12. Automatic merge decisions.

## Example: dark mode epic

Epic:

```text
Add dark mode to Nurtly.
```

Recommended routing:

```text
Epic intake: Qwen3 8B
Product fit check: Qwen3 8B
Risk scoring: Qwen3 8B
Task breakdown: Qwen3 8B draft + strong model validation
Implementation: strong Cline/Codex model
PR review: strong model
Merge: project owner
```

Reason:

Dark mode touches theme architecture and multiple screens. It appears product-compatible, but implementation can affect app-wide UX, accessibility, settings persistence, screenshots, and QA. It should not be treated as a trivial styling change.

## Example: QA checklist update

Epic:

```text
Add manual QA checks for dark mode.
```

Recommended routing:

```text
Draft: Qwen3 8B
Review: project owner or strong model optional
Implementation: Qwen3 8B acceptable if docs-only
```

Reason:

Docs-only QA checklist changes are low risk and easy to review.

## Example: billing product update

Epic:

```text
Update monthly and yearly premium product handling.
```

Recommended routing:

```text
Intake: Qwen3 8B allowed
Risk scoring: Qwen3 8B allowed
Plan validation: strong model required
Implementation: strong Cline/Codex model
Review: strong model + project owner
```

Reason:

Billing affects release readiness, monetization, user trust, and platform behavior.

## Model selection output schema

A routing step should produce this structure:

```json
{
  "task_id": "",
  "task_title": "",
  "risk_level": "low | medium | high",
  "recommended_model": "local_qwen | strong_coding_model | strong_reasoning_model | human",
  "local_model_allowed": true,
  "strong_model_required": false,
  "human_approval_required": false,
  "reason": "",
  "verification_required": [],
  "blocked_until": []
}
```

## Prompting rule for local models

Local models should receive constrained prompts with clear output schemas.

Avoid asking local models to "think broadly" or "improve the product" without boundaries.

Prefer:

```text
Using only the provided repository context, classify this request and output JSON matching this schema.
Do not propose implementation details outside the requested scope.
Flag uncertainty explicitly.
```

Avoid:

```text
Improve this feature however you think is best.
```

## Review rule

Any local-model output that changes product direction, implementation scope, privacy behavior, release behavior, monetization, or architecture must be reviewed before execution.

## Final rule

Qwen3 8B should make the workflow cheaper and faster, not less controlled.

When in doubt, route upward to a stronger model or the project owner.
