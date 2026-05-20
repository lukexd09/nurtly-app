import 'package:flutter/material.dart';

import '../../core/navigation/app_tab.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/tappable_nurtly_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onSelectTab,
    super.key,
  });

  final ValueChanged<AppTab> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _HomeHero(
          onTap: () => onSelectTab(AppTab.play),
        ),
        const SizedBox(height: AppSpacing.lg),
        _HomeQuickLink(
          title: 'Save a small note',
          subtitle: 'Keep the moment without overthinking it.',
          icon: Icons.event_note_outlined,
          onTap: () => onSelectTab(AppTab.journal),
        ),
        const SizedBox(height: AppSpacing.md),
        _HomeQuickLink(
          title: 'Start a calming sound',
          subtitle: 'A quiet background for a softer pause.',
          icon: Icons.graphic_eq,
          onTap: () => onSelectTab(AppTab.sounds),
        ),
      ],
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadii.panelRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(38),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -26,
            top: -24,
            child: Icon(
              Icons.spa_outlined,
              color: Color(0x33E8DCC8),
              size: 132,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.secondary,
                  size: 26,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Start with one small moment',
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.surfaceBright,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Choose a gentle idea, save a quiet note, or add a calming sound when the day feels full.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primarySoft,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceBright,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: onTap,
                  child: const Text('Find a play idea'),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No pressure. Just a softer place to begin.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeQuickLink extends StatelessWidget {
  const _HomeQuickLink({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TappableNurtlyCard(
      semanticLabel: 'Open $title',
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textMuted,
            size: 16,
          ),
        ],
      ),
    );
  }
}
