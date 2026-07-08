import 'package:just_audio/just_audio.dart';

import 'bundled_sound_file_cache.dart';

/// Loads a bundled sound by materializing it to app-private storage first.
Future<void> loadLoopingSoundAsset(
  AudioPlayer player,
  String assetPath,
) async {
  final cache = BundledSoundFileCache();
  final localPath = await cache.materialize(assetPath);
  final sources = buildGaplessLoopSources(Uri.file(localPath));
  await player.setAudioSource(
    // ignore: deprecated_member_use
    ConcatenatingAudioSource(
      children: sources,
      useLazyPreparation: false,
    ),
  );
  await player.setLoopMode(LoopMode.all);
}

List<AudioSource> buildGaplessLoopSources(Uri uri) {
  return List<AudioSource>.generate(
    4,
    (_) => AudioSource.uri(uri),
  );
}
