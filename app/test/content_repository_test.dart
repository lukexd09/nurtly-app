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
}
