# Nurtly – Knowledge Base Review Checklist

Status: Knowledge Base v1 review tool  
Confidence: High  
Last updated: 2026-05-31

## Purpose

This checklist exists to keep the Nurtly Knowledge Base reliable, useful, and safe for future RAG and AI-agent workflows.

The knowledge base is intended to become a source of truth for the project. Because the first version was created from historical project context, some areas are confirmed decisions, while others are assumptions, recommendations, or open questions.

This checklist helps separate:

- confirmed decisions
- working assumptions
- open questions
- items requiring review
- documents that must be updated after future changes

## Review Principles

When reviewing the knowledge base:

1. Do not treat assumptions as confirmed decisions.
2. Mark uncertain areas clearly.
3. Update the decision log when a real decision is made.
4. Keep 99-chatgpt-project-context.md aligned with current product direction.
5. Prefer clear, boring documentation over impressive but vague wording.
6. Avoid documenting things that are not true yet.
7. Use this knowledge base as a source for RAG only if confidence levels are respected.

## Global Review Checklist

### Repository Structure

- [ ] Confirm docs/knowledge-base exists on main.
- [ ] Confirm README.md explains the purpose of the knowledge base.
- [ ] Confirm all knowledge base files are in English.
- [ ] Confirm file names are stable and readable.
- [ ] Confirm documents use consistent status and confidence labels.

### Product Vision

File: 01-product-vision.md

- [ ] Confirm the app is correctly described as a parent-facing mobile application.
- [ ] Confirm children are not described as users.
- [ ] Confirm the calm, supportive, premium direction is accurate.
- [ ] Confirm product positioning does not overstate AI.
- [ ] Confirm target audience is accurate.
- [ ] Confirm initial market assumptions are still valid.
- [ ] Review whether Poland and English-speaking markets are both still relevant.
- [ ] Review whether long-term vision is too broad or still useful.

### Product Principles

File: 02-product-principles.md

- [ ] Confirm "Parents are the users" is a hard product principle.
- [ ] Confirm "Reduce stress, do not create work" is still valid.
- [ ] Confirm privacy-first direction is still valid.
- [ ] Confirm AI should remain a tool, not the main product promise.
- [ ] Confirm gamification and dark patterns should be avoided.
- [ ] Confirm rebrand-friendly architecture is still needed.
- [ ] Add any new principles discovered during development.

### User Personas

File: 03-user-personas.md

- [ ] Review whether the listed personas match the real target users.
- [ ] Validate personas against user interviews or tester feedback when available.
- [ ] Identify which persona is primary for MVP.
- [ ] Confirm whether privacy-conscious parent should remain a separate persona.
- [ ] Add real user insights after testing.

### MVP Scope

File: 04-mvp-scope.md

- [ ] Confirm MVP modules: Home, Journal, Sounds, Play, Onboarding, Settings.
- [ ] Confirm whether Journal is truly part of MVP.
- [ ] Confirm whether Sounds is part of MVP.
- [ ] Confirm whether Play is part of MVP.
- [ ] Confirm exact MVP entry types for Journal.
- [ ] Confirm whether multiple children are supported in MVP.
- [ ] Confirm whether accounts are required in MVP.
- [ ] Confirm whether cloud sync is part of MVP.
- [ ] Confirm whether monetization is included in MVP.
- [ ] Remove or move any feature that is too broad for MVP.

### Feature Catalog

File: 05-feature-catalog.md

- [ ] Review all MVP Candidate features.
- [ ] Move uncertain features to Needs Validation if needed.
- [ ] Move too-advanced features to Post-MVP or Future.
- [ ] Confirm features marked Avoid really should be avoided.
- [ ] Add missing features from current codebase.
- [ ] Remove stale feature ideas that no longer fit the product.

### Architecture

File: 06-architecture.md

- [ ] Confirm actual app technology stack.
- [ ] Confirm storage model.
- [ ] Confirm local-first vs cloud decisions.
- [ ] Confirm whether accounts exist or are planned.
- [ ] Confirm content management approach.
- [ ] Confirm localization approach.
- [ ] Confirm analytics approach.
- [ ] Confirm monetization architecture if introduced.
- [ ] Confirm AI architecture if AI features are introduced.
- [ ] Update architecture after major implementation decisions.

### Decisions

File: 07-decisions.md

- [ ] Confirm all listed decisions are real decisions, not just suggestions.
- [ ] Convert working assumptions into open decisions where needed.
- [ ] Add decision records for new product choices.
- [ ] Add decision records for new technical choices.
- [ ] Add decision records for privacy choices.
- [ ] Keep open decisions current.
- [ ] Close decisions once resolved.
- [ ] Avoid making decisions only in chat without documenting them here.

