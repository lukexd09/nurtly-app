# Android Sounds Playback 212 Investigation

Issue `#212` reports that bundled Sounds fail to play in the Google Play Android release build.

## Symptom

- Internal Testing build `0.1.0+1` was reported to fail playback for bundled Sounds on Android release installs.
- The local repo workflow does not include a device reproduction artifact for this issue.

## Hypotheses checked

- The bundled audio files might not be real MP3 files.
- The asset paths in content JSON might not match `pubspec.yaml`.
- The asset bundle might omit one or more sound files.
- The current playlist workaround might behave differently in Android release than single-asset playback.

## Asset inventory

The `assetPath` values for Sounds in both locale files are identical:

- `assets/audio/soft_rain.mp3`
- `assets/audio/warm_noise.mp3`
- `assets/audio/quiet_stream.mp3`
- `assets/audio/evening_crickets.mp3`
- `assets/audio/room_fan.mp3`
- `assets/audio/dishwasher_hum.mp3`

All six paths are covered by `app/pubspec.yaml` via `assets/audio/`.

## Audio format evidence

All six files exist, are non-empty, and probe as MP3 containers with MP3 codec audio streams.

| File | Size | Container | Codec | Duration | Sample rate | Channels | Bitrate |
| --- | ---: | --- | --- | ---: | ---: | ---: | ---: |
| `soft_rain.mp3` | 2,162,349 | mp3 | mp3 | 90.044083 s | 48,000 Hz | 2 | 192,000 bps |
| `warm_noise.mp3` | 2,162,355 | mp3 | mp3 | 90.044082 s | 44,100 Hz | 2 | 192,000 bps |
| `quiet_stream.mp3` | 2,882,081 | mp3 | mp3 | 120.032653 s | 44,100 Hz | 2 | 192,000 bps |
| `evening_crickets.mp3` | 2,403,100 | mp3 | mp3 | 100.075102 s | 44,100 Hz | 2 | 192,000 bps |
| `room_fan.mp3` | 2,882,081 | mp3 | mp3 | 120.032653 s | 44,100 Hz | 2 | 192,000 bps |
| `dishwasher_hum.mp3` | 2,882,081 | mp3 | mp3 | 120.032653 s | 44,100 Hz | 2 | 192,000 bps |

Conclusion: the `.mp3` extensions are correct and the files are valid MP3 assets.

## Bundle inspection

- `flutter pub get --enforce-lockfile` completed successfully.
- `flutter build bundle` completed successfully.
- The generated Flutter asset bundle contains the expected sound assets.
- `AssetManifest` generation succeeded for the debug asset bundle.

## Working hypothesis

The local investigation did not reproduce a bad audio format or missing asset bundle entry.

The playlist workaround is the best candidate remaining from the local evidence, so the current fix is to load the bundled sound as a single asset with `LoopMode.one` while improving error logging so the Android release failure can be distinguished from content issues in future reports.

## Fix applied

- Switched bundled sound loading from a 3-item identical playlist to a single asset source.
- Kept looped playback behavior via `LoopMode.one`.
- Added debug-only playback error logging with exception type, `PlayerException` code/message when available, player index, asset path, and stack trace.
- Moved timer start to after playback starts successfully.
- Added tests that cover asset-path forwarding and the failure retry path without invoking native audio in widget tests.

## Automated tests

- `flutter pub get --enforce-lockfile` - PASS
- `flutter build bundle` - PASS
- `dart format --output=none --set-exit-if-changed .` - final result after fixes
- `flutter analyze` - final result after fixes
- `flutter test --reporter expanded` - final result after fixes
- `flutter test --coverage` - final result after fixes
- `flutter build apk --debug` - final result after fixes
- `flutter build apk --release` - NOT RUN / BLOCKED LOCALLY: missing `key.properties`

## Manual QA still required

- Install the release candidate on a real Android device from Google Play Internal Testing.
- Verify playback, pause, resume, loop, timer, fade-out, and recovery after a failed play attempt.
- Confirm that the Play-installed release build now plays `soft_rain.mp3` and the other bundled sounds.
- Record the final Google Play evidence separately after the next upload.
