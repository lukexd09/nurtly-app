import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads and parses sample published content package', () async {
    final package = await const ContentLoader().load();

    expect(package.metadata.packageId, 'nurtly_sample_content');
    expect(package.metadata.locale, 'en');
    expect(package.playIdeas, hasLength(2));
    expect(package.sounds, hasLength(2));
    expect(package.playIdeas.first.neededItems, contains('Soft cloth'));
    expect(package.playIdeas.first.steps, hasLength(3));
  });
}