### Roadmap

File: 08-roadmap.md

- [ ] Confirm current stage.
- [ ] Confirm next milestone.
- [ ] Confirm MVP sequence.
- [ ] Confirm Google Play readiness items.
- [ ] Confirm whether roadmap matches Codex / GitHub work.
- [ ] Move completed items into project history.
- [ ] Remove outdated roadmap assumptions.

### Competitor Research

File: 09-competitor-research.md

- [ ] Validate Huckleberry observations.
- [ ] Validate Nara Baby observations.
- [ ] Add current Google Play competitors.
- [ ] Add current App Store competitors.
- [ ] Add pricing research.
- [ ] Add review analysis.
- [ ] Identify strongest differentiation opportunities.
- [ ] Mark unverified competitor assumptions clearly.

### Privacy and Compliance

File: 10-privacy-and-compliance.md

- [ ] Confirm whether Journal data is local or cloud-based.
- [ ] Confirm what data is collected.
- [ ] Confirm what data is shared.
- [ ] Confirm analytics provider.
- [ ] Confirm whether account deletion is needed.
- [ ] Confirm Google Play Data Safety requirements.
- [ ] Confirm privacy policy contents.
- [ ] Review GDPR implications.
- [ ] Review AI privacy implications before adding AI features.
- [ ] Confirm no medical claims are made.

### Design Principles

File: 11-design-principles.md

- [ ] Confirm calm premium visual direction.
- [ ] Confirm adult-oriented design.
- [ ] Confirm sound artwork constraints.
- [ ] Confirm app UI does not look childish.
- [ ] Confirm store assets match product direction.
- [ ] Confirm accessibility basics.
- [ ] Add examples from actual implemented UI.

### Monetization

File: 12-monetization.md

- [ ] Confirm whether monetization is included in MVP.
- [ ] Validate freemium assumptions.
- [ ] Validate subscription assumptions.
- [ ] Validate premium sound pack idea.
- [ ] Validate activity pack idea.
- [ ] Confirm paywall principles.
- [ ] Avoid monetization based on parental fear or guilt.
- [ ] Add competitor pricing research.

### Project History

File: 13-project-history.md

- [ ] Confirm historical summary is accurate.
- [ ] Add major milestones.
- [ ] Add first MVP build milestone.
- [ ] Add first testing milestone.
- [ ] Add first Google Play milestone.
- [ ] Add major pivots.
- [ ] Keep this file factual, not aspirational.

### AI Agent Context

File: 99-chatgpt-project-context.md

- [ ] Confirm this file is short enough for agents.
- [ ] Confirm it reflects current product direction.
- [ ] Confirm it does not contain outdated assumptions.
- [ ] Update it after major product changes.
- [ ] Keep it aligned with decisions and MVP scope.
- [ ] Ensure future agents read this before coding.

## Open Product Questions

These questions should be resolved over time:

- [ ] What are the exact MVP Journal entry types?
- [ ] Is Journal local-only in MVP?
- [ ] Is an account required in MVP?
- [ ] Is cloud sync part of MVP or post-MVP?
- [ ] Does MVP include monetization?
- [ ] What is the initial launch language?
- [ ] Which analytics provider will be used?
- [ ] What are the exact analytics events?
- [ ] How will Play content be stored and updated?
- [ ] How will Sounds assets be stored and delivered?
- [ ] Is age range enough for personalization?
- [ ] Is the Nurtly name safe enough for launch?
- [ ] What must be declared in Google Play Data Safety?

## Maintenance Rule

Whenever a meaningful decision is made, update at least one of:

- 07-decisions.md
- 04-mvp-scope.md
- 06-architecture.md
- 10-privacy-and-compliance.md
- 99-chatgpt-project-context.md

If the change affects product direction, update 01-product-vision.md or 02-product-principles.md as well.

## RAG Readiness Checklist

Before using this knowledge base as a serious RAG source:

- [ ] Review all documents once.
- [ ] Resolve or mark open decisions.
- [ ] Confirm confidence levels.
- [ ] Remove outdated assumptions.
- [ ] Add source references where possible.
- [ ] Add current codebase facts.
- [ ] Add current MVP implementation status.
- [ ] Add store release status.
- [ ] Ensure no sensitive private information is included.
- [ ] Ensure future AI agents are instructed to distinguish decisions from assumptions.

## Final Note

This checklist is not a blocker.

It is a quality gate.

The knowledge base should be useful early, then improved continuously as Nurtly evolves.
