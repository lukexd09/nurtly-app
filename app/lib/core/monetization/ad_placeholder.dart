import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../localization/app_strings.dart';

class AdPlaceholderCard extends StatelessWidget {
  const AdPlaceholderCard({
    required this.strings,
    super.key,
  });

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('ad-placeholder'),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.panelRadius,
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                Icons.campaign_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.adPlaceholderTitle,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    strings.adPlaceholderSubtitle,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
