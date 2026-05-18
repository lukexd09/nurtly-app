import 'package:flutter/material.dart';

import 'app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_shell.dart';

void main() {
  runApp(const NurtlyApp());
}

class NurtlyApp extends StatelessWidget {
  const NurtlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
