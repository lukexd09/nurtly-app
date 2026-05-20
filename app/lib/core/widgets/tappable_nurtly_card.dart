import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class TappableNurtlyCard extends StatelessWidget {
  const TappableNurtlyCard({
    required this.semanticLabel,
    required this.onTap,
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadii.cardRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withAlpha(10),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.cardRadius,
            side: const BorderSide(color: AppColors.borderSoft),
          ),
          child: InkWell(
            borderRadius: AppRadii.cardRadius,
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
