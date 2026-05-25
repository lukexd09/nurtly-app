import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_repository.dart';
import 'package:nurtly/core/content/content_source.dart';
import 'package:nurtly/core/content/remote_content_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled repository strategy loads bundled content', () async {
    final package = await const ContentRepository.bundled().load();

    expect(package.metadata.packageId, 'nurtly-core-en');
  });

  test('returns primary package when primary is valid', () async {
    final repository = ContentRepository(
      primaryLoader: ContentLoader(
        source: _RawContentSource(_primaryPackageJson),
      ),
      fallbackLoader: ContentLoader(
        source: _RawContentSource(_fallbackPackageJson),
      ),
    );

    final package = await repository.load();

    expect(package.metadata.packageId, 'primary-package');
  });

  test('falls back when primary throws', () async {
    final repository = ContentRepository(
      primaryLoader: const ContentLoader(source: _ThrowingContentSource()),
      fallbackLoader: ContentLoader(
        source: _RawContentSource(_fallbackPackageJson),
      ),
    );

    final package = await repository.load();

    expect(package.metadata.packageId, 'fallback-package');
  });

  test('falls back when primary schemaVersion is unsupported', () async {
    final repository = ContentRepository(
      primaryLoader: ContentLoader(
        source: _RawContentSource(_unsupportedSchemaPackageJson),
      ),
      fallbackLoader: ContentLoader(
        source: _RawContentSource(_fallbackPackageJson),
      ),
    );

    final package = await repository.load();

    expect(package.metadata.packageId, 'fallback-package');
  });

  test('throws FormatException when primary and fallback fail', () async {
    final repository = ContentRepository(
      primaryLoader: const ContentLoader(source: _ThrowingContentSource()),
      fallbackLoader: const ContentLoader(source: _ThrowingContentSource()),
    );

    await expectLater(repository.load(), throwsFormatException);
  });

  test('RemoteContentSource uses the provided fetcher and uri', () async {
    final uri = Uri.parse('content://nurtly/core-en');
    final source = RemoteContentSource(
      uri: uri,
      fetcher: (receivedUri) async {
        expect(receivedUri, uri);
        return _primaryPackageJson;
      },
    );

    final content = await source.loadRawContent();

    expect(content, _primaryPackageJson);
  });
}

class _RawContentSource implements ContentSource {
  const _RawContentSource(this.content);

  final String content;

  @override
  Future<String> loadRawContent() async => content;
}

class _ThrowingContentSource implements ContentSource {
  const _ThrowingContentSource();

  @override
  Future<String> loadRawContent() async {
    throw const FormatException('Content source failed.');
  }
}

final _primaryPackageJson = _packageJson(
  packageId: 'primary-package',
  schemaVersion: 1,
);

final _fallbackPackageJson = _packageJson(
  packageId: 'fallback-package',
  schemaVersion: 1,
);

final _unsupportedSchemaPackageJson = _packageJson(
  packageId: 'unsupported-package',
  schemaVersion: 2,
);

String _packageJson({
  required String packageId,
  required int schemaVersion,
}) {
  return '''
{
  "metadata": {
    "packageId": "$packageId",
    "schemaVersion": $schemaVersion,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "taxonomy": $_taxonomyJson,
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
      "place": "place_home",
      "messLevel": "mess_low",
      "childEngagement": "child_engagement_low",
      "parentInvolvement": "parent_involvement_low",
      "activityType": "activity_quiet_time",
      "contexts": ["context_home", "context_quiet"],
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
          "value": "parent_involvement_low"
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
}

const _taxonomyJson = '''
{
  "places": [
    { "id": "place_home", "label": "Home" },
    { "id": "place_floor", "label": "Floor" },
    { "id": "place_kitchen", "label": "Kitchen" },
    { "id": "place_living_room", "label": "Living room" },
    { "id": "place_bedroom", "label": "Bedroom" },
    { "id": "place_outside", "label": "Outside" },
    { "id": "place_bathroom", "label": "Bathroom" },
    { "id": "place_table", "label": "Table" },
    { "id": "place_sofa", "label": "Sofa" },
    { "id": "place_window", "label": "Window" },
    { "id": "place_any_quiet_spot", "label": "Any quiet spot" },
    { "id": "place_hallway", "label": "Hallway" }
  ],
  "messLevels": [
    { "id": "mess_low", "label": "Low" },
    { "id": "mess_medium", "label": "Medium" }
  ],
  "childEngagementLevels": [
    { "id": "child_engagement_low", "label": "Low" },
    { "id": "child_engagement_medium", "label": "Medium" },
    { "id": "child_engagement_high", "label": "High" }
  ],
  "parentInvolvementLevels": [
    { "id": "parent_involvement_low", "label": "Low" },
    { "id": "parent_involvement_medium", "label": "Medium" },
    { "id": "parent_involvement_high", "label": "High" }
  ],
  "activityTypes": [
    { "id": "activity_connection", "label": "Connection" },
    { "id": "activity_fine_motor", "label": "Fine motor" },
    { "id": "activity_imaginative_play", "label": "Imaginative play" },
    { "id": "activity_language", "label": "Language" },
    { "id": "activity_movement", "label": "Movement" },
    { "id": "activity_music", "label": "Music" },
    { "id": "activity_observation", "label": "Observation" },
    { "id": "activity_practical_life", "label": "Practical life" },
    { "id": "activity_quiet_time", "label": "Quiet time" },
    { "id": "activity_sensory", "label": "Sensory" },
    { "id": "activity_sorting", "label": "Sorting" }
  ],
  "contexts": [
    { "id": "context_home", "label": "home" },
    { "id": "context_baby", "label": "baby" },
    { "id": "context_sensory", "label": "sensory" },
    { "id": "context_low_setup", "label": "low_setup" },
    { "id": "context_toddler", "label": "toddler" },
    { "id": "context_movement", "label": "movement" },
    { "id": "context_kitchen", "label": "kitchen" },
    { "id": "context_practical_life", "label": "practical_life" },
    { "id": "context_quiet", "label": "quiet" },
    { "id": "context_transition", "label": "transition" },
    { "id": "context_preschool", "label": "preschool" },
    { "id": "context_pretend", "label": "pretend" },
    { "id": "context_connection", "label": "connection" },
    { "id": "context_outside", "label": "outside" },
    { "id": "context_bathroom", "label": "bathroom" }
  ],
  "soundCategories": [
    { "id": "sound_category_calm", "label": "Calm" },
    { "id": "sound_category_home", "label": "Home" },
    { "id": "sound_category_nature", "label": "Nature" },
    { "id": "sound_category_white_noise", "label": "White noise" }
  ]
}
''';
