# Android signing strategy

Status: strategy documented. Protected values are not created by this repository change.

## Purpose

This guide documents the owner-controlled signing strategy for the Android release path and prepares the handoff for #196 without adding a signed release workflow.

#195 remains BLOCKED until the owner confirms the signing owner, two encrypted backups, recovery method, repository-level GitHub Actions secrets and required recovery records.

## Ownership and responsibilities

- Release signing owner: the repository/product owner; approves all signing changes and release use.
- Backup custodian: the owner or a separately authorized trusted custodian; maintains encrypted recovery copies.
- Workflow maintainer: may maintain workflow code but receives no plaintext signing material unless separately authorized.
- Pull-request workflows: must never access release signing credentials.
- Store delivery owner: explicitly approves any future Internal Testing upload.

## Repository-level Actions secrets

Required secret names:

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
```

- `ANDROID_KEYSTORE_BASE64` stores the base64 representation of the release or upload keystore.
- `ANDROID_KEYSTORE_PASSWORD` stores the keystore password.
- `ANDROID_KEY_ALIAS` stores the signing key alias.
- `ANDROID_KEY_PASSWORD` stores the private key password.

Owner setup steps:

1. Open repository `Settings`.
2. Open `Secrets and variables`, then `Actions`.
3. Add the four names above as repository secrets.
4. Do not create them as repository variables.
5. Do not print or commit their values.
6. Do not expose them to pull-request workflows.
7. Keep the release workflow manual and owner-only.

Implementation of #196 may exist before repository signing values are created. The first real signed run remains blocked until values, backups and recovery are confirmed.

The release workflow decodes the keystore into a temporary runner path and generates `app/android/key.properties` only for the signed release job.

Temporary signing files must be removed during cleanup even after failure.

## Local manual fallback

The current local fallback uses `app/android/key.properties`.

Required keys:

```properties
storePassword=<owner-supplied>
keyPassword=<owner-supplied>
keyAlias=<owner-supplied>
storeFile=<path-relative-to-app/android>
```

Rules for the fallback:

- The placeholder values must never be replaced with real values in committed documentation.
- The keystore file remains outside git.
- `app/android/key.properties` remains ignored.
- The owner should verify with `git status --short` before and after the build.
- The local release command is:

```powershell
cd C:\Projekty\Nurtly\app
flutter build appbundle --release
```

Expected AAB path:

```text
app/build/app/outputs/bundle/release/app-release.aab
```

## Backup strategy

Use these principles:

- Keep at least two encrypted copies.
- Store them in separate trusted locations.
- Do not use the repository as a backup location.
- Store passwords separately from keystore bytes.
- Limit access and review it periodically.
- Test recovery before relying on the backup.
- Record the actual private location only in owner-controlled operational records.

Owner confirmation checklist:

```text
[ ] Primary encrypted backup confirmed
[ ] Secondary encrypted backup confirmed
[ ] Password recovery method confirmed
[ ] Signing owner confirmed
[ ] Required repository secrets confirmed
[ ] Recovery records confirmed
```

## Rotation and recovery

Rotation should be triggered by events such as:

- loss or suspected compromise of the upload key;
- owner-requested key replacement;
- a Play Console recovery or reset requirement;
- a change in the protected signing workflow that requires new material.

Rotation should be approved by the signing owner and any additional maintainer required by repository governance.

Before activation of new material:

- back up the new signing material in encrypted form;
- confirm the recovery method;
- verify the repository secrets are ready.

Replace GitHub Actions credentials by updating the repository-level secret values only.

Retain or revoke old material according to Google Play signing and upload-key requirements and the owner-approved Play Console procedure.

Key rotation must not occur automatically.

Google Play App Signing and upload-key recovery must be handled through owner-approved Play Console procedures.

Do not claim Google Play App Signing is enabled unless it has been verified separately.

## Related release runbooks

- [Closed-testing release candidate runbook](closed_testing_release_candidate_runbook.md)
- [Closed-testing upload handoff](closed_testing_upload_handoff.md)
- [Closed-testing release candidate evidence](closed_testing_release_candidate_evidence.md)

Do not duplicate their procedures here.

## Evidence boundaries

Allowed repository evidence:

- GitHub Actions secret names;
- workflow run IDs;
- commit SHA;
- app version or build number;
- artifact filename;
- checksum;
- repository secret names;
- PASS / FAIL / BLOCKED outcome.

Forbidden repository evidence:

- keystore bytes;
- base64 payload;
- passwords;
- raw `key.properties`;
- service-account JSON;
- private backup paths;
- unredacted environment screenshots;
- signing command output containing sensitive values.

## Handoff to #196

The release implementation task can be implemented before all repository signing values exist, but the first signed run should not start until all of the following are true:

- All four credential names exist at repository level.
- The owner confirms backup and recovery ownership.
- PR CI remains green.
- The release workflow design uses `workflow_dispatch`.
- No Play upload is included in #196.

## Read-only repository evidence

Current repository evidence relevant to this strategy:

- `app/android/app/build.gradle` expects `app/android/key.properties` for release signing.
- Release builds fail clearly when `app/android/key.properties` is missing or incomplete.
- `app/.gitignore` ignores `app/android/key.properties`, Android `.jks` files, Android `.keystore` files, `.aab` files, and `.apk` files.
- A file scan did not show tracked signing artifacts or obvious credential files.

## Local verification notes

For local release checks, the owner can still use the existing command:

```powershell
cd C:\Projekty\Nurtly\app
flutter build appbundle --release
```

This repository change does not execute a signed release build.
