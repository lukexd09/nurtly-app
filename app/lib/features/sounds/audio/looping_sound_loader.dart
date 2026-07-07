import 'package:just_audio/just_audio.dart';

import 'bundled_sound_file_cache.dart';

/// Loads a bundled sound by materializing it to app-private storage first.
Future<void> loadLoopingSoundAsset(
  AudioPlayer player,
  String assetPath,
) async {
  final cache = BundledSoundFileCache();
  final localPath = await cache.materialize(assetPath);
  await player.setFilePath(localPath, initialPosition: Duration.zero);
  await player.setLoopMode(LoopMode.one);
}
