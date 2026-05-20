import 'content_package.dart';

const supportedContentSchemaVersion = 1;
const supportedContentLocale = 'en';

void validateContentCompatibility(ContentPackage package) {
  final metadata = package.metadata;

  if (metadata.schemaVersion != supportedContentSchemaVersion) {
    throw FormatException(
      'Unsupported content schemaVersion "${metadata.schemaVersion}".',
    );
  }
  if (metadata.locale != supportedContentLocale) {
    throw FormatException('Unsupported content locale "${metadata.locale}".');
  }
  if (metadata.packageId.trim().isEmpty) {
    throw const FormatException('Content packageId must not be empty.');
  }
  if (metadata.version.trim().isEmpty) {
    throw const FormatException('Content version must not be empty.');
  }
  if (metadata.minAppVersion.trim().isEmpty) {
    throw const FormatException('Content minAppVersion must not be empty.');
  }
  if (DateTime.tryParse(metadata.publishedAt) == null) {
    throw FormatException(
      'Content publishedAt must be an ISO date: "${metadata.publishedAt}".',
    );
  }
}
