# Nurtly – AI-Assisted Development Flow

Status: v0.1
Confidence: Medium
Last updated: 2026-05-31

## Purpose

This folder defines the AI-assisted multi-agent development workflow for Nurtly.

The goal is to create a repeatable process where AI agents can plan, implement, review, and test changes using the Nurtly Knowledge Base as context.

This is not full autonomy. This is a controlled, semi-automated development process with a human approval gate.

## Why this exists

Nurtly now has a structured Knowledge Base in docs/knowledge-base.

That Knowledge Base should be used as project memory for AI-assisted development.

Without project context, AI agents may:

- make product decisions that contradict prior decisions
- overengineer MVP features
- introduce privacy risks
- require unnecessary child data
- ignore design principles
- generate generic parenting-app solutions
- treat Nurtly as an AI-first product

## Target Flow

Feature request
-> Context Pack Builder
-> Planner Agent
-> Architect / Risk Agent
-> Codex / Implementation Agent
-> Reviewer Agent
-> Test Agent
-> Human Approval
-> Merge
-> Knowledge Base update if needed

## Core Rule

No AI-generated implementation should be merged without human approval.

## Initial Documents

- 01-context-pack-builder.md
- 02-planner-agent.md
- 03-architect-risk-agent.md
- 04-codex-executor-flow.md
- 05-reviewer-agent.md
- 06-test-agent.md
- 07-human-approval-template.md

## Recommended First Test Feature

Use a small, safe feature to validate the process.

Good candidates:

1. Add or refine Journal empty state.
2. Add Settings / Privacy entry point.
3. Add basic Sounds list placeholder.
4. Add centralized app brand config.
5. Add manual test checklist.

Avoid testing the process first on large features such as:

- full Journal implementation
- authentication
- subscriptions
- cloud sync
- AI features
- production release work
