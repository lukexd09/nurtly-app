import 'json_readers.dart';
import 'play_filter.dart';
import 'play_idea.dart';
import 'sound_item.dart';

class ContentPackage {
  const ContentPackage({
    required this.metadata,
    required this.playIdeas,
    required this.playFilters,
    required this.sounds,
  });

  final ContentMetadata metadata;
  final List<PlayIdea> playIdeas;
  final List<PlayFilter> playFilters;
  final List<SoundItem> sounds;

  factory ContentPackage.fromJson(Map<String, Object?> json) {
    final playFilters = json.containsKey('playFilters')
        ? readItems(json, 'playFilters', PlayFilter.fromJson)
        : const <PlayFilter>[];

    return ContentPackage(
      metadata: ContentMetadata.fromJson(readMap(json, 'metadata')),
      playIdeas: readItems(json, 'playIdeas', PlayIdea.fromJson),
      playFilters: playFilters,
      sounds: readItems(json, 'sounds', SoundItem.fromJson),
    );
  }
}

class ContentMetadata {
  const ContentMetadata({
    required this.packageId,
    required this.schemaVersion,
    required this.version,
    required this.locale,
    required this.publishedAt,
    required this.minAppVersion,
  });

  final String packageId;
  final int schemaVersion;
  final String version;
  final String locale;
  final String publishedAt;
  final String minAppVersion;

  factory ContentMetadata.fromJson(Map<String, Object?> json) {
    return ContentMetadata(
      packageId: readString(json, 'packageId'),
      schemaVersion: readInt(json, 'schemaVersion'),
      version: readString(json, 'version'),
      locale: readString(json, 'locale'),
      publishedAt: readString(json, 'publishedAt'),
      minAppVersion: readString(json, 'minAppVersion'),
    );
  }
}
