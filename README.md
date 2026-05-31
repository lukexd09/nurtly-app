# Nurtly

Nurtly is a Flutter mobile app for parents and caregivers.

## Current MVP

- Home / app shell
- Play / activity ideas
- Sounds
- Journal
- Premium and billing readiness
- Ads placeholders and test configuration
- EN / PL localization
- release documentation and QA readiness

## Current status

- MVP-1 Journal is completed.
- MVP-2 release readiness is in progress.
- Google Play account and console setup still happen outside the repository.

## Repository structure

```text
app/      Flutter application source.
content/  Reserved editorial workspace for source, published, and license materials.
docs/     Project documentation, including architecture, QA, release, legal, and knowledge-base notes.
tools/    Project tooling and helper scripts.
.github/  GitHub workflow and issue-template folders.
```

## Start here

- [App README](app/README.md)
- [Architecture overview](docs/architecture/README.md)
- [Release docs](docs/release/README.md)
- [QA docs](docs/qa/README.md)
- [Legal docs](docs/legal/README.md)
- [Knowledge base](docs/knowledge-base/README.md)

## Documentation note

The knowledge base captures product context and decisions, but current MVP behavior is reflected by code and release docs first. If a knowledge-base note conflicts with implemented behavior, treat the code and release docs as current for MVP and mark the note as historical or deferred.
