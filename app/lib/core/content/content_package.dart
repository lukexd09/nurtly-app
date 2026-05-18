import 'play_idea.dart';
import 'sound_item.dart';

class ContentPackage {
  const ContentPackage({
    required this.metadata,
    required this.playIdeas,
    required this.sounds,
  });

  final ContentMetadata metadata;
  final List<PlayIdea> playIdeas;
  final List<SoundItem> sounds;

  factory ContentPackage.fromJson(Map<String, Object?> json) {
    return ContentPackage(
      metadata: ContentMetadata.fromJson(_readMap(json, 'metadata')),
      playIdeas: _readItems(json, 'playIdeas', PlayIdea.fromJson),
      sounds: _readItems(json, 'sounds', SoundItem.fromJson),
    );
  }
}

class ContentMetadata {
  const ContentMetadata({
    required this.packageId,
    required this.version,
    required this.locale,
    required this.publishedAt,
  });

  final String packageId;
  final String version;
  final String locale;
  final String publishedAt;

  factory ContentMetadata.fromJson(Map<String, Object?> json) {
    return ContentMetadata(
      packageId: _readString(json, 'packageId'),
      version: _readString(json, 'version'),
      locale: _readString(json, 'locale'),
      publishedAt: _readString(json, 'publishedAt'),
    );
  }
}

Map<String, Object?> _readMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException('Expected object field "$key".');
}

List<T> _readItems<T>(
  Map<String, Object?> json,
  String key,
  T Function(Map<String, Object?> json) fromJson,
) {
  final value = json[key];
  if (value is! List) {
    throw FormatException('Expected list field "$key".');
  }

  return List<T>.unmodifiable(
    value.map((item) {
      if (item is Map<String, Object?>) {
        return fromJson(item);
      }
      throw FormatException('Expected object item in "$key".');
    }),
  );
}

String _readString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Expected non-empty string field "$key".');
}
