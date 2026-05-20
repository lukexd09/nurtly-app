import 'content_compatibility.dart';
import 'content_loader.dart';
import 'content_package.dart';

class ContentRepository {
  const ContentRepository({
    required this.primaryLoader,
    required this.fallbackLoader,
  });

  const ContentRepository.bundled()
      : primaryLoader = const ContentLoader(),
        fallbackLoader = const ContentLoader();

  final ContentLoader primaryLoader;
  final ContentLoader fallbackLoader;

  Future<ContentPackage> load() async {
    Object? primaryError;

    try {
      final package = await primaryLoader.load();
      validateContentCompatibility(package);
      return package;
    } catch (error) {
      primaryError = error;
    }

    try {
      final package = await fallbackLoader.load();
      validateContentCompatibility(package);
      return package;
    } catch (fallbackError) {
      throw FormatException(
        'Content primary and fallback loading failed. '
        'Primary: $primaryError. Fallback: $fallbackError.',
      );
    }
  }
}
