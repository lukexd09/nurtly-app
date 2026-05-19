import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_note.dart';
import '../../core/widgets/detail_section.dart';
import '../../core/widgets/section_header.dart';

class PrivacyDataScreen extends StatelessWidget {
  const PrivacyDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back',
                color: AppColors.primary,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const SectionHeader(
              title: 'Privacy & Data',
              subtitle: 'What Nurtly does with data in this MVP.',
            ),
            const SizedBox(height: AppSpacing.lg),
            const DetailSection(
              title: 'Current MVP behavior',
              children: [
                _PrivacyLine('No account is used.'),
                _PrivacyLine(
                  'Journal notes are currently kept only in this app session as a local in-memory prototype.',
                ),
                _PrivacyLine('No cloud sync is currently enabled.'),
                _PrivacyLine('No analytics are currently enabled.'),
                _PrivacyLine('No ads are currently enabled.'),
                _PrivacyLine(
                  'Bundled sample content is included in the app.',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const DetailNote(
              title: 'Future changes',
              text:
                  'Future data-related changes should be introduced clearly before they are enabled.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyLine extends StatelessWidget {
  const _PrivacyLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text('- $text', style: AppTextStyles.body);
  }
}
