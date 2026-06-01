# 08 – Target AI Development Orchestrator Model

Status: v0.1
Confidence: Medium
Last updated: 2026-06-01

## Purpose

This document defines the target automation model for AI-assisted development in Nurtly.

It captures the intended direction after the first working milestone: a local n8n workflow that generates a task package, queues a worker job, lets a Windows host watcher run Cline through `ai_task_runner.ps1`, runs quality checks, and returns a runner report.

The purpose is to preserve the architecture for future work, RAG retrieval, and future AI agents. This document should help prevent agents from treating the current happy path as the final system.

## Current Milestone

The current working milestone is a task-level happy path:

```text
n8n manual input
-> task package generation
-> file queue job
-> Windows watcher
-> ai_task_runner.ps1
-> Cline implementation draft
-> dart format / flutter analyze / flutter test
-> runner status and report
-> n8n displays the result
```

This proves the basic execution chain works, but it is not yet the target delivery process for epics or larger features.

## Core Architectural Principle

n8n is the orchestrator.

Cline is the development worker.

The runner script is the execution wrapper around Cline, Git, Flutter checks, cleanup, retry, and reporting.

GitHub Issues and labels are the target source of truth for work intake, approvals, task status, and later PR creation.

Large work items must not be sent directly to a coding agent as one large prompt. Epics should be analyzed, planned, risk-reviewed, decomposed into smaller tasks, approved by a human, and then executed task by task.

## Target System Overview

```text
GitHub Epic Issue
-> Epic intake
-> Context collection
-> Epic plan
-> Risk analysis
-> Task breakdown
-> Human approval
-> Child GitHub task issues
-> Task runner per child issue
-> Quality checks and fallback loop
-> Review stage
-> PR creation after explicit approval
-> Epic summary and Knowledge Base updates if needed
```

## GitHub Issue Model

GitHub Issues should become the formal work intake channel.

### Epic issue

An epic issue represents a larger feature or functional area.

Recommended label:

```text
ai-epic
```

An epic issue should include:

```markdown
## Goal

## Context

## Scope

## Non-goals

## Acceptance Criteria

## Constraints

## Notes / Links
```

The epic workflow must not implement code directly. It should produce a plan, risk analysis, and task breakdown.

### Task issue

A task issue represents a small, implementable unit of work.

Recommended labels:

```text
ai-task
ai-ready
```

A task issue should be small enough for one draft implementation run and should include explicit acceptance criteria and non-goals.

## Label Model

Initial recommended labels:

```text
ai-epic
ai-task
ai-ready
ai-approved
ai-running
ai-awaiting-approval
ai-needs-review
ai-needs-human
ai-failed
ai-done
ai-done-no-changes
ai-create-pr
ai-pr-created
```

Optional mode labels:

```text
ai-plan-only
ai-implement-draft
ai-docs-only
ai-safe-small
```

The first production-ready trigger should be conservative:

```text
Issue labeled ai-ready -> run task workflow
Issue labeled ai-epic -> run epic planning workflow only
```

## Workflow 1 – Epic Intake and Planning

Trigger:

```text
GitHub Issue labeled ai-epic
```

Target flow:

```text
GitHub Trigger
-> Normalize GitHub Issue
-> Validate Epic Input
-> Build Epic Context Pack
-> Run Epic Planner
-> Run Risk Analyst
-> Generate Task Breakdown
-> Comment Plan on GitHub Issue
-> Add label ai-awaiting-approval
```

Output should be a GitHub issue comment similar to:

```markdown
## AI Epic Plan

### Summary

### Proposed Task Breakdown

1. [ ] Task 1: ...
2. [ ] Task 2: ...
3. [ ] Task 3: ...

### Risks

### Suggested Execution Order

### Requires Human Approval

To start execution, add label: ai-approved.
```

This workflow should not change application code.

## Workflow 2 – Epic Approval and Child Task Creation

Trigger:

```text
GitHub Issue labeled ai-approved
```

