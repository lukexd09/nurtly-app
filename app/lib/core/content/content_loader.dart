import 'dart:convert';

import 'package:flutter/services.dart';

import 'content_package.dart';

class ContentLoader {
  const ContentLoader({
    this.assetPath = 'assets/content/nurtly_content_en_v1.json',
  });

  final String assetPath;

  Future<ContentPackage> load() async {
    final content = await rootBundle.loadString(assetPath);
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
