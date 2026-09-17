# Nurtly

### Mobile product case study: an idea taken through MVP definition, architecture, implementation, QA and release preparation

Nurtly is a Flutter mobile app for parents and caregivers. It combines activity inspiration, calming sounds and a private local journal in a lightweight bilingual product.

| | |
|---|---|
| **My role** | Product owner · Technical Project Manager · solution designer · AI-assisted builder |
| **Delivery scope** | Product concept → MVP scope → architecture → backlog → implementation → QA → release readiness |
| **Core stack** | Flutter · Dart · local JSON content · local device storage · in-app purchase and ads foundations |
| **Languages** | English and Polish |
| **Current status** | Journal MVP completed; store and release readiness in progress |

## What this project demonstrates

- turning a broad product idea into a focused, testable MVP,
- defining product modules and technical boundaries before implementation,
- balancing user value, privacy, monetization and delivery cost,
- managing bilingual content and localization as part of product architecture,
- preparing QA, legal and release documentation alongside the application,
- using an AI-assisted workflow with explicit risk routing and human approval.

## Current MVP

- **Home** — entry point and product navigation
- **Play** — activity ideas for parents and caregivers
- **Sounds** — bundled audio content
- **Journal** — local sleep, feeding, diaper and note entries with edit/delete flows and a sleep timer
- **Premium readiness** — monthly/yearly entitlement and restore-purchase foundations
- **Ads readiness** — test and placeholder configuration for free users
- **Localization** — English and Polish product content

The journal is intentionally local-only in the current MVP: no backend or cloud synchronization is required for personal entries.

## Product and architecture decisions

- Runtime editorial content is bundled as localized JSON assets.
- Navigation, theme, localization, content, monetization and ads are separated into core modules.
- Premium users should not see ads; lifetime purchase is outside the MVP.
- Release, QA and legal readiness are managed as first-class delivery workstreams.
- The repository distinguishes current implemented behavior from historical or deferred product ideas.

## AI-assisted delivery model

The project includes a documented approach for turning broad epics into focused tasks, assessing delivery risk and routing work between local models, stronger reasoning/coding models and human approval.

AI supports analysis and implementation, while product scope, architecture, safety boundaries, acceptance and release remain human-owned decisions.

See:

- [AI delivery workflow](./docs/architecture/ai-delivery-workflow.md)
- [Model routing](./docs/architecture/model-routing.md)
- [Model usage matrix](./docs/architecture/model-usage-matrix.md)

## Repository map

```text
app/      Flutter application source and bundled runtime assets
content/  Editorial workspace and content licensing materials
docs/     Architecture, QA, release, legal and product knowledge
tools/    Project tooling and helper scripts
.github/  Workflows and issue templates
```

## Start here

- [Application README](./app/README.md)
- [Architecture overview](./docs/architecture/README.md)
- [QA documentation](./docs/qa/README.md)
- [Release documentation](./docs/release/README.md)
- [Legal documentation](./docs/legal/README.md)
- [Product knowledge base](./docs/knowledge-base/README.md)

## Run locally

```bash
cd app
flutter pub get
flutter run
```

## Related project

- [Nurtly Web](https://github.com/lukexd09/nurtly-web) — localized support, privacy and product pages

