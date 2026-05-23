import 'package:just_audio/just_audio.dart';

const int loopingSoundPlaylistCopies = 3;

/// Repeats identical sources to reduce the audible loop gap seen with
/// single-source LoopMode.one, while preserving the current MVP behavior.
Future<void> loadLoopingSoundAsset(
  AudioPlayer player,
  String assetPath,
) async {
  await player.setAudioSources(
    List<AudioSource>.generate(
      loopingSoundPlaylistCopies,
      (_) => AudioSource.asset(assetPath),
    ),
    initialIndex: 0,
    initialPosition: Duration.zero,
  );
  await player.setLoopMode(LoopMode.all);
}
