import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'nurtly_card.dart';

class DetailSection extends StatelessWidget {
  const DetailSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.xs),
            children[index],
          ],
        ],
      ),
    );
  }
}
