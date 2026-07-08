import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/features/sounds/audio/looping_sound_loader.dart';

void main() {
  test('buildGaplessLoopSources duplicates the source four times', () {
    final uri = Uri.file('/tmp/soft_rain.mp3');

    final sources = buildGaplessLoopSources(uri);

    expect(sources, hasLength(4));
  });
}
