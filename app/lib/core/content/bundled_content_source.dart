import 'package:flutter/services.dart';

import '../localization/app_language.dart';
import 'content_source.dart';

const defaultContentAssetPath = 'assets/content/nurtly_content_en_v1.json';

String bundledContentAssetPathFor(AppLanguage language) {
  return switch (language) {
    AppLanguage.english => 'assets/content/nurtly_content_en_v1.json',
    AppLanguage.polish => 'assets/content/nurtly_content_pl_v1.json',
  };
}

class BundledContentSource implements ContentSource {
  const BundledContentSource({
    this.language = AppLanguage.english,
  });

  final AppLanguage language;

  @override
  Future<String> loadRawContent() {
    return rootBundle.loadString(bundledContentAssetPathFor(language));
  }
}
