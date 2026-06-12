# Android release signing

Nurtly uses Google Play App Signing for release distribution. The keystore you keep locally is the upload key only; Google keeps the app signing key.

## Recommended workflow

1. Let Google Play App Signing manage the app signing key.
2. Generate one local upload keystore for your machine.
3. Keep the keystore and passwords outside git.
4. Store release credentials in `app/android/key.properties`.

## Local files

Expected local file:

- `app/android/key.properties`

Optional local upload keystore file:

- `app/android/upload-keystore.jks`

Never commit the `.jks`, `.keystore`, or private credential files.

Before building a release AAB, confirm the local signing files exist and are not tracked by git:

```powershell
Test-Path app\android\key.properties
Test-Path app\android\upload-keystore.jks
git status --short
```

For a non-secret local preflight check, use [Closed-testing release candidate runbook](closed_testing_release_candidate_runbook.md) together with `tools/release_preflight_check.ps1`.

## `key.properties` fields

Use these properties:

```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=upload
storeFile=upload-keystore.jks
```

`storeFile` is resolved relative to `C:\Serwer\Projekty\Nurtly\app\android`.

## Create an upload keystore locally

From PowerShell in `C:\Serwer\Projekty\Nurtly\app\android`:

```powershell
keytool -genkeypair -v `
  -keystore upload-keystore.jks `
  -alias upload `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000
```

You will be prompted for keystore and key passwords. Keep them private.

## Build a release AAB

From `C:\Serwer\Projekty\Nurtly`:

```powershell
powershell -ExecutionPolicy Bypass -File tools/pre_pr_check.ps1
cd app
flutter build appbundle --release
```

Expected output:

- from `C:\Serwer\Projekty\Nurtly`: `app/build/app/outputs/bundle/release/app-release.aab`
- from `C:\Serwer\Projekty\Nurtly\app`: `build/app/outputs/bundle/release/app-release.aab`

## Verify the AAB path

After the build, confirm the file exists from the repo root:

```powershell
Test-Path app\build\app\outputs\bundle\release\app-release.aab
```

## Rotate or recreate the upload key

If an upload key is lost or needs replacement, use Google Play Console upload key reset/rotation flow. Do not create a new app signing key locally; Google manages the app signing key.

## Notes

- Debug builds are unchanged.
- This repo intentionally does not store sensitive release values.
- Release builds should use the local `key.properties` file when present.
- For the closed-testing upload handoff, use the output path and pre-checks documented in [Closed-testing upload handoff](closed_testing_upload_handoff.md).
