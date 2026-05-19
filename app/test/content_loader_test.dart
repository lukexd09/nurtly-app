import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads and parses sample published content package', () async {
    final package = await const ContentLoader().load();

    expect(package.metadata.packageId, 'nurtly_sample_content');
    expect(package.metadata.locale, 'en');
    expect(package.playIdeas, hasLength(8));
    expect(package.sounds, hasLength(5));
    expect(package.playIdeas.first.neededItems, contains('Soft cloth'));
    expect(package.playIdeas.first.steps, hasLength(3));
  });

  test('sample play idea ids are unique and well formed', () async {
    final package = await const ContentLoader().load();
    final ids = package.playIdeas.map((idea) => idea.id).toList();

    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, startsWith('play_'));
      expect(id, id.toLowerCase());
    }
  });

  test('sample sound ids are unique and well formed', () async {
    final package = await const ContentLoader().load();
    final ids = package.sounds.map((sound) => sound.id).toList();

    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, startsWith('sound_'));
      expect(id, id.toLowerCase());
    }
  });

  test('sample play ideas have required content fields', () async {
    final package = await const ContentLoader().load();

    for (final idea in package.playIdeas) {
      expect(_isNotBlank(idea.title), isTrue, reason: '${idea.id} title');
      expect(_isNotBlank(idea.summary), isTrue, reason: '${idea.id} summary');
      expect(_isNotBlank(idea.ageGroup), isTrue, reason: '${idea.id} ageGroup');
      expect(_isNotBlank(idea.place), isTrue, reason: '${idea.id} place');
      expect(_isNotBlank(idea.messLevel), isTrue,
          reason: '${idea.id} messLevel');
      expect(
        _isNotBlank(idea.childEngagement),
        isTrue,
        reason: '${idea.id} childEngagement',
      );
      expect(
        _isNotBlank(idea.parentInvolvement),
        isTrue,
        reason: '${idea.id} parentInvolvement',
      );
      expect(
        _isNotBlank(idea.activityType),
        isTrue,
        reason: '${idea.id} activityType',
      );
      expect(idea.neededItems, isNotEmpty, reason: '${idea.id} neededItems');
      expect(idea.steps, isNotEmpty, reason: '${idea.id} steps');
      expect(
        _isNotBlank(idea.parentNote),
        isTrue,
        reason: '${idea.id} parentNote',
      );
      expect(
        _isNotBlank(idea.safetyNote),
        isTrue,
        reason: '${idea.id} safetyNote',
      );
    }
  });

  test('sample sounds have required placeholder fields', () async {
    final package = await const ContentLoader().load();

    for (final sound in package.sounds) {
      expect(_isNotBlank(sound.title), isTrue, reason: '${sound.id} title');
      expect(_isNotBlank(sound.category), isTrue,
          reason: '${sound.id} category');
      expect(_isNotBlank(sound.summary), isTrue, reason: '${sound.id} summary');
      expect(_isNotBlank(sound.assetPath), isTrue,
          reason: '${sound.id} assetPath');
      expect(_isNotBlank(sound.unlockType), isTrue,
          reason: '${sound.id} unlockType');
      expect(sound.assetPath, startsWith('placeholder://sounds/'));
      expect(sound.unlockType, 'free');
    }
  });
}

bool _isNotBlank(String value) => value.trim().isNotEmpty;
