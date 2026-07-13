# Android backup and device-transfer policy

Issue: #179

This change makes Android backup behavior explicit for all Nurtly-owned local data.

## Current local-data inventory

The repo inspection found three durable app-owned stores backed by SharedPreferences:

| Area | Store key | Contents |
| --- | --- | --- |
| Journal | `nurtly_journal_entries_v1` | Local journal entries |
| Saved language | `nurtly.selected_language` | Saved app language choice |
| Reviewer access | `nurtly.reviewer_access_enabled` | Reviewer access flag |

The sounds module also writes bundled audio files into `Directory.systemTemp`, which is an ephemeral cache location rather than durable app backup storage.

## Android-version behavior

- Android 11 and lower use `android:fullBackupContent="@xml/backup_rules"`.
- Android 12 and higher use `android:dataExtractionRules="@xml/data_extraction_rules"`.
- Both rule sets exclude the standard app-data domains, including `sharedpref`, so no Nurtly-owned local data is included in cloud backup or device-to-device transfer.

## Files changed

- `app/android/app/src/main/AndroidManifest.xml`
- `app/android/app/src/main/res/xml/backup_rules.xml`
- `app/android/app/src/main/res/xml/data_extraction_rules.xml`

## Verification

- Manifest and XML files were checked locally for structure and rule references.
- `git diff --check` was run after the edits.
- `git status --short` was run after the edits.

## Out of scope

- No Dart app code changed.
- No privacy UI or user-facing strings changed.
- No journal implementation changed.
- No legal or final release blocker docs changed.
