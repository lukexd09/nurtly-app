import 'package:flutter/material.dart';

import '../../core/navigation/app_tab.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/nurtly_card.dart';
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
        const _HomeHero(),
        const SizedBox(height: AppSpacing.md),
        _HomeQuickLink(
          title: 'Play ideas',
          subtitle: 'Simple screen-free ideas for calm, connected moments.',
          icon: Icons.lightbulb_outline,
          onTap: () => onSelectTab(AppTab.play),
        ),
        const SizedBox(height: AppSpacing.md),
        _HomeQuickLink(
          title: 'Journal',
          subtitle: 'Keep a small note from today.',
          icon: Icons.event_note_outlined,
          onTap: () => onSelectTab(AppTab.journal),
        ),
        const SizedBox(height: AppSpacing.md),
        _HomeQuickLink(
          title: 'Sounds',
          subtitle: 'Choose a sound for a quiet moment.',
          icon: Icons.graphic_eq,
          onTap: () => onSelectTab(AppTab.sounds),
        ),
        const SizedBox(height: AppSpacing.md),
        const NurtlyCard(
          padding: EdgeInsets.all(AppSpacing.md),
          backgroundColor: AppColors.primarySoft,
          child: Text(
            'Start with one small moment. No pressure, no streaks, no goals.',
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return const NurtlyCard(
      padding: EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.surfaceBright,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.spa_outlined,
            color: AppColors.primary,
            size: 32,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Small moments, calmly planned',
            style: AppTextStyles.screenTitle,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Find simple play ideas, keep gentle notes, and choose quiet sounds for everyday family moments.',
            style: AppTextStyles.body,
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
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
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
