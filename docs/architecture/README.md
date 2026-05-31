# Architecture

This file gives a concise as-built overview of the current MVP.

## App structure

- Flutter app code lives under `app/`
- `AppShell` owns the main navigation and language state
- Main modules are Home, Play, Sounds, Journal, and settings/premium-related screens

## Core modules

- `core/navigation`
- `core/theme`
- `core/localization`
- `core/content`
- `core/monetization`
- `core/ads`

## Content loading

Runtime content is bundled as JSON assets and loaded through:

- `ContentLoader`
- `ContentRepository`
- `BundledContentSource`

Current MVP runtime content lives in:

- `app/assets/content/nurtly_content_en_v1.json`
- `app/assets/content/nurtly_content_pl_v1.json`

## Journal

Journal is local-only in the current MVP.

- local store
- sleep / feeding / diaper / note entries
- edit and delete flows
- sleep timer
- selected day context
- custom date and time pickers
- no backend or cloud sync for Journal notes

## Premium and ads

- Premium uses monthly and yearly entitlement flows
- restore purchases is supported
- lifetime is not part of the MVP
- free users may see ads
- Premium users should not see ads
- test / placeholder ad configuration is used until release setup is finalized

## Release and QA

Current release-related documentation lives under:

- `docs/release`
- `docs/qa`
- `docs/legal`

This folder is for the current architecture snapshot, not for speculative future features.