Target flow:

```text
GitHub Trigger
-> Read latest epic plan
-> Create child GitHub issues
-> Label child issues ai-task and ai-ready
-> Link child issues back to the epic
-> Comment summary on epic
```

The task issues should be small and independently executable.

## Workflow 3 – Task Runner

Trigger:

```text
GitHub Issue labeled ai-ready
```

Current n8n task runner flow should evolve into:

```text
GitHub Trigger
-> Normalize Task Issue
-> Validate Labels and Scope
-> Build Task Metadata
-> Create Task Folder
-> Build Context Pack
-> Generate Cline Prompts
-> Queue Cline Draft Worker
-> Wait for Runner Result
-> Parse Runner Status
-> Comment Result on Issue
-> Apply Status Labels
```

Current file queue model:

```text
n8n writes .ai-runner-queue/pending/<task-id>.json
-> Windows watcher moves it to processing
-> watcher runs ai_task_runner.ps1
-> runner writes runner-status.json and runner-report.md
-> watcher moves job to done or failed
-> n8n waits for runner-status.json and displays or posts the result
```

The task runner should work on one task at a time and should avoid cross-task state leaks.

## Workflow 4 – Review Stage

A successful implementation should not automatically be merged.

Target flow:

```text
Runner PASS
-> Generate diff summary
-> Run Cline Review Prompt
-> Reviewer verdict
-> Comment review on issue
-> Add label ai-needs-review
```

Reviewer verdicts:

```text
APPROVE
REQUEST_CHANGES
BLOCK
```

The review agent should not modify files. It should only assess the diff, scope, risks, and test coverage.

## Workflow 5 – PR Creation

PR creation should initially require explicit human approval.

Trigger:

```text
Issue labeled ai-create-pr
```

Target flow:

```text
Check runner status and review verdict
-> git status
-> git diff
-> commit
-> push branch
-> create GitHub PR
-> comment PR link on issue
-> add label ai-pr-created
```

PR creation should not run automatically after every successful implementation until the system is proven reliable.

## Fallback and Fix Loop

The runner must support a bounded fix loop.

Target behavior:

```text
IMPLEMENT_DRAFT
-> dart format / flutter analyze / flutter test
-> if checks fail:
   -> Cline fix attempt 1 using quality log
   -> rerun checks
-> if checks still fail:
   -> Cline fix attempt 2 using latest quality log
   -> rerun checks
-> if checks still fail:
   -> FAIL
   -> comment logs and require human action
```

The system must distinguish failure types:

```text
compile/analyze fail -> Cline may fix
flutter test fail -> Cline may fix, but should avoid changing tests unless clearly justified
scope guard fail -> stop and mark NEEDS_HUMAN
unexpected files changed -> cleanup or NEEDS_HUMAN
bad task package -> infrastructure failure, not a coding failure
Cline timeout -> retry once, then fail
repo dirty before start -> stop and mark NEEDS_HUMAN
```

Not every failure should trigger another AI attempt.

## Runner Status Model

The runner should use stable statuses:

```text
PASS
PASS_NO_CHANGES
FAIL
NEEDS_HUMAN
INFRA_FAILURE
```

Meanings:

- `PASS` – quality checks passed and commit-worthy changes remain.
- `PASS_NO_CHANGES` – quality checks passed, but no commit-worthy changes remain.
- `FAIL` – quality checks failed after bounded fix attempts.
- `NEEDS_HUMAN` – the runner stopped due to ambiguity, unexpected files, dirty repo, or scope risk.
- `INFRA_FAILURE` – infrastructure failed before the task could be evaluated properly.

The n8n workflow should parse these statuses and apply labels/comments accordingly.

## Required Artifacts

### Epic artifacts

```text
.ai-epics/<epic-id>/
  00-issue.md
  01-epic-context-pack.md
  02-epic-plan.md
  03-risk-analysis.md
  04-task-breakdown.md
  05-approval.md
```

