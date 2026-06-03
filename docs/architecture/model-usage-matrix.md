# Nurtly AI Model Usage Matrix

Status: Working proposal  
Confidence: Medium-High  
Last updated: 2026-06-03

## Purpose

This document summarizes which model or tool should be used for each part of the Nurtly AI-assisted delivery process.

It is based on the current target process and practical local tests with Qwen3 8B on the project owner's server.

The goal is to use zero-cost local processing where it is useful, while keeping implementation quality, privacy, release safety, and architecture control intact.

## Tested local setup summary

Current tested path:

```text
PowerShell → Ollama API → qwen3:8b → strict JSON → PowerShell / n8n-ready output
```

Result:

- Works correctly.
- Can return valid JSON that parses with PowerShell `ConvertFrom-Json`.
- Good fit for structured classification, risk scoring, model routing, and prompt preparation.
- Slower execution is acceptable for background orchestration steps.

Also tested:

```text
PowerShell → Cline CLI → Ollama → qwen3:8b
```

Result:

- Works for very small prompts.
- Too slow for repository-aware Cline agent work on the current machine.
- Should not be the default route for Qwen-based analysis.

Recommended conclusion:

```text
Use Qwen3 8B directly through Ollama API for orchestration and analysis.
Use Cline/Codex for implementation work.
Use strong reasoning models for validation and review.
```

## Model roles at a glance

| Role | Recommended model/tool | Main purpose |
|---|---|---|
| Local process analyst | Qwen3 8B via Ollama API | Intake, classification, risk scoring, task draft, routing, prompt draft. |
| Local executor | Qwen3 8B via Cline | Experimental only for very small docs/copy/tooling tasks. |
| Coding executor | Cline/Codex with strong coding model | Flutter/Dart implementation, branches, PRs, code edits. |
| Strong reviewer | Strong reasoning model / ChatGPT | Plan validation, architecture review, PR review, decision support. |
| Orchestrator | n8n / PowerShell | Runs steps, passes context, stores JSON outputs, routes tasks. |
| Deterministic verifier | Project scripts | `tools/pre_pr_check.ps1`, Flutter verification, git status. |
| Decision owner | Project owner | Product, architecture, privacy, release, merge decisions. |

## Detailed usage matrix

| Process step | Preferred model/tool | Qwen3 8B fit | Notes |
|---|---|---:|---|
| Epic intake | Qwen3 8B via Ollama API | High | Excellent zero-cost first step. Output should be strict JSON. |
| Product fit check | Qwen3 8B via Ollama API | High | Use Nurtly principles and guardrails. Escalate unclear cases. |
| Scope classification | Qwen3 8B via Ollama API | High | Mostly rule-based and schema-friendly. |
| Risk scoring | Qwen3 8B via Ollama API | Very high | One of the best use cases. Use fixed enum values. |
| Model routing | Qwen3 8B via Ollama API | Very high | Routes work to local model, strong coding model, strong reasoning model, or human. |
| Definition of Ready check | Qwen3 8B via Ollama API | High | Good for finding missing information and blocking questions. |
| Task breakdown draft | Qwen3 8B via Ollama API | Medium-High | Good draft source; medium/high-risk plans should be validated. |
| Prompt drafting for Cline/Codex | Qwen3 8B via Ollama API | High | Use templates and `AGENTS.md` constraints. |
| Prompt linting / prompt safety check | Qwen3 8B via Ollama API | High | Good at checking missing scope, missing verification, or unsafe permissions. |
| QA checklist draft | Qwen3 8B via Ollama API | High | Good background step; easy to review. |
| Knowledge base update suggestion | Qwen3 8B via Ollama API | High | Can propose documents to update and draft entries. Review required. |
| Documentation-only implementation | Qwen3 8B via Cline or direct manual application | Medium | Acceptable for low-risk docs if reviewed. Direct Ollama cannot modify files unless wrapped by tooling. |
| Copy-only app text proposal | Qwen3 8B via Ollama API | Medium | Good for draft wording. Do not apply automatically if product positioning is sensitive. |
| Small UI polish | Strong coding model preferred | Low-Medium | Qwen may draft intent, but implementation should usually go to Cline/Codex strong model. |
| Flutter feature implementation | Cline/Codex strong coding model | Low | Do not use Qwen as default developer. |
| Cross-module implementation | Cline/Codex strong coding model | Low | Requires stronger code understanding and review. |
| Theme architecture changes | Cline/Codex strong coding model + strong review | Low | Qwen can classify and plan, but should not implement by default. |
| Persistence/storage changes | Cline/Codex strong coding model + human review | Low | Sensitive because of Journal/local data behavior. |
| Privacy/data changes | Strong reasoning + strong coding + human approval | Low | Qwen may classify only. |
| Billing/subscriptions | Strong coding model + human approval | Low | Qwen may classify risk and draft questions only. |
| Ads/analytics | Strong coding model + human approval | Low | Qwen may classify risk and draft guardrails only. |
| Platform Android/iOS changes | Strong coding model + human approval | Low | Qwen should not execute. |
| Verification execution | Project scripts | Not applicable | Use deterministic scripts, not model judgement. |
| Verification result summary | Qwen3 8B or strong model | Medium | Qwen can summarize logs if not too large; strong model for complex failures. |
| Preliminary PR checklist | Qwen3 8B via Ollama API | Medium | Can flag scope/QA/doc concerns. Not final code review. |
| Final PR review | Strong reasoning/coding model | Low | Do not rely on Qwen alone for non-trivial code review. |
| Merge decision | Project owner | Not applicable | Human decision. |

