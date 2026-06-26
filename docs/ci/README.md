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
- Manual merge is still required
- Flutter: `3.41.9`
- Bundled Dart: `3.11.5`
- Java: Temurin `17`
- Required job / check name: `PR CI gate`
- Workflow sequence: checkout, Java, Flutter, Java/Flutter/Dart version prints, dependency resolution, lockfile drift check, formatting, analyzer, full test suite, scope guard, debug Android APK build, repository-wide tracked-file integrity check
- `actions/checkout` pinned to `v7.0.0` via full SHA
- `actions/setup-java` pinned to `v5.4.0` via full SHA
- `subosito/flutter-action` pinned to `v2.23.0` via full SHA
- CI enforces the committed lockfile with `flutter pub get --enforce-lockfile` and `git diff --exit-code -- pubspec.lock`
- Formatting uses `dart format --output=none --set-exit-if-changed .`
- Tests use `flutter test --reporter expanded`
- Android output is a clean unsigned debug APK at `app/build/app/outputs/flutter-apk/app-debug.apk`
- Signing and Play credentials: not included
- Local Java verification is unavailable in this Codex environment
- GitHub Actions provides Temurin Java 17 independently
- Local CI runs do not replace GitHub CI evidence or manual QA

Deferred to later issues:

- #193: branch protection

## Failure triage

When a CI run fails, capture:

1. workflow run ID and URL;
2. head SHA;
3. job and failing step;
4. first real root-cause log line;
5. whether the failure is deterministic or transient infrastructure-related.

## Local Windows parity

Start from `C:\Projekty\Nurtly`.

```powershell
cd C:\Projekty\Nurtly
git status --short
git branch --show-current
git fetch origin
git rev-parse origin/main
git log -1 --oneline origin/main
gh pr view 202 --json state,headRefName,headRefOid,url

cd app
flutter pub get --enforce-lockfile
git diff --exit-code -- pubspec.lock
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --reporter expanded
flutter build apk --debug --no-pub
cd ..

pwsh -NoLogo -NoProfile -File .\tools\check_scope_guard.ps1
git diff --exit-code
```

The direct non-mutating commands above are the authoritative CI parity path.

## Existing scripts

- `tools/verify_flutter.ps1` runs mutating `dart format .`
- `tools/pre_pr_check.ps1` runs Flutter verification, cleanup, scope guard and quality checks, then checks repository cleanliness
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

## #193 preparation

- required check candidate is `PR CI gate`
- #193 will configure or verify branch protection
- branch protection is not yet configured
- auto-merge remains disabled

Do not weaken the workflow to hide a failure.
Do not treat local success as a substitute for GitHub CI.
Do not infer manual device QA from CI.
