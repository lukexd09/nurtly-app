import 'package:flutter/services.dart';

import 'content_source.dart';

const defaultContentAssetPath = 'assets/content/nurtly_content_en_v1.json';

class BundledContentSource implements ContentSource {
  const BundledContentSource({
    this.assetPath = defaultContentAssetPath,
  });

  final String assetPath;

  @override
  Future<String> loadRawContent() {
    return rootBundle.loadString(assetPath);
  }
}