## Recommended default pipeline

Default route for most epics:

```text
1. Qwen3 8B via Ollama API: epic intake
2. Qwen3 8B via Ollama API: product fit + risk scoring
3. Qwen3 8B via Ollama API: task breakdown draft
4. Qwen3 8B via Ollama API: model routing
5. Strong model: validate medium/high-risk plan
6. Qwen3 8B via Ollama API: draft implementation prompt
7. Qwen3 8B via Ollama API: lint prompt for scope safety
8. Cline/Codex strong coding model: implementation
9. Project scripts: verification
10. Strong model: PR review
11. Project owner: merge decision
12. Qwen3 8B via Ollama API: KB/QA update draft if needed
```

## Where Qwen3 8B should be used aggressively

Use Qwen3 8B frequently for zero-cost background work where latency is acceptable:

1. Epic intake.
2. Product fit scoring.
3. Risk matrix generation.
4. Model routing.
5. Definition of Ready checks.
6. Task breakdown drafts.
7. Prompt generation.
8. Prompt linting.
9. QA checklist drafts.
10. Knowledge base update suggestions.
11. Backlog grooming.
12. Release checklist draft updates.
13. PR description summarization.
14. Preliminary scope review.

These tasks are repetitive, structured, and easy to validate. They are good candidates for n8n background execution.

## Where Qwen3 8B should be used carefully

Use Qwen3 8B only as a draft or advisory model for:

1. User-facing product copy.
2. Documentation that records accepted decisions.
3. Medium-risk task breakdown.
4. Release documentation.
5. QA interpretation.
6. Small docs-only file changes.
7. Prompt preparation for implementation tasks.

These outputs should be reviewed before they become source of truth or trigger implementation.

## Where Qwen3 8B should not be the main model

Do not use Qwen3 8B as the main model for:

1. Flutter/Dart implementation.
2. App-wide theme architecture implementation.
3. Cross-module code changes.
4. Storage or persistence changes.
5. Privacy-sensitive logic.
6. Child data handling.
7. Billing/subscriptions.
8. Ads or analytics.
9. Platform Android/iOS changes.
10. New dependencies or SDKs.
11. Broad refactors.
12. Final PR review.
13. Merge decisions.

It may still classify these tasks, score risk, and route them upward.

## Direct Ollama API vs Cline route

### Preferred Qwen route

```text
PowerShell / n8n → Ollama API → qwen3:8b → JSON output
```

Use this for:

- structured analysis,
- classification,
- routing,
- prompt drafts,
- QA drafts,
- documentation suggestions.

Reason:

- Lower overhead than Cline.
- Easier JSON parsing.
- Better fit for n8n.
- Zero cost.

### Experimental Qwen route

```text
PowerShell / n8n → Cline CLI → Ollama → qwen3:8b
```

Use this only for:

- very small docs-only tasks,
- very small copy changes,
- controlled experiments.

