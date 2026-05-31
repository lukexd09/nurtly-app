# 07 – Human Approval Template

Status: v0.1
Confidence: Medium
Last updated: 2026-05-31

## Purpose

This template defines the final human approval gate for AI-assisted development work.

No AI-assisted task should be merged without a clear human-readable summary.

## Human Approval Summary Template

# Human Approval Summary

## Feature Request

[original request]

## What Changed

- change 1
- change 2
- change 3

## Files Changed

- file 1
- file 2
- file 3

## Acceptance Criteria Status

- [ ] criterion 1
- [ ] criterion 2
- [ ] criterion 3

## Tests Run

- command / manual check: result

## Reviewer Verdict

APPROVE / REQUEST CHANGES / BLOCK

## Known Limitations

- limitation 1
- limitation 2

## Risks

- risk 1
- risk 2

## Follow-Up Issues Needed

- issue 1
- issue 2

## Knowledge Base Updates Needed

- [ ] No update needed
- [ ] Update 04-mvp-scope.md
- [ ] Update 05-feature-catalog.md
- [ ] Update 06-architecture.md
- [ ] Update 07-decisions.md
- [ ] Update 10-privacy-and-compliance.md
- [ ] Update 99-chatgpt-project-context.md

## Human Decision

- [ ] Approve
- [ ] Request changes
- [ ] Reject

## Approval Rules

Human approval is required when:

- code changes are ready to merge
- a product decision is implied
- privacy assumptions change
- a new dependency is added
- data storage changes
- user-facing copy changes product positioning
- onboarding changes child data collection
- AI features are introduced

## Merge Criteria

A change may be merged when:

- acceptance criteria are met
- tests/checks are acceptable
- reviewer did not block
- product principles are respected
- privacy risks are understood
- Knowledge Base updates are completed or tracked
