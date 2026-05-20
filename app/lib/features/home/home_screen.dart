import 'package:flutter/material.dart';

import '../../core/navigation/app_tab.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

abstract final class _HomeTypography {
  static const heroTitle = TextStyle(
    fontSize: 34,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: AppColors.surfaceBright,
  );

  static const heroSubtitle = TextStyle(
    fontSize: 17,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.primarySoft,
  );

  static const heroCta = TextStyle(
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onSelectTab,
    super.key,
  });

  final ValueChanged<AppTab> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(34),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
        borderRadius: BorderRadius.circular(36),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -34,
            top: -10,
            child: Icon(
              Icons.spa_outlined,
              color: Color(0x33E8DCC8),
              size: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Start with one small moment',
                  style: _HomeTypography.heroTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Choose a gentle idea, save a quiet note, or add a calming sound when the day feels full.',
                  style: _HomeTypography.heroSubtitle,
                ),
                const SizedBox(height: AppSpacing.xl),
                _HeroPillButton(
                  onPressed: onTap,
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Text(
                    'NO PRESSURE, NO STREAKS, NO GOALS',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary.withAlpha(190),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                    ),
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

class _HeroPillButton extends StatelessWidget {
  const _HeroPillButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceBright,
      borderRadius: AppRadii.chipRadius,
      child: InkWell(
        borderRadius: AppRadii.chipRadius,
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Find a play idea',
                  style: _HomeTypography.heroCta,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Icon(Icons.arrow_forward, color: AppColors.primary, size: 22),
            ],
          ),
        ),
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
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.panelRadius,
          side: const BorderSide(color: AppColors.borderSoft),
        ),
        child: InkWell(
          borderRadius: AppRadii.panelRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 22,
                  ),
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
                  Icons.chevron_right,
                  color: AppColors.borderSoft,
                  size: 26,
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
    return Semantics(
      button: true,
      label: 'Open $title',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceBright,
          borderRadius: AppRadii.panelRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withAlpha(8),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadii.panelRadius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadii.controlSmallRadius,
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.cardTitle),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(subtitle, style: AppTextStyles.body),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.borderSoft,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
