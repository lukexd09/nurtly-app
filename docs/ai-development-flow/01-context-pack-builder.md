# 01 – Context Pack Builder

Status: v0.1
Confidence: Medium
Last updated: 2026-05-31

## Purpose

The Context Pack Builder prepares the minimum useful project context before any AI agent starts planning or coding.

The goal is to prevent agents from working blindly.

## Input

A user request, for example:

"Add a basic Journal empty state."

or:

"Implement Settings / Privacy entry point."

## Required Knowledge Base Files

For most Nurtly development tasks, include:

- docs/knowledge-base/99-chatgpt-project-context.md
- docs/knowledge-base/02-product-principles.md
- docs/knowledge-base/04-mvp-scope.md
- docs/knowledge-base/05-feature-catalog.md
- docs/knowledge-base/06-architecture.md
- docs/knowledge-base/07-decisions.md
- docs/knowledge-base/10-privacy-and-compliance.md

For visual/UI tasks, also include:

- docs/knowledge-base/11-design-principles.md

For monetization tasks, also include:

- docs/knowledge-base/12-monetization.md

For release/store tasks, also include:

- docs/release/store_listing_copy.md
- docs/release/screenshot_plan.md
- docs/release/store_assets_checklist.md

## Output

The Context Pack should produce a compact summary containing:

- project summary
- relevant product principles
- relevant MVP scope
- relevant decisions
- privacy constraints
- architecture constraints
- design constraints if applicable
- open questions
- files likely to inspect

## Context Pack Template

# Context Pack

## Feature Request

[original user request]

## Product Context

[summary from Knowledge Base]

## Relevant Principles

- Parents are users; children are not users.
- Reduce stress, do not create work.
- Privacy-first.
- AI is a tool, not the product.
- Calm premium direction.

## Relevant MVP Scope

[short summary]

## Relevant Decisions

[short list]

## Privacy Constraints

[short list]

## Architecture Constraints

[short list]

## Design Constraints

[short list if UI-related]

## Open Questions

[questions that should be answered before or during planning]

## Files to Inspect

[likely files/directories]

## Rules

- Do not include the entire Knowledge Base if a compact context is enough.
- Prefer relevant excerpts over huge context dumps.
- Distinguish decisions from assumptions.
- If a requested feature contradicts a documented principle, flag it before planning.
- If the feature requires a product decision, mark it clearly.
