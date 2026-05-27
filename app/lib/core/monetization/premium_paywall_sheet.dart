import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import 'premium_access_controller.dart';
import 'purchase_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class PremiumPaywallSheet extends StatefulWidget {
  const PremiumPaywallSheet({
    required this.strings,
    required this.controller,
    required this.onRestoreAccess,
    super.key,
  });

  final AppStrings strings;
  final PremiumAccessController controller;
  final VoidCallback onRestoreAccess;

  @override
  State<PremiumPaywallSheet> createState() => _PremiumPaywallSheetState();
}

class _PremiumPaywallSheetState extends State<PremiumPaywallSheet> {
  var _isBuyingMonthly = false;
  var _isBuyingLifetime = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final catalog = widget.controller.productCatalog;
    final monthly = catalog.monthly;
    final lifetime = catalog.lifetime;

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
            widget.strings.premiumTitle,
            style: AppTextStyles.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.strings.premiumPaywallSubtitle,
              style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          _BenefitLine(text: widget.strings.premiumRemoveAds),
          _BenefitLine(text: widget.strings.premiumUnlockContent),
          const SizedBox(height: AppSpacing.md),
          _PlanCard(
            title: monthly?.title ?? widget.strings.premiumMonthlyPlan,
            price: monthly?.price ?? widget.strings.premiumMonthlyPrice,
            note: monthly?.description ?? widget.strings.premiumMonthlyPlan,
            actionLabel: widget.strings.premiumMonthlyPlan,
            isLoading: _isBuyingMonthly,
            onPressed: _buyMonthly,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PlanCard(
            title: lifetime?.title ?? widget.strings.premiumLifetimePlan,
            price: lifetime?.price ?? widget.strings.premiumLifetimePrice,
            note: lifetime?.description ?? widget.strings.premiumLifetimePlan,
            actionLabel: widget.strings.premiumLifetimePlan,
            isLoading: _isBuyingLifetime,
            onPressed: _buyLifetime,
          ),
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
            onPressed: () {
              widget.onRestoreAccess();
            },
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

  Future<void> _buyLifetime() async {
    setState(() {
      _isBuyingLifetime = true;
      _statusMessage = null;
    });
    final result = await widget.controller.buyLifetime();
    if (!mounted) {
      return;
    }
    setState(() {
      _isBuyingLifetime = false;
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.note,
    required this.actionLabel,
    required this.isLoading,
    required this.onPressed,
  });

  final String title;
  final String price;
  final String note;
  final String actionLabel;
  final bool isLoading;
  final VoidCallback onPressed;

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
