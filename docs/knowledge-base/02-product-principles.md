# Nurtly – Product Principles

Status: Knowledge Base v1  
Confidence: High  
Last updated: 2026-05-31

## Purpose

This document defines the product principles that should guide Nurtly decisions.

These principles should be used when planning features, writing copy, designing screens, building onboarding, reviewing UX, preparing store assets, and instructing future AI agents.

## Principle 1: Parents are the users

Nurtly is for parents and caregivers.

Children are not users of the application.

This affects:

- onboarding
- privacy
- language
- design
- app store positioning
- compliance assumptions
- feature prioritization

The product should never be designed as something that encourages direct child usage.

## Principle 2: Reduce stress, do not create work

Every feature should reduce parental load.

A feature is questionable if it requires parents to maintain complex data, configure too much, or feel guilty for not using it every day.

Good features:

- save time
- reduce memory burden
- support calm routines
- help parents make decisions faster

Bad features:

- create pressure
- require excessive input
- feel like homework
- punish missed days
- create guilt

## Principle 3: Calm first

The visual and emotional tone of Nurtly should be calm.

Nurtly should feel like a supportive companion, not a dashboard demanding attention.

Avoid:

- red warning-style UI unless truly necessary
- noisy illustrations
- childish cartoon design
- excessive animations
- urgency-based copy
- too many CTAs
- notification pressure

Prefer:

- soft colors
- warm neutral tones
- gentle transitions
- short copy
- clear hierarchy
- quiet empty states

## Principle 4: Privacy by design

Privacy should be designed into the product from the beginning.

Nurtly should collect the minimum amount of personal data required to provide value.

Default assumptions:

- child name should not be mandatory
- date of birth should not be mandatory unless needed for a clear feature
- child data should be optional where possible
- parent account requirements should be minimized for MVP
- local-first storage should be considered for Journal where feasible
- analytics should be minimal and purposeful

## Principle 5: AI is a tool, not the product

Nurtly should not position itself as an AI app.

AI may support:

- internal content creation
- future personalized suggestions
- future summaries
- future activity recommendations
- future parenting assistant features

But the user-facing promise should remain practical and human:

- calmer routines
- better organization
- useful ideas
- support for parents

## Principle 6: Premium simplicity

Nurtly should feel premium because it is clear, calm, and well-crafted, not because it is visually overloaded.

Premium means:

- thoughtful spacing
- consistent typography
- calm colors
- strong microcopy
- smooth flows
- fewer but better features
- no clutter

## Principle 7: Avoid dark patterns

Nurtly should not manipulate parents through guilt, fear, artificial urgency, or addictive mechanics.

Avoid:

- streak pressure
- shame-based copy
- fear-based parenting claims
- fake scarcity
- confusing cancellation paths
- notification spam
- emotional exploitation

## Principle 8: Practical over theoretical

The product should solve real everyday problems.

When choosing between an impressive feature and a useful feature, choose useful.

Examples of practical value:

- logging care events quickly
- finding an activity fast
- starting a calming sound without friction
- checking what happened today
- supporting an evening routine

## Principle 9: Design for tired users

Parents may use Nurtly while tired, distracted, holding a child, or in the evening.

Therefore:

- flows should be short
- taps should be obvious
- copy should be simple
- contrast should be accessible
- navigation should be predictable
- important actions should be easy to find

## Principle 10: Build for future rebranding

The product name Nurtly may need to change if trademark, app store, or brand issues appear.

Architecture and content should avoid hardcoding the brand name where unnecessary.

Branding should be centralized where possible.

## Principle 11: Source of truth over chat memory

Project decisions should be moved from chat discussions into the knowledge base.

Future AI agents should treat this folder as more authoritative than old conversation history.

## Feature Evaluation Checklist

Before adding a feature, ask:

1. Does it reduce parental stress?
2. Does it save time or mental effort?
3. Does it support calm routines?
4. Does it require unnecessary personal data?
5. Does it make the app more complex?
6. Is it useful for the MVP, or should it wait?
7. Can a tired parent understand it quickly?
8. Does it fit the calm premium direction?
9. Does it create any privacy or compliance concern?
10. Should this decision be recorded in 07-decisions.md?
