# Nurtly – Decision Log

Status: Knowledge Base v1  
Confidence: Medium-High  
Last updated: 2026-05-31

## Purpose

This document records important product, design, technical, privacy, and business decisions for Nurtly.

It should be updated whenever a meaningful decision is made.

Decision records are important because future contributors and AI agents need to understand not only what was decided, but why.

## Decision Format

Each decision should include:

- Date
- Area
- Decision
- Reason
- Status
- Confidence
- Follow-up if needed

## 2026-05-31 — Create structured Knowledge Base

Area: Documentation / RAG

Decision:

Create a structured knowledge base under docs/knowledge-base.

Reason:

Most Nurtly context previously lived in ChatGPT conversations. This is useful during discussion but weak as a long-term source of truth.

A structured markdown knowledge base is easier to:

- index with RAG
- use with AI coding agents
- maintain over time
- review manually
- cite in future decisions

Status: Accepted  
Confidence: High

## 2026-05-31 — Use English for Knowledge Base

Area: Documentation

Decision:

Maintain the Nurtly Knowledge Base in English.

Reason:

English is more useful for:

- AI agents
- coding assistants
- GitHub documentation
- future international collaboration
- app store and product expansion
- RAG consistency

Status: Accepted  
Confidence: High

## 2026-05-31 — Parents are users, children are not users

Area: Product / Privacy / Compliance

Decision:

Nurtly is designed for parents and caregivers. Children are not users of the application.

Reason:

This simplifies product direction, UX, privacy assumptions, store positioning, and compliance framing.

It also prevents the product from drifting into child-facing entertainment, games, or direct child engagement.

Status: Accepted  
Confidence: High

## 2026-05-31 — Privacy-first product direction

Area: Privacy / Product

Decision:

Nurtly should collect the minimum amount of personal data required to provide value.

Reason:

The app deals with parenting-related context, which may include sensitive information. Trust is essential.

Privacy-conscious design also supports a calmer user experience and lowers regulatory risk.

Status: Accepted  
Confidence: High

## 2026-05-31 — Child name should not be mandatory

Area: Privacy / Onboarding

Decision:

Child name should not be mandatory.

Reason:

The product can deliver value without requiring a real child name. Avoiding mandatory child identification reduces friction and privacy concerns.

Status: Accepted  
Confidence: High

## 2026-05-31 — Exact child date of birth should not be mandatory by default

Area: Privacy / Onboarding

Decision:

Exact child date of birth should not be mandatory unless a specific feature clearly requires it.

Reason:

Age-based content may be useful, but exact date of birth is more sensitive than an age range or approximate stage.

Possible alternatives:

- age range
- month/year
- developmental stage
- optional DOB

Status: Accepted as default principle  
Confidence: High  
Follow-up: Review when Play filters and personalization are implemented.

## 2026-05-31 — AI should not be front-and-center in positioning

Area: Product / Marketing

Decision:

Nurtly should not be marketed primarily as an AI app.

Reason:

The core value should be parenting support, calm routines, organization, and practical tools.

AI may support the product internally or in future features, but AI-first positioning could reduce trust or make the product feel gimmicky.

Status: Accepted  
Confidence: High

## 2026-05-31 — Calm premium design direction

Area: Design

Decision:

Nurtly should use a calm, premium, adult-oriented design direction.

Reason:

The target user is the parent, not the child. The product should feel safe, soothing, and trustworthy.

This applies especially to:

- app UI
- sound artwork
- store assets
- onboarding
- copywriting

Status: Accepted  
Confidence: High

## 2026-05-31 — Avoid gamification and dark patterns

Area: Product / UX

Decision:

Nurtly should avoid gamification, streak pressure, guilt mechanics, and dark patterns.

Reason:

Parents are often tired, stressed, and emotionally overloaded. The app should not manipulate users or increase pressure.

Status: Accepted  
Confidence: High

## 2026-05-31 — Build rebrand-friendly architecture

Area: Architecture / Brand

Decision:

The product architecture should support possible future renaming.

Reason:

The name Nurtly may face trademark, store, or market-positioning risks.

Hardcoded brand strings should be minimized.

Status: Accepted  
Confidence: Medium-High

## 2026-05-31 — English and Polish should be supported early

Area: Localization / Market

Decision:

English and Polish should be supported early.

Reason:

The creator is Polish, but the product may target broader English-speaking markets. English also helps with AI tooling, store copy, and documentation.

Status: Accepted  
Confidence: Medium  
Follow-up: Decide exact launch language strategy.

## 2026-05-31 — Sounds should be parent-facing, not child-facing

Area: Product / Design

Decision:

The Sounds module and sound artwork should be designed for parents/adults, not children.

Reason:

The product experience should be calm, premium, and suitable for evening routines.

Known artwork constraints:

- no text
- no logos
- no UI
- no people
- no babies
- no children
- no cartoon animals
- no music notes
- no headphones
- no speaker icons

Status: Accepted  
Confidence: High

## 2026-05-31 — Journal is a strong MVP value candidate

Area: Product / MVP

Decision:

Journal should be treated as one of the strongest MVP candidates.

Reason:

Journal can create recurring practical value by reducing mental load and helping parents remember daily care events.

Status: Working decision  
Confidence: Medium  
Follow-up: Define exact Journal event types and storage model.

## 2026-05-31 — Keep MVP narrow

Area: Product / Delivery

Decision:

MVP should remain narrow and launchable.

Reason:

Nurtly has several possible product directions: Journal, Play, Sounds, routines, AI, content, insights, monetization.

Trying to build all of them deeply in the first version would delay launch and increase risk.

Status: Accepted  
Confidence: High

## 2026-05-31 — RAG should use structured docs over raw chat history

Area: AI / Documentation

Decision:

Future RAG should index structured markdown documents rather than raw ChatGPT conversations.

Reason:

Raw chats contain noise, outdated ideas, casual comments, and context shifts. Structured documents are cleaner, more reliable, and easier to maintain.

Status: Accepted  
Confidence: High

## Open Decisions

The following decisions still need to be made:

1. Exact MVP Journal entry types.
2. Whether Journal is local-only in MVP.
3. Whether user accounts are required in MVP.
4. Whether cloud sync is part of MVP or post-MVP.
5. Exact monetization model.
6. Initial launch language.
7. Analytics provider and event list.
8. Whether subscriptions are included in v1.
9. Content management approach for Play.
10. Audio storage and delivery approach for Sounds.
11. Whether age range is enough for Play personalization.
12. App store category and final positioning.
13. Whether Nurtly name is safe enough for launch.
