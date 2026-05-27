import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'premium_access_controller.dart';
import 'purchase_result.dart';

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({
    required this.strings,
    required this.controller,
    required this.onRestoreAccess,
    super.key,
  });

  final AppStrings strings;
  final PremiumAccessController controller;
  final VoidCallback onRestoreAccess;

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  var _isBuyingMonthly = false;
  var _isBuyingYearly = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final catalog = widget.controller.productCatalog;
    final monthly = catalog.monthly;
    final yearly = catalog.yearly;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          tooltip: widget.strings.back,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.strings.premiumTitle),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: [
            Text(
              widget.strings.premiumPaywallSubtitle,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            _CalloutCard(
              title: widget.strings.premiumLaunchOfferTitle,
              body: widget.strings.premiumLaunchOfferDescription,
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanCard(
              titleKey: const ValueKey('premium-paywall-yearly-title'),
              priceKey: const ValueKey('premium-paywall-yearly-price'),
              noteKey: const ValueKey('premium-paywall-yearly-note'),
              title: widget.strings.premiumYearlyPlan,
              price: yearly?.price ?? widget.strings.premiumYearlyPrice,
              note: widget.strings.premiumYearlyRegularPrice,
              badge: widget.strings.premiumBestValue,
              actionLabel: widget.strings.premiumYearlyPlan,
              isLoading: _isBuyingYearly,
              onPressed: _buyYearly,
            ),
            const SizedBox(height: AppSpacing.sm),
            _PlanCard(
              titleKey: const ValueKey('premium-paywall-monthly-title'),
              priceKey: const ValueKey('premium-paywall-monthly-price'),
              noteKey: const ValueKey('premium-paywall-monthly-note'),
              title: widget.strings.premiumMonthlyPlan,
              price: monthly?.price ?? widget.strings.premiumMonthlyPrice,
              note: widget.strings.premiumMonthlyRegularPrice,
              actionLabel: widget.strings.premiumMonthlyPlan,
              isLoading: _isBuyingMonthly,
              onPressed: _buyMonthly,
            ),
            const SizedBox(height: AppSpacing.md),
            _BenefitLine(text: widget.strings.premiumRemoveAds),
            _BenefitLine(text: widget.strings.premiumUnlockPlayIdeas),
            _BenefitLine(text: widget.strings.premiumUnlockSounds),
            _BenefitLine(text: widget.strings.premiumFuturePremiumContent),
            if (_statusMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _statusMessage!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            TextButton(
              key: const ValueKey('premium-paywall-restore-link'),
              onPressed: widget.onRestoreAccess,
              child: Text(widget.strings.premiumRestoreAccessLink),
            ),
            const SizedBox(height: AppSpacing.xs),
            FilledButton(
              key: const ValueKey('premium-paywall-not-now'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(widget.strings.premiumNotNow),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buyMonthly() async {
    setState(() {
      _isBuyingMonthly = true;
      _statusMessage = null;
    });
    final result = await widget.controller.buyMonthly();
    if (!mounted) {
      return;
    }
    setState(() {
      _isBuyingMonthly = false;
      _statusMessage = _messageForPurchaseResult(result);
    });
  }

  Future<void> _buyYearly() async {
    setState(() {
      _isBuyingYearly = true;
      _statusMessage = null;
    });
    final result = await widget.controller.buyYearly();
    if (!mounted) {
      return;
    }
    setState(() {
      _isBuyingYearly = false;
      _statusMessage = _messageForPurchaseResult(result);
    });
  }

  String? _messageForPurchaseResult(PurchaseActionResult result) {
    return switch (result.status) {
      PurchaseActionStatus.pending => widget.strings.premiumPurchasePending,
      PurchaseActionStatus.unavailable ||
      PurchaseActionStatus.error ||
      PurchaseActionStatus.canceled =>
        widget.strings.premiumPurchaseUnavailable,
      PurchaseActionStatus.success ||
      PurchaseActionStatus.noPurchaseFound =>
        null,
    };
  }
}

class _CalloutCard extends StatelessWidget {
  const _CalloutCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(body, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.note,
    required this.actionLabel,
    required this.isLoading,
    required this.onPressed,
    this.titleKey,
    this.priceKey,
    this.noteKey,
    this.badge,
  });

  final String title;
  final String price;
  final String note;
  final String actionLabel;
  final bool isLoading;
  final VoidCallback onPressed;
  final String? badge;
  final Key? titleKey;
  final Key? priceKey;
  final Key? noteKey;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    key: titleKey,
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _Badge(label: badge!),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(price, key: priceKey, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.xxs),
            Text(note, key: noteKey, style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: isLoading ? null : onPressed,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
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
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
