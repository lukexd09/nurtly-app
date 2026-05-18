String readString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Expected non-empty string field "$key".');
}

List<String> readStringList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is List && value.every((item) => item is String)) {
    return List<String>.unmodifiable(value.cast<String>());
  }
  throw FormatException('Expected string list field "$key".');
}

Map<String, Object?> readMap(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException('Expected object field "$key".');
}

List<T> readItems<T>(
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
