import 'package:flutter/material.dart';

import 'app_config.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/empty_state.dart';
import 'core/widgets/nurtly_card.dart';
import 'core/widgets/nurtly_chip.dart';
import 'core/widgets/primary_button.dart';
import 'core/widgets/secondary_button.dart';
import 'core/widgets/section_header.dart';

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
      home: const PlaceholderHomeScreen(),
    );
  }
}

class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const NurtlyCard(
                    child: Column(
                      children: [
                        _AccentMark(),
                        SizedBox(height: AppSpacing.lg),
                        _AppTitle(),
                        SizedBox(height: AppSpacing.sm),
                        _AppSubtitle(),
                        SizedBox(height: AppSpacing.lg),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            NurtlyChip(label: 'Calm'),
                            NurtlyChip(label: 'Practical'),
                            NurtlyChip(label: 'Parent-focused'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'A quiet foundation',
                    subtitle: 'Theme tokens and shared components are ready.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const EmptyState(
                    title: 'No feature modules yet',
                    message: 'Play, journal, sounds, and content delivery '
                        'will be added in separate tasks.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: 'Primary action', onPressed: () {}),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(label: 'Secondary action', onPressed: () {}),
                ],
              ),
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
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      appName,
      textAlign: TextAlign.center,
      style: AppTextStyles.display,
    );
  }
}

class _AppSubtitle extends StatelessWidget {
  const _AppSubtitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      appSubtitle,
      textAlign: TextAlign.center,
      style: AppTextStyles.body,
    );
  }
}
