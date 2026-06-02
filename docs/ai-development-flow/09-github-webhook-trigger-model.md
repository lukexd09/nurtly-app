# 09 – GitHub Webhook Trigger Model

Status: v0.1
Confidence: Medium
Last updated: 2026-06-02

## Purpose

This document captures the intended trigger transport model for the Nurtly AI-assisted development orchestrator.

The main target is still GitHub Issues and labels as the work intake interface, but the transport from GitHub into the local n8n orchestrator should be event-driven rather than polling-based.

This document complements `08-target-automation-model.md`.

## Decision

Do not use GitHub polling as the target architecture.

Polling may be used as a temporary fallback or diagnostic mechanism, but the target model should be:

```text
GitHub Issue event
-> GitHub webhook
-> small local webhook bridge
-> n8n internal/local workflow
-> existing task package / queue / runner flow
```

## Why not polling

Polling GitHub every few minutes would work, but it is not the clean target model.

Problems with polling:

- it creates many empty GitHub API requests
- it adds artificial latency
- each new workflow may require another poller or a central dispatcher
- it is harder to reason about which GitHub event actually started a run
- it scales poorly once there are separate flows for tasks, epics, approvals, review, and PR creation

Polling should remain a fallback only.

## Why not expose n8n directly

A direct GitHub webhook into n8n is technically possible, especially through a tunnel such as Cloudflare Tunnel.

However, the safer target is not to expose n8n itself publicly.

n8n should remain local/private. Only a minimal webhook bridge should be reachable from GitHub.

## Target Bridge Model

The recommended model is:

```text
GitHub
-> public webhook URL
-> Cloudflare Tunnel or equivalent
-> local GitHub webhook bridge
-> signature validation
-> event and label filtering
-> local n8n trigger or local event queue
```

The bridge should do only a small set of responsibilities:

1. Verify the GitHub webhook signature using a shared secret.
2. Accept only expected event types, initially Issues events.
3. Accept only relevant actions, such as `labeled`.
4. Accept only relevant labels, such as `ai-ready`, `ai-epic`, `ai-approved`, or `ai-create-pr`.
5. Reject everything else.
6. Pass a normalized payload to n8n or write it to a local event queue.

## Preferred Local Flow

For the current local setup, the bridge can use either of these approaches.

### Option A – Bridge calls local n8n webhook

```text
GitHub webhook
-> bridge validates and filters
-> bridge calls http://localhost:5678/webhook/...
-> n8n starts the relevant workflow
```

This keeps n8n private and lets the bridge be the only public-facing component.

### Option B – Bridge writes local event files

```text
GitHub webhook
-> bridge validates and filters
-> bridge writes .ai-github-events/pending/<event-id>.json
-> n8n or another local worker consumes the event
```

This is more consistent with the existing file-queue style and can be easier to debug, but it adds another queue.

## Initial Trigger Mapping

The first event-driven triggers should be conservative:

```text
Issue labeled ai-ready      -> run task workflow
Issue labeled ai-epic       -> run epic planning workflow only
Issue labeled ai-approved   -> create child task issues from approved epic plan
Issue labeled ai-create-pr  -> create PR only after successful review and explicit approval
```

No epic should ever trigger direct implementation.

## Security Rules

- Do not expose the n8n UI publicly.
- Do not expose all n8n webhooks publicly by default.
- Verify GitHub webhook signatures before processing events.
- Reject events from unexpected repositories.
- Reject events without the expected labels.
- Treat the webhook bridge as a small security boundary.
- Keep GitHub secrets out of repository files.
- Log accepted and rejected events enough for debugging, without logging secrets.

## Operational Notes

The bridge should be a small local service, separate from the Cline runner.

Recommended responsibilities split:

```text
GitHub webhook bridge = receives and validates GitHub events
n8n = orchestrates workflows
file queue = passes implementation jobs to the local Windows runner
ai_runner_watch.ps1 = background worker for implementation jobs
ai_task_runner.ps1 = Cline/Git/Flutter execution wrapper
```

This keeps each part small and easier to reason about.

## Fallback Model

If the webhook bridge is unavailable or not configured yet, polling can be used temporarily.

Fallback polling should be:

- centralized in one n8n workflow
- limited to relevant labels
- rate-limited
- treated as temporary infrastructure
- documented as fallback, not the target state

## RAG Importance

Future AI agents should use this document when modifying or extending automation triggers.

The important rule is:

```text
GitHub Issues and labels are the product/workflow interface.
GitHub webhooks through a small bridge are the target transport.
Polling is only a fallback.
n8n should remain private/local.
```
