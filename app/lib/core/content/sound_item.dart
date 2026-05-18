class SoundItem {
  const SoundItem({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.assetPath,
    required this.unlockType,
  });

  final String id;
  final String title;
  final String category;
  final String summary;
  final String assetPath;
  final String unlockType;

  factory SoundItem.fromJson(Map<String, Object?> json) {
    return SoundItem(
      id: _readString(json, 'id'),
      title: _readString(json, 'title'),
      category: _readString(json, 'category'),
      summary: _readString(json, 'summary'),
      assetPath: _readString(json, 'assetPath'),
      unlockType: _readString(json, 'unlockType'),
    );
  }
}

String _readString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Expected non-empty string field "$key".');
}
