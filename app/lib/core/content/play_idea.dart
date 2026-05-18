class PlayIdea {
  const PlayIdea({
    required this.id,
    required this.title,
    required this.summary,
    required this.ageGroup,
    required this.place,
    required this.messLevel,
    required this.childEngagement,
    required this.parentInvolvement,
    required this.activityType,
    required this.neededItems,
    required this.steps,
    required this.parentNote,
    required this.safetyNote,
  });

  final String id;
  final String title;
  final String summary;
  final String ageGroup;
  final String place;
  final String messLevel;
  final String childEngagement;
  final String parentInvolvement;
  final String activityType;
  final List<String> neededItems;
  final List<String> steps;
  final String parentNote;
  final String safetyNote;

  factory PlayIdea.fromJson(Map<String, Object?> json) {
    return PlayIdea(
      id: _readString(json, 'id'),
      title: _readString(json, 'title'),
      summary: _readString(json, 'summary'),
      ageGroup: _readString(json, 'ageGroup'),
      place: _readString(json, 'place'),
      messLevel: _readString(json, 'messLevel'),
      childEngagement: _readString(json, 'childEngagement'),
      parentInvolvement: _readString(json, 'parentInvolvement'),
      activityType: _readString(json, 'activityType'),
      neededItems: _readStringList(json, 'neededItems'),
      steps: _readStringList(json, 'steps'),
      parentNote: _readString(json, 'parentNote'),
      safetyNote: _readString(json, 'safetyNote'),
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

List<String> _readStringList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is List && value.every((item) => item is String)) {
    return List<String>.unmodifiable(value.cast<String>());
  }
  throw FormatException('Expected string list field "$key".');
}
