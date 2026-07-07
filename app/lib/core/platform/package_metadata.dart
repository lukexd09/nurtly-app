import 'package:flutter/services.dart';

class PackageMetadata {
  const PackageMetadata({
    required this.version,
    required this.buildNumber,
  });

  static const MethodChannel _channel =
      MethodChannel('nurtly/package_metadata');

  final String version;
  final String buildNumber;

  static Future<PackageMetadata> fromPlatform() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'getPackageMetadata',
    );
    if (result == null) {
      throw StateError('Package metadata unavailable');
    }
    final version = (result['versionName'] ?? '').toString();
    final buildNumber = (result['versionCode'] ?? '').toString();
    if (version.isEmpty) {
      throw StateError('Package metadata version unavailable');
    }
    return PackageMetadata(version: version, buildNumber: buildNumber);
  }
}
