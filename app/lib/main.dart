import 'package:flutter/material.dart';

import 'app_config.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7D9B76),
        ).copyWith(surface: const Color(0xFFFFFBF2)),
        scaffoldBackgroundColor: const Color(0xFFFFFBF2),
        useMaterial3: true,
      ),
      home: const PlaceholderHomeScreen(),
    );
  }
}

class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AccentMark(),
                SizedBox(height: 24),
                _AppTitle(),
                SizedBox(height: 12),
                _AppSubtitle(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccentMark extends StatelessWidget {
  const _AccentMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF7D9B76),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      appName,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: const Color(0xFF354235),
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _AppSubtitle extends StatelessWidget {
  const _AppSubtitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      appSubtitle,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF526052),
            height: 1.4,
          ),
    );
  }
}
