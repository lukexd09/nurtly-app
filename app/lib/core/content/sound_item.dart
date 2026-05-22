import 'json_readers.dart';

class SoundItem {
  const SoundItem({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.assetPath,
    this.artworkAssetPath,
    required this.unlockType,
  });

  final String id;
  final String title;
  final String category;
  final String summary;
  final String assetPath;
  final String? artworkAssetPath;
  final String unlockType;

  factory SoundItem.fromJson(Map<String, Object?> json) {
    return SoundItem(
      id: readString(json, 'id'),
      title: readString(json, 'title'),
      category: readString(json, 'category'),
      summary: readString(json, 'summary'),
      assetPath: readString(json, 'assetPath'),
      artworkAssetPath: json['artworkAssetPath'] == null
          ? null
          : readString(json, 'artworkAssetPath'),
      unlockType: readString(json, 'unlockType'),
    );
  }
}
