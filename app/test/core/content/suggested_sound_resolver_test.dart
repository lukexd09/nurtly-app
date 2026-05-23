import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/play_idea.dart';
import 'package:nurtly/core/content/sound_item.dart';
import 'package:nurtly/core/content/suggested_sound_resolver.dart';

void main() {
  test('returns matching sound when suggestedSoundId resolves', () {
    final idea = _idea(suggestedSoundId: 'sound_soft_rain');
    final sounds = [
      _sound('sound_soft_rain', title: 'Soft rain'),
      _sound('sound_warm_noise', title: 'Warm noise'),
    ];

    final resolved = resolveSuggestedSound(idea, sounds);

    expect(resolved, same(sounds.first));
  });

  test('returns null when suggestedSoundId is null', () {
    final idea = _idea();
    final sounds = [_sound('sound_soft_rain')];

    expect(resolveSuggestedSound(idea, sounds), isNull);
  });

  test('returns null when suggestedSoundId is empty', () {
    final idea = _idea(suggestedSoundId: '');
    final sounds = [_sound('sound_soft_rain')];

    expect(resolveSuggestedSound(idea, sounds), isNull);
  });

  test('returns null when suggestedSoundId is whitespace', () {
    final idea = _idea(suggestedSoundId: '   ');
    final sounds = [_sound('sound_soft_rain')];

    expect(resolveSuggestedSound(idea, sounds), isNull);
  });

  test('returns null when suggestedSoundId does not match any sound', () {
    final idea = _idea(suggestedSoundId: 'missing_sound');
    final sounds = [_sound('sound_soft_rain')];

    expect(resolveSuggestedSound(idea, sounds), isNull);
  });

  test('returns the correct sound when multiple sounds exist', () {
    final idea = _idea(suggestedSoundId: 'sound_quiet_stream');
    final sounds = [
      _sound('sound_soft_rain', title: 'Soft rain'),
      _sound('sound_quiet_stream', title: 'Quiet stream'),
      _sound('sound_warm_noise', title: 'Warm noise'),
    ];

    final resolved = resolveSuggestedSound(idea, sounds);

    expect(resolved, same(sounds[1]));
  });

  test('does not mutate input lists or objects', () {
    final idea = _idea(suggestedSoundId: 'sound_soft_rain');
    final sounds = [
      _sound('sound_soft_rain', title: 'Soft rain'),
      _sound('sound_warm_noise', title: 'Warm noise'),
    ];
    final ideaBefore = idea;
    final soundsBefore = List<SoundItem>.of(sounds);

    resolveSuggestedSound(idea, sounds);

    expect(idea, same(ideaBefore));
    expect(sounds, hasLength(soundsBefore.length));
    for (var index = 0; index < sounds.length; index++) {
      expect(sounds[index], same(soundsBefore[index]));
    }
  });
}

PlayIdea _idea({String? suggestedSoundId}) {
  return PlayIdea(
    id: 'play_test_idea',
    title: 'Test idea',
    summary: 'A calm test idea.',
    ageGroup: '2-5 years',
    ageRangeMonths: AgeRangeMonths(min: 24, max: 60),
    place: 'Home',
    messLevel: 'Low',
    childEngagement: 'Low',
    parentInvolvement: 'Low',
    activityType: 'Quiet time',
    contexts: const ['home', 'quiet'],
    neededItems: const ['Soft cloth'],
    steps: const ['Place the item nearby.'],
    whatToExpect: 'A simple test note for content loading.',
    suggestedSoundId: suggestedSoundId,
    parentNote: 'Keep it simple.',
    safetyNote: 'Use safe items.',
  );
}

SoundItem _sound(
  String id, {
  String title = 'Soft rain',
}) {
  return SoundItem(
    id: id,
    title: title,
    category: 'Nature',
    summary: 'Gentle rain for a calmer background.',
    assetPath: 'assets/audio/$id.mp3',
    unlockType: 'free',
  );
}
