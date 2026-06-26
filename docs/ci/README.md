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
- Validation scope for #190: checkout, toolchain setup, version prints, `flutter pub get`, and lockfile drift check
- The application lockfile was normalized with Flutter `3.41.9`
- The lockfile change is limited to SDK-pinned transitive test dependencies (`meta` and `test_api`)
- CI enforces the committed lockfile with `flutter pub get --enforce-lockfile` and `git diff --exit-code -- pubspec.lock`
- Permissions: `contents: read`
- Signing and Play credentials: not included
- Local Java verification was unavailable in the current Codex environment
- GitHub Actions provides Temurin Java 17 independently
- Manual merge: still required

Deferred to later issues:

- #191: formatting, analysis, and tests
- #192: scope guard and Android build
- #193: branch protection
- #194: parity and failure-triage documentation
