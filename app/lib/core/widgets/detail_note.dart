import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'nurtly_card.dart';

class DetailNote extends StatelessWidget {
  const DetailNote({
    required this.title,
    required this.text,
    super.key,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      backgroundColor: AppColors.primarySoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
