import 'package:flutter/services.dart';

class PackageMetadata {
  const PackageMetadata({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildSignature,
  });

  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String buildSignature;

  static const MethodChannel _channel =
      MethodChannel('dev.fluttercommunity.plus/package_info');

  static Future<PackageMetadata> load() async {
    final values = await _channel.invokeMapMethod<String, dynamic>('getAll');
    if (values == null) {
      throw StateError('Package metadata is unavailable.');
    }
    return PackageMetadata(
      appName: values['appName'] as String? ?? '',
      packageName: values['packageName'] as String? ?? '',
      version: values['version'] as String? ?? '',
      buildNumber: values['buildNumber'] as String? ?? '',
      buildSignature: values['buildSignature'] as String? ?? '',
    );
  }
}
