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
