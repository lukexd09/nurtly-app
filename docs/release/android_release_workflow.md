# Android Release Workflow

## Overview

This repository uses a GitHub Free KISS release flow for a single owner:

- PR CI stays advisory and is reviewed manually before merge.
- The Android release workflow is manual only.
- No branch protection or GitHub Environment is required for this path.
- No automatic Play upload is included.

## Workflow

- File: `.github/workflows/android-release.yml`
- Name: `Android Release`
- Trigger: `workflow_dispatch` only

The workflow must be started from the default branch:

```powershell
gh workflow run android-release.yml `
  --ref main `
  -f source_ref=<commit-or-tag>
```

## Inputs

- `source_ref`: required commit SHA or tag to build.
- `release_notes_from`: optional lower boundary for release notes.

`source_ref` is resolved to an immutable commit SHA and must belong to `main` history.

## Guards

- The workflow fails unless `github.actor == github.repository_owner`.
- The workflow fails unless `github.ref == refs/heads/main`.
- The selected source commit must be an ancestor of `origin/main`.
- `release_notes_from`, when provided, must be an ancestor of the selected source commit.

## Toolchain and validation

- Java: Temurin 17
- Flutter: 3.41.9
- Dart: bundled 3.11.5

Validation runs before signing:

- `flutter pub get --enforce-lockfile`
- lockfile drift check
- non-mutating Dart formatting
- `flutter analyze`
- `flutter test --reporter expanded`
- cleanup of generated local Flutter files
- scope guard
- tracked-file integrity check

## Signing model

Repository-level Actions secrets:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

The workflow reads these values only in the signing-preparation step and decodes the keystore into `RUNNER_TEMP`.
`app/android/key.properties` is generated only for the signed build job and removed in cleanup.

## Artifact and metadata

The upload produces one immutable artifact package containing only:

- the signed AAB
- the AAB SHA-256 file
- metadata JSON
- release notes Markdown
- release evidence Markdown

Artifact name:

```text
nurtly-android-<version>-<build>-<short-sha>
```

Retention is 14 days.

## Release evidence

The metadata package records:

- workflow run ID
- run attempt
- workflow SHA
- source ref
- resolved source SHA
- artifact name
- artifact ID
- artifact URL
- archive digest
- AAB SHA-256
- version/build
- automated validation result
- manual QA result
- store delivery result

Manual QA and store delivery remain `NOT_RUN` until the owner performs them separately.

## Download and verification

Download from the GitHub UI or with:

```powershell
gh run download <run-id> -n <artifact-name>
```

Verify the checksum with the downloaded `*.sha256` file.

## Artifact package contents

- signed AAB
- AAB SHA-256 checksum file
- metadata JSON
- release notes Markdown
- release evidence Markdown

## Job summary outputs

- artifact ID
- artifact URL
- archive digest

The artifact package does not contain job-summary-only outputs.

The AAB SHA-256 is the checksum of the app bundle file. The GitHub artifact archive digest is the checksum of the uploaded artifact archive and is a separate value.

## Cleanup and rollback

- Cleanup removes temporary signing material with `if: always()`.
- Temporary keystore and `key.properties` never enter the repository.
- If the workflow is misconfigured, revert the workflow file and related docs in a follow-up PR.

## First post-merge signed run

After merge, the owner:

1. Adds the four repository secrets.
2. Confirms the workflow file is on `main`.
3. Runs the workflow manually from `main`.
4. Reviews the generated artifact package and evidence.
5. Keeps the run separate from Google Play upload and manual QA.

## Boundaries

- No Google Play upload.
- No claim of manual QA from CI.
- No claim of a successful signed run until a real post-merge workflow run succeeds.
