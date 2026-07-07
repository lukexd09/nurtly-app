import 'dart:io';

import 'package:flutter/services.dart';

class BundledSoundFileCache {
  const BundledSoundFileCache({
    this.directoryProvider = _systemTempDirectory,
  });

  final Future<Directory> Function() directoryProvider;

  Future<String> materialize(String assetPath) async {
    final directory = await directoryProvider();
    final file = File(_filePath(directory.path, assetPath));
    if (await file.exists() && await file.length() > 0) {
      return file.path;
    }

    final byteData = await rootBundle.load(assetPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
      flush: true,
    );
    return file.path;
  }

  String _filePath(String directoryPath, String assetPath) {
    final safeName = assetPath
        .replaceAll(RegExp(r'[:\\/]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    return '$directoryPath${Platform.pathSeparator}$safeName';
  }
}

Future<Directory> _systemTempDirectory() async => Directory.systemTemp;
