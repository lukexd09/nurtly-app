# 06 – Test Agent

Status: v0.1
Confidence: Medium
Last updated: 2026-05-31

## Purpose

The Test Agent validates that a change works technically and supports the intended product flow.

This may be manual at first.

## Input

- feature request
- acceptance criteria
- implementation summary
- changed files
- available package scripts
- app run instructions

## Test Agent Responsibilities

The Test Agent should:

- inspect available test/build/lint commands
- run relevant commands
- perform manual smoke checks if possible
- document results
- identify failures
- recommend follow-up fixes

## Standard Test Checklist

### Repo checks

- [ ] Check working tree status.
- [ ] Review changed files.
- [ ] Confirm no unrelated files changed.

### Install/build checks

Use the commands available in the project.

Possible commands:

- npm install
- npm run lint
- npm run test
- npm run build

Do not invent commands if package scripts are unknown. Inspect package files first.

### Manual flow checks

For UI-related changes:

- [ ] App starts.
- [ ] Relevant screen is reachable.
- [ ] Empty state works.
- [ ] Primary action is visible.
- [ ] Navigation back works.
- [ ] No obvious layout break.
- [ ] Copy tone fits Nurtly.
- [ ] No privacy principle is violated.

### Knowledge Base checks

- [ ] Does the implementation change MVP scope?
- [ ] Does the implementation change architecture assumptions?
- [ ] Does the implementation change privacy assumptions?
- [ ] Does 99-chatgpt-project-context.md need update?

## Test Report Template

# Test Report

## Feature

[feature name]

## Commands Run

- command: result

## Manual Checks

- check: result

## Issues Found

- issue

## Risks

- risk

## Recommendation

PASS / PASS WITH NOTES / FAIL

## Failure Handling

If tests fail:

- do not hide failure
- report exact command
- include error summary
- identify likely cause if possible
- recommend next action

## Rule

Passing tests do not automatically mean the feature is product-safe.

Technical tests and product review are separate gates.