Avoid this as the default route because Cline adds significant prompt and agent overhead on the current machine.

## Strong coding model usage

Use Cline/Codex with a strong coding model for:

1. Code implementation.
2. Flutter/Dart changes.
3. App feature slices.
4. Theme implementation.
5. Refactors.
6. Cross-module work.
7. PR creation.
8. Applying verified implementation prompts.

Strong coding models should still follow `AGENTS.md`:

- small focused PRs,
- explicit prompt scope only,
- no autonomous backlog selection,
- no new dependencies unless explicitly requested,
- no platform files unless explicitly requested,
- verification must be reported honestly.

## Strong reasoning model usage

Use a strong reasoning model for:

1. Reviewing Qwen-generated medium/high-risk plans.
2. Architecture review.
3. Privacy-sensitive decision review.
4. Monetization/billing decision review.
5. PR review.
6. Resolving conflicting documentation.
7. Deciding whether a task is ready for implementation.
8. Reviewing accepted decision log entries.

This model does not need to do all work from scratch. It can validate or correct Qwen outputs to reduce cost.

## Human approval usage

Human approval is required for:

1. Product direction changes.
2. New dependencies.
3. Platform file changes.
4. Privacy/data behavior changes.
5. Billing, ads, analytics, or release-impacting decisions.
6. Accepted decision records.
7. Merge decisions.
8. Scope expansion.
9. Any automation path that would modify files without review.

## Recommended enum values for automation

Use these enum values in n8n-friendly JSON outputs.

### Risk values

```text
low
medium
high
```

### Product fit values

```text
strong
acceptable
weak
reject
```

### Model routing values

```text
local_qwen
strong_coding_model
strong_reasoning_model
human
deterministic_script
```

### Decision readiness values

```text
ready
needs_review
blocked
reject
```

## Recommended JSON output for model routing

```json
{
  "epic": "",
  "product_fit": "strong",
  "overall_risk": "medium",
  "affected_areas": [],
  "risk_matrix": {
    "privacy_risk": "low",
    "platform_risk": "medium",
    "dependency_risk": "low",
    "scope_creep_risk": "medium",
    "release_risk": "medium",
    "ux_risk": "medium",
    "localization_risk": "low",
    "verification_risk": "medium"
  },
  "recommended_model_routing": {
    "intake": "local_qwen",
    "definition_of_ready": "local_qwen",
    "task_breakdown": "local_qwen",
    "plan_validation": "strong_reasoning_model",
    "implementation": "strong_coding_model",
    "verification": "deterministic_script",
    "pr_review": "strong_reasoning_model",
    "merge_decision": "human"
  },
  "suggested_tasks": [],
  "explicit_approval_required_for": [],
  "knowledge_base_update_needed": false,
  "notes": []
}
```

## Practical examples

### Dark mode

Recommended routing:

```text
Qwen: intake, risk scoring, task draft, prompt draft, QA draft
Strong reasoning model: plan validation
Strong coding model: implementation
Scripts: verification
Strong reasoning model: PR review
Human: merge
```

Reason:

Dark mode touches theme architecture, multiple screens, accessibility, settings persistence, QA, and release screenshots. Qwen is useful for preparation, but implementation should use a stronger coding model.

### QA checklist update

Recommended routing:

```text
Qwen: draft and optionally implement docs-only update
Human or strong model: light review
```

Reason:

Low-risk documentation work is a good zero-cost local-model use case.

### Billing change

Recommended routing:

```text
Qwen: classify and list risks/questions
Strong reasoning model: validate plan
Strong coding model: implementation
Human: approval and merge
```

Reason:

Billing has business, platform, release, and trust risk.

### Backlog grooming

Recommended routing:

```text
Qwen: categorize backlog items, detect high-risk items, propose ordering
Strong reasoning model: review only selected candidates
Human: choose next epic
```

Reason:

This is repetitive, structured, and cheap to run locally.

## Final recommendation

Use Qwen3 8B as a zero-cost background process analyst, not as the default developer.

The best value comes from letting it prepare, classify, route, and draft work before more expensive models or humans spend attention on it.

Slow execution is acceptable when Qwen runs asynchronously through n8n and produces structured JSON for the next workflow step.
