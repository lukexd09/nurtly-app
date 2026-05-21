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

enum _HomeDensityVariant { compact, cozy, spacious }

class _HomeDensity {
  const _HomeDensity._({
    required this.variant,
    required this.outerPadding,
    required this.heroPadding,
    required this.heroTopGap,
    required this.heroContentGap,
    required this.heroBottomGap,
    required this.heroTitleSize,
    required this.heroSubtitleSize,
    required this.heroCtaMinHeight,
    required this.heroCtaHorizontalPadding,
    required this.heroDecorationSize,
    required this.afterHeroGap,
    required this.afterGentleStartGap,
    required this.gentleStartPadding,
    required this.secondaryCardPadding,
    required this.secondaryIconWellSize,
    required this.secondaryIconSize,
  });

  factory _HomeDensity.forHeight(double height) {
    if (height < 700) {
      return const _HomeDensity._(
        variant: _HomeDensityVariant.compact,
        outerPadding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        heroPadding: EdgeInsets.all(AppSpacing.lg),
        heroTopGap: AppSpacing.lg,
        heroContentGap: AppSpacing.sm,
        heroBottomGap: AppSpacing.lg,
        heroTitleSize: 30,
        heroSubtitleSize: 16,
        heroCtaMinHeight: 56,
        heroCtaHorizontalPadding: AppSpacing.lg,
        heroDecorationSize: 118,
        afterHeroGap: AppSpacing.sm,
        afterGentleStartGap: AppSpacing.md,
        gentleStartPadding: EdgeInsets.all(AppSpacing.md),
        secondaryCardPadding: EdgeInsets.all(AppSpacing.md),
        secondaryIconWellSize: 44,
        secondaryIconSize: 22,
      );
    }

    if (height < 820) {
      return const _HomeDensity._(
        variant: _HomeDensityVariant.cozy,
        outerPadding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        heroPadding: EdgeInsets.all(AppSpacing.lg),
        heroTopGap: AppSpacing.lg,
        heroContentGap: AppSpacing.md,
        heroBottomGap: AppSpacing.lg,
        heroTitleSize: 32,
        heroSubtitleSize: 16,
        heroCtaMinHeight: 60,
        heroCtaHorizontalPadding: AppSpacing.xl,
        heroDecorationSize: 132,
        afterHeroGap: AppSpacing.md,
        afterGentleStartGap: AppSpacing.lg,
        gentleStartPadding: EdgeInsets.all(AppSpacing.lg),
        secondaryCardPadding: EdgeInsets.all(AppSpacing.lg),
        secondaryIconWellSize: 48,
        secondaryIconSize: 23,
      );
    }

    return const _HomeDensity._(
      variant: _HomeDensityVariant.spacious,
      outerPadding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      heroPadding: EdgeInsets.all(AppSpacing.xl),
      heroTopGap: AppSpacing.xl,
      heroContentGap: AppSpacing.md,
      heroBottomGap: AppSpacing.xl,
      heroTitleSize: 34,
      heroSubtitleSize: 17,
      heroCtaMinHeight: 64,
      heroCtaHorizontalPadding: AppSpacing.xl,
      heroDecorationSize: 150,
      afterHeroGap: AppSpacing.md,
      afterGentleStartGap: AppSpacing.lg,
      gentleStartPadding: EdgeInsets.all(AppSpacing.lg),
      secondaryCardPadding: EdgeInsets.all(AppSpacing.lg),
      secondaryIconWellSize: 52,
      secondaryIconSize: 24,
    );
  }

  final _HomeDensityVariant variant;
  final EdgeInsets outerPadding;
  final EdgeInsets heroPadding;
  final double heroTopGap;
  final double heroContentGap;
  final double heroBottomGap;
  final double heroTitleSize;
  final double heroSubtitleSize;
  final double heroCtaMinHeight;
  final double heroCtaHorizontalPadding;
  final double heroDecorationSize;
  final double afterHeroGap;
  final double afterGentleStartGap;
  final EdgeInsets gentleStartPadding;
  final EdgeInsets secondaryCardPadding;
  final double secondaryIconWellSize;
  final double secondaryIconSize;

  TextStyle get heroTitle =>
      _HomeTypography.heroTitle.copyWith(fontSize: heroTitleSize);

  TextStyle get heroSubtitle =>
      _HomeTypography.heroSubtitle.copyWith(fontSize: heroSubtitleSize);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onSelectTab,
    required this.onOpenTodaysIdea,
    super.key,
  });

  final ValueChanged<AppTab> onSelectTab;
  final VoidCallback onOpenTodaysIdea;

  @override
  Widget build(BuildContext context) {
    final density = _HomeDensity.forHeight(MediaQuery.sizeOf(context).height);

    return ListView(
      padding: density.outerPadding,
      children: [
        _HomeHero(
          density: density,
          onTap: () => onSelectTab(AppTab.play),
        ),
        SizedBox(height: density.afterHeroGap),
        _GentleStartCard(
          density: density,
          onTap: onOpenTodaysIdea,
        ),
        SizedBox(height: density.afterGentleStartGap),
        _HomeQuickLink(
          density: density,
          title: 'Save a small note',
          subtitle: 'Keep the moment without overthinking it.',
          icon: Icons.event_note_outlined,
          onTap: () => onSelectTab(AppTab.journal),
        ),
        const SizedBox(height: AppSpacing.md),
        _HomeQuickLink(
          density: density,
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
  const _HomeHero({
    required this.density,
    required this.onTap,
  });

  final _HomeDensity density;
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
          Positioned(
            right: -34,
            top: -10,
            child: Icon(
              Icons.spa_outlined,
              color: Color(0x33E8DCC8),
              size: density.heroDecorationSize,
            ),
          ),
          Padding(
            padding: density.heroPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.secondary,
                  size: 24,
                ),
                SizedBox(height: density.heroTopGap),
                Text(
                  'Start with one small moment',
                  style: density.heroTitle,
                ),
                SizedBox(height: density.heroContentGap),
                Text(
                  'Choose a gentle idea, save a quiet note, or add a calming sound when the day feels full.',
                  style: density.heroSubtitle,
                ),
                SizedBox(height: density.heroBottomGap),
                _HeroPillButton(
                  density: density,
                  onPressed: onTap,
                ),
                SizedBox(height: density.heroBottomGap),
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
  const _HeroPillButton({
    required this.density,
    required this.onPressed,
  });

  final _HomeDensity density;
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
          constraints: BoxConstraints(minHeight: density.heroCtaMinHeight),
          padding: EdgeInsets.symmetric(
            horizontal: density.heroCtaHorizontalPadding,
          ),
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
  const _GentleStartCard({
    required this.density,
    required this.onTap,
  });

  final _HomeDensity density;
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
            padding: density.gentleStartPadding,
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
    required this.density,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final _HomeDensity density;
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
              padding: density.secondaryCardPadding,
              child: Row(
                children: [
                  Container(
                    width: density.secondaryIconWellSize,
                    height: density.secondaryIconWellSize,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadii.controlSmallRadius,
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primary,
                      size: density.secondaryIconSize,
                    ),
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
