import 'package:just_audio/just_audio.dart';

/// Loads a single bundled asset source for the sound player.
Future<void> loadLoopingSoundAsset(
  AudioPlayer player,
  String assetPath,
) async {
  await player.setAsset(assetPath, preload: false);
  await player.setLoopMode(LoopMode.one);
}
