import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads production content package from default asset path', () async {
    final package = await const ContentLoader().load();

    expect(package.metadata.packageId, 'nurtly-core-en');
    expect(package.metadata.schemaVersion, 1);
    expect(package.metadata.version, '1.7.0');
    expect(package.metadata.locale, 'en');
    expect(_isNotBlank(package.metadata.publishedAt), isTrue);
    expect(DateTime.tryParse(package.metadata.publishedAt), isNotNull);
    expect(_isNotBlank(package.metadata.minAppVersion), isTrue);
    expect(package.playIdeas, hasLength(50));
    expect(package.playFilters, hasLength(7));
    expect(package.sounds, hasLength(6));
    expect(package.playIdeas.first.neededItems, contains('Soft cloth'));
    expect(package.playIdeas.first.steps, hasLength(3));
  });

  test('content metadata fields are production ready', () async {
    final package = await const ContentLoader().load();
    final metadata = package.metadata;

    expect(_isNotBlank(metadata.packageId), isTrue);
    expect(metadata.schemaVersion, 1);
    expect(_isNotBlank(metadata.version), isTrue);
    expect(_isNotBlank(metadata.locale), isTrue);
    expect(_isNotBlank(metadata.publishedAt), isTrue);
    expect(DateTime.tryParse(metadata.publishedAt), isNotNull);
    expect(_isNotBlank(metadata.minAppVersion), isTrue);
    expect(metadata.locale, 'en');
  });

  test('loads content from a custom content source', () async {
    final package = await const ContentLoader(
      source: _RawContentSource(_minimalContentPackageJson),
    ).load();

    expect(package.metadata.packageId, 'test-package');
    expect(package.playIdeas.single.id, 'play_test_idea');
    expect(package.playFilters.single.id, 'low_effort');
    expect(package.sounds.single.id, 'sound_test_sound');
    expect(package.sounds.single.artworkAssetPath,
        'assets/images/sounds/test_sound.webp');
  });

  test('missing sound artworkAssetPath parses as null', () async {
    final package = await const ContentLoader(
      source: _RawContentSource(_minimalContentPackageWithoutFiltersJson),
    ).load();

    expect(package.sounds.single.artworkAssetPath, isNull);
  });

  test('missing contexts parses as an empty list', () async {
    final package = await const ContentLoader(
      source: _RawContentSource(_minimalContentPackageWithoutContextsJson),
    ).load();

    expect(package.playIdeas.single.contexts, isEmpty);
  });

  test('missing suggestedSoundId parses as null', () async {
    final package = await const ContentLoader(
      source:
          _RawContentSource(_minimalContentPackageWithoutSuggestedSoundJson),
    ).load();

    expect(package.playIdeas.single.suggestedSoundId, isNull);
  });

  test('missing ageRangeMonths throws FormatException', () async {
    final loader = ContentLoader(
      source:
          _RawContentSource(_minimalContentPackageWithoutAgeRangeMonthsJson),
    );

    await expectLater(loader.load(), throwsFormatException);
  });

  test('invalid ageRangeMonths throws FormatException', () async {
    final loader = ContentLoader(
      source: _RawContentSource(_minimalContentPackageWithInvalidAgeRangeJson),
    );

    await expectLater(loader.load(), throwsFormatException);
  });

  test('missing playFilters parses as an empty list', () async {
    final package = await const ContentLoader(
      source: _RawContentSource(_minimalContentPackageWithoutFiltersJson),
    ).load();

    expect(package.playFilters, isEmpty);
  });

  test('malformed custom content source throws FormatException', () async {
    const loader = ContentLoader(
      source: _RawContentSource('{not-json'),
    );

    await expectLater(loader.load(), throwsFormatException);
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

  test('play filters are valid and include expected labels', () async {
    final package = await const ContentLoader().load();
    const supportedFields = {
      'parentInvolvement',
      'messLevel',
      'ageRangeMonths',
      'activityType',
      'childEngagement',
      'place',
      'contexts',
    };
    const supportedOperators = {'equals', 'contains', 'overlaps'};
    const expectedLabels = {
      'Low effort',
      'Low mess',
      'For babies',
      'Toddlers',
      'Preschool',
      'Movement',
      'Quiet',
    };

    expect(package.playFilters, isNotEmpty);

    final ids = package.playFilters.map((filter) => filter.id).toList();
    final labels = package.playFilters.map((filter) => filter.label).toSet();

    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, id.toLowerCase());
      expect(id, matches(r'^[a-z0-9_]+$'));
    }
    expect(labels, containsAll(expectedLabels));

    for (final filter in package.playFilters) {
      expect(_isNotBlank(filter.label), isTrue, reason: '${filter.id} label');
      expect(filter.rules, isNotEmpty, reason: '${filter.id} rules');
      expect(filter.matchMode.name, anyOf('all', 'any'));
      for (final rule in filter.rules) {
        expect(supportedFields, contains(rule.field),
            reason: '${filter.id} field');
        expect(supportedOperators, contains(rule.operator),
            reason: '${filter.id} operator');
        if (rule.operator == 'overlaps') {
          expect(rule.min, isNotNull, reason: '${filter.id} overlaps min');
          expect(rule.max, isNotNull, reason: '${filter.id} overlaps max');
        } else {
          expect(_isNotBlank(rule.value ?? ''), isTrue,
              reason: '${filter.id} value');
        }
      }
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
    final soundIds = package.sounds.map((sound) => sound.id).toSet();

    for (final idea in package.playIdeas) {
      expect(_isNotBlank(idea.id), isTrue, reason: '${idea.id} id');
      expect(_isNotBlank(idea.title), isTrue, reason: '${idea.id} title');
      expect(_isNotBlank(idea.summary), isTrue, reason: '${idea.id} summary');
      expect(_isNotBlank(idea.ageGroup), isTrue, reason: '${idea.id} ageGroup');
      expect(idea.ageRangeMonths.min, greaterThanOrEqualTo(0),
          reason: '${idea.id} ageRangeMonths min');
      expect(idea.ageRangeMonths.max,
          greaterThanOrEqualTo(idea.ageRangeMonths.min),
          reason: '${idea.id} ageRangeMonths max>=min');
      expect(idea.ageRangeMonths.max, lessThanOrEqualTo(96),
          reason: '${idea.id} ageRangeMonths max');
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
      expect(idea.contexts, isNotEmpty, reason: '${idea.id} contexts');
      expect(idea.neededItems, isNotEmpty, reason: '${idea.id} neededItems');
      expect(idea.steps, isNotEmpty, reason: '${idea.id} steps');
      expect(
        _isNotBlank(idea.whatToExpect),
        isTrue,
        reason: '${idea.id} whatToExpect',
      );
      expect(
        idea.whatToExpect.length,
        lessThanOrEqualTo(260),
        reason: '${idea.id} whatToExpect length',
      );
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
      if (idea.suggestedSoundId != null) {
        expect(soundIds, contains(idea.suggestedSoundId),
            reason: '${idea.id} suggestedSoundId exists');
      }
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

  test('play idea contexts are controlled and well formed', () async {
    final package = await const ContentLoader().load();
    const allowedContexts = {
      'home',
      'baby',
      'toddler',
      'preschool',
      'low_setup',
      'quiet',
      'movement',
      'sensory',
      'connection',
      'practical_life',
      'outside',
      'bathroom',
      'kitchen',
      'transition',
      'pretend',
    };

    for (final idea in package.playIdeas) {
      expect(idea.contexts.length, lessThanOrEqualTo(5),
          reason: '${idea.id} contexts length');
      expect(idea.contexts.toSet(), hasLength(idea.contexts.length),
          reason: '${idea.id} duplicate contexts');
      for (final context in idea.contexts) {
        expect(context, context.toLowerCase(),
            reason: '${idea.id} context lowercase');
        expect(context, matches(r'^[a-z0-9_]+$'),
            reason: '${idea.id} context snake_case');
        expect(allowedContexts, contains(context),
            reason: '${idea.id} allowed context');
      }
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
        idea.whatToExpect,
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

  test('play idea whatToExpect values are distinct', () async {
    final package = await const ContentLoader().load();
    final values = package.playIdeas
        .map((idea) => idea.whatToExpect.trim().toLowerCase())
        .toList();

    expect(values.toSet(), hasLength(values.length));
  });

  test('sounds have local mp3 assets and non-placeholder copy', () async {
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
      expect(sound.assetPath, startsWith('assets/audio/'));
      expect(sound.assetPath, endsWith('.mp3'));
      expect(sound.artworkAssetPath, isNull);
      expect(sound.summary.toLowerCase(), isNot(contains('placeholder')));
      expect(sound.summary.toLowerCase(), isNot(contains('future')));
      expect(sound.unlockType, 'free');
    }
  });
}

bool _isNotBlank(String value) => value.trim().isNotEmpty;

class _RawContentSource implements ContentSource {
  const _RawContentSource(this.content);

  final String content;

  @override
  Future<String> loadRawContent() async => content;
}

const _minimalContentPackageJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 24,
        "max": 60
      },
      "place": "Home",
      "messLevel": "Low",
      "childEngagement": "Low",
      "parentInvolvement": "Low",
      "activityType": "Quiet time",
      "contexts": ["home", "quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "Low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "artworkAssetPath": "assets/images/sounds/test_sound.webp",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithoutFiltersJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 24,
        "max": 60
      },
      "place": "Home",
      "messLevel": "Low",
      "childEngagement": "Low",
      "parentInvolvement": "Low",
      "activityType": "Quiet time",
      "contexts": ["home", "quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithoutContextsJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 24,
        "max": 60
      },
      "place": "Home",
      "messLevel": "Low",
      "childEngagement": "Low",
      "parentInvolvement": "Low",
      "activityType": "Quiet time",
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "Low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithoutAgeRangeMonthsJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "place": "Home",
      "messLevel": "Low",
      "childEngagement": "Low",
      "parentInvolvement": "Low",
      "activityType": "Quiet time",
      "contexts": ["home", "quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "Low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithoutSuggestedSoundJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 24,
        "max": 60
      },
      "place": "Home",
      "messLevel": "Low",
      "childEngagement": "Low",
      "parentInvolvement": "Low",
      "activityType": "Quiet time",
      "contexts": ["home", "quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "Low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithInvalidAgeRangeJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 36,
        "max": 24
      },
      "place": "Home",
      "messLevel": "Low",
      "childEngagement": "Low",
      "parentInvolvement": "Low",
      "activityType": "Quiet time",
      "contexts": ["home", "quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "Low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';
