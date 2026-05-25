import 'json_readers.dart';
import 'play_filter.dart';
import 'play_idea.dart';
import 'content_taxonomy.dart';
import 'sound_item.dart';

class ContentPackage {
  const ContentPackage({
    required this.metadata,
    required this.playIdeas,
    required this.playFilters,
    required this.sounds,
    required this.taxonomy,
  });

  final ContentMetadata metadata;
  final List<PlayIdea> playIdeas;
  final List<PlayFilter> playFilters;
  final List<SoundItem> sounds;
  final ContentTaxonomy taxonomy;

  factory ContentPackage.fromJson(Map<String, Object?> json) {
    final playFilters = json.containsKey('playFilters')
        ? readItems(json, 'playFilters', PlayFilter.fromJson)
        : const <PlayFilter>[];
    final playIdeas = readItems(json, 'playIdeas', PlayIdea.fromJson);
    final sounds = readItems(json, 'sounds', SoundItem.fromJson);
    final taxonomy = ContentTaxonomy.fromJson(readMap(json, 'taxonomy'));

    taxonomy.validatePlayIdeasAndFilters(
      playIdeas: playIdeas,
      playFilters: playFilters,
    );

    return ContentPackage(
      metadata: ContentMetadata.fromJson(readMap(json, 'metadata')),
      playIdeas: playIdeas,
      playFilters: playFilters,
      sounds: sounds,
      taxonomy: taxonomy,
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
