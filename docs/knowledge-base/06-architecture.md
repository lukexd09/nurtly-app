# Nurtly – Architecture

Status: Knowledge Base v1  
Confidence: Medium  
Last updated: 2026-05-31

## Purpose

This document describes the current architectural assumptions for Nurtly.

It is not a final technical specification. It is a working architecture context for future implementation, AI agents, technical planning, and RAG.

## Architectural Philosophy

Nurtly should be simple enough to launch, but structured enough to grow.

The architecture should support:

- fast MVP development
- privacy-conscious data handling
- future rebranding
- localization
- future monetization
- future AI features
- future RAG / knowledge-base assisted development

The architecture should avoid unnecessary complexity in the MVP.

## Key Architectural Principles

### 1. Rebrand-friendly architecture

The product name Nurtly may change in the future due to trademark, store, or positioning issues.

Therefore:

- app name should be centralized
- hardcoded brand strings should be minimized
- store copy should be maintained in documentation
- visual identity should be replaceable
- domain-specific naming should be avoided inside core logic where possible

Bad examples:

- NurtlyJournalManager
- NurtlySoundService
- nurtlyHardcodedCopy

Better examples:

- JournalManager
- SoundService
- AppBrandConfig

### 2. Privacy-first data model

Nurtly should not collect child-related data unless there is a clear product reason.

Default assumptions:

- child name is optional
- exact date of birth is optional or avoidable
- age range may be preferred over exact DOB
- Journal should avoid unnecessary sensitive data
- analytics should be minimal and purposeful
- local-first storage should be considered where practical

### 3. MVP-first complexity control

The MVP should avoid heavy backend dependencies unless clearly needed.

Possible MVP approach:

- local app storage for Journal
- bundled or lightweight remote content for Sounds and Play
- minimal analytics
- no complex account system unless needed for store or monetization
- no cloud sync in the first version unless validated

### 4. Future extensibility

Even if MVP is simple, the architecture should not block future expansion.

Future possible needs:

- user accounts
- cloud sync
- subscription
- premium sound packs
- content management
- AI suggestions
- AI summaries
- multi-language content
- caregiver sharing
- export

## Data Areas

### Journal Data

Potential data:

- entry ID
- entry type
- timestamp
- note
- optional duration
- optional metadata
- created at
- updated at

Privacy sensitivity:

Medium to high, depending on content.

Recommended approach:

- store locally in MVP if feasible
- avoid medical interpretation
- make deletion possible
- clearly explain storage model

### Sounds Data

Potential data:

- sound ID
- title
- category
- duration
- audio asset path
- artwork path
- premium/free flag
- playback metadata

Privacy sensitivity:

Low.

Usage analytics may become sensitive if over-collected.

### Play Data

Potential data:

- activity ID
- title
- age range
- duration
- category
- materials
- instructions
- tags
- language
- premium/free flag

Privacy sensitivity:

Low for static content.

### User Preferences

Potential data:

- language
- favorite sounds
- saved activities
- onboarding state
- timer preferences
- app settings

Privacy sensitivity:

Low to medium.

### Child Profile

Status: Needs careful review.

Potential optional fields:

- nickname
- age range
- approximate birth month/year
- preferences

Avoid mandatory:

- full child name
- exact date of birth
- unnecessary health data

## Localization

Nurtly should support at least:

- English
- Polish

Architecture implications:

- UI copy should be externalized
- content should support language versions
- store listing copy should be maintained separately
- future content packs should include language metadata

## Content Management

### Option A: Static bundled content

Pros:

- simple
- fast
- offline-friendly
- low cost

Cons:

- app update required for new content
- limited flexibility

Good for:

- initial Play content
- initial Sounds metadata

### Option B: Remote JSON content

Pros:

- easy updates
- lightweight
- no full CMS required

Cons:

- requires hosting
- needs caching
- needs version handling

Good for:

- Play activity updates
- sound metadata
- promotional content

### Option C: CMS

Pros:

- scalable
- editor-friendly

Cons:

- more complexity
- more cost
- more moving parts

Recommended for:

- post-MVP only, unless content growth becomes painful early

## Analytics

Analytics should be minimal and intentional.

Potential MVP events:

- app_opened
- onboarding_completed
- journal_entry_created
- sound_played
- sound_timer_used
- play_activity_opened
- language_selected

Avoid:

- unnecessary child-specific analytics
- detailed sensitive event tracking
- excessive behavioral profiling

Analytics should answer product questions, not collect data for its own sake.

## Monetization Architecture

Future monetization may require:

- subscription state
- premium content access
- purchase restore
- app store billing integration
- entitlement management

MVP should not overbuild this unless monetization is included in the first release.

Possible premium areas:

- sound packs
- activity packs
- advanced journal history
- export
- AI summaries
- routines

## AI Architecture

AI should not be central to MVP unless a very specific, safe use case is defined.

Potential future AI features:

- activity suggestions
- journal summaries
- routine suggestions
- content personalization
- onboarding assistant

Risks:

- hallucination
- medical boundary issues
- privacy
- cost
- latency
- trust

Recommended approach:

- use AI internally first
- keep generated user-facing parenting content reviewed or constrained
- do not provide diagnosis or medical advice
- add guardrails before exposing AI to users

## RAG / Knowledge Base Architecture

This repository now includes:

docs/knowledge-base

This folder should become the source of truth for:

- product vision
- decisions
- MVP scope
- architecture
- design principles
- privacy assumptions
- roadmap
- agent context

Future AI agents should index this folder before working on the project.

Recommended RAG behavior:

- prefer docs/knowledge-base over chat history
- cite document sections
- distinguish confirmed decisions from assumptions
- update decision records when product direction changes

## Release Documentation

The repository includes store/release-related documentation under:

docs/release

Knowledge Base and release docs should stay aligned.

Release documentation may include:

- store listing copy
- screenshot plan
- feature graphic brief
- store assets checklist

## Security and Compliance Notes

Nurtly should avoid collecting regulated or sensitive data unless required.

Areas requiring future review:

- GDPR
- child data handling
- app store data safety
- privacy policy
- analytics consent
- account deletion
- subscription terms
- medical disclaimer

## Architecture Risks

Key risks:

- adding accounts too early
- collecting child data unnecessarily
- building too much backend too soon
- making Journal too complex
- exposing AI features before safety boundaries exist
- hardcoding product name everywhere
- weak localization structure
- unclear content management ownership

## Recommended MVP Architecture Direction

For MVP, prefer:

- simple local-first Journal
- static or lightweight remote content
- simple Sounds module
- simple Play library
- minimal analytics
- privacy-first onboarding
- rebrand-friendly naming
- clear documentation

Avoid:

- heavy backend
- complex user accounts
- AI assistant
- medical features
- social features
- over-engineered CMS
