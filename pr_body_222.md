Refs #222
Refs #212
Refs #218
Refs #221
Related #104
Related #125
Related #216
Related #219
Related #220

Summary:
- Fixes bundled Sounds playback path for Android release builds by materializing the selected Flutter asset into app-private temp storage and playing it via `setFilePath(...)` instead of the previously failing `setAsset(...)` path.
- Preserves looping behavior with `LoopMode.one`.
- Adds installed app version/build visibility inside the existing Settings sheet as a read-only QA/support row.
- Reads the displayed version/build from installed package metadata instead of a hardcoded app constant.
- Adds focused tests for the bundled sound cache helper and the Settings version row.
- Does not bump Android versionCode; final `0.1.0+4` bump is intentionally left for a separate release PR.

Audio implementation:
- Bundled audio assets are copied/materialized into app-private temp storage before playback.
- Repeated playback reuses the copied file path when the cached file is already present.
- Looping is preserved with `LoopMode.one`.
- Playback failures still surface through the existing error handling and snackbar path.

Version visibility:
- The version/build is shown in the existing Settings sheet as a read-only `App version` row.
- Example display value: `0.1.0+3`.
- The value is read from installed package metadata, not hardcoded in app config.
- No extra dependency is required in the final implementation.

Validation:
- `flutter pub get` passed.
- `dart format .` passed.
- `dart format --output=none --set-exit-if-changed .` passed.
- `flutter analyze` passed.
- `flutter test --reporter expanded` passed.
- `powershell -NoLogo -NoProfile -File .\tools\check_scope_guard.ps1` passed.
- `powershell -NoLogo -NoProfile -File .\tools\pre_pr_check.ps1` passed.
- `git diff --check` passed.
- `git status --short` passed clean after the final pre-PR check.

Manual QA note:
- CI/local tests are not enough to close #212/#218.
- Sounds must still be verified from a Google Play-installed Android build after the final `0.1.0+4` release upload.
