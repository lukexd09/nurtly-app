# CI

## Mobile CI workflow

- Workflow file: `.github/workflows/mobile-ci.yml`
- Workflow name: `Mobile CI`
- Job / check name: `PR CI gate`
- Trigger: pull requests to `main`
- Runner: `ubuntu-24.04`
- Timeout: `45` minutes
- Permissions: `contents: read`
- Concurrency cancels obsolete runs per pull request
- Cache is disabled
- Manual merge remains required
- Flutter: `3.41.9`
- Bundled Dart: `3.11.5`
- Java: Temurin `17`
- The workflow is pinned to complete immutable SHAs for all direct Actions references
- `actions/checkout` pinned to `v7.0.0`
- `actions/setup-java` pinned to `v5.4.0`
- `subosito/flutter-action` pinned to `v2.23.0`
- Validation scope for #190: checkout, toolchain setup, version prints, `flutter pub get`, and lockfile drift check
- The application lockfile was normalized with Flutter `3.41.9`
- The lockfile change is limited to SDK-pinned transitive test dependencies (`meta` and `test_api`)
- CI enforces the committed lockfile with `flutter pub get --enforce-lockfile` and `git diff --exit-code -- pubspec.lock`
- Signing and Play credentials: not included
- Local Android build parity requires Java 17. GitHub Actions provisions Temurin Java 17 explicitly.

## Governance docs

- [Branch protection guide](branch-protection.md)
- [Android signing strategy](../release/android_signing.md)

## #193 preparation

- The required check candidate is `PR CI gate`.
- The authoritative branch-protection guide is [Branch protection guide](branch-protection.md).
- Branch protection or repository-ruleset configuration could not be confirmed from the available API credentials.

## Local Windows parity

Start from `C:\Projekty\Nurtly`.

```powershell
cd C:\Projekty\Nurtly

git status --short
git branch --show-current
git fetch origin
git rev-parse origin/main
git log -1 --oneline origin/main

cd app
flutter pub get --enforce-lockfile
git diff --exit-code -- pubspec.lock
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
cd ..

pwsh -NoLogo -NoProfile -File .\tools\cleanup_flutter_local.ps1
pwsh -NoLogo -NoProfile -File .\tools\check_scope_guard.ps1

cd app
flutter build apk --debug --no-pub
cd ..

git diff --exit-code
```

The documented order is:

1. dependency resolution;
2. lockfile check;
3. formatting;
4. analyzer;
5. full tests;
6. cleanup generated Flutter files;
7. scope guard;
8. Android debug build;
9. repository-wide tracked-file integrity check.

Cleanup runs before the scope guard because Flutter commands can generate ignored or local platform files that the scope guard intentionally treats as generated noise.

## Existing scripts

- `tools/verify_flutter.ps1` runs mutating `dart format .`
- `tools/pre_pr_check.ps1` runs Flutter verification, cleanup, scope guard and quality checks, then checks repository cleanliness
- `tools/cleanup_flutter_local.ps1` removes generated Flutter local noise such as iOS registrant files
- `-AllowDirty` only relaxes the final clean-tree requirement
- `-AllowPlatformChanges` relaxes platform-file restrictions and requires explicit task approval
- These scripts are useful locally, but the direct non-mutating commands above match CI more closely

## Lockfile policy

- `app/pubspec.lock` is committed
- CI uses `--enforce-lockfile`
- unexpected lockfile drift fails CI
- lockfile changes must not be silently committed or restored
- record Flutter version, Dart version, `pubspec.yaml` status and the exact lockfile diff
- approved toolchain-driven changes require a second `flutter pub get` to prove deterministic resolution

## Failure categories

- Action/toolchain setup
- dependency and lockfile
- formatting
- analyzer
- tests
- scope guard
- Gradle/Android build
- infrastructure/network/cache

## Failure diagnosis

Before fixing a failure, record:

1. run ID and URL;
2. head SHA;
3. job;
4. failing step;
5. first actual root-cause log line;
6. deterministic versus transient classification.

## Rerun policy

- rerun without code change only for proven transient infrastructure or network failures
- deterministic failures require a code or config correction
- do not rerun blindly
- do not weaken checks

## Evidence and QA boundaries

- local success does not override failing GitHub CI
- green CI does not prove manual device QA
- green CI does not prove signing, Play configuration or store delivery
- manual QA must not be inferred
- owner approval and manual merge are required

Do not weaken the workflow to hide a failure.
Do not treat local success as a substitute for GitHub CI.
Do not infer manual device QA from CI.
