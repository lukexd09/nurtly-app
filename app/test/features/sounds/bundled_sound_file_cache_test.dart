import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/features/sounds/audio/bundled_sound_file_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('materializes bundled asset to app-private storage and caches it',
      () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'nurtly-sound-cache-test',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final cache = BundledSoundFileCache(
      directoryProvider: () async => tempDir,
    );

    final firstPath = await cache.materialize('assets/audio/soft_rain.mp3');
    final firstFile = File(firstPath);

    expect(firstPath, startsWith(tempDir.path));
    expect(firstPath, contains('assets_audio_soft_rain.mp3'));
    expect(await firstFile.exists(), isTrue);
    expect(await firstFile.length(), greaterThan(0));

    final secondPath = await cache.materialize('assets/audio/soft_rain.mp3');
    expect(secondPath, firstPath);
  });
}
