import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/nurtly_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/widgets/section_header.dart';
import '../privacy/privacy_data_screen.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreenFrame(
      title: 'Play',
      subtitle: 'Simple ideas for calm, connected moments.',
      chipLabel: 'Placeholder',
      emptyTitle: 'Play ideas are not built yet',
      emptyMessage: 'This tab is ready for future screen-free activity ideas.',
    );
  }
}

class _PlaceholderScreenFrame extends StatelessWidget {
  const _PlaceholderScreenFrame({
    required this.title,
    required this.subtitle,
    required this.chipLabel,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final String title;
  final String subtitle;
  final String chipLabel;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SectionHeader(
                  title: title,
                  subtitle: subtitle,
                ),
              ),
              IconButton(
                tooltip: 'Privacy & Data',
                color: AppColors.primary,
                icon: const Icon(Icons.privacy_tip_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacyDataScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          NurtlyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NurtlyChip(label: chipLabel),
                const SizedBox(height: AppSpacing.md),
                Text(title, style: AppTextStyles.screenTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          EmptyState(
            title: emptyTitle,
            message: emptyMessage,
          ),
        ],
      ),
    );
  }
}
