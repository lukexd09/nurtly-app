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
        const SizedBox(height: AppSpacing.md),
        _GentleStartCard(
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3E5846),
            AppColors.primary,
            Color(0xFF5F735E),
          ],
        ),
        borderRadius: AppRadii.panelRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(34),
            blurRadius: 28,
            offset: const Offset(0, 16),
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
              size: 118,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(height: AppSpacing.md),
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
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.chipRadius,
                    ),
                  ),
                  onPressed: onTap,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Find a play idea'),
                      SizedBox(width: AppSpacing.sm),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No pressure, no streaks, no goals — just a softer place to begin.',
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

class _GentleStartCard extends StatelessWidget {
  const _GentleStartCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "Open today's idea",
      child: Material(
        color: AppColors.primarySoft,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: const BorderSide(color: AppColors.borderSoft),
        ),
        child: InkWell(
          borderRadius: AppRadii.cardRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A gentle start for now',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Try one simple, screen-free moment before the day gets louder.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Open today's idea",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Icon(
                  Icons.arrow_forward,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
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
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
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