### Task artifacts

```text
.ai-tasks/<task-id>/
  00-request.md
  01-context-pack.md
  02-cline-plan-prompt.md
  03-cline-risk-prompt.md
  04-cline-implementation-prompt.md
  05-cline-fix-prompt.md
  06-cline-review-prompt.md
  07-test-checklist.md
  08-human-approval.md
  runner-YYYYMMDD-HHMMSS/
    runner-status.json
    runner-report.md
    runner-log.md
    cline-implementation.jsonl
    quality-checks-attempt-0.txt
    cline-fix-attempt-1.jsonl
```

## Current Working Components

Already proven in v0.1:

```text
n8n generates Cline task packages
n8n writes queue JSON files
Windows watcher picks pending queue jobs
ai_task_runner.ps1 runs Cline
runner runs dart format, flutter analyze, and flutter test
runner cleans known generated noise
runner writes status and report
n8n waits for runner-status.json and displays the result
```

## Known Gaps

Still missing from the target model:

```text
GitHub Issue trigger
label-based filtering
GitHub issue comments with runner status
GitHub labels updated from runner status
Epic planner workflow
Risk analyst workflow before implementation
Task breakdown generation
Child issue creation
Dedicated review stage
PR creation after approval
Watcher as a stable Windows service or scheduled task
structured RAG index over docs/knowledge-base and docs/ai-development-flow
```

## Recommended Roadmap

### Milestone 1 – Stabilize Task Runner

Goal: make the current task runner reliable.

Tasks:

```text
Fix runner-status.json formatting
Remove BOM from generated status/report files if practical
Normalize empty arrays in JSON
Parse runner status in n8n
Improve status labels and comments
Run a real docs-only change that produces PASS, not only PASS_NO_CHANGES
Run watcher as a stable background process
```

### Milestone 2 – GitHub Issue Trigger for Small Tasks

Goal: issue labeled `ai-ready` starts the current task runner.

Tasks:

```text
Add GitHub Trigger
Normalize issue title/body/labels
Filter for ai-ready
Generate task package from issue
Queue runner job
Wait for result
Comment result on issue
Apply status labels
```

### Milestone 3 – Epic Planner

Goal: issue labeled `ai-epic` produces a plan, risk analysis, and task breakdown only.

Tasks:

```text
Build epic context pack
Run epic planner
Run risk analyst
Generate task breakdown
Comment plan on epic issue
Add ai-awaiting-approval label
```

### Milestone 4 – Child Task Creation

Goal: approved epics create small task issues automatically.

Tasks:

```text
Detect ai-approved label
Read latest plan
Create child issues
Label child issues ai-task and ai-ready
Link child issues to epic
```

### Milestone 5 – Review and PR Creation

Goal: after successful task execution, support review and optional PR creation.

Tasks:

```text
Run review agent on diff
Comment review verdict
Wait for ai-create-pr label
Commit and push branch
Create PR
Comment PR link on issue
```

## Safety Rules

- Never run implementation for an epic directly.
- Never merge AI-generated code without human approval.
- Never let the agent silently expand scope.
- Never ignore privacy constraints from the Knowledge Base.
- Never change secrets or production configuration through this workflow.
- Never modify Android/iOS generated files unless the task explicitly requires it.
- Treat `pubspec.lock` changes as unexpected unless dependencies were explicitly part of the task.
- Treat medical, child-data, account, analytics, sync, and monetization changes as high-risk unless explicitly planned and approved.

## RAG Importance

This document should be included in future RAG context for AI development tasks.

It defines the automation architecture, workflow boundaries, expected artifacts, statuses, safety gates, and roadmap. Future agents should use it to understand that:

- the current runner is task-level, not epic-level
- GitHub Issues are the intended work intake mechanism
- labels control automation stages
- epics must be decomposed before implementation
- risk analysis and human approval are mandatory for larger work
- Cline is the worker, not the orchestrator
- n8n is the orchestrator
