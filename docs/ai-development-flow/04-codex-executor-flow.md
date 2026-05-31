# 04 – Codex Executor Flow

Status: v0.1
Confidence: Medium
Last updated: 2026-05-31

## Purpose

This document defines how Codex or another implementation agent should receive and execute work for Nurtly.

The executor should not make major product decisions independently.

## Input for Codex

Each Codex task should include:

- feature request
- Context Pack
- Planner output
- Architect / Risk Agent verdict
- acceptance criteria
- constraints
- suggested files to inspect

## Suggested Branch Naming

Use:

ai/<short-feature-name>

Examples:

- ai/journal-empty-state
- ai/settings-privacy-entry
- ai/sounds-placeholder
- ai/app-brand-config

## Codex Task Template

You are implementing a Nurtly task.

Read and follow:

- docs/knowledge-base/99-chatgpt-project-context.md
- docs/knowledge-base/02-product-principles.md
- docs/knowledge-base/04-mvp-scope.md
- docs/knowledge-base/06-architecture.md
- docs/knowledge-base/07-decisions.md

Feature request:

[feature request]

Planner output:

[paste plan]

Architect/Risk verdict:

[paste review]

Acceptance criteria:

[list]

Constraints:

- Keep MVP scope narrow.
- Do not require child name.
- Do not require exact child date of birth.
- Do not add medical advice.
- Do not add gamification or streak pressure.
- Do not introduce unnecessary data collection.
- Keep UX calm and parent-facing.
- Prefer simple implementation over overengineering.

Expected output:

- implementation
- summary of changed files
- tests run
- known limitations
- docs update recommendation if needed

## Executor Rules

Codex should:

- inspect existing code before changing
- keep changes small
- avoid unrelated refactors
- avoid broad architecture changes without approval
- update documentation only when clearly required
- explain assumptions
- leave follow-up notes for unresolved decisions

Codex should not:

- merge to main automatically
- deploy automatically
- introduce new dependencies without explaining why
- create account/cloud systems unless specifically requested
- make medical or legal claims
- modify Knowledge Base decisions without clear instruction

## Expected Codex Summary

After implementation, Codex should provide:

## Summary

- What changed
- Why it changed
- Files changed

## Tests

- Commands run
- Results
- Manual checks

## Risks / Limitations

- Known gaps
- Follow-up needed

## Knowledge Base Updates

- Required / Not required

## First Test Features

Good first tasks:

1. Journal empty state
2. Settings / Privacy entry
3. Sounds placeholder list
4. App brand config
5. Manual smoke test docs

Avoid first tasks:

- full authentication
- subscriptions
- full Journal engine
- cloud sync
- AI assistant
- production deployment
