import 'dart:convert';

import 'bundled_content_source.dart';
import 'content_package.dart';
import 'content_source.dart';

class ContentLoader {
  const ContentLoader({
    this.source = const BundledContentSource(),
  });

  final ContentSource source;

  Future<ContentPackage> load() async {
    final content = await source.loadRawContent();
    final decoded = jsonDecode(content);

    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Content package root must be an object.');
    }

    try {
      return ContentPackage.fromJson(decoded);
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('Malformed content package: $error');
    }
  }
}
