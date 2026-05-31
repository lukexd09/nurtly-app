# Nurtly – Feature Catalog

Status: Knowledge Base v1  
Confidence: Medium  
Last updated: 2026-05-31

## Purpose

This document lists known and potential Nurtly features.

It is not a commitment to build everything. It is a structured catalog for planning, prioritization, RAG, and AI-assisted product work.

## Feature Status Definitions

- MVP Candidate: likely useful for first release.
- Post-MVP: valuable but should wait.
- Future: possible long-term direction.
- Needs Validation: requires user or business validation.
- Avoid: conflicts with product principles.

## Home Features

### Calm Home Screen

Status: MVP Candidate

Description:

A simple starting screen that gives users access to the most important modules.

Possible elements:

- Journal shortcut
- Sounds shortcut
- Play shortcut
- today summary
- gentle prompt
- recent activity

Risks:

- becoming too crowded
- turning into a dashboard
- creating pressure

### Daily Summary

Status: Post-MVP / Needs Validation

Description:

A simple overview of what has been logged today.

Potential value:

- helps parents remember the day
- supports continuity
- makes Journal more useful

Risks:

- requires enough data
- may become too analytical

### Personalized Suggestions

Status: Future

Description:

Suggestions based on routines, child age, usage, or recent entries.

Potential examples:

- calming sound suggestion
- play idea suggestion
- reminder to add a note

Risks:

- privacy concerns
- AI hallucination if generated
- too much complexity

## Journal Features

### Basic Journal Entry

Status: MVP Candidate

Description:

Allow parent to add a simple daily note or care event.

Possible fields:

- type
- time
- note
- optional duration
- optional tags

### Entry Types

Status: MVP Candidate / Needs Review

Potential types:

- sleep
- feeding
- diaper
- health
- mood
- observation
- custom note

The exact list should be validated before implementation.

### Today View

Status: MVP Candidate

Description:

Chronological view of today’s entries.

Value:

- easy recall
- low complexity
- useful immediately

### History View

Status: MVP Candidate / Post-MVP

Description:

Simple list or calendar view of previous entries.

### Journal Search

Status: Post-MVP

Description:

Search through notes and entries.

### Journal Export

Status: Future

Description:

Export selected notes to PDF, CSV, or shareable summary.

Potential use cases:

- pediatrician visit
- caregiver handoff
- personal record

Risks:

- privacy
- formatting complexity
- medical interpretation concerns

### AI Journal Summary

Status: Future / Needs Validation

Description:

AI-generated summary of recent entries.

Important:

Should not provide medical diagnosis or advice.

Possible safe framing:

- "Here is a summary of your notes"
- "You may want to review this with a professional if concerned"

## Sounds Features

### Sound Library

Status: MVP Candidate

Description:

A curated list of calming sounds.

Known concepts:

- Soft rain
- Warm noise
- Quiet stream
- Evening crickets
- Room fan
- Dishwasher hum

### Audio Player

Status: MVP Candidate

Expected capabilities:

- play
- pause
- loop
- timer
- fade-out

### Sound Cover Artwork

Status: MVP Candidate

Style:

- adult-oriented
- calm
- premium
- no text
- no children
- no childish imagery

### Favorites

Status: Post-MVP

Description:

Allow users to mark favorite sounds.

### Sound Packs

Status: Post-MVP / Monetization Candidate

Description:

Premium sound packs could support monetization.

Potential packs:

- sleep routine
- evening calm
- household hums
- nature ambience

### Sound Mixing

Status: Future

Description:

Allow users to mix multiple sounds.

Risk:

May increase complexity beyond the calm MVP experience.

## Play Features

### Activity Library

Status: MVP Candidate

Description:

Curated list of play ideas.

Possible fields:

- title
- age range
- duration
- materials
- instructions
- benefits
- indoor/outdoor
- energy level

### Filters

Status: MVP Candidate / Post-MVP

Possible filters:

- age
- duration
- indoor/outdoor
- materials required
- calm/active
- developmental area

### Activity Detail

Status: MVP Candidate

Description:

Simple page explaining how to do the activity.

Should be practical and short.

### Saved Activities

Status: Post-MVP

Description:

Users can save favorite activities.

### AI Activity Suggestions

Status: Future / Needs Validation

Description:

AI suggests activities based on constraints.

Example:

- "5-minute indoor activity with no materials"

Important:

Generated content should be reviewed or constrained.

## Onboarding Features

### Minimal Onboarding

Status: MVP Candidate

Description:

Short introduction and optional setup.

### Optional Child Profile

Status: MVP Candidate / Needs Review

Possible optional fields:

- nickname
- age range
- month/year of birth instead of exact DOB
- preferences

Important:

Avoid mandatory child name and exact DOB unless necessary.

### Privacy Explanation

Status: MVP Candidate

Description:

Simple explanation of what data is collected and why.

## Settings Features

### Language

Status: MVP Candidate

Languages:

- English
- Polish

### Privacy & Data

Status: MVP Candidate

Should include:

- data storage explanation
- privacy policy link
- account/data deletion if account exists
- analytics explanation if analytics are used

### App Info

Status: MVP Candidate

Should include:

- version
- support/contact
- legal links

## Monetization Features

### Freemium Model

Status: Needs Validation

Possible free features:

- basic sounds
- limited journal
- limited play content

Possible premium features:

- more sounds
- premium activity packs
- advanced journal history
- export
- AI summaries
- routines

### Subscription

Status: Future / Needs Validation

Potential monthly or yearly subscription.

Risks:

- users may resist paying for basic parenting utility
- value proposition must be clear

### One-Time Purchase

Status: Needs Validation

Could fit premium sound packs or lifetime access.

## AI Features

### AI Content Support

Status: Internal / Current Direction

AI may support internal content creation, cover prompts, activity drafts, and documentation.

### AI Parenting Assistant

Status: Future / High Risk

Could answer questions or suggest routines.

Risks:

- safety
- medical boundaries
- hallucinations
- compliance
- trust

### AI Journal Insights

Status: Future / Needs Validation

Could summarize user-entered notes.

Must avoid diagnosis.

## Features to Avoid

Avoid in MVP:

- child-facing games
- social feed
- parent comparison
- child scoring
- medical diagnosis
- aggressive notifications
- streaks
- guilt mechanics
- public sharing of child data
- complex AI assistant
- mandatory detailed child profile

## Prioritization Rule

A feature should move forward if it:

1. Helps tired parents quickly.
2. Fits the calm product direction.
3. Does not require unnecessary child data.
4. Can be explained simply.
5. Supports MVP validation.
6. Does not create major compliance or trust risk.
