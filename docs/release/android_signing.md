# Android signing strategy

Status: strategy documented. Protected values are not created by this repository change.

## Purpose

This guide documents the owner-controlled signing strategy for the Android release path and prepares the handoff for #196 without adding a signed release workflow.

## Protected environment

Recommended GitHub Environment name:

```text
android-release
```

Recommended controls:

- Restrict deployment access to the owner or approved maintainers.
- Require reviewer approval before a protected release job can access protected values.
- Prefer environment-level protected values over repository-level protected values when both are available.
- Do not expose release protected values to pull-request workflows.
- Verify environment protection before #196 is executed.

## Required credential names

Document names and purposes only:

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

The follow-up release workflow in #196 should decode the keystore into a temporary runner path and generate `app/android/key.properties` only for the protected release job.

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
[ ] Protected GitHub environment confirmed
[ ] Required environment credentials created
[ ] Required reviewer protection confirmed
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
- verify the protected environment credentials are ready.

Replace GitHub environment credentials by updating the protected `android-release` environment values only.

Retain or revoke old material according to Google Play signing and upload-key requirements and the owner-approved Play Console procedure.

Key rotation must not occur automatically.

Google Play App Signing and upload-key recovery must be handled through owner-approved Play Console procedures.

Do not claim Google Play App Signing is enabled unless it has been verified separately.

## Evidence boundaries

Allowed repository evidence:

- credential names;
- workflow run IDs;
- commit SHA;
- app version or build number;
- artifact filename;
- checksum;
- environment name;
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

The release implementation task should not start until all of the following are true:

- `android-release` environment exists.
- Required reviewer protection exists.
- All four credential names exist at environment level.
- The owner confirms backup and recovery ownership.
- PR CI remains green.
- No signing material is present in the repository.
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
