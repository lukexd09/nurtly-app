import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads production content package from default asset path', () async {
    final package = await const ContentLoader().load();

    expect(package.metadata.packageId, 'nurtly-core-en');
    expect(package.metadata.version, '1.0.0');
    expect(package.metadata.locale, 'en');
    expect(package.metadata.publishedAt, '2026-05-18');
    expect(package.playIdeas, hasLength(8));
    expect(package.sounds, hasLength(5));
    expect(package.playIdeas.first.neededItems, contains('Soft cloth'));
    expect(package.playIdeas.first.steps, hasLength(3));
  });

  test('content metadata fields are production ready', () async {
    final package = await const ContentLoader().load();
    final metadata = package.metadata;

    expect(_isNotBlank(metadata.packageId), isTrue);
    expect(_isNotBlank(metadata.version), isTrue);
    expect(_isNotBlank(metadata.locale), isTrue);
    expect(_isNotBlank(metadata.publishedAt), isTrue);
    expect(metadata.locale, 'en');
  });

  test('play idea ids and titles are unique and well formed', () async {
    final package = await const ContentLoader().load();
    final ids = package.playIdeas.map((idea) => idea.id).toList();
    final titles = package.playIdeas
        .map((idea) => idea.title.trim().toLowerCase())
        .toList();

    expect(ids.toSet(), hasLength(ids.length));
    expect(titles.toSet(), hasLength(titles.length));
    for (final id in ids) {
      expect(id, startsWith('play_'));
      expect(id, id.toLowerCase());
    }
  });

  test('sound ids are unique and well formed', () async {
    final package = await const ContentLoader().load();
    final ids = package.sounds.map((sound) => sound.id).toList();

    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, startsWith('sound_'));
      expect(id, id.toLowerCase());
    }
  });

  test('play ideas have required content fields', () async {
    final package = await const ContentLoader().load();

    for (final idea in package.playIdeas) {
      expect(_isNotBlank(idea.id), isTrue, reason: '${idea.id} id');
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

  test('play idea engagement values are controlled', () async {
    final package = await const ContentLoader().load();
    const allowedLevels = {'Low', 'Medium', 'High'};

    for (final idea in package.playIdeas) {
      expect(allowedLevels, contains(idea.messLevel),
          reason: '${idea.id} messLevel');
      expect(allowedLevels, contains(idea.childEngagement),
          reason: '${idea.id} childEngagement');
      expect(allowedLevels, contains(idea.parentInvolvement),
          reason: '${idea.id} parentInvolvement');
    }
  });

  test('play ideas avoid banned language', () async {
    final package = await const ContentLoader().load();
    const bannedTerms = [
      'diagnose',
      'treat',
      'therapy',
      'cure',
      'guaranteed',
      'milestone guarantee',
      'optimize development',
      'fix development',
      'delayed development',
      'autism',
      'ADHD',
      'medical',
    ];

    for (final idea in package.playIdeas) {
      final searchableText = [
        idea.title,
        idea.summary,
        ...idea.steps,
        idea.parentNote,
        idea.safetyNote,
      ].join(' ').toLowerCase();

      for (final term in bannedTerms) {
        expect(
          searchableText,
          isNot(contains(term.toLowerCase())),
          reason: '${idea.id} contains "$term"',
        );
      }
    }
  });

  test('sounds have required placeholder fields', () async {
    final package = await const ContentLoader().load();

    expect(package.sounds, isNotEmpty);
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
