# CI

## Mobile CI workflow

- Workflow file: `.github/workflows/mobile-ci.yml`
- Workflow name: `Mobile CI`
- Job / check name: `PR CI gate`
- Trigger: pull requests to `main`
- Runner: `ubuntu-24.04`
- Flutter: `3.41.9` on `stable`
- Bundled Dart: `3.11.5`
- Java: `temurin` 17
- Required job / check name: `PR CI gate`
- Workflow sequence: checkout, Java, Flutter, Java/Flutter/Dart version prints, dependency resolution, lockfile drift check, formatting, analyzer, full test suite, scope guard, debug Android APK build, tracked-file integrity check
- `actions/checkout` pinned to `v6.0.3` via full SHA
- `actions/setup-java` pinned to `v5.2.0` via full SHA
- `subosito/flutter-action` pinned to `v2.23.0` via full SHA
- CI enforces the committed lockfile with `flutter pub get --enforce-lockfile` and `git diff --exit-code -- pubspec.lock`
- Formatting uses `dart format --output=none --set-exit-if-changed .`
- Tests use `flutter test --reporter expanded`
- Android output is a clean unsigned debug APK
- Permissions: `contents: read`
- Cache is disabled
- Signing and Play credentials: not included
- Local Java verification is unavailable in this Codex environment
- GitHub Actions provides Temurin Java 17 independently
- Local CI runs do not replace GitHub CI evidence or manual QA
- Manual merge: still required

Deferred to later issues:

- #191: enforced formatting, analyzer, and full test suite
- #192: scope guard and Android build
- #193: branch protection
- #194: CI parity, lockfile policy, and failure triage documentation

## Failure triage

When a CI run fails, capture:

1. workflow run ID and URL;
2. head SHA;
3. job and failing step;
4. first real root-cause log line;
5. whether the failure is deterministic or infrastructure-related.

Do not weaken the workflow to hide a failure.
Do not treat local success as a substitute for GitHub CI.
Do not infer manual device QA from CI.
