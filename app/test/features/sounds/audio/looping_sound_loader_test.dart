import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nurtly/features/sounds/audio/looping_sound_loader.dart';

void main() {
  test('buildGaplessLoopSources duplicates the same local file uri', () {
    final uri = Uri.file('C:/temp/soft_rain_loop.ogg');

    final sources = buildGaplessLoopSources(uri);

    expect(sources, hasLength(2));
    expect(sources[0], isA<AudioSource>());
    expect(sources[1], isA<AudioSource>());
    expect(identical(sources[0], sources[1]), isFalse);
  });
}
