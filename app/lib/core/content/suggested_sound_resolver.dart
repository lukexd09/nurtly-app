import 'play_idea.dart';
import 'sound_item.dart';

SoundItem? resolveSuggestedSound(PlayIdea idea, List<SoundItem> sounds) {
  final suggestedSoundId = idea.suggestedSoundId;
  if (suggestedSoundId == null || suggestedSoundId.trim().isEmpty) {
    return null;
  }

  for (final sound in sounds) {
    if (sound.id == suggestedSoundId) {
      return sound;
    }
  }

  return null;
}
