import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class PremiumPaywallSheet extends StatelessWidget {
  const PremiumPaywallSheet({
    required this.strings,
    required this.onShowRestoreUnavailable,
    super.key,
  });

  final AppStrings strings;
  final VoidCallback onShowRestoreUnavailable;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        shrinkWrap: true,
        children: [
          Text(
            strings.premiumTitle,
            style: AppTextStyles.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(strings.premiumPaywallSubtitle, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          _BenefitLine(text: strings.premiumRemoveAds),
          _BenefitLine(text: strings.premiumUnlockContent),
          const SizedBox(height: AppSpacing.md),
          _PlanCard(
            title: strings.premiumMonthlyPlan,
            price: strings.premiumMonthlyPrice,
            note: strings.premiumBillingComingSoon,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PlanCard(
            title: strings.premiumLifetimePlan,
            price: strings.premiumLifetimePrice,
            note: strings.premiumBillingComingSoon,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () {
              onShowRestoreUnavailable();
            },
            child: Text(strings.restorePurchases),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.note,
  });

  final String title;
  final String price;
  final String note;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.xxs),
            Text(price, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.xxs),
            Text(note, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _BenefitLine extends StatelessWidget {
  const _BenefitLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
