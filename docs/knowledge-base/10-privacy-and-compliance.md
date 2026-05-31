# Nurtly – Privacy and Compliance

Status: Knowledge Base v1  
Confidence: Medium  
Last updated: 2026-05-31

## Purpose

This document captures privacy and compliance assumptions for Nurtly.

It is not legal advice. It should be reviewed before production launch, especially before collecting personal data, child-related data, analytics, account data, or payments.

## Core Privacy Position

Nurtly should be privacy-conscious from the beginning.

The product deals with parenting context, and users may enter information related to children, routines, health observations, sleep, feeding, or daily care.

Even if the app is not a medical product, trust and data minimization are critical.

## Key Principle

Collect only what is necessary.

Do not ask for child data just because parenting apps usually do.

## User Definition

The user is the parent or caregiver.

The child is not the user.

This distinction should guide:

- onboarding
- legal copy
- privacy policy
- app store data declarations
- analytics
- feature design
- account model

## Child Data

### Default Position

Child-related data should be optional wherever possible.

Avoid mandatory collection of:

- full child name
- exact date of birth
- health data
- photos
- location
- sensitive notes
- unnecessary identifiers

### Safer Alternatives

Instead of exact date of birth:

- age range
- approximate age
- month/year
- developmental stage

Instead of real child name:

- nickname
- "Child"
- no name required

## Journal Privacy

Journal may contain sensitive user-entered information.

Possible sensitive content:

- health notes
- sleep issues
- feeding observations
- emotional notes
- routine patterns
- family context

Recommended safeguards:

- clearly explain where data is stored
- allow deletion
- avoid unnecessary cloud sync
- avoid medical interpretation
- avoid sharing by default
- do not use Journal content for advertising
- consider local-first storage for MVP

## Analytics

Analytics should be minimal and purposeful.

Potential safe events:

- app_opened
- onboarding_completed
- sound_played
- sound_timer_used
- play_activity_opened
- journal_entry_created

Avoid collecting:

- journal note contents
- child name
- exact birth date
- sensitive health data
- detailed behavioral profiles
- excessive event streams

Analytics should answer product questions, not maximize surveillance.

## Accounts

MVP should avoid mandatory account creation unless clearly required.

Reasons to avoid mandatory accounts:

- lower friction
- less personal data
- simpler compliance
- faster MVP
- stronger trust

Reasons accounts may be needed later:

- cloud sync
- subscriptions
- multi-device use
- caregiver sharing
- premium access
- data backup

Open decision:

Account model is not finalized.

## Cloud Sync

Cloud sync can add value but increases privacy and technical complexity.

Potential benefits:

- backup
- multi-device support
- caregiver sharing
- account-based subscription

Risks:

- storing child-related information server-side
- data deletion requirements
- security responsibility
- privacy policy complexity
- higher compliance burden

Recommendation:

Do not include cloud sync in MVP unless clearly required.

## AI and Privacy

AI features require special caution.

Potential AI features:

- journal summaries
- activity suggestions
- routine suggestions
- parenting assistant

Risks:

- sending sensitive data to model providers
- hallucinated advice
- medical boundary issues
- unclear data retention
- user trust concerns

Rules for future AI:

- no diagnosis
- no medical advice
- no emergency guidance
- clear disclaimers
- minimize data sent to AI services
- consider opt-in
- review provider data policies
- add safety boundaries

## Medical Boundary

Nurtly should not present itself as a medical app.

Avoid:

- diagnosis
- treatment recommendations
- medical claims
- emergency advice
- claims about curing sleep, anxiety, or health issues

Safe framing:

- daily organization
- notes
- calming routines
- activity ideas
- general support

If users are concerned about health, copy should recommend consulting a qualified professional.

## App Store Data Safety

Before release, review:

- what data is collected
- what data is shared
- whether data is encrypted in transit
- whether users can request deletion
- whether data is used for analytics
- whether data is used for personalization
- whether child-related data is collected

The Google Play Data Safety form must align with actual implementation.

## GDPR Considerations

Areas to review:

- lawful basis for processing
- privacy policy
- data minimization
- user consent
- analytics consent
- data deletion
- data export
- processor agreements
- third-party SDKs
- age-related implications
- sensitive data risks

## Privacy UX

Privacy should be explained in simple language.

Good privacy UX:

- short explanation during onboarding
- clear settings section
- plain-language privacy summary
- no hidden data collection
- no forced oversharing

Avoid:

- legal-only explanation
- vague claims
- burying important information
- asking for sensitive data without explaining why

## Recommended MVP Privacy Direction

For MVP, prefer:

- no mandatory child name
- no mandatory exact DOB
- minimal analytics
- local-first Journal if feasible
- no cloud sync unless needed
- clear privacy policy
- clear settings entry
- no AI processing of user Journal data
- no ads based on child data

## Open Privacy Decisions

1. Is Journal stored locally only?
2. Is an account required?
3. Which analytics provider is used?
4. Are sounds/content downloaded remotely?
5. Are any personal identifiers collected?
6. Is subscription included in MVP?
7. Is cloud backup planned?
8. What deletion flow is required?
9. What exact data safety declaration applies?
10. How should privacy be explained in onboarding?
